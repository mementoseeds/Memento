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

import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12

Item {
    property int marginBase: 10

    width: root.width
    height: courseExteriorDelegate.height + marginBase * 2

    RowLayout {
        id: courseExteriorDelegate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: marginBase
        anchors.rightMargin: marginBase

        Image {
            id: courseImage
            source: "file:/" + icon
            Layout.maximumHeight: 120
            Layout.preferredWidth: height
            Layout.topMargin: marginBase
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width - courseImage.width
            spacing: 5

            Label {
                text: title
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.topMargin: marginBase
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: planted + " / " + items + " | " + water + " water " + difficult + " difficult"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            ProgressBar {
                id: courseProgressBar
                from: 0
                to: items
                value: planted
                indeterminate:  false
                Material.accent: completed ? globalBlue : globalGreen
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: parent.width / 1.1
            }

            Label {
                text: Math.floor(courseProgressBar.value / courseProgressBar.to * 100) + "%"
                Layout.alignment: Qt.AlignCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Button {
                    text: completed ? "Water" : "Plant"
                    icon.source: completed ? "assets/actions/water.svg" : "assets/actions/plant.svg"
                    Material.background: completed ? globalBlue : globalGreen
                    onClicked: showPassiveNotification("Todo")
                }

                Button {
                    text: "Refresh"
                    Material.background: globalOrange
                    icon.source: "assets/actions/refresh.svg"
                    onClicked:
                    {
                        globalBackend.refreshCourse(directory)
                        reloadCourseList()
                    }
                }
            }
        }
    }

    Rectangle {
        id: itemBackground
        height: parent.height - marginBase
        width: parent.width - marginBase
        x: marginBase / 2
        color: "transparent"
        border.width: 1
        border.color: "gray"
        radius: 10
        z: -1

        Behavior on color {
            ColorAnimation {duration: 200}
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: itemBackground.color = "#3F51B5"
        onExited: itemBackground.color = "transparent"
        onClicked:
        {
            mainToolbarTitle.text = title
            rootStackView.push("qrc:/CourseInterior.qml", {
                        "directory": directory,
                        "courseTitle": title,
                        "author": author,
                        "description": description,
                        "category": category,
                        "icon": icon,
                        "items": items,
                        "planted": planted,
                        "water": water,
                        "difficult": difficult,
                        "ignored": ignored
                            })
        }
    }
}
