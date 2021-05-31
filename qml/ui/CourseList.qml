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
import QtQuick.Window 2.15
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ScrollablePage {

    function refreshAll()
    {
        globalBackend.getCourseList()
    }

    actions {
        main: Kirigami.Action {
            text: "Top"
            iconName: "arrow-up"
            onTriggered: courseList.positionViewAtBeginning()
        }
    }

    Component.onCompleted: refreshAll()

    Kirigami.Heading {
        id: courseListEmptyHeading
        text: "Your course list is empty. Download some courses or set your courses directory from the settings"
        level: 1
        anchors.fill: parent
        horizontalAlignment: Qt.AlignHCenter
        visible: false
    }

    Kirigami.CardsListView {
        id: courseList

        model: ListModel {id: courseListModel}

        delegate: Kirigami.AbstractCard {
            //NOTE: never put a Layout as contentItem as it will cause binding loops
            showClickFeedback: true

            onClicked: root.pageStack.push("qrc:/CourseInterior.qml", {
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

            contentItem: CourseExterior{}
        }
    }

    Connections {
        target: globalBackend
        function onAddCourse(directory, title, author, description, category, icon, items, planted, water, difficult, ignored, completed)
        {
            courseListModel.append({
                "directory": directory,
                "title": title,
                "author": author,
                "description": description,
                "category": category,
                "icon": icon,
                "items": items,
                "planted": planted,
                "water": water,
                "difficult": difficult,
                "ignored": ignored,
                "completed": completed
                                   })
        }

        function onFinishedAddingCourses()
        {
            if (courseListModel.count === 0)
                courseListEmptyHeading.visible = true
        }
    }
}
