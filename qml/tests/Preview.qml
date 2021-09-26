/*    This file is part of Memento.
 *
 *    Memento is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Memento is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Memento.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtMultimedia 5.15

Item {
    property string itemId: ""
    property string testColumn: ""
    property string promptColumn: ""

    property int marginBase: 10

    Component.onCompleted: globalBackend.readItem(itemId, testColumn, promptColumn)

    ListView {
        anchors.fill: parent
        spacing: 10

        header: RowLayout {
            width: parent.width

            Shortcut {
                sequence: "Left"
                onActivated: backButton.clicked()
            }

            Shortcut {
                sequences: ["Right", "Return", "Enter"]
                onActivated: forwardButton.clicked()
            }

            Button {
                id: backButton
                Layout.alignment: Qt.AlignLeft
                icon.source: "assets/actions/go-previous.svg"
                display: AbstractButton.IconOnly
                enabled: actionType === "preview"
                onClicked:
                {
                    if (itemIndex !== 1)
                    {
                        itemIndex -= 2
                        triggerNextItem()
                    }
                }
            }

            Button {
                id: forwardButton
                Layout.alignment: Qt.AlignRight
                icon.source: "assets/actions/go-next.svg"
                display: AbstractButton.IconOnly
                onClicked: triggerNextItem()
            }
        }

        model: ListModel{id: previewListModel}
        delegate: Loader {
            width: parent.width

            property string type: model.type
            property string name: model.name
            property string content: model.content

            sourceComponent: switch (type)
                {
                    case "audio": return audioComponent
                    case "attributes":
                    case "alternative":
                    case "text": return textComponent
                    case "image": return imageComponent
                    case "separator": return separatorComponent
                }
        }

        footer: ListView {
            id: mnemonicsListView

            property real mnemonicWidth: platformIsMobile ? (root.width - marginBase * 2) : (root.width / 2)
            property real mnemonicHeight: platformIsMobile ? 200 : 500

            width: mnemonicWidth
            height: mnemonicHeight
            ScrollBar.horizontal: ScrollBar {height: 10}
            anchors {left: parent.left; right: parent.right}
            orientation: ListView.Horizontal

            model: ListModel{id: mnemonicsPreviewListModel}
            spacing: marginBase

            delegate: MnemonicEntry {width: mnemonicWidth; height: mnemonicHeight}

            Component.onCompleted: globalBackend.getAllMnemonics(itemId)

            Connections {
                target: globalBackend

                function onAddMnemonic(mnemonicId, author, text, imagePath)
                {
                    mnemonicsPreviewListModel.append({"mnemonicId": mnemonicId, "mnemonicAuthor": author, "mnemonicText": text, "mnemonicImagePath": imagePath})
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: triggerNextItem()
        }
    }

    Connections {
        id: previewGlobalBackendConncetions
        target: globalBackend
        function onAddItemDetails(type, name, content)
        {
            previewListModel.append({"type": type, "name": name, "content": content})
        }

        function onAddItemSeparator()
        {
            previewListModel.append({"type": "separator", "name": "", "content": ""})
        }
    }

    Connections {
        target: signalSource

        function onDisablePreviousPageConnections()
        {
            previewGlobalBackendConncetions.enabled = false
        }
    }

    Component {
        id: audioComponent

        ColumnLayout {
            width: parent.width

            Label {
                id: audioName
                text: name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }

            RowLayout {
                Layout.preferredWidth: parent.Layout.preferredWidth
                Layout.alignment: Qt.AlignCenter

                Repeater {
                    id: audioRepeater
                    model: content.split(":")
                    property int randomAudioPlayIndex: Math.floor(Math.random() * model.length)

                    Label {
                        text: audioIcon
                        font.pointSize: 40
                        font.family: "Icons"
                        color: audio.playbackState === Audio.PlayingState ? globalAmber : "white"
                        horizontalAlignment: Text.AlignHCenter
                        rightPadding: marginBase

                        Audio {
                            id: audio
                            source: Qt.resolvedUrl(fileUrlStart + courseDirectory + "/" + modelData)
                            autoPlay: index === audioRepeater.randomAudioPlayIndex
                            audioRole: Audio.GameRole
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                if (audio.playbackState !== Audio.PlayingState)
                                {
                                    signalSource.stopAllAudio()
                                    audio.play()
                                }
                                else
                                    audio.stop()
                            }
                        }

                        Connections {
                            target: signalSource

                            function onStopAllAudio()
                            {
                                audio.stop()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: textComponent
        ColumnLayout {
            width: parent.width

            Label {
                id: textName
                visible: textContent.visible && type !== "alternative"
                text: name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }

            Label {
                id: textContent
                visible: text.length > 0
                text: content
                font.bold: type !== "alternative"
                font.pointSize: type === "attributes" || type === "alternative" ? userSettings["testAttributesFontSize"] : userSettings["previewTextFontSize"]
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }
        }
    }

    Component {
        id: imageComponent

        ColumnLayout {
            width: parent.width

            Label {
                text: name
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }

            Image {
                source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + content)
                sourceSize.width: 200
                Layout.alignment: Qt.AlignCenter
            }
        }
    }

    Component {
        id: separatorComponent
        Rectangle {
            width: parent.width
            color: "gray"
            height: 2
            radius: 50
        }
    }
}
