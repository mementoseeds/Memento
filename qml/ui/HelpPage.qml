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
import QtQuick.Controls.Material 2.12

Item {
    property int marginBase: 10

    objectName: "HelpPage.qml"

    property string helpText: "## Useful shortcuts for PC\n
Escape - same as pressing back button in top right corner\n
Ctrl + p - open settings\n
Alt + r - refresh course list\n\n

### In any level\n
Left / Right arrow keys - move levels back and forward\n\n

### In learning levels\n
Enter / Return - start planting or watering session\n\n

### In preview
Left arrow - go back\n
Right arrow / Enter / Return - go forward\n\n

### During test\n
Alt + p - pause active test\n
Alt + a - auto learn item during planting\n
Number keys 1-8 - choose answer in multiple choice\n
Enter / Return - accept answer in typing tests\n
Enter / Return - skip cooldown and continue to next item after choosing an answer\n\n

## Learning details\n
To learn an item you must correctly answer it at least 5 times. Afterwards it will be marked as planted and its streak counter will become 1.\n
An item's streak counter determines its next watering (review) date in the following way:\n
1 = 5 hours\n
2 = 12 hours\n
3 = 24 hours\n
4 = 6 days\n
5 = 12 days\n
6 = 24 days\n
7 = 48 days\n
8 = 96 days\n
9 = 180 days\n
10 = 270 days\n
11 = 1 year\n
12 and above will result in 1 year again\n
When an item's review date arrives, answering it correctly will increment its streak and push back its next review date. If you choose incorrectly its streak will be reset to 1.
If you initiate a watering session while there are no items that need watering, choosing correctly will not increment the streak counter, but choosing incorrectly will still reset it to 1.\n
It is possible to initiate a \"Mock water\" session which starts a test for all items in a level, whether they are planted or not, and no progress is saved.\n\n

## Difficult items\n
You can see which items throughout an entire course are difficult by pressing the dropdown menu in a course and pressing \"Difficult\".
 In this page you can initiate a review of all difficult items or remove them.\n
It is also possible to view, mark and unmark certain items as difficult from the level themselves.\n
During a review of all difficult items, you must answer correctly 3 times for the item to be unmarked as difficult.
 If you answer incorrectly it will remain marked difficult until you start another review session."

    ScrollView {
        anchors.fill: parent
        contentWidth: root.width

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: marginBase
            anchors.rightMargin: marginBase
            spacing: marginBase

            Image {
                source: "assets/icons/icon.svg"
                sourceSize.height: 200
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: helpText
                font.pointSize: userSettings["defaultFontSize"]
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }
        }
    }
}
