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

    Component.onCompleted: globalBackend.getCourseLevels(directory)
    Component.onDestruction:
    {
        mainToolbarTitle.text = root.title
        globalBackend.unloadSeedbox()
    }

    GridView {
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
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    text: "Created by " + author
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    text: category
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
                    font.bold: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                RowLayout {
                    Layout.bottomMargin: 40

                    ComboBox {
                        model: ["Debug"]
                        onActivated: signalSource.refreshCourseLevels()
                    }

                    Label {
                        text: ""
                        Layout.fillWidth: true
                    }

                    Button {
                        text: completed ? "Water" : "Plant"
                        icon.source: completed ? "assets/actions/water.svg" : "assets/actions/plant.svg"
                        Material.background: completed ? globalBlue : globalGreen
                        onClicked: showPassiveNotification("Todo")
                    }
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

        function onOpenPreviousLevel(currentIndex)
        {
            if (currentIndex !== 0)
            {
                //rootPageStack.pop()
                var newLevelPath = courseLevelsListModel.get(currentIndex - 1).levelPath
                console.debug(newLevelPath)
//                if (newLevelPath.endsWith(".json"))
//                    rootPageStack.push("qrc:/LearningLevelView.qml", {"levelPath": levelPath})
//                else if (newLevelPath.endsWith(".md"))
//                    rootPageStack.push("qrc:/MediaLevel.qml", {"levelTitle": levelTitle, "levelNumber": (index + 1), "levelContent": globalBackend.readMediaLevel(levelPath)})
            }
        }
    }
}
