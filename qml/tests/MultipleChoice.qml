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
import QtQuick.Controls.Material 2.12
import TestType 1.0
import QtMultimedia 5.15

Item {
    property string testType: "MultipleChoice"
    property int marginBase: 10

    property string itemId: ""
    property string testColumn: ""
    property string promptColumn: ""

    property int numberChoices: Math.floor(Math.random() * 5) + 4
    property var itemData: globalBackend.readItemColumn(itemId, testColumn)

    function correctAnswer()
    {
        correctAnswerCounter++
        testHeader.radialBarText = "Success"
    }

    function wrongAnswer()
    {
        wrongAnswerCounter++
        testHeader.radialBarText = "Fail"

        var test = {}
        test[itemId] = TestType.PREVIEW
        tests.splice(itemIndex, 0, test)

        test = {}
        test[itemId] = getRandomTest()
        tests.splice(itemIndex + 1, 0, test)
    }

    function stopAllAudio()
    {
        for (var i = 0; i < choices.model.length; i++)
            choices.itemAt(i).children[1].item.stopAudio()
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: root.width

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: marginBase
            anchors.rightMargin: marginBase

            TestHeader {id: testHeader}

            Flow {
                id: flowLayout
                Layout.fillWidth: true
                Layout.margins: marginBase
                spacing: 20

                Repeater {
                    id: choices
                    model: globalBackend.getRandomValues(itemId, testColumn, numberChoices).sort(() => Math.random() - 0.5)

                    Rectangle {
                        height: childrenRect.height + choiceIndex.contentHeight
                        width: choicesLoader.width
                        color: "transparent"

                        Label {
                            id: choiceIndex
                            Component.onCompleted:
                            {
                                if (itemData[0] === "text" || itemData[0] === "audio")
                                {
                                    anchors.top = parent.top
                                    anchors.left = parent.left
                                    anchors.topMargin = marginBase
                                    anchors.leftMargin = marginBase
                                }
                                else if (itemData[0] === "image")
                                {
                                    anchors.top = parent.top
                                    anchors.topMargin = marginBase * -4
                                    anchors.horizontalCenter = parent.horizontalCenter
                                    flowLayout.Layout.topMargin = marginBase * 4
                                }
                            }

                            text: index + 1
                            font.pointSize: 15
                            visible: !platformIsMobile
                            z: 1
                        }

                        Loader {
                            id: choicesLoader
                            property string choiceData: modelData
                            property int buttonHeight: (root.height - testHeader.testHeaderHeight) / numberChoices - choiceIndex.contentHeight
                            sourceComponent:
                            {
                                switch (itemData[0])
                                {
                                    case "text":
                                        return buttonComponent
                                    case "image":
                                        return imageComponent
                                    case "audio":
                                        return audioComponent
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: buttonComponent

        Button {
            id: choiceButton
            text: choiceData
            width: root.width / 2 - flowLayout.spacing - flowLayout.Layout.margins
            height: buttonHeight
            font.capitalization: Font.MixedCase
            font.pointSize: 40
            Material.background: Material.color(Material.BlueGrey, Material.Shade600)

            contentItem: Text {
                id: buttonContentItem
                text: parent.text
                font: parent.font
                fontSizeMode: Text.Fit
                minimumPointSize: 10
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }

            onClicked:
            {
                if (testHeader.countdownTimer.running)
                {
                    testHeader.countdownTimer.running = false
                    testHeader.showAfterTests()

                    if (globalBackend.checkAnswer(itemId, testColumn, choiceData))
                    {
                        choiceButton.Material.background = globalGreen
                        correctAnswer()
                    }
                    else
                    {
                        choiceButton.Material.background = globalRed
                        wrongAnswer()
                    }

                    testHeader.cooldownTimer.running = true
                }
                else
                    triggerNextItem()
            }
        }
    }

    Component {
        id: imageComponent

        Image {
            function clicked()
            {
                if (testHeader.countdownTimer.running)
                {
                    testHeader.countdownTimer.running = false

                    if (globalBackend.checkAnswer(itemId, testColumn, choiceData))
                    {
                        setToolbarColor(Material.color(Material.Green, Material.ShadeA700))
                        correctAnswer()
                    }

                    else
                    {
                        setToolbarColor(globalRed)
                        wrongAnswer()
                    }

                    testHeader.cooldownTimer.running = true
                }
                else
                    triggerNextItem()
            }

            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + choiceData)
            width: root.width / 3 - flowLayout.spacing - flowLayout.Layout.margins
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignCenter

            MouseArea {
                anchors.fill: parent
                onClicked: parent.clicked()
            }
        }
    }

    Component {
        id: audioComponent

        Button {
            id: audioButton
            text: audioIcon
            width: root.width / 2 - flowLayout.spacing - flowLayout.Layout.margins
            height: buttonHeight
            font.family: "Icons"
            font.pointSize: 100
            Material.background: Material.color(Material.BlueGrey, Material.Shade600)

            contentItem: Text {
                id: buttonContentItem
                text: parent.text
                font: parent.font
                fontSizeMode: Text.Fit
                minimumPointSize: 10
                opacity: enabled ? 1.0 : 0.3
                color: audio.playbackState === Audio.PlayingState ? globalAmber : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }

            onClicked:
            {
                if (audio.playbackState !== Audio.PlayingState)
                {
                    stopAllAudio()
                    audio.play()
                }
                else
                {
                    if (testHeader.countdownTimer.running)
                    {
                        testHeader.countdownTimer.running = false

                        if (globalBackend.checkAnswer(itemId, testColumn, choiceData))
                        {
                            audioButton.Material.background = globalGreen
                            correctAnswer()
                        }
                        else
                        {
                            audioButton.Material.background = globalRed
                            wrongAnswer()
                        }

                        testHeader.cooldownTimer.running = true
                    }
                    else
                        triggerNextItem()
                }
            }

            function stopAudio()
            {
                audio.stop()
            }

            Audio {
                id: audio
                source: Qt.resolvedUrl(fileUrlStart + courseDirectory + "/" + choiceData.split(":")[0])
                autoLoad: false
                audioRole: Audio.GameRole
            }
        }
    }

    Connections {
        target: testHeader
        function onCountdownReached()
        {
            //Lock the test
            testHeader.testRunning = false

            //Just for updating statistics
            globalBackend.checkAnswer(itemId, testColumn, "")

            for (var i = 0; i < choices.model.length; i++)
            {
                if (choices.model[i] !== itemData[1])
                    choices.itemAt(i).children[1].item.Material.background = globalRed
                else
                    choices.itemAt(i).children[1].item.Material.background = globalGreen
            }

            if (itemData[0] === "image")
                setToolbarColor(globalRed)

            wrongAnswer()
            testHeader.cooldownTimer.running = true
        }
    }

    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: testHeader.cooldownTimer.running
        onActivated: triggerNextItem()
    }

    Shortcut {
        property int choiceShortcut: 1
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }

    Shortcut {
        property int choiceShortcut: 2
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }

    Shortcut {
        property int choiceShortcut: 3
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }

    Shortcut {
        property int choiceShortcut: 4
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }

    Shortcut {
        property int choiceShortcut: 5
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }

    Shortcut {
        property int choiceShortcut: 6
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }

    Shortcut {
        property int choiceShortcut: 7
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }

    Shortcut {
        property int choiceShortcut: 8
        sequence: choiceShortcut.toString()
        enabled: choiceShortcut <= numberChoices && testHeader.countdownTimer.running
        onActivated: choices.itemAt(choiceShortcut - 1).children[1].item.clicked()
    }
}
