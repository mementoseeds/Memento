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

Kirigami.ScrollablePage {
    property string itemId: ""
    property string testColumn: ""
    property string promptColumn: ""

    Component.onCompleted: globalBackend.readItem(itemId, testColumn, promptColumn)

    ListView {
        spacing: 10

//        header: RowLayout {
//            anchors.left: parent.left
//            anchors.leftMargin: parent.width / 2 - childrenRect.width / 2

//            Button {
//                text: "Forward"
//                onClicked: triggerNextItem()
//            }
//        }

        model: ListModel{id: previewListModel}
        delegate: Loader {
            width: parent.width

            property string type: model.type
            property string columnName: model.columnName
            property string primary: model.primary
            property var other: model.other

            sourceComponent: switch (type)
                {
                    case "attributes":
                    case "text": return textComponent
                }
        }
    }

    Connections {
        target: globalBackend
        function onAddItemDetails(type, columnName, primary, other)
        {
            previewListModel.append({"type": type, "columnName": columnName, "primary": primary, "other": other})
        }
    }

    Component {
        id: textComponent
        ColumnLayout {
            width: parent.width
            spacing: 10

            Kirigami.Heading {
                id: textColumnName
                visible: textPrimary.visible
                text: columnName
                level: 5
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Kirigami.Heading {
                id: textPrimary
                visible: text.length > 0
                text: primary
                level: 1
                font.pointSize: 20
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                visible: textColumnName.visible && textPrimary.visible
                Layout.topMargin: 10
                color: "gray"
                height: 2
                Layout.fillWidth: true
                radius: 50
            }
        }
    }
}
