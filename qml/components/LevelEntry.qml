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

Item {
    implicitWidth: levelEntryDelegate.childrenRect.width
    implicitHeight: levelEntryDelegate.childrenRect.height

    Rectangle {
        id: levelEntryDelegate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "transparent"

        Loader {
            id: levelFirstColumn
            anchors.left: parent.left
            width: parent.width / 3
            property string columnEntry: test
            sourceComponent:
            {
                if (testColumnType === "text")
                    return textColumnComponent
                else if (testColumnType === "image")
                    return imageColumnComponent
            }
        }

        Loader {
            id: levelSecondColumn
            anchors.left: levelFirstColumn.right
            anchors.right: levelThirdColumn.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            width: parent.width / 3 - anchors.leftMargin - anchors.rightMargin
            property string columnEntry: prompt
            sourceComponent:
            {
                if (promptColumnType === "text")
                    return textColumnComponent
                else if (promptColumnType === "image")
                    return imageColumnComponent
            }
        }

        Kirigami.Heading {
            id: levelThirdColumn
            anchors.right: parent.right
            width: parent.width / 3
            text: ignored ? "ignored" : (planted ? "nextWater" : "ready")
            level: 4
            horizontalAlignment: Text.AlignRight
        }
    }

    Component {
        id: textColumnComponent
        Kirigami.Heading {
            text: columnEntry
            level: 2
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignLeft
        }
    }

    Component {
        id: imageColumnComponent
        Image {
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + columnEntry)
            fillMode: Image.PreserveAspectFit
        }
    }
}
