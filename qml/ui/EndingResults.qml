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

    property string courseDirectory: ""
    property string levelPath: ""
    property var itemArray: []
    property string testColumn: ""
    property string promptColumn: ""

    Component.onCompleted: globalBackend.getLevelItems(courseDirectory, levelPath)

    ListView {
        anchors.fill: parent
        spacing: 20
        ScrollBar.vertical: ScrollBar {width: 10}

        header: ColumnLayout {
            width: parent.width

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: "Correct answers"
                    Layout.alignment: Qt.AlignLeft
                }

                Label {
                    text: "input"
                    Layout.alignment: Qt.AlignRight
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: "Speed"
                    Layout.alignment: Qt.AlignLeft
                }

                Label {
                    text: "input"
                    Layout.alignment: Qt.AlignRight
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: "Accuracy"
                    Layout.alignment: Qt.AlignLeft
                }

                Label {
                    text: "input"
                    Layout.alignment: Qt.AlignRight
                }
            }
        }

        model: ListModel {id: resultsListView}

        delegate: LevelEntry {inResults: true}
    }
}
