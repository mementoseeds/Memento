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

    property string courseDirectory: ""
    property string levelPath: ""
    property int levelNumber: 0
    property string levelTitle: ""
    property int itemAmount: 0
    property bool levelCompleted: false

    Component.onCompleted: globalBackend.getLevelItems(courseDirectory, levelPath)

    actions {
        left: Kirigami.Action {
            text: "Close"
            iconName: "dialog-close"
            onTriggered: rootPageStack.pop()
        }
        main: Kirigami.Action {
            text: "Previous"
            iconName: "arrow-left"
            onTriggered: signalSource.openPreviousLevel(levelNumber - 1)
        }
        right: Kirigami.Action {
            text: "Next"
            iconName: "arrow-right"
            onTriggered: signalSource.openNextLevel(levelNumber - 1)
        }
    }

    Kirigami.CardsListView {
        headerPositioning: ListView.InlineHeader
        header: ColumnLayout {
            width: parent.width

            LevelHeader {
                levelHeaderTitle: levelTitle
                levelHeaderNumber: levelNumber
                levelHeaderIcon: levelCompleted ? "assets/icons/flower.svg" : "assets/icons/seeds.svg"
                levelHeaderItemAmount: itemAmount
            }

            RowLayout {

                ComboBox {
                    model: ["Preview", "Reset"]
                    onActivated: console.debug(index)
                }

                Label {
                    text: ""
                    Layout.fillWidth: true
                }

                Button {
                    text: levelCompleted ? "Water" : "Plant"
                }
            }

            RowLayout {
                Layout.bottomMargin: 20

                Kirigami.Heading {
                    text: itemAmount + " Items"
                    level: 2
                }

                Label {
                    text: ""
                    Layout.fillWidth: true
                }

                Kirigami.Heading {
                    id: ignoredAmountHeading
                    text: "N Ignored"
                    level: 2

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

        model: ListModel {id: levelEntryListModel}

        delegate: Kirigami.AbstractCard {

            contentItem: LevelEntry{}
        }
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
