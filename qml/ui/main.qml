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
    id: root
    title: "Memento"

    property alias rootColor: root.color
    property alias rootPageStack: root.pageStack

    Item {
        id: signalsSource
        visible: false
        signal courseOpened()
        signal courseClosed()
    }

    Backend {
        id: globalBackend
    }

    //Component.onCompleted: globalBackend.debugFun()

    globalDrawer: Kirigami.GlobalDrawer {
        title: "Memento"
        titleIcon: "applications-graphics"
        actions: [
            Kirigami.Action {
                text: "View"
                iconName: "view-list-icons"
                Kirigami.Action {
                    text: "View Action 1"
                    onTriggered: showPassiveNotification("View Action 1 clicked")
                }
                Kirigami.Action {
                    text: "View Action 2"
                    onTriggered: showPassiveNotification("View Action 2 clicked")
                }
            },
            Kirigami.Action {
                text: "Action 1"
                onTriggered: showPassiveNotification("Action 1 clicked")
            },
            Kirigami.Action {
                text: "Action 2"
                onTriggered: showPassiveNotification("Action 2 clicked")
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
