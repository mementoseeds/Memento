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
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.12

Item {
    objectName: "CourseInterior.qml"
    property int marginBase: 10

    property string directory: ""
    property string courseTitle: ""
    property string author: ""
    property string description: ""
    property string category: ""
    property string icon: ""
    property int items: 0
    property int planted: 0
    property int water: 0
    property int difficult: 0
    property int ignored: 0
    property bool completed: false

    Component.onCompleted:
    {
        globalBackend.getCourseLevels(directory)
        globalBackend.loadSeedbox(directory)
    }

    Component.onDestruction: mainToolbarTitle.text = root.title

    function plantAction()
    {
        var levelVariables = globalBackend.getFirstIncompleteLevel(directory)
        if (Object.keys(levelVariables).length !== 0)
            rootStackView.push("qrc:/LearningLevelView.qml", levelVariables)
        else
            showPassiveNotification("This course is already completed")
    }

    function waterAction()
    {
        var wateringData = globalBackend.getCourseWideWateringItems(directory, userSettings["maxWateringItems"])
        if (Object.keys(wateringData).length !== 0)
                rootStackView.push("qrc:/StagingArea.qml", {"courseDirectory": directory, "testingContentOriginal": wateringData["testingContentOriginal"],
                    "actionType": "water", "manualReview": wateringData["manualReview"], "totalWateringItems": wateringData["totalItems"]})
        else
            showPassiveNotification("This course has no planted items")
    }

    Shortcut {
        sequence: "Home"
        enabled: rootStackView.currentItem.objectName === "CourseInterior.qml"
        onActivated: levelsGridView.positionViewAtBeginning()
    }

    Shortcut {
        sequence: "End"
        enabled: rootStackView.currentItem.objectName === "CourseInterior.qml"
        onActivated: levelsGridView.positionViewAtEnd()
    }

    GridView {
        id: levelsGridView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{width: 10}
        maximumFlickVelocity: 6000
        cellWidth: 300
        cellHeight: cellWidth

        header: ColumnLayout {
            width: parent.width

            ColumnLayout {
                Layout.leftMargin: marginBase
                Layout.rightMargin: marginBase

                Label {
                    id: courseTitleHeading
                    text: courseTitle
                    font.pointSize: userSettings["defaultFontSize"]
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    text: "Created by " + author
                    font.pointSize: userSettings["defaultFontSize"]
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    text: category
                    font.pointSize: userSettings["defaultFontSize"]
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Image {
                    source: Qt.resolvedUrl("file:/" + icon)
                    sourceSize.height: 200
                    sourceSize.width: 200
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: description
                    font.pointSize: userSettings["defaultFontSize"]
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.bottomMargin: 20
                }

                Rectangle {
                    color: "gray"
                    height: 2
                    Layout.fillWidth: true
                    radius: 50
                }

                Label {
                    text: "Levels (" + courseLevelsListModel.count + ")"
                    font.pointSize: userSettings["defaultFontSize"]
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                RowLayout {
                    Layout.preferredWidth: parent.width
                    Layout.bottomMargin: 20

                    ComboBox {
                        model: ["Plant", "Water", "Difficult", "Auto learn", "Reset"]
                        onActivated:
                        {
                            switch (currentText)
                            {
                                case "Plant":
                                    plantAction()
                                    break

                                case "Water":
                                    waterAction()
                                    break

                                case "Difficult":
                                    rootStackView.push("qrc:/DifficultView.qml", {"courseDirectory": directory, "courseTitle": courseTitle, "items": items, "difficult": difficult})
                                    break

                                case "Auto learn":
                                    rootStackView.push("qrc:/AdvancedAutoLearn.qml", {"courseDirectory": directory})
                                    break

                                case "Reset":
                                    resetCourseMessageBox.visible = true
                                    break
                            }
                        }
                    }

                    Button {
                        text: completed ? "Water" : "Plant"
                        icon.source: completed ? "assets/icons/water.svg" : "assets/icons/plant.svg"
                        Material.background: completed ? globalBlue : globalGreen
                        Layout.alignment: Qt.AlignRight
                        onClicked: text === "Plant" ? plantAction() : waterAction()
                    }
                }

                RowLayout {
                    Layout.preferredWidth: parent.width

                    Label {
                        text: planted + " / " + items + " planted | " + water + " water | " + difficult + " difficult"
                        font.pointSize: userSettings["defaultFontSize"]
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.alignment: Qt.AlignLeft
                    }

                    Label {
                        text: ignored + " ignored"
                        font.pointSize: userSettings["defaultFontSize"]
                        font.bold: true
                        horizontalAlignment: Text.AlignRight
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.alignment: Qt.AlignRight
                    }
                }

                ProgressBar {
                    id: courseProgressBar
                    from: 0
                    to: items
                    value: planted + ignored
                    indeterminate:  false
                    Material.accent: completed ? globalBlue : globalGreen
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                }

                Label {
                    text: Math.floor(courseProgressBar.value / courseProgressBar.to * 100) + "%"
                    font.pointSize: userSettings["defaultFontSize"]
                    Layout.alignment: Qt.AlignCenter
                    Layout.bottomMargin: 40
                }
            }
        }

        model: ListModel {id: courseLevelsListModel}

        delegate: CourseLevelExterior {}
    }

    Connections {
        target: globalBackend
        function onAddCourseLevel(levelPath, levelTitle, testColumn, promptColumn, testColumnType, promptColumnType, isLearning, itemAmount, levelCompleted)
        {
            courseLevelsListModel.append({
                "levelPath": levelPath,
                "levelTitle": levelTitle,
                "testColumn": testColumn,
                "promptColumn": promptColumn,
                "testColumnType": testColumnType,
                "promptColumnType": promptColumnType,
                "isLearning": isLearning,
                "itemAmount": itemAmount,
                "levelCompleted": levelCompleted
                                         })
        }
    }

    Connections {
        target: signalSource
        function onRefreshCourseLevels()
        {
            courseLevelsListModel.clear()
            globalBackend.getCourseLevels(directory)
        }
    }

    MessageDialog {
        id: resetCourseMessageBox
        icon: StandardIcon.Question
        title: "Reset course?"
        text: "Are you sure you want to reset the entire course?"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes:
        {
            globalBackend.advancedAutoLevelAdjust(false, directory, 1, globalBackend.getCourseLevelAmount(directory), 1, false)
            globalBackend.refreshCourses([directory])
            rootStackView.pop(null)
        }
    }
}
