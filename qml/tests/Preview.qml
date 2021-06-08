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
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15
import QtMultimedia 5.15

Kirigami.ScrollablePage {
    property string itemId: ""
    property string testColumn: ""
    property string promptColumn: ""

    Component.onCompleted: globalBackend.readItem(itemId, testColumn, promptColumn)

    ListView {
        spacing: 10

        model: ListModel{id: previewListModel}
        delegate: Loader {
            width: parent.width

            property string type: model.type
            property string name: model.name
            property string content: model.content

            sourceComponent: switch (type)
                {
                    case "attributes":
                    case "text": return textComponent
                    case "alternative": return alternativeComponent
                    case "audio": return audioComponent
                }
        }
    }

    Connections {
        target: globalBackend
        function onAddItemDetails(type, name, content)
        {
            previewListModel.append({"type": type, "name": name, "content": content})
        }
    }

    Component {
        id: audioComponent

        RowLayout {
            width: parent.width

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Repeater {
                    model: content.split(":")

                    Image {
                        source: "assets/icons/playaudio.svg"
                        sourceSize.width: Kirigami.Units.iconSizes.huge

                        Audio {
                            id: audio
                            source: Qt.resolvedUrl("file://" + courseDirectory + "/" + modelData)
                            autoPlay: index === 0
                            audioRole: Audio.GameRole
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: audio.play()
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
            spacing: 10

            Kirigami.Heading {
                id: textName
                visible: textContent.visible
                text: name
                level: 4
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }

            Kirigami.Heading {
                id: textContent
                visible: text.length > 0
                text: content
                font.pointSize: type === "attributes" ? 12 : 20
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }

            Rectangle {
                visible: type === "attributes"
                Layout.topMargin: 10
                color: "gray"
                height: 2
                Layout.fillWidth: true
                radius: 50
            }
        }
    }

    Component {
        id: alternativeComponent
        ColumnLayout {
            width: parent.width

            Kirigami.Heading {
                visible: textContent.visible
                text: name
                level: 5
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }

            Kirigami.Heading {
                id: textContent
                visible: text.length > 0
                text: content
                level: 4
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }

            Rectangle {
                Layout.topMargin: 10
                color: "gray"
                height: 2
                Layout.fillWidth: true
                radius: 50
            }
        }
    }
}
