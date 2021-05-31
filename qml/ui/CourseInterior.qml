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
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15

Kirigami.ScrollablePage {

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

    Component.onDestruction: signalSource.courseClosed()
    Component.onCompleted:
    {
        signalSource.courseOpened()
        globalBackend.getCourseLevels(directory)
    }

    actions {
        main: Kirigami.Action {
            text: "Close"
            iconName: "dialog-close"
            shortcut: "Escape"
            onTriggered: rootPageStack.pop()
        }
        right: Kirigami.Action {
            text: "Info"
            iconName: "documentinfo"
            onTriggered: showPassiveNotification("Info Stuff")
        }
    }

    Kirigami.CardsGridView {

        header: ColumnLayout {
            width: parent.width

            Kirigami.Heading {
                id: courseTitleHeading
                text: courseTitle
                font.bold: true
                level: 1
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            Kirigami.Heading {
                text: "Created by " + author
                level: 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Kirigami.Heading {
                text: category
                level: 3
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

            Kirigami.Heading {
                text: description
                level: 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.bottomMargin: Kirigami.Units.largeSpacing
            }

            Rectangle {
                color: "gray"
                height: 2
                Layout.fillWidth: true
                radius: 50
            }

            Kirigami.Heading {
                text: "Levels (" + courseLevelsListModel.count + ")"
                font.bold: true
                level: 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.bottomMargin: Kirigami.Units.largeSpacing * 2
            }
        }

        model: ListModel {id: courseLevelsListModel}

        delegate: Kirigami.AbstractCard {
            showClickFeedback: true

            onClicked:
            {
                if (levelPath.endsWith(".json"))
                    rootPageStack.push("qrc:/LearningLevelView.qml", {"levelPath": levelPath, "levelNumber": (index + 1), "levelTitle": levelTitle, "itemAmount": itemAmount, "levelCompleted": levelCompleted})
                else if (levelPath.endsWith(".md"))
                    rootPageStack.push("qrc:/MediaLevel.qml", {"levelTitle": levelTitle, "levelNumber": (index + 1), "levelContent": globalBackend.readMediaLevel(levelPath)})
            }

            contentItem: CourseLevelExterior{}
        }
    }

    Connections {
        target: globalBackend
        function onAddCourseLevel(levelPath, levelTitle, isLearning, itemAmount, levelCompleted)
        {
            courseLevelsListModel.append({
                "levelPath": levelPath,
                "levelTitle": levelTitle,
                "isLearning": isLearning,
                "itemAmount": itemAmount,
                "levelCompleted": levelCompleted
                                         })
        }
    }

    Connections {
        target: signalSource
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
