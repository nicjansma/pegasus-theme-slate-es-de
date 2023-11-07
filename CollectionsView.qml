import QtQuick 2.0
import "collections.js" as Collections // collection definitions

// The collections view consists of two carousels, one for the collection logo bar
// and one for the background images. They should have the same number of elements
// to be kept in sync.
FocusScope {
    id: root

    // This element has the same size as the whole screen (ie. its parent).
    // Because this screen itself will be moved around when a collection is
    // selected, I've used width/height instead of anchors.
    width: parent.width
    height: parent.height
    enabled: focus // do not receive key/mouse events when unfocused
    visible: y + height >= 0 // optimization: do not render the item when it's not on screen

    signal collectionSelected

    // Shortcut for the currently selected collection. They will be used
    // by the Details view too, for example to show the collection's logo.
    property alias currentCollectionIndex: logoAxis.currentIndex
    readonly property var currentCollection: logoAxis.model.get(logoAxis.currentIndex)

    // These functions can be called by other elements of the theme if the collection
    // has to be changed manually. See the connection between the Collection and
    // Details views in the main theme file.
    function selectNext() {
        logoAxis.incrementCurrentIndex();
    }

    function selectPrev() {
        logoAxis.decrementCurrentIndex();
    }

    // The carousel of background images. This isn't the item we control with the keys,
    // however it reacts to mouse and so should still update the Index.
    Carousel {
        id: bgAxis

        anchors.fill: parent
        itemWidth: width

        model: api.collections
        delegate: bgAxisItem
        currentIndex: logoAxis.currentIndex

        highlightMoveDuration: 500 // it's moving a little bit slower than the main bar
    }

    Component {
        // Either the image for the collection or a single colored rectangle
        id: bgAxisItem

        Item {
            width: root.width
            height: root.height
            visible: PathView.onPath // optimization: do not draw if not visible

            // background
            Rectangle {
                anchors.fill: parent
                color: "#404040"
            }

            Item {
                id: hiddenBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: vpx(170)
                visible: false
            }

            // bands
            Rectangle {
                id: band4
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 80
                width: 20
                color: Collections.COLLECTIONS[currentCollection.shortName].colors[3] ?
                    ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[3]) : "#303030"
            }

            Rectangle {
                id: band3
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: band4.left
                width: 20
                color: Collections.COLLECTIONS[currentCollection.shortName].colors[2] ?
                    ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[2]) : "#FF0000"
            }

            Rectangle {
                id: band2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: band3.left
                width: 20
                color: Collections.COLLECTIONS[currentCollection.shortName].colors[1] ?
                    ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[1]) : "#800000"
            }

            Rectangle {
                id: band1
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: band2.left
                width: 20
                color: Collections.COLLECTIONS[currentCollection.shortName].colors[0] ?
                    ("#" + Collections.COLLECTIONS[currentCollection.shortName].colors[0]) : "#F6DD08"
            }

            // controller
            Image {
                id: controllerImage
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.right: band1.left
                anchors.rightMargin: 20
                anchors.bottom: hiddenBar.top
                anchors.bottomMargin: 20
                fillMode: Image.PreserveAspectFit
                // NOTE: SVGs were rendering black for many of these, so converted to PNG
                source: modelData.shortName ? "controller/%1.png".arg(modelData.shortName) : ""
                asynchronous: true
            }

            // console + game
            Image {
                id: consoleGameImage
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.bottom: hiddenBar.top
                anchors.bottomMargin: 20
                fillMode: Image.PreserveAspectFit
                // NOTE: SVGs were rendering black for many of these, so converted to PNG
                source: modelData.shortName ? "consolegame/%1.png".arg(modelData.shortName) : ""
                asynchronous: true
            }
        }
    }

    // I've put the main bar's parts inside this wrapper item to change the opacity
    // of the background separately from the carousel. You could also use a Rectangle
    // with a color that has alpha value.
    Item {
        id: logoBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: vpx(170)

        // Background
        Rectangle {
            anchors.fill: parent
            color: "#747474"
            opacity: 0.85
        }

        // The main carousel that we actually control
        Carousel {
            id: logoAxis

            anchors.fill: parent
            itemWidth: vpx(480)

            model: api.collections
            delegate: CollectionLogo {
                longName: modelData.name
                shortName: modelData.shortName
            }

            focus: true

            Keys.onPressed: {
                if (event.isAutoRepeat)
                    return;

                if (api.keys.isNextPage(event)) {
                    event.accepted = true;
                    incrementCurrentIndex();
                }
                else if (api.keys.isPrevPage(event)) {
                    event.accepted = true;
                    decrementCurrentIndex();
                }
            }

            onItemSelected: root.collectionSelected()
        }
    }

    // Game count bar -- like above, I've put it in an Item to separately control opacity
    Item {
        id: gameCountBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logoBar.bottom
        height: label.height * 1.5

        Rectangle {
            anchors.fill: parent
            color: "#555"
            opacity: 0.85
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: "%1 GAMES".arg(currentCollection.games.count)
            color: "#c6c6c6"
            font.pixelSize: vpx(25)
            font.family: "Open Sans"
        }
    }

    // Collection Info section
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: gameCountBar.bottom
        anchors.bottom: parent.bottom

        Text {
            id: collectionInfoLabel
            anchors.centerIn: parent
            text: Collections.COLLECTIONS[currentCollection.shortName].info.join("\n")
            color: "#b6b6b6"
            font.pixelSize: vpx(12)
            font.family: "Open Sans"
        }
    }
}
