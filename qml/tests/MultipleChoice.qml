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

Item {
    property int marginBase: 10

    property string itemId: ""
    property string testColumn: ""
    property string promptColumn: ""

    property int numberChoices: Math.floor(Math.random() * 5) + 4

    function correctAnswer()
    {
        correctAnswerCounter++
        testHeader.testAudio.play()
    }

    function wrongAnswer()
    {
        wrongAnswerCounter++

        var test = {}
        test[itemId] = TestType.PREVIEW
        tests.splice(itemIndex, 0, test)

        test = {}
        test[itemId] = TestType.MULTIPLECHOICE //randomize
        tests.splice(itemIndex + 1, 0, test)
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
                spacing: 50

                Repeater {
                    id: choices
                    model: globalBackend.getRandomValues(itemId, testColumn, numberChoices).sort(() => Math.random() - 0.5) //choiceList.sort(() => Math.random() - 0.5)

                    Rectangle {
                        height: childrenRect.height + choiceIndex.contentHeight
                        width: choicesLoader.width
                        color: "transparent"

                        Label {
                            id: choiceIndex
                            anchors {top: parent.top; left: parent.left; topMargin: marginBase; leftMargin: marginBase}
                            text: index + 1
                            font.pointSize: 15
                            visible: !platformIsMobile
                            z: 1
                        }

                        Loader {
                            id: choicesLoader
                            property string textData: modelData
                            property string buttonHeight: (root.height - testHeader.testHeaderHeight) / numberChoices - choiceIndex.contentHeight
                            sourceComponent: buttonComponent
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
            text: textData
            width: root.width / 2 - flowLayout.spacing
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

                    if (globalBackend.checkAnswer(itemId, testColumn, textData))
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

    Connections {
        target: testHeader
        function onCountdownReached()
        {
            //Just for updating statistics
            globalBackend.checkAnswer(itemId, testColumn, "")

            var answer = globalBackend.readItemColumn(itemId, testColumn)[1]
            for (var i = 0; i < choices.model.length; i++)
            {
                if (choices.model[i] !== answer)
                    choices.itemAt(i).Material.background = globalRed
                else
                    choices.itemAt(i).Material.background = globalGreen
            }

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
