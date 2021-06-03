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
import Memento.Backend 1.0

Kirigami.ApplicationWindow {

    property bool platformIsMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    id: root
    width: !platformIsMobile ? 1500 : undefined
    height: !platformIsMobile ? 1000 : undefined
    title: "Memento"

    property var userSettings: globalBackend.getUserSettings()

    property alias rootColor: root.color
    property alias rootPageStack: root.pageStack

    Item {
        id: signalSource
        visible: false
        signal openPreviousLevel(int currentIndex)
        signal openNextLevel(int currentIndex)
    }

    Backend {
        id: globalBackend
    }

    globalDrawer: Kirigami.GlobalDrawer {
        title: "Memento"
        isMenu: true
        titleIcon: "applications-graphics"
        actions: [
            Kirigami.Action {
                text: "Options"
                iconName: "games-config-options"
                onTriggered: root.pageStack.push("qrc:/Options.qml")
            }
        ]
    }

    pageStack.initialPage: CourseList{}

//    Component {
//        id: mainPageComponent

//        Kirigami.Page {
//            title: "Memento"

//             actions {
//                 main: Kirigami.Action {
//                     iconName: "go-home"
//                     onTriggered: showPassiveNotification("Main action triggered")
//                 }

//                 left: Kirigami.Action {
//                     icon.name: "go-previous"
//                     onTriggered: showPassiveNotification("Left action triggered")
//                 }
//                 right: Kirigami.Action {
//                     icon.name: "go-next"
//                     onTriggered: showPassiveNotification("Right action triggered")
//                 }
//                 contextualActions: [
//                     Kirigami.Action {
//                         text: "Contextual Action 1"
//                         icon.name: "bookmarks"
//                         onTriggered: showPassiveNotification("Contextual action 1 clicked")
//                     },
//                     Kirigami.Action {
//                         text: "Contextual Action 2"
//                         icon.name: "folder"
//                         enabled: false
//                     }
//                 ]
//             }
//        }
//    }
}
