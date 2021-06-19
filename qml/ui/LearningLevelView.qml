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
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.12

Item {
    id: learningLevelView
    objectName: "LearningLevelView.qml"
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
    property int plantedItems: countPlanted()
    property bool manualReview: false

    property int iconSize: platformIsMobile ? 20 : 15

    Component.onCompleted:
    {
        globalBackend.getLevelItems(courseDirectory, levelPath)

        levelCompleted = globalBackend.getLevelCompleted()
    }

    function countPlanted()
    {
        var planted = 0
        for (var i = 0; i < levelEntryListModel.count; i++)
            if (levelEntryListModel.get(i).planted)
                planted++

        return planted
    }

    function getAllItems()
    {
        var items = []
        for (var i = 0; i < levelEntryListModel.count; i++)
            items.push(levelEntryListModel.get(i).id)
        return items
    }

    function getPlantingItems(total)
    {
        var items = []
        for (var i = 0; i < total; i++)
        {
            if ((i + 1) <= levelEntryListModel.count)
            {
                var item = levelEntryListModel.get(i)
                if (!item.planted && !item.ignored)
                    items.push(item.id)
                else
                    total++
            }
        }

        return items
    }

    function getWateringItems(total)
    {
        var items = []
        for (var i = 0; i < total; i++)
        {
            if ((i + 1) <= levelEntryListModel.count)
            {
                var item = levelEntryListModel.get(i)
                if (item.progress === "Now")
                    items.push(item.id)
                else
                    total++
            }
        }

        if (items.length === 0)
        {
            for (i = 0; i < levelEntryListModel.count; i++)
            {
                item = levelEntryListModel.get(i)
                if (item.planted && !item.ignored)
                    items.push(levelEntryListModel.get(i).id)
            }

            manualReview = true
            return items
        }
        else
            return items
    }

    function plantAction()
    {
        if (!levelCompleted)
            rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "levelPath": levelPath,
                "itemArray": getPlantingItems(5), "actionType": "plant", "testColumn": testColumn, "promptColumn": promptColumn})
        else
            showPassiveNotification("This level is already completed")
    }

    function waterAction()
    {
        if (plantedItems !== 0)
            rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "levelPath": levelPath,
                "itemArray": getWateringItems(50), "actionType": "water", "testColumn": testColumn, "promptColumn": promptColumn, "manualReview": manualReview})
        else
            showPassiveNotification("There are no items to water")
    }

    function reloadLevel()
    {
        rootStackView.replace(findPageIndex(learningLevelView.objectName), "qrc:/LearningLevelView.qml", {
            "courseDirectory": courseDirectory,
            "levelPath": levelPath,
            "levelNumber": levelNumber,
            "levelTitle": levelTitle,
            "testColumn": testColumn,
            "promptColumn": promptColumn,
            "testColumnType": testColumnType,
            "promptColumnType": promptColumnType,
            "itemAmount": itemAmount})
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
                    levelHeaderCompletedItemAmount: plantedItems
                }

                RowLayout {
                    Layout.preferredWidth: parent.width

                    ComboBox {
                        model: ["Preview", "Plant", "Water", "Refresh", "Auto learn", "Reset"]
                        Layout.alignment: Qt.AlignLeft
                        onActivated:
                        {
                            switch (currentText)
                            {
                                case "Preview":
                                    rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "itemArray": getAllItems(), "actionType": "preview", "testColumn": testColumn, "promptColumn": promptColumn})
                                    break
                                case "Plant":
                                    plantAction()
                                    break
                                case "Water":
                                    waterAction()
                                    break
                                case "Reset":
                                    confirmLevelReset.visible = true
                                    break
                                case "Refresh":
                                    reloadLevel()
                                    break
                                case "Auto learn":
                                    if (!levelCompleted)
                                    {
                                        globalBackend.autoLearn(getPlantingItems(5), levelPath)
                                        signalSource.refreshCourseLevels()
                                        reloadLevel()
                                    }
                                    else showPassiveNotification("No items to auto learn")

                                    break
                            }
                        }
                    }

                    Button {
                        id: plantWaterButton
                        text: levelCompleted ? "Water" : "Plant"
                        icon.source: levelCompleted ? "assets/icons/water.svg" : "assets/icons/plant.svg"
                        Material.background: levelCompleted ? globalBlue : globalGreen
                        Layout.alignment: Qt.AlignRight
                        onClicked:
                        {
                            if (text === "Plant")
                                plantAction()
                            else if (text === "Water")
                                waterAction()
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
        function onAddLevelItem(id, test, prompt, planted, progress, ignored, difficult)
        {
            levelEntryListModel.append({
                "id": id,
                "test": test,
                "prompt": prompt,
                "planted": planted,
                "progress": ignored ? "ignored" : (planted ? progress + " <span style=font-size:" + iconSize + "pt style=color:" + globalBlue + ">" + waterIcon + "</span>"
                                                           : "<span style=font-size:" + iconSize + "pt style=color:" + globalGreen + ">" + plantIcon + "</span>"),
                "ignored": ignored
                                       })
        }
    }

    Connections {
        target: signalSource
        function onReloadLearningLevel()
        {
            reloadLevel()
        }
    }

    MessageDialog {
        id: confirmLevelReset
        icon: StandardIcon.Question
        title: "Reset level?"
        text: "Are you sure you want to reset this level?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes:
        {
            globalBackend.resetCurrentLevel(levelPath)
            signalSource.refreshCourseLevels()
            reloadLevel()
        }
    }
}
