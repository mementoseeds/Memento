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

    width: root.width
    height: resultEntry.height

    ColumnLayout {
        id: resultEntry
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
                id: testItem
                property string columnEntry: testData
                Layout.preferredWidth: parent.Layout.preferredWidth / 3
                sourceComponent:
                {
                    switch (testDataType)
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
                property string columnEntry: promptData
                Layout.preferredWidth: testItem.Layout.preferredWidth
                sourceComponent:
                {
                    switch (promptDataType)
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
                id: accuracyMeta
                text: "<font color='" + globalGreen + "'>" + successes + "</font> / " + "<font color='" + globalRed + "'>" + failures + "</font>"
                font.pointSize: 12
                font.bold: true
                Layout.alignment: Qt.AlignRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: testItem.Layout.preferredWidth / 2
            }

            Label {
                text: streak
                font.pointSize: 12
                font.bold: true
                Layout.alignment: Qt.AlignRight
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: accuracyMeta.Layout.preferredWidth
            }
        }

        Rectangle {
            Layout.preferredWidth: parent.width
            height: 1
        }
    }

    Component {
        id: textColumnComponent
        Label {
            text: columnEntry
            font.pointSize: 12
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignLeft
        }
    }

    Component {
        id: imageColumnComponent
        Image {
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + columnEntry)
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 200
        }
    }

    Component {
        id: audioColumnComponent

        Image {
            source: "assets/icons/playaudio.svg"
            sourceSize.width: platformIsMobile ? 50 : 100
            sourceSize.height: platformIsMobile ? 50 : 100
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignLeft

            Audio {
                id: audio
                source: Qt.resolvedUrl("file://" + courseDirectory + "/" + columnEntry.split(":")[0])
                autoPlay: false
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
