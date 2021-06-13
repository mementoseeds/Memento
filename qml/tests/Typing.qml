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
                    Material.accent: Material.Indigo
                    onAccepted:
                    {
                        if (globalBackend.checkAnswer(itemId, testColumn, text))
                        {
                            textfieldBackground.color = "green"
                            readOnly = true
                            //Mark as correct
                            testHeader.cooldownTimer.running = true
                        }
                        else
                        {
                            textfieldBackground.color = "red"
                            //Mark item as incorrect, add preview for it, and add another test for it in tests[]
                        }
                    }
                }
            }
        }
    }

    Shortcut {
        sequences: ["Enter", "Return"]
        enabled: textfield.readOnly //Enable only when the textfield has become read only
        onActivated: triggerNextItem()
    }
}
