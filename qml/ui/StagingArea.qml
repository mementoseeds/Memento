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

    property var testingContent: ({})
    property var levels: []
    property int uniqueItemCount: 0
    property int totalWateringIndex: 0
    property int levelIndex: 0
    property int itemIndex: 0
    property int correctAnswerCounter: 0
    property int wrongAnswerCounter: 0
    property var autoLearned: []

    // testingContent structure -->
    // dictionary of lists of dictionaries
    // outer dictionary has level paths as keys and lists as values
    // lists contain dictionaries
    // inner dictionary has seed IDs as keys and enumerated test types as values
    // example
    /*
{
    "path/to/course/levels/00001.json": [
        {
            "67742594": 1
        },
        {
            "67742595": 2
        }
    ],
    "path/to/course/levels/00002.json": [
        {
            "67742596": 1
        },
        {
            "67742597": 3
        }
    ]
}
    */

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
        testLoader.active = false
        testLoader.setSource(test, variables)
        testLoader.active = true
    }

    function scheduleTestAfterMistake(levelPath, id)
    {
        var test = {}
        test[id] = TestType.PREVIEW
        testingContent[levelPath].splice(itemIndex, 0, test)

        var newRandomPosition = Math.floor((Math.random() * (testingContent[levelPath].length - itemIndex)) + 1) + itemIndex
        test = {}
        test[id] = getRandomTest()
        testingContent[levelPath].splice(newRandomPosition, 0, test)
    }

    function autoLearnItem(levelPath, itemId)
    {
        autoLearned.push(itemId)
        globalBackend.autoLearnItem(levelPath, itemId, 1)
        triggerNextItem()
    }

    Component.onCompleted:
    {
        signalSource.stopAllAudio()
        globalBackend.setReviewType(manualReview, mockWater)
        globalBackend.loadCourseInfo(courseDirectory)

        levels = Object.keys(testingContentOriginal)
        globalBackend.loadLevelJsons(levels)

        if (actionType === "preview")
        {
            for (var level in testingContentOriginal)
            {
                var itemArray = testingContentOriginal[level]
                testingContent[level] = []

                for (var id in itemArray)
                {
                    var test = {}
                    test[itemArray[id]] = TestType.PREVIEW
                    testingContent[level].push(test)
                }
            }
        }
        else if (actionType === "plant")
        {
            for (level in testingContentOriginal)
            {
                itemArray = testingContentOriginal[level]
                uniqueItemCount = itemArray.length
                testingContent[level] = []

                for (id in itemArray)
                {
                    test = {}
                    test[itemArray[id]] = TestType.PREVIEW
                    testingContent[level].push(test)

                    test = {}
                    test[itemArray[id]] = userSettings["enabledTests"]["enabledMultipleChoice"] ? TestType.MULTIPLECHOICE : getRandomTest()
                    testingContent[level].push(test)
                }

                var unorderedTests = []
                for (var i = 0; i < 4; i++)
                {
                    for (id in itemArray)
                    {
                        test = {}
                        test[itemArray[id]] = getRandomTest()
                        unorderedTests.push(test)
                    }
                }

                testingContent[level] = testingContent[level].concat(unorderedTests.sort(() => Math.random() - 0.5))
            }
        }
        else if (actionType === "water")
        {
            for (level in testingContentOriginal)
            {
                itemArray = testingContentOriginal[level]
                uniqueItemCount = itemArray.length
                testingContent[level] = []

                for (id in itemArray)
                {
                    test = {}
                    test[itemArray[id]] = getRandomTest()
                    testingContent[level].push(test)
                }
            }

            testingContent[level].sort(() => Math.random() - 0.5)
        }
    }

    function triggerNextItem()
    {
        if (levelIndex < levels.length)
        {
            var level = levels[levelIndex]
            var columns = globalBackend.getLevelColumns(level)

            if (actionType === "preview")
            {
                replaceToolbar("Previewing ", testingContent[level].length, testingContent[level].length, itemIndex, actionType)

                if (itemIndex < testingContent[level].length)
                {
                    testLoader.active = false
                    testLoader.setSource("qrc:/Preview.qml", {"itemId": Object.keys(testingContent[level][itemIndex]).toString(), "testColumn": columns[0], "promptColumn": columns[1]})
                    testLoader.active = true
                    itemIndex++
                }
                else
                    rootStackView.pop()

                return
            }
            else if (actionType === "plant")
            {
                replaceToolbar("Planting ", uniqueItemCount, testingContent[level].length, itemIndex, actionType)
            }
            else if (actionType === "water")
            {
                var total = 0
                for (var testLevel in testingContent)
                    total += testingContent[testLevel].length

                replaceToolbar("Watering ", totalWateringItems, total, totalWateringIndex, actionType)
            }

            if (itemIndex < testingContent[level].length)
            {
                var itemId = Object.keys(testingContent[level][itemIndex]).toString()

                //Skip over this item if the user has requested a skip
                if (autoLearned.includes(itemId))
                {
                    itemIndex++
                    triggerNextItem()
                    return
                }

                //Random chance to switch test and prompt columns if the next test is multiple choice
                if (Math.random() < 0.5 && userSettings["enableTestPromptSwitch"] && testingContent[level][itemIndex][itemId] === TestType.MULTIPLECHOICE)
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

                testLoader.active = false
                switch (testingContent[level][itemIndex][itemId])
                {
                    case TestType.PREVIEW:
                        testLoader.setSource("qrc:/Preview.qml", variables)
                        break

                    case TestType.MULTIPLECHOICE:
                        testLoader.setSource("qrc:/MultipleChoice.qml", variables)
                        break

                    case TestType.TAPPING:
                        variables["tappingEnabled"] = true
                    case TestType.TYPING:
                        testLoader.setSource("qrc:/Typing.qml", variables)
                        break
                }

                testLoader.active = true
                itemIndex++
                totalWateringIndex++
            }
            else
            {
                levelIndex++
                autoLearned = []
                itemIndex = 0
                triggerNextItem()
            }
        }
        else
        {
            globalBackend.saveLevels()
            rootStackView.replace("qrc:/ResultSummary.qml", {"testingContent": testingContentOriginal, "correctAnswerCounter": correctAnswerCounter, "totalTests": (correctAnswerCounter + wrongAnswerCounter)})
        }
    }

    Loader {
        id: testLoader
        anchors.fill: parent
        active: false
        Component.onCompleted:
        {
            globalBackend.setStartTime()
            triggerNextItem()
        }
    }
}
