import QtQuick 2.7 // note the version: Text padding is used below and that was added in 2.7 as per docs
import "utils.js" as Utils // some helper functions
import "collections.js" as Collections // collection definitions

// The details "view". Consists of some images, a bunch of textual info and a game list.
FocusScope {
    id: root

    // This will be set in the main theme file
    property var currentCollection

    // Shortcuts for the game list's currently selected game
    property alias currentGameIndex: gameList.currentIndex
    readonly property var currentGame: currentCollection.games.get(currentGameIndex)

    readonly property int padding: vpx(20)
    readonly property int halfPadding: vpx(10)
    readonly property int detailsTextHeight: vpx(30)

    // Nothing particularly interesting, see CollectionsView for more comments
    width: parent.width
    height: parent.height
    enabled: focus
    visible: y < parent.height

    signal cancel
    signal nextCollection
    signal prevCollection
    signal launchGame

    // Key handling. In addition, pressing left/right also moves to the prev/next collection.
    Keys.onLeftPressed: prevCollection()
    Keys.onRightPressed: nextCollection()
    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            launchGame();
            return;
        }
        if (api.keys.isCancel(event)) {
            event.accepted = true;
            cancel();
            return;
        }
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextCollection();
            return;
        }
        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevCollection();
            return;
        }
    }

    Item {
        width: root.width
        height: root.height

        Rectangle {
            // background
            anchors.fill: parent
            color: "#404040"
        }
    }

    //
    // Header
    //

    // bands
    Rectangle {
        id: band4
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 80
        width: root.padding
        color: Collections.COLLECTIONS[currentCollection.shortName].colors[3] ?
            ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[3]) : "#303030"
    }

    Rectangle {
        id: band3
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: band4.left
        width: root.padding
        color: Collections.COLLECTIONS[currentCollection.shortName].colors[2] ?
            ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[2]) : "#FF0000"
    }

    Rectangle {
        id: band2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: band3.left
        width: root.padding
        color: Collections.COLLECTIONS[currentCollection.shortName].colors[1] ?
            ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[1]) : "#800000"
    }

    Rectangle {
        id: band1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: band2.left
        width: root.padding
        color: Collections.COLLECTIONS[currentCollection.shortName].colors[0] ?
            ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[0]) : "#F6DD08"
    }

    // The header bar on the top, with the collection's consolegame and controller on left and logo on right
    Rectangle {
        id: header

        color: "#404040"

        anchors.top: parent.top
        anchors.right: band1.left
        anchors.left: parent.left
        height: vpx(115)

        Image {
            id: logo
            anchors.top: parent.top
            anchors.topMargin: root.padding
            anchors.right: parent.right
            anchors.rightMargin: root.padding
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.padding
            fillMode: Image.PreserveAspectFit
            source: currentCollection.shortName ? "logo/%1.svg".arg(currentCollection.shortName) : ""
            asynchronous: true
        }

        Image {
            id: consoleGame
            anchors.top: parent.top
            anchors.topMargin: root.padding
            anchors.left: parent.left
            anchors.leftMargin: root.padding
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.padding
            fillMode: Image.PreserveAspectFit
            source: currentCollection.shortName ? "consolegame/%1.svg".arg(currentCollection.shortName) : ""
            asynchronous: true
        }

        Image {
            id: controller
            anchors.top: parent.top
            anchors.topMargin: root.padding
            anchors.left: consoleGame.right
            anchors.leftMargin: root.padding
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.padding
            fillMode: Image.PreserveAspectFit
            source: currentCollection.shortName ? "controller/%1.svg".arg(currentCollection.shortName) : ""
            asynchronous: true
        }
    }

    //
    // Main content
    //
    Item {
        id: content
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top

        ListView {
            id: gameList
            width: parent.width * 0.35
            opacity: 0.95

            anchors {
                top: parent.top
                left: parent.left
                leftMargin: root.padding
                bottom: parent.bottom
                bottomMargin: root.padding
            }

            focus: true

            model: currentCollection.games

            delegate: Rectangle {
                readonly property bool selected: ListView.isCurrentItem
                readonly property color clrDark: "#000000"
                readonly property color clrLight: "#6D6D6D"
                readonly property color clrDarkText: "#000000"
                readonly property color clrLightText: "#AFAFAF"

                width: ListView.view.width
                height: gameTitle.height
                color: selected ? clrDark : clrLight

                Text {
                    id: gameTitle
                    text: (modelData.favorite ? "X" : "") + " " + modelData.title
                    color: parent.selected ? parent.clrLightText : parent.clrDarkText

                    font.pixelSize: vpx(20)
                    font.capitalization: Font.AllUppercase
                    font.family: "Open Sans"

                    lineHeight: 1.2
                    verticalAlignment: Text.AlignVCenter

                    width: parent.width
                    elide: Text.ElideRight
                    leftPadding: vpx(10)
                    rightPadding: leftPadding
                }
            }

            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 0
            preferredHighlightBegin: height * 0.5 - vpx(15)
            preferredHighlightEnd: height * 0.5 + vpx(15)
        }

        Rectangle {
            anchors {
                left: gameList.right
                leftMargin: root.padding
                right: parent.right
                rightMargin: root.padding
                top: parent.top
                bottom: parent.bottom
            }

            color: "#6D6D6D"
            opacity: 0.95

            RatingBar {
                id: ratingBar

                anchors {
                    left: parent.left
                    leftMargin: root.halfPadding
                    top: parent.top
                    topMargin: root.halfPadding
                }

                percentage: currentGame.rating
            }

            Item {
                id: boxart

                //height: vpx(218)
                //width: Math.max(vpx(160), Math.min(height * boxartImage.aspectRatio, vpx(320)))

                height: width * (1 / boxartImage.aspectRatio)
                width: parent.width / 2

                anchors {
                    top: ratingBar.bottom;
                    topMargin: root.padding
                    left: parent.left;
                    leftMargin: root.padding
                }

                Image {
                    id: boxartImage

                    readonly property double aspectRatio: (implicitWidth / implicitHeight) || 0

                    anchors.fill: parent
                    asynchronous: true
                    source: currentGame.assets.boxFront ||
                            currentGame.assets.logo ||
                            currentGame.assets.screenshot ||
                            currentGame.assets.marquee
                    sourceSize { width: 256; height: 256 } // optimization (max size)
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                }
            }

            // While the game details could be a grid, I've separated them to two
            // separate columns to manually control the width of the second one below.
            Column {
                id: gameLabels
                anchors {
                    top: boxart.top
                    left: boxart.right;
                    leftMargin: root.padding
                }

                GameInfoText { text: "Released:"; font.family: "Open Sans Bold"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { text: "Developer:"; font.family: "Open Sans Bold"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { text: "Publisher:"; font.family: "Open Sans Bold"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { text: "Genre:"; font.family: "Open Sans Bold"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { text: "Players:"; font.family: "Open Sans Bold"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { text: "Last played:"; font.family: "Open Sans Bold"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { text: "Play time:"; font.family: "Open Sans Bold"; color: "#000000"; height: root.detailsTextHeight }
            }

            Column {
                id: gameDetails
                anchors {
                    top: gameLabels.top
                    left: gameLabels.right
                    leftMargin: root.padding
                    right: parent.right
                    rightMargin: root.paddingF
                }

                // 'width' is set so if the text is too long it will be cut. I also use some
                // JavaScript code to make some text pretty.
                
                GameInfoText { width: parent.width; text: Utils.formatDate(currentGame.release) || "unknown"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { width: parent.width; text: currentGame.developer || "unknown"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { width: parent.width; text: currentGame.publisher || "unknown"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { width: parent.width; text: currentGame.genre || "unknown"; color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { width: parent.width; text: Utils.formatPlayers(currentGame.players); color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { width: parent.width; text: Utils.formatLastPlayed(currentGame.lastPlayed); color: "#000000"; height: root.detailsTextHeight }
                GameInfoText { width: parent.width; text: Utils.formatPlayTime(currentGame.playTime); color: "#000000"; height: root.detailsTextHeight }
            }

            GameInfoText {
                id: gameDescription

                anchors {
                    top: boxart.bottom
                    topMargin: root.padding
                    left: parent.left
                    leftMargin: root.padding
                    right: parent.right
                    rightMargin: root.padding
                    bottom: parent.bottom
                    bottomMargin: root.padding
                }

                text: currentGame.description
                wrapMode: Text.WordWrap
                elide: Text.ElideRight

                font.pixelSize: vpx(16)
                font.capitalization: Font.AllUppercase
                font.family: "Open Sans Semi-Bold"
                color: "#000000"
            }
        }
    }

    //
    // Footer
    //
    Item {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.padding
    }
}
