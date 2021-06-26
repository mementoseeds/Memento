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
        var items = [id]
        var levels = {}
        levels[levelPath] = items
        rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "testingContentOriginal": levels, "actionType": "preview"})
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

            Button {
                visible: ignoreVisible
                width: this.Layout.preferredWidth
                height: this.Layout.preferredHeight
                text: ignoreIcon
                font.pointSize: platformIsMobile ? 15 : 10
                font.family: "Icons"
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: ignoreButtonContentItem.contentWidth * 2
                Layout.preferredHeight: ignoreButtonContentItem.contentHeight * 2.1

                contentItem: Text {
                    id: ignoreButtonContentItem
                    text: parent.text
                    font: parent.font
                    opacity: enabled ? 1.0 : 0.3
                    color: ignored ? "red" : "white"
                    textFormat: Text.RichText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                onClicked:
                {
                    ignored = !ignored
                    globalBackend.ignoreItem(levelPath, id, ignored)
                }
            }

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
                text: ignored ? ignoreIcon : progress
                color: ignored ? "red" : "white"
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
            color: ignored ? "gray" : "white"
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

        Label {
            text: audioIcon
            font.pointSize: 40
            font.family: "Icons"
            color: audio.playbackState === Audio.PlayingState ? globalAmber : "white"

            Audio {
                id: audio
                source: Qt.resolvedUrl(fileUrlStart + courseDirectory + "/" + columnEntry.split(":")[0])
                autoLoad: false
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
