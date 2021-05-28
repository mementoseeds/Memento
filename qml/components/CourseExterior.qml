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
            source: Qt.resolvedUrl("file:/" + icon)
            Layout.fillHeight: true
            Layout.maximumHeight: Kirigami.Units.iconSizes.huge
            Layout.preferredWidth: height
        }

        ColumnLayout {

            Kirigami.Heading {
                text: title
                level: 1
                Layout.alignment: Qt.AlignHCenter
            }

            ProgressBar {
                from: 0
                to: seeds
                value: planted
                indeterminate:  false
                Layout.alignment: Qt.AlignHCenter
            }
        }

        ColumnLayout {

            Kirigami.Heading {
                text: planted + " / " + seeds + " seeds planted"
                level: 2
                Layout.alignment: Qt.AlignHCenter
            }

            Kirigami.Heading {
                text: water + " water " + difficult + " difficult"
                level: 3
                Layout.alignment: Qt.AlignHCenter
            }
        }

        RowLayout {
            spacing: 10

            Button {
                text: "Plant"
                visible: !completed
            }

            Button {
                text: "Water"
            }
        }
    }
}
