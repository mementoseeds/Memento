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
    property string levelPath: ""
    property var itemArray: []
    property string actionType: ""
    property string testColumn: ""
    property string promptColumn: ""
    property bool manualReview: false

    property int itemIndex: 0
    property var tests: []
    property int correctAnswerCounter: 0
    property int wrongAnswerCounter: 0

    Component.onDestruction: restoreToolbar(globalBackend.readCourseTitle(courseDirectory))

    Component.onCompleted:
    {
        if (actionType === "plant")
        {
            //Create array of dicts for amount of tests, the item to test on and its test type
            for (var i = 0; i < itemArray.length; i++)
            {
                var test = {}
                test[itemArray[i]] = TestType.PREVIEW
                tests.push(test)

                test = {}
                test[itemArray[i]] = TestType.TYPING //Start all with multiple choice
                tests.push(test)
            }

            var unorderedTests = []
            for (i = 0; i < itemArray.length; i++)
            {
                for (var o = 0; o < 4; o++) //4 is amount of tests - 1
                {
                    test = {}
                    test[itemArray[i]] = TestType.TYPING //Math.floor(Math.random() * testTypes)
                    unorderedTests.push(test)
                }
            }

            unorderedTests.sort(() => Math.random() - 0.5) //Shuffle unorderedTests
            tests = tests.concat(unorderedTests)
            delete unorderedTests
        }
        else if (actionType === "water")
        {
            for (i = 0; i < itemArray.length; i++)
            {
                test = {}
                test[itemArray[i]] = TestType.TYPING //Math.floor(Math.random() * testTypes)
                tests.push(test)
            }

            tests.sort(() => Math.random() - 0.5)
        }
    }

    function triggerNextItem()
    {
        if (actionType !== "preview")
        {
            //Random chance to switch test and prompt columns
            if (Math.random() < 0.5)
            {
                var tempColumn = stagingArea.testColumn
                var testColumn = stagingArea.promptColumn
                var promptColumn = tempColumn
                delete tempColumn
            }
            else
            {
                testColumn = stagingArea.testColumn
                promptColumn = stagingArea.promptColumn
            }
        }

        if (actionType === "preview")
        {
            replaceToolbar("Previewing ", itemArray.length, itemArray.length, itemIndex, actionType)

            if (itemIndex !== itemArray.length)
            {
                testLoader.active = false
                testLoader.setSource("qrc:/Preview.qml", {"itemId": itemArray[itemIndex], "testColumn": stagingArea.testColumn, "promptColumn": stagingArea.promptColumn})
                testLoader.active = true
                itemIndex++
            }
            else
                rootStackView.pop()
        }
        else if (actionType === "plant")
        {
            if (itemIndex !== tests.length)
            {
                replaceToolbar("Planting ", itemArray.length, tests.length, itemIndex, actionType)

                var itemId = Object.keys(tests[itemIndex]).toString()
                var variables = {"itemId": itemId, "testColumn": testColumn, "promptColumn": promptColumn}

                testLoader.active = false
                switch (tests[itemIndex][itemId])
                {
                    case TestType.PREVIEW:
                        testLoader.setSource("qrc:/Preview.qml", variables)
                        break

                    case TestType.TYPING:
                        testLoader.setSource("qrc:/Typing.qml", variables)
                        break
                }
                testLoader.active = true
                itemIndex++
            }
            else
            {
                globalBackend.saveLevel(levelPath)
                rootStackView.replace("qrc:/ResultSummary.qml", {"courseDirectory": courseDirectory, "levelPath": levelPath, "itemArray": itemArray,
                    "testColumn": stagingArea.testColumn, "promptColumn": stagingArea.promptColumn, "correctAnswerCounter": correctAnswerCounter,
                    "totalTests": (correctAnswerCounter + wrongAnswerCounter)})
            }
        }
        else if (actionType === "water")
        {
            if (itemIndex !== tests.length)
            {
                replaceToolbar("Watering ", itemArray.length, tests.length, itemIndex, actionType)

                itemId = Object.keys(tests[itemIndex]).toString()
                variables = {"itemId": itemId, "testColumn": testColumn, "promptColumn": promptColumn}

                testLoader.active = false
                switch (tests[itemIndex][itemId])
                {
                    case TestType.PREVIEW:
                        testLoader.setSource("qrc:/Preview.qml", variables)
                        break

                    case TestType.TYPING:
                        testLoader.setSource("qrc:/Typing.qml", variables)
                        break
                }
                testLoader.active = true
                itemIndex++
            }
            else
            {
                globalBackend.saveLevel(levelPath)
                rootStackView.replace("qrc:/ResultSummary.qml", {"courseDirectory": courseDirectory, "levelPath": levelPath, "itemArray": itemArray,
                    "testColumn": stagingArea.testColumn, "promptColumn": stagingArea.promptColumn, "correctAnswerCounter": correctAnswerCounter,
                    "totalTests": (correctAnswerCounter + wrongAnswerCounter)})
            }
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
