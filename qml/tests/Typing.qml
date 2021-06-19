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
                    Component.onCompleted: textfield.forceActiveFocus()
                    focus: true
                    horizontalAlignment: TextInput.AlignHCenter
                    width: parent.width
                    Material.accent: testColor[actionType]

                    onTextChanged:
                    {
                        if (userSettings["autoAcceptAnswer"] && text.toLocaleLowerCase() === globalBackend.readItemColumn(itemId, testColumn)[1].toLocaleLowerCase())
                            accepted()
                    }

                    onAccepted:
                    {
                        if (text.length === 0 && testHeader.countdownTimer.running)
                            return

                        testHeader.countdownTimer.running = false

                        testHeader.testAudio.play()

                        if (globalBackend.checkAnswer(itemId, testColumn, text))
                        {
                            correctAnswerCounter++
                            textfieldBackground.color = "green"
                            readOnly = true
                            testHeader.cooldownTimer.running = true
                        }
                        else
                        {
                            wrongAnswerCounter++
                            textfieldBackground.color = "red"
                            readOnly = true
                            testHeader.cooldownTimer.running = true

                            var test = {}
                            test[itemId] = TestType.PREVIEW
                            tests.splice(itemIndex, 0, test)

                            test = {}
                            test[itemId] = TestType.TYPING //randomize
                            tests.splice(itemIndex + 1, 0, test)
                        }
                    }
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
            textfield.accepted()
        }
    }
}
