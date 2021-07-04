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
    id: stagingArea
    objectName: "StagingArea.qml"

    property string courseDirectory: ""
    property var testingContentOriginal: ({})
    property string actionType: ""
    property bool manualReview: false
    property int totalWateringItems: 0
    property bool mockWater: false
    property bool difficultReview: false

    property var testingContent: []
    property int itemIndex: 0
    property int correctAnswerCounter: 0
    property int wrongAnswerCounter: 0
    property var skippedItems: ({})

    // testingContentOriginal structure -->
    // dictionary of level paths that hold an array of item IDs

    // testingContent structure -->
    // outermost part - array
    // array holds dictionary of level path + dictionary
    // second dictionary holds item ID + test ID

    Component.onDestruction: restoreToolbar(globalBackend.readCourseTitle())

    function getRandomTest()
    {
        var testType = Math.floor(Math.random() * 3) + 1
        if ((testType === TestType.MULTIPLECHOICE && !userSettings["enabledTests"]["enabledMultipleChoice"])
            || (testType === TestType.TYPING && !userSettings["enabledTests"]["enabledTyping"])
            || (testType === TestType.TAPPING && !userSettings["enabledTests"]["enabledTapping"]))
            return getRandomTest()
        else
            return testType
    }

    function manuallyChangeTest(test, variables)
    {
        testStackView.replace(test, variables)
    }

    function mistakenTest(levelPath, id)
    {
        if (actionType !== "difficult")
        {
            var test = {}
            test[id] = TestType.PREVIEW
            var levelItem = {}
            levelItem[levelPath] = test
            testingContent.splice(itemIndex, 0, levelItem)

            var newRandomPosition = Math.floor((Math.random() * (testingContent.length - itemIndex)) + 1) + itemIndex
            test = {}
            test[id] = getRandomTest()
            levelItem = {}
            levelItem[levelPath] = test
            testingContent.splice(newRandomPosition, 0, levelItem)
        }
        else
        {
            skippedItems[levelPath].push(id)

            for (var i = 0; i < testingContentOriginal[levelPath].length; i++)
                if (testingContentOriginal[levelPath][i] === id)
                    testingContentOriginal[levelPath].splice(i, 1)
        }
    }

    function autoLearnItem(levelPath, itemId)
    {
        if (actionType === "plant")
        {
            skippedItems[levelPath].push(itemId)

            globalBackend.autoLearnItem(levelPath, itemId, 1)
            triggerNextItem()
        }
    }

    Connections {
        target: signalSource

        function onSetMnemonic(mnemonicId)
        {
            var index = itemIndex - 1
            var level = Object.keys(testingContent[index]).toString()
            globalBackend.setMnemonic(level, Object.keys(testingContent[index][level]).toString(), mnemonicId)
        }
    }

    Component.onCompleted:
    {
        signalSource.stopAllAudio()
        globalBackend.setReviewType(manualReview, mockWater, difficultReview)
        globalBackend.loadCourseInfo(courseDirectory)

        globalBackend.loadLevelJsons(Object.keys(testingContentOriginal))

        if (actionType === "preview")
        {
            for (var level in testingContentOriginal)
            {
                var itemArray = testingContentOriginal[level]

                for (var id in itemArray)
                {
                    var test = {}
                    test[itemArray[id]] = TestType.PREVIEW
                    var levelItem = {}
                    levelItem[level] = test
                    testingContent.push(levelItem)
                }
            }
        }
        else if (actionType === "plant")
        {
            for (level in testingContentOriginal)
            {
                itemArray = testingContentOriginal[level]

                for (id in itemArray)
                {
                    test = {}
                    test[itemArray[id]] = TestType.PREVIEW
                    levelItem = {}
                    levelItem[level] = test
                    testingContent.push(levelItem)

                    test = {}
                    test[itemArray[id]] = userSettings["enabledTests"]["enabledMultipleChoice"] ? TestType.MULTIPLECHOICE : getRandomTest()
                    levelItem = {}
                    levelItem[level] = test
                    testingContent.push(levelItem)
                }
            }

            var unorderedTests = []
            for (var i = 0; i < 4; i++)
            {
                for (id in itemArray)
                {
                    test = {}
                    test[itemArray[id]] = getRandomTest()
                    levelItem = {}
                    levelItem[level] = test
                    unorderedTests.push(levelItem)
                }
            }

            testingContent = testingContent.concat(unorderedTests.sort(() => Math.random() - 0.5))
        }
        else if (actionType === "water")
        {
            for (level in testingContentOriginal)
            {
                itemArray = testingContentOriginal[level]

                for (id in itemArray)
                {
                    test = {}
                    test[itemArray[id]] = getRandomTest()
                    levelItem = {}
                    levelItem[level] = test
                    testingContent.push(levelItem)
                }

                testingContent.sort(() => Math.random() - 0.5)
            }
        }
        else if (actionType === "difficult")
        {
            for (level in testingContentOriginal)
            {
                itemArray = testingContentOriginal[level]

                for (i = 0; i < 3; i++)
                {
                    for (id in itemArray)
                    {
                        test = {}
                        test[itemArray[id]] = getRandomTest()
                        levelItem = {}
                        levelItem[level] = test
                        testingContent.push(levelItem)
                    }
                }

                testingContent.sort(() => Math.random() - 0.5)
            }
        }
    }

    function triggerNextItem()
    {
        signalSource.disablePreviousPageConnections()

        if (actionType === "preview")
        {
            replaceToolbar("Previewing ", testingContent.length, testingContent.length, itemIndex, actionType)

                if (itemIndex < testingContent.length)
                {
                    var level = Object.keys(testingContent[itemIndex]).toString()
                    var columns = globalBackend.getLevelColumns(level)

                    testStackView.replace("qrc:/Preview.qml", {"itemId": Object.keys(testingContent[itemIndex][level]).toString(), "testColumn": columns[0], "promptColumn": columns[1]})
                    itemIndex++
                }
                else
                    rootStackView.pop()

            return
        }

        if (itemIndex < testingContent.length)
        {
            level = Object.keys(testingContent[itemIndex]).toString()
            columns = globalBackend.getLevelColumns(level)
            var itemId = Object.keys(testingContent[itemIndex][level]).toString()

            //Setup skipped items container
            if (!Array.isArray(skippedItems[level]))
                skippedItems[level] = []

            if (actionType === "plant")
            {
                replaceToolbar("Planting ", testingContentOriginal[level].length, testingContent.length, itemIndex, actionType)
            }
            else if (actionType === "water" || actionType === "difficult")
            {
                replaceToolbar(actionType === "water" ? "Watering " : "Reviewing ", totalWateringItems, testingContent.length, itemIndex, actionType)
            }

            //Skip over this item if the user has requested a skip
            if (skippedItems[level].includes(itemId))
            {
                itemIndex++
                triggerNextItem()
                //Return otherwise crashes at the result
                return
            }

            //Random chance to switch test and prompt columns if the next test is multiple choice
            if (Math.random() < 0.5 && userSettings["enableTestPromptSwitch"] && testingContent[itemIndex][level][itemId] === TestType.MULTIPLECHOICE)
            {
                var tempColumn = columns[0]
                var testColumn = columns[1]
                var promptColumn = tempColumn
                delete tempColumn
            }
            else
            {
                testColumn = columns[0]
                promptColumn = columns[1]
            }

            var variables = {"itemId": itemId, "levelPath": level, "testColumn": testColumn, "promptColumn": promptColumn}

            switch (testingContent[itemIndex][level][itemId])
            {
                case TestType.PREVIEW:
                    testStackView.replace("qrc:/Preview.qml", variables)
                    break

                case TestType.MULTIPLECHOICE:
                    testStackView.replace("qrc:/MultipleChoice.qml", variables)
                    break

                case TestType.TAPPING:
                    variables["tappingEnabled"] = true
                case TestType.TYPING:
                    testStackView.replace("qrc:/Typing.qml", variables)
                    break
            }

            itemIndex++
        }
        else
        {
            if (actionType === "difficult")
                globalBackend.unmarkDifficult(testingContentOriginal)

            globalBackend.saveLevels()
            rootStackView.replace("qrc:/ResultSummary.qml", {"courseDirectory": courseDirectory, "testingContent": testingContentOriginal, "correctAnswerCounter": correctAnswerCounter, "totalTests": (correctAnswerCounter + wrongAnswerCounter)})
        }
    }

    StackView {
        id: testStackView
        anchors.fill: parent
        Component.onCompleted:
        {
            globalBackend.setStartTime()
            triggerNextItem()
        }
    }
}
