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

RowLayout {
    width: parent.width

    property string levelHeaderTitle: ""
    property int levelHeaderNumber: 0
    property string levelHeaderIcon: ""
    property int levelHeaderItemAmount: 0
    property int levelHeaderCompletedItemAmount: 0
    property bool headerIsLearning: true

    ColumnLayout {
        Layout.preferredWidth: parent.width

        Label {
            text: "Level " + levelHeaderNumber
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Image {
            source: levelHeaderIcon
            sourceSize.width: 80
            sourceSize.height: typeof(levelCompleted) === "undefined" ? 80 : (levelCompleted ? 80 : 100)
            Layout.alignment: Qt.AlignHCenter
        }
    }

    ColumnLayout {
        Layout.preferredWidth: parent.width

        Label {
            text: levelHeaderTitle
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
        }

        ProgressBar {
            id: levelProgressBar
            from: 0
            to: headerIsLearning ? levelHeaderItemAmount : 100
            value: headerIsLearning ? levelHeaderCompletedItemAmount : 0
            indeterminate:  false
            Material.accent: typeof(levelCompleted) === "undefined" ? defaultToolbarColor : (levelCompleted ? globalBlue : globalGreen)
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
        }

        Label {
            visible: headerIsLearning
            text: Math.floor(levelProgressBar.value / levelProgressBar.to * 100) + "%"
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
