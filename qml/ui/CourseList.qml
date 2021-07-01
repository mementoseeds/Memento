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
    objectName: "CourseList.qml"

    function reloadCourseList()
    {
        courseListModel.clear()
        globalBackend.getCourseList()
    }

    function refreshCourses()
    {
        var courses = []
        for (var i = 0; i < courseListModel.count; i++)
            courses.push(courseListModel.get(i).directory)

        globalBackend.refreshCourses(courses)
    }

    Component.onCompleted:
    {
        globalBackend.getCourseList()

        if (userSettings["autoRefreshCourses"])
            signalSource.refreshAllCourses()
    }

    Shortcut {
        sequence: "Home"
        enabled: rootStackView.currentItem.objectName === "CourseList.qml"
        onActivated: courseList.positionViewAtBeginning()
    }

    Shortcut {
        sequence: "End"
        enabled: rootStackView.currentItem.objectName === "CourseList.qml"
        onActivated: courseList.positionViewAtEnd()
    }

    Label {
        id: courseListEmptyHeading
        text: "Your course list is empty. Download some courses or set your courses directory from the settings"
        anchors.fill: parent
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        visible: false
    }

    ListView {
        id: courseList
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}

        header: Item {height: 20}

        model: ListModel {id: courseListModel}

        delegate: CourseExterior {}
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

        function onFinishedRefreshingCourses()
        {
            reloadCourseList()
        }
    }

    Connections {
        target: signalSource
        function onRefreshAllCourses()
        {
            refreshCourses()
        }
    }
}
