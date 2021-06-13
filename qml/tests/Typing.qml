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

            TestHeader {}

            TextField {
                id: textfield
                font.pointSize: 15
                horizontalAlignment: TextInput.AlignHCenter
                Layout.fillWidth: true
                Material.accent: Material.Indigo
            }
        }
    }
}
