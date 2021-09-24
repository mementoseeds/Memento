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
import QtQuick.Controls.Material 2.12

Item {
    objectName: "DifficultView.qml"
    property int marginBase: 10

    property string courseDirectory: ""
    property string courseTitle: ""
    property int items: 0

    Component.onCompleted: globalBackend.getCourseDifficultItems(courseDirectory)

    function difficultAction()
    {
        var testingContentOriginal = {}
        var totalItems = Math.min(userSettings["maxDifficultItems"], difficultListModel.count)

        if (totalItems === 0)
        {
            showPassiveNotification("There are no difficult items")
            return
        }

        for (var i = 0;  i < totalItems; i++)
        {
            var item = difficultListModel.get(i)

            if (testingContentOriginal.hasOwnProperty(item.levelPath))
                testingContentOriginal[item.levelPath].push(item.id)
            else
            {
                testingContentOriginal[item.levelPath] = []
                testingContentOriginal[item.levelPath].push(item.id)
            }
        }

        rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": courseDirectory, "testingContentOriginal": testingContentOriginal, "actionType": "difficult", "difficultReview": true, "totalWateringItems": totalItems})
    }

    ListView {
        anchors.fill: parent
        spacing: 20
        ScrollBar.vertical: ScrollBar {width: 10}

        header: ColumnLayout {
            width: parent.width

            Shortcut {
                sequences: ["Enter", "Return"]
                enabled: rootStackView.currentItem.objectName !== "StagingArea.qml" && rootStackView.currentItem.objectName !== "ResultSummary.qml"
                onActivated: reviewButton.clicked()
            }

            ColumnLayout {
                Layout.topMargin: marginBase
                Layout.leftMargin: marginBase
                Layout.rightMargin: marginBase

                Label {
                    text: difficultIcon + " " + courseTitle + " difficult items " + difficultIcon
                    font.family: "Icons"
                    font.pointSize: userSettings["defaultFontSize"]
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.preferredWidth: parent.width
                    Layout.alignment: Qt.AlignCenter
                }

                ProgressBar {
                    id: difficultProgressBar
                    from: 0
                    to: items
                    value: 0
                    indeterminate:  false
                    Material.accent: globalAmber
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                }

                Label {
                    id: difficultCountLabel
                    text: "X" + " of " + items
                    font.pointSize: userSettings["defaultFontSize"]
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    id: reviewButton
                    text: "Review"
                    icon.source: "assets/icons/difficult.svg"
                    Material.background: Material.color(Material.Amber, Material.Shade700)
                    Layout.alignment: Qt.AlignRight
                    onClicked: difficultAction()
                }

                RowLayout {
                    Layout.preferredWidth: parent.width
                    Layout.topMargin: marginBase

                    Label {
                        text: "Test"
                        font.pointSize: 12
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignLeft
                        Layout.leftMargin: marginBase
                        Layout.preferredWidth: parent.Layout.preferredWidth / 3
                    }

                    Label {
                        text: "Prompt"
                        font.pointSize: 12
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignLeft
                        Layout.preferredWidth: parent.Layout.preferredWidth / 3
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    Layout.bottomMargin: marginBase
                }
            }

            Connections {
                target: globalBackend

                function onFinishedGetDifficultItemInfo()
                {
                    difficultProgressBar.value = difficultListModel.count
                    difficultCountLabel.text = difficultListModel.count + " of " + items
                }
            }
        }

        model: ListModel {id: difficultListModel}

        delegate: DifficultEntry {}
    }

    Connections {
        target: globalBackend

        function onAddDifficultItem(levelPath, id, test, prompt, testColumnType, promptColumnType)
        {
            difficultListModel.append({
                "levelPath": levelPath,
                "id": id,
                "test": test,
                "prompt": prompt,
                "testColumnType": testColumnType,
                "promptColumnType": promptColumnType,
                "difficult": true})
        }
    }

    Connections {
        target: signalSource

        function onReloadDifficultView()
        {
            difficultListModel.clear()
            globalBackend.getCourseDifficultItems(courseDirectory)
        }
    }
}
