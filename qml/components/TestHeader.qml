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
    property alias radialBarText: radialBar.showText
    property int testHeaderHeight: 0
    property bool testRunning: true

    signal countdownReached()

    spacing: 20

    function answered()
    {
        //Lock the test
        testRunning = false
    }

    function showAfterTests()
    {
        globalBackend.getShowAfterTests(itemId, testColumn, promptColumn)
    }

    Component.onCompleted: mainMenuBar.insertAction(0, pauseAction)
    Component.onDestruction: mainMenuBar.takeAction(0)

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
        id: testHeaderMainLoader
        Layout.fillWidth: true
        property var columnData: globalBackend.readItemColumn(itemId, promptColumn)
        property int textSize: 20
        property int audioSize: 40
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

    Repeater {
        model: ListModel {id: showAfterTestsModel}

        Loader {
            Layout.fillWidth: true
            property var columnData: showAfterTestsData.split(";")
            property int textSize: 15
            property int audioSize: 20
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
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignCenter

        Repeater {
            id: attributesRepeater
            model: globalBackend.readItemAttributes(itemId)

            Rectangle {
                width: attributes.contentWidth + 10
                height: attributes.contentHeight + 5
                Layout.alignment: Qt.AlignCenter
                color: "gray"
                radius: 100
                visible: attributes.text.length > 0

                Label {
                    id: attributes
                    text: modelData
                    font.pointSize: platformIsMobile ? 15 : 10
                    anchors.centerIn: parent
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }
            }
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
        interval: userSettings["cooldownTimer"]
        running: false
        repeat: false
        onTriggered: triggerNextItem()
    }

    Component {
        id: textComponent

        Label {
            text: columnData[1]
            font.pointSize: textSize
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter

            Component.onCompleted: testHeaderHeight = testHeaderHeight = radialBar.height + (attributesRepeater.model.length > 0 ? attributesRepeater.itemAt(0).height : 0) + contentHeight + instructions.contentHeight
        }
    }

    Component {
        id: imageComponent

        Image {
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + columnData[1])
            sourceSize.width: platformIsMobile ? 100 : 150
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignCenter

            Component.onCompleted: testHeaderHeight = testHeaderHeight = radialBar.height + (attributesRepeater.model.length > 0 ? attributesRepeater.itemAt(0).height : 0) + height + instructions.contentHeight
        }
    }

    Component {
        id: audioComponent

        Label {

            function pauseAudio()
            {
                audio.pause()
            }

            function resumeAudio()
            {
                audio.play()
            }

            text: audioIcon
            font.pointSize: audioSize
            font.family: "Icons"
            color: audio.playbackState === Audio.PlayingState ? globalAmber : "white"
            horizontalAlignment: Text.AlignHCenter

            Component.onCompleted: testHeaderHeight = testHeaderHeight = radialBar.height + (attributesRepeater.model.length > 0 ? attributesRepeater.itemAt(0).height : 0) + contentHeight + instructions.contentHeight

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

    Connections {
        target: globalBackend

        function onAddShowAfterTests(type, content)
        {
            showAfterTestsModel.append({"showAfterTestsData": [type, content].join(";")})
        }
    }

    Connections {
        target: signalSource

        function onPauseTest()
        {
            if (testRunning)
            {
                countdownTimer.running = false

                if (testHeaderMainLoader.columnData[0] === "audio")
                    testHeaderMainLoader.item.pauseAudio()

                rootStackView.push("qrc:/PauseRoom.qml")
            }
        }

        function onResumeTest()
        {
            if (testRunning)
            {
                countdownTimer.running = true
                if (testHeaderMainLoader.columnData[0] === "audio")
                    testHeaderMainLoader.item.resumeAudio()
            }
        }
    }
}
