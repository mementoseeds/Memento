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
    property int marginBase: 10

    function openOnePreview()
    {
        rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "itemArray": [id], "actionType": "preview", "testColumn": testColumn, "promptColumn": promptColumn})
    }

    width: root.width
    height: levelEntryDelegate.height

    ColumnLayout {
        id: levelEntryDelegate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: marginBase
        anchors.rightMargin: marginBase

        RowLayout {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width
            spacing: marginBase

            Loader {
                id: levelTestColumn
                Layout.preferredWidth: parent.Layout.preferredWidth / 3
                property string columnEntry: test
                sourceComponent:
                {
                    switch (testColumnType)
                    {
                        case "text":
                            return textColumnComponent
                        case "image":
                            return imageColumnComponent
                        case "audio":
                            return audioColumnComponent
                    }
                }
            }

            Loader {
                id: levelPromptColumn
                Layout.preferredWidth: levelTestColumn.Layout.preferredWidth
                property string columnEntry: prompt
                sourceComponent:
                {
                    switch (promptColumnType)
                    {
                        case "text":
                            return textColumnComponent
                        case "image":
                            return imageColumnComponent
                        case "audio":
                            return audioColumnComponent
                    }
                }
            }

            Label {
                id: metaColumn
                text: progress
                font.pointSize: 10
                font.family: "Icons"
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: levelTestColumn.Layout.preferredWidth / 2
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }
    }

    Component {
        id: textColumnComponent

        Label {
            text: columnEntry
            font.pointSize: 12
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignLeft

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: openOnePreview()
            }
        }
    }

    Component {
        id: imageColumnComponent

        Image {
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + columnEntry)
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 200

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: openOnePreview()
            }
        }
    }

    Component {
        id: audioColumnComponent

        Image {
            source: "assets/icons/playaudio.svg"
            sourceSize.width: platformIsMobile ? 50 : 100
            sourceSize.height: platformIsMobile ? 50 : 100
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignCenter

            Audio {
                id: audio
                source: Qt.resolvedUrl("file://" + courseDirectory + "/" + columnEntry.split(":")[0])
                autoLoad: false
                audioRole: Audio.GameRole
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    if (audio.playbackState !== Audio.PlayingState)
                        audio.play()
                    else
                        audio.stop()
                }
            }
        }
    }
}
