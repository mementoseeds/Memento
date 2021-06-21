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

ColumnLayout {
    property alias cooldownTimer: cooldownTimer
    property alias countdownTimer: countdownTimer
    //property alias testAudio: audio
    property alias radialBarText: radialBar.showText
    property int testHeaderHeight: 0

    signal countdownReached()

    spacing: 20

    function showAfterTests()
    {

    }

    RadialBar {
        id: radialBar
        minValue: 0
        maxValue: 100
        value: maxValue
        showText: "Countdown"
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignCenter
    }

    Loader {
        Layout.fillWidth: true
        property var columnData: globalBackend.readItemColumn(itemId, promptColumn)
        sourceComponent:
        {
            switch (columnData[0])
            {
                case "text":
                    return textComponent
                case "image":
                    return imageComponent
                case "audio":
                    return audioComponent
            }
        }
    }

    Rectangle {
        id: attributesBackground
        width: attributes.contentWidth + 10
        height: attributes.contentHeight + 5
        Layout.alignment: Qt.AlignCenter
        color: "gray"
        radius: 100
        visible: attributes.text.length > 0

        Label {
            id: attributes
            text: globalBackend.readItemAttributes(itemId)
            font.pointSize: platformIsMobile ? 15 : 10
            anchors.centerIn: parent
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Label {
        id: instructions
        text: (testType === "MultipleChoice" ? "Choose " : "Type ") + "the <b>" + testColumn + "</b> for the <b>" + promptColumn + "</b> above"
        font.pointSize: platformIsMobile ? 15 : 12
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
    }

    Timer {
        id: countdownTimer
        property int maxSeconds: userSettings["countdownTimer"]
        property int currentSeconds: 0
        interval: 1000
        running: true
        repeat: true
        onTriggered:
        {
            currentSeconds++
            if (currentSeconds <= maxSeconds)
            {
                radialBar.value = radialBar.maxValue - (Math.floor(currentSeconds / maxSeconds * 100))
            }
            else
            {
                running = false
                countdownReached()
            }
        }
    }

    Timer {
        id: cooldownTimer
        interval: 2000
        running: false
        repeat: false
        onTriggered: triggerNextItem()
    }

    Component {
        id: textComponent

        Label {
            text: columnData[1]
            font.pointSize: 20
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter

            Component.onCompleted: testHeaderHeight = radialBar.height + attributesBackground.height + contentHeight + instructions.contentHeight
        }
    }

    Component {
        id: imageComponent

        Image {
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + columnData[1])
            sourceSize.width: platformIsMobile ? 100 : 150
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignCenter

            Component.onCompleted: testHeaderHeight = radialBar.height + attributesBackground.height + height + instructions.contentHeight
        }
    }

    Component {
        id: audioComponent

        Label {
            text: audioIcon
            font.pointSize: 40
            font.family: "Icons"
            color: audio.playbackState === Audio.PlayingState ? globalAmber : "white"
            horizontalAlignment: Text.AlignHCenter

            Component.onCompleted: testHeaderHeight = radialBar.height + attributesBackground.height + contentHeight + instructions.contentHeight

            Audio {
                id: audio
                source: Qt.resolvedUrl(fileUrlStart + courseDirectory + "/" + columnData[1].split(":")[0])
                autoPlay: true
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
                    {
                        audio.stop()
                        audio.play()
                    }
                }
            }
        }
    }
}
