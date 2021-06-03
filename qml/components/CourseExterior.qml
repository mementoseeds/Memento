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

import QtQuick 2.0
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15

Item {
    implicitWidth: courseExteriorDelegate.implicitWidth
    implicitHeight: courseExteriorDelegate.implicitHeight

    RowLayout {
        id: courseExteriorDelegate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Image {
            id: courseImage
            source: "file:/" + icon
            Layout.fillHeight: true
            Layout.maximumHeight: Kirigami.Units.iconSizes.huge * 1.5
            Layout.preferredWidth: height
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width - courseImage.width
            spacing: 0

            Kirigami.Heading {
                text: title
                level: 1
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Kirigami.Heading {
                text: planted + " / " + items + " | " + water + " water " + difficult + " difficult"
                level: 2
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            ProgressBar {
                id: courseProgressBar
                from: 0
                to: items
                value: planted
                indeterminate:  false
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width / 1.1
            }

            Kirigami.Heading {
                text: courseProgressBar.value / courseProgressBar.to * 100 + "%"
                level: 4
                Layout.alignment: Qt.AlignCenter
            }
        }

//        RowLayout {
//            id: courseButtonsRowLayout
//            spacing: 0

//            Button {
//                text: "Plant"
//                visible: !completed
//            }

//            Button {
//                text: "Water"
//            }
//        }
    }
}
