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
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15

RowLayout {
    property string levelHeaderTitle: ""
    property int levelHeaderNumber: 0
    property string levelHeaderIcon: ""
    property int levelHeaderItemAmount: 0
    property int levelHeaderCompletedItemAmount: 0
    property bool headerIsLearning: true

    ColumnLayout {

        Kirigami.Heading {
            text: "Level " + levelHeaderNumber
            font.bold: true
            level: 1
            Layout.alignment: Qt.AlignHCenter
        }

        Image {
            source: levelHeaderIcon
            sourceSize.width: 80
            sourceSize.height: 100
            Layout.alignment: Qt.AlignHCenter
        }
    }

    ColumnLayout {

        Kirigami.Heading {
            text: levelHeaderTitle
            font.bold: true
            level: 1
            font.pointSize: 30
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            Layout.fillWidth: true
            Layout.leftMargin: 10
        }

        ProgressBar {
            id: levelProgressBar
            from: 0
            to: headerIsLearning ? levelHeaderItemAmount : 100
            value: headerIsLearning ? levelHeaderCompletedItemAmount : 0
            indeterminate:  false
            Layout.fillWidth: true
        }

        Kirigami.Heading {
            visible: headerIsLearning
            text: levelProgressBar.value / levelProgressBar.to * 100 + "%"
            level: 4
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
