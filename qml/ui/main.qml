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
import QtQuick.Controls 2.15
import Memento.Backend 1.0
import QtQuick.Controls.Material 2.12

ApplicationWindow {

    property bool platformIsMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    id: root
    visible: true
    width: !platformIsMobile ? 1500 : undefined
    height: !platformIsMobile ? 1000 : undefined
    title: "Memento"
    color: "#333333"
    Material.theme: Material.Dark

    property var userSettings: globalBackend.getUserSettings()

    Item {
        id: signalSource
        visible: false
        signal openPreviousLevel(int currentIndex)
        signal openNextLevel(int currentIndex)
    }

    Backend {
        id: globalBackend
    }

    StackView {
        id: rootStackView
        anchors.fill: parent
        initialItem: Options{}

        pushEnter: Transition {
               PropertyAnimation {
                   property: "opacity"
                   from: 0
                   to: 1
                   duration: 100
               }
           }
       pushExit: Transition {
           PropertyAnimation {
               property: "opacity"
               from: 1
               to: 0
               duration: 100
           }
       }
       popEnter: Transition {
           PropertyAnimation {
               property: "opacity"
               from: 0
               to: 1
               duration: 100
           }
       }
       popExit: Transition {
           PropertyAnimation {
               property: "opacity"
               from: 1
               to: 0
               duration: 100
           }
       }
    }
}
