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

    Component.onDestruction: globalBackend.unloadSeedbox()
    Component.onCompleted:
    {
        if (testType !== "preview")
        {
            //Change 5 to user amount

            //Create array of dicts for amount of tests, the item to test on and its test type
            for (var i = 0; i < itemArray.length; i++)
            {
                for (var o = 0; o < 5; o++)
                {
                    var myMap = {}
                    myMap[itemArray[i]] = TestType.TYPING //Math.floor(Math.random() * testTypes)
                    tests.push(myMap)
                }
            }
        }
    }

    function triggerNextItem()
    {
        if (testType === "preview")
        {
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
            var itemId = Object.keys(tests[itemIndex]).toString()

            testLoader.active = false
            switch (tests[itemIndex][itemId])
            {
                case TestType.TYPING:
                    testLoader.setSource("qrc:/Typing.qml", {"itemId": itemId, "testColumn": testColumn, "promptColumn": promptColumn})
                    break
            }
            testLoader.active = true
            itemIndex++
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
