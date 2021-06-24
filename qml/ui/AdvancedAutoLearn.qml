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

    property int levelAmount: 50

    objectName: "AdvancedAutoLearn.qml"

    ScrollView {
        anchors.fill: parent
        contentWidth: root.width

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: marginBase
            anchors.rightMargin: marginBase
            spacing: marginBase

            Label {
                text: "<b>Advanced auto learn</b><br>Here you can select what range of levels you want to auto learn<br>how much their streak should be<br>and whether the next review should be scheduled now or in the future based on the streak"
                font.pointSize: 10
                textFormat: Text.RichText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: "Level begin and end"
                font.pointSize: 10
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.fillWidth: true
                Layout.topMargin: marginBase
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: Math.floor(levelRangeSlider.first.value)
                    font.pointSize: 10
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.alignment: Qt.AlignLeft
                    horizontalAlignment: Text.AlignHCenter
                }

                RangeSlider {
                    id: levelRangeSlider
                    from: 1
                    to: levelAmount
                    stepSize: 1
                    first.value: from
                    second.value: to
                    Material.accent: globalGreen
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                }

                Label {
                    text: Math.floor(levelRangeSlider.second.value)
                    font.pointSize: 10
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Label {
                text: "Streak count for determining watering date"
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: streakCountSpinBox
                from: 1
                to: 11
                value: 1
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "1 = 5 hours\n2 = 12 hours\n3 = 24 hours\n4 = 6 days\n5 = 12 days\n6 = 24 days\n7 = 48 days\n8 = 96 days\n9 = 180 days\n10 = 270 days\n11 = 1 year"
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: waterNow
                text: "Schedule next watering right now?"
                checked: false
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Button {
                text: "Begin"
                Layout.alignment: Qt.AlignCenter
                onClicked: console.debug("Begin")
            }
        }
    }
}
