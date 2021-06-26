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

Item {
    objectName: "ResultSummary.qml"
    property int marginBase: 10

    property string courseDirectory: ""
    property var testingContent: ({})
    property int correctAnswerCounter: 0
    property int totalTests: 0

    property var levels: []

    Component.onCompleted:
    {
        levels = Object.keys(testingContent)
        for (var level in levels)
        {
            var itemArray = testingContent[levels[level]]
            globalBackend.getSessionResults(levels[level], itemArray)
        }
    }

    Component.onDestruction:
    {
        signalSource.reloadLearningLevel()
        signalSource.refreshCourseLevels()
    }

    ListView {
        anchors.fill: parent
        spacing: 20
        ScrollBar.vertical: ScrollBar {width: 10}

        header: ColumnLayout {
            width: parent.width

            Label {
                text: "Session complete!"
                font.pointSize: 15
                font.bold: true
                Layout.alignment: Qt.AlignCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: "Correct answers:"
                    font.pointSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                Label {
                    text: correctAnswerCounter + " of " + totalTests
                    font.pointSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignRight
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: "Speed:"
                    font.pointSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                Label {
                    text: globalBackend.getStopTime()
                    font.pointSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignRight
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: "Accuracy:"
                    font.pointSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignLeft
                }

                Label {
                    text: Math.floor(correctAnswerCounter / totalTests * 100) + "%"
                    font.pointSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignRight
                }
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
                    Layout.rightMargin: marginBase * -1
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

                Label {
                    text: "Accuracy"
                    font.pointSize: 12
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignLeft
                    Layout.preferredWidth: parent.Layout.preferredWidth / 3 / 2
                }

                Label {
                    text: "Streak"
                    font.pointSize: 12
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignLeft
                    Layout.preferredWidth: parent.Layout.preferredWidth / 3 / 2
                }
            }

            Rectangle {
                height: 1
                Layout.preferredWidth: parent.width
                Layout.bottomMargin: marginBase * 2
            }
        }

        model: ListModel {id: resultsListView}

        delegate: ResultEntry {}
    }

    Connections {
        target: globalBackend
        function onAddItemResults(testData, testDataType, promptData, promptDataType, successes, failures, streak)
        {
            resultsListView.append({"testData": testData, "testDataType": testDataType, "promptData": promptData, "promptDataType": promptDataType, "successes": successes, "failures": failures, "streak": streak})
        }
    }
}
