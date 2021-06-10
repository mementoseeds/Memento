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
    property int previewIndex: 0

    Component.onDestruction: globalBackend.unloadSeedbox()

    function triggerNextItem()
    {
        if (testType === "preview")
        {
            if (previewIndex !== itemArray.length)
            {
                testLoader.active = false
                testLoader.setSource("qrc:/Preview.qml", {"itemId": itemArray[previewIndex], "testColumn": testColumn, "promptColumn": promptColumn})
                testLoader.active = true
                previewIndex++
            }
            else
                rootStackView.pop()
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
