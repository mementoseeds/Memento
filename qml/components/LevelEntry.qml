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

Item {
    property int marginBase: 10

    width: root.width - marginBase * 2
    x: marginBase
    height: levelEntryDelegate.childrenRect.height + 10

    Rectangle {
        id: levelEntryDelegate
        height: childrenRect.height + 15
        width: parent.width
        color: "transparent"

        Loader {
            id: levelFirstColumn
            anchors.left: parent.left
            anchors.leftMargin: marginBase
            width: parent.width / 3
            property string columnEntry: test
            sourceComponent: testColumnType === "text" ? textColumnComponent : imageColumnComponent
        }

        Loader {
            id: levelSecondColumn
            anchors.left: levelFirstColumn.right
            anchors.right: levelThirdColumn.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            width: parent.width / 3 - anchors.leftMargin - anchors.rightMargin
            property string columnEntry: prompt
            sourceComponent: promptColumnType === "text" ? textColumnComponent : imageColumnComponent
        }

        Label {
            id: levelThirdColumn
            anchors.right: parent.right
            anchors.rightMargin: marginBase
            width: parent.width / 3
            text: ignored ? "ignored" : (planted ? "nextWater" : "ready")
            font.pointSize: 8
            horizontalAlignment: Text.AlignRight
        }
    }

    MouseArea {
        anchors.fill: levelEntryDelegate
        cursorShape: Qt.PointingHandCursor
        onClicked: rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "itemArray": [id], "testType": "preview", "testColumn": testColumn, "promptColumn": promptColumn})
    }

    Rectangle {
        width: parent.width
        anchors.top: levelEntryDelegate.bottom
        height: 1
    }

    Component {
        id: textColumnComponent
        Label {
            text: columnEntry
            font.pointSize: 12
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignLeft
        }
    }

    Component {
        id: imageColumnComponent
        Image {
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + columnEntry)
            fillMode: Image.PreserveAspectFit
            height: 200
        }
    }
}
