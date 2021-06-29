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
    property string testType: "Typing"
    property int marginBase: 10

    property string levelPath: ""
    property string itemId: ""
    property string testColumn: ""
    property string promptColumn: ""
    property bool tappingEnabled: false

    property var itemData: globalBackend.readItemColumn(itemId, testColumn)
    property int numberTappingButtons: Math.floor(Math.random() * 6) + 5

    Component.onCompleted:
    {
        if (itemData[0] === "image" || itemData[0] === "audio")
            manuallyChangeTest("qrc:/MultipleChoice.qml", {"itemId": itemId, "levelPath": levelPath, "testColumn": testColumn, "promptColumn": promptColumn})
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

            Rectangle {
                id: textfieldBackground
                Layout.fillWidth: true
                height: textfield.contentHeight + 10
                Layout.alignment: Qt.AlignCenter
                color: "gray"
                radius: 100

                TextField {
                    id: textfield
                    font.pointSize: 15
                    horizontalAlignment: TextInput.AlignHCenter
                    width: parent.width
                    Material.accent: testColor[actionType]

                    Component.onCompleted:
                    {
                        if (!tappingEnabled || !platformIsMobile)
                            textfield.forceActiveFocus()
                        else
                            focus = true
                    }

                    onTextChanged:
                    {
                        if (userSettings["autoAcceptAnswer"] && text.toLocaleLowerCase() === itemData[1].toLocaleLowerCase())
                            accepted()
                    }

                    onAccepted:
                    {
                        if (text.length === 0 && testHeader.countdownTimer.running)
                            return

                        testHeader.answered()

                        testHeader.countdownTimer.running = false
                        testHeader.showAfterTests()
                        readOnly = true

                        if (globalBackend.checkAnswer(levelPath, itemId, testColumn, text))
                        {
                            correctAnswerCounter++
                            textfieldBackground.color = "green"
                        }
                        else
                        {
                            wrongAnswerCounter++
                            textfieldBackground.color = "red"
                            mistakenTest(levelPath, itemId)
                        }

                        testHeader.cooldownTimer.running = true
                    }
                }
            }

            Flow {
                id: flowLayout
                visible: tappingEnabled
                Layout.fillWidth: true
                Layout.topMargin: marginBase
                Layout.bottomMargin: marginBase
                Layout.leftMargin: root.width / 2 - childrenRect.width / 2 - marginBase
                spacing: 5

                Repeater {
                    model: globalBackend.getRandomCharacters(itemId, testColumn, numberTappingButtons).sort(() => Math.random() - 0.5)

                    RoundButton {
                        id: tapButton
                        radius: 5
                        text: modelData
                        font.capitalization: Font.MixedCase
                        font.pointSize: platformIsMobile ? 20 : 15
                        Material.background: globalBlueGrey
                        onClicked: textfield.text += text
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                RoundButton {
                    visible: flowLayout.visible
                    radius: 5
                    text: spacebarIcon
                    font.family: "Icons"
                    implicitWidth: root.width / 3
                    font.capitalization: Font.MixedCase
                    font.pointSize: 12
                    Material.background: globalBlueGrey
                    onClicked: textfield.text += " "
                }

                RoundButton {
                    visible: flowLayout.visible
                    radius: 5
                    text: backspaceIcon
                    font.family: "Icons"
                    implicitWidth: root.width / 3
                    font.capitalization: Font.MixedCase
                    font.pointSize: 20
                    Material.background: globalBlueGrey
                    onClicked: textfield.remove(textfield.length - 1, textfield.length)
                }
            }

            Button {
                text: "Continue"
                icon.source: "assets/actions/go-next.svg"
                enabled: textfield.text.length > 0
                Layout.topMargin: marginBase
                Layout.alignment: Qt.AlignHCenter
                onClicked:
                {
                    if (textfield.readOnly)
                        triggerNextItem()
                    else
                        textfield.accepted()
                }
            }
        }
    }

    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: textfield.readOnly //Enable only when the textfield has become read only
        onActivated: triggerNextItem()
    }

    Connections {
        target: testHeader
        function onCountdownReached()
        {
            testHeader.answered()

            textfield.accepted()
        }
    }
}
