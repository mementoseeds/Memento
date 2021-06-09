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
import QtQuick.Controls 2.15

Item {
    property int marginBase: 20

    width: courseExteriorDelegate.width
    height: courseExteriorDelegate.height

    Component.onCompleted: console.debug(height, width)

    ColumnLayout {
        id: courseExteriorDelegate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            width: levelNumberIndicator.contentWidth + 10
            height: levelNumberIndicator.contentHeight + 5
            radius: 100
            color: "gray"
            Layout.alignment: Qt.AlignHCenter

            Label {
                id: levelNumberIndicator
                text: index + 1
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Image {
            Layout.topMargin: 10
            source: isLearning ? (levelCompleted ? "assets/icons/flower.svg" : "assets/icons/seeds.svg") : "assets/icons/media.svg"
            sourceSize.width: levelCompleted ? 100 : 80
            sourceSize.height: 100
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: isLearning ? (levelCompleted ? "🗸" : "Ready to learn") : "Ready to read"
            font.bold: levelCompleted
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
        }

        Label {
            text: isLearning ? levelTitle : (levelTitle.length > 0 ? levelTitle : "Untitled media level")
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignCenter
        }

        Rectangle {
            width: itemAmountIndicator.contentWidth + 10
            height: itemAmountIndicator.contentHeight + 5
            radius: 100
            color: "gray"
            Layout.alignment: Qt.AlignHCenter

            Label {
                id: itemAmountIndicator
                text: isLearning ? (itemAmount + " items" + (levelCompleted ? " (Completed)" : "")) : "Media level"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
