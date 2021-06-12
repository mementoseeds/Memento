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
import TestType 1.0

Item {
    property int marginBase: 10

    property string courseDirectory: ""
    property string levelPath: ""
    property int levelNumber: 0
    property string levelTitle: ""
    property string testColumn: ""
    property string promptColumn: ""
    property string testColumnType: ""
    property string promptColumnType: ""
    property int itemAmount: 0
    property bool levelCompleted: false

    Component.onCompleted: globalBackend.getLevelItems(courseDirectory, levelPath)

    function getItemArray(total)
    {
        var items = []
        for (var i = 0; i < total; i++)
        {
            var itemId = levelEntryListModel.get(i).id
            if (typeof(itemId) !== "undefined")
                items.push(itemId)
        }

        return items
    }

    ListView {
        anchors.fill: parent
        spacing: 20
        ScrollBar.vertical: ScrollBar {width: 10}
        header: ColumnLayout {
            width: parent.width

            ColumnLayout {
                width: parent.width - marginBase * 2
                Layout.leftMargin: marginBase
                Layout.rightMargin: marginBase

                LevelHeader {
                    levelHeaderTitle: levelTitle
                    levelHeaderNumber: levelNumber
                    levelHeaderIcon: levelCompleted ? "assets/icons/flower.svg" : "assets/icons/seeds.svg"
                    levelHeaderItemAmount: itemAmount
                }

                RowLayout {
                    Layout.preferredWidth: parent.width

                    ComboBox {
                        model: ["Preview", "Plant", "Water", "Reset"]
                        Layout.alignment: Qt.AlignLeft
                        onActivated:
                        {
                            if (currentText === "Preview")
                                rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "itemArray": getItemArray(levelEntryListModel.count), "testType": "preview", "testColumn": testColumn, "promptColumn": promptColumn})
                        }
                    }

                    Button {
                        text: levelCompleted ? "Water" : "Plant"
                        Layout.alignment: Qt.AlignRight
                        onClicked:
                        {
                            if (text === "Plant")
                            {
                                rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "itemArray": getItemArray(5), "testType": "plant", "testColumn": testColumn, "promptColumn": promptColumn})
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.preferredWidth: parent.width
                    Layout.bottomMargin: 20

                    Label {
                        text: itemAmount + " Items"
                        Layout.alignment: Qt.AlignLeft
                    }

                    Label {
                        id: ignoredAmountHeading
                        text: "N Ignored"
                        Layout.alignment: Qt.AlignRight

                        Connections {
                            target: globalBackend
                            function onFinishedAddingLevel()
                            {
                                var amountIgnored = 0
                                for (var i = 0; i < levelEntryListModel.count; i++)
                                {
                                    if (levelEntryListModel.get(i).ignored)
                                        amountIgnored++
                                }
                                ignoredAmountHeading.text = amountIgnored + " Ignored"
                            }
                        }
                    }
                }
            }
        }

        model: ListModel {id: levelEntryListModel}

        delegate: LevelEntry {}
    }

    Connections {
        target: globalBackend
        function onAddLevelItem(id, test, prompt, planted, nextWatering, ignored, difficult)
        {
            levelEntryListModel.append({
                "id": id,
                "test": test,
                "prompt": prompt,
                "planted": planted,
                "nextWatering": nextWatering,
                "ignored": ignored
                                       })
        }
    }
}
