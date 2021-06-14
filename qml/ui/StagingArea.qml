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
    property string courseDirectory: ""
    property var itemArray: []
    property string testType: ""
    property string testColumn: ""
    property string promptColumn: ""

    property int itemIndex: 0
    property var tests: []

    Component.onDestruction:
    {
        globalBackend.unloadSeedbox()
        restoreToolbar(globalBackend.readCourseTitle(courseDirectory))
    }

    Component.onCompleted:
    {
        if (testType === "plant")
        {
            //Create array of dicts for amount of tests, the item to test on and its test type
            for (var i = 0; i < itemArray.length; i++)
            {
                var myMap = {}
                myMap[itemArray[i]] = TestType.PREVIEW
                tests.push(myMap)

                myMap = {}
                myMap[itemArray[i]] = TestType.TYPING //Start all with multiple choice
                tests.push(myMap)
            }

            var unorderedTests = []
            for (i = 0; i < itemArray.length; i++)
            {
                for (var o = 0; o < 4; o++) //4 is amount of tests - 1
                {
                    myMap = {}
                    myMap[itemArray[i]] = TestType.TYPING //Math.floor(Math.random() * testTypes)
                    unorderedTests.push(myMap)
                }
            }

            unorderedTests.sort(() => Math.random() - 0.5) //Shuffle unorderedTests
            tests = tests.concat(unorderedTests)
            delete unorderedTests
        }
    }

    function triggerNextItem()
    {
        if (testType === "preview")
        {
            replaceToolbar("Previewing ", itemArray.length, itemArray.length, itemIndex)

            if (itemIndex !== itemArray.length)
            {
                testLoader.active = false
                testLoader.setSource("qrc:/Preview.qml", {"itemId": itemArray[itemIndex], "testColumn": testColumn, "promptColumn": promptColumn})
                testLoader.active = true
                itemIndex++
            }
            else
                rootStackView.pop()
        }
        else if (testType === "plant")
        {
            if (itemIndex !== tests.length)
            {
                replaceToolbar("Planting ", itemArray.length, tests.length, itemIndex)

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
                console.debug("Reached end")
                //Show results screen
                rootStackView.pop()
            }
        }
    }

    Loader {
        id: testLoader
        anchors.fill: parent
        active: false
        Component.onCompleted:
        {
            globalBackend.loadSeedbox(courseDirectory)
            triggerNextItem()
        }
    }
}
