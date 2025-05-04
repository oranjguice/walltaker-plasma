import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root
    width: 300
    height: 300

    property string linkID: ""
    property string imageUrl: ""
    property bool imageLoaded: false

    fullRepresentation: Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: imageLoaded ? "transparent" : "#2A2E32"

            ColumnLayout {
                id: inputArea
                anchors.centerIn: parent
                spacing: 10
                visible: !imageLoaded

                TextField {
                    id: codeInput
                    placeholderText: "Enter Walltaker Link ID.."
                    Layout.preferredWidth: 200
                    onAccepted: {
                        root.linkID = text
                        updateImage()
                    }
                }

                Button {
                    text: "Load"
                    onClicked: {
                        root.linkID = codeInput.text
                        updateImage()
                    }
                }
            }

            Image {
                id: wallImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: root.imageUrl
                visible: imageLoaded
                asynchronous: true
                cache: false

                antialiasing: true

                onStatusChanged: {
                    if (status === Image.Ready) {
                        root.imageLoaded = true;
                        console.log("Image loaded successfully.");
                    } else if (status === Image.Error) {
                        console.log("Error loading image:", wallImage.source);
                    }
                }
            }
        }

        // Poll API every 10s
        Timer {
            interval: 10000 // 10 seconds
            running: imageLoaded
            repeat: true
            onTriggered: updateImage()
        }

        function updateImage() {
            if (root.linkID === "") {
                console.log("No link code provided.");
                return;
            }
            console.log("Fetching image for link code:", root.linkID);
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "https://walltaker.joi.how/api/links/" + root.linkID + ".json");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    console.log("HTTP Status:", xhr.status);
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            if (response.post_url) {
                                root.imageUrl = response.post_url;
                                console.log("Image (thumbnail):", root.imageUrl);

                            } else {
                                console.log("post_url not found in response.");
                            }
                        } catch (e) {
                            console.log("Error parsing JSON response:", e);
                        }
                    } else {
                        console.log("Failed to fetch image. Status:", xhr.status);
                    }
                }
            }
            xhr.send();
        }
    }
}
