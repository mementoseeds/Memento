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
import TestType 1.0

Kirigami.Page {
    property string courseDirectory: ""
    property var itemArray: []
    property string testType: ""
    property int previewIndex: 0

    Component.onCompleted: globalBackend.loadSeedbox(courseDirectory)
    Component.onDestruction: globalBackend.unloadSeedbox()

    function triggerNextItem()
    {
        if (testType === "preview")
        {
            if (previewIndex !== itemArray.length - 1)
            {
                testLoader.active = false
                testLoader.setSource("qrc:/Preview.qml", {"itemId": itemArray[previewIndex]})
                testLoader.active = true
                previewIndex++
            }
            else
                console.debug("reached end")
        }
    }

    Loader {
        id: testLoader
        anchors.fill: parent
        active: false
        Component.onCompleted: triggerNextItem()
    }
}
