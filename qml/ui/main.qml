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
import Memento.Backend 1.0
import QtQuick.Controls.Material 2.12

ApplicationWindow {

    Component.onCompleted:
    {
        globalBackend.debugFun()
        globalBackend.setGlobalBackendInstance()
    }

    property bool platformIsMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    id: root
    visible: true
    width: !platformIsMobile ? 1500 : undefined
    height: !platformIsMobile ? 1000 : undefined
    title: "Memento"
    color: "#333333"
    Material.theme: Material.Dark

    property var userSettings: globalBackend.getUserSettings()

    function showPassiveNotification(text, duration)
    {
        passiveNotification.show(text, duration)
    }

    function replaceToolbar(text, amount, total, progress)
    {
        mainToolbarTitle.horizontalAlignment = Qt.AlignLeft
        mainToolbarTitle.text = text + amount + " seeds"
        mainToolbarTitle.Layout.fillWidth = false

        toolbarProgressBar.visible = true
        toolbarProgressBar.to = total
        toolbarProgressBar.value = progress
    }

    function restoreToolbar(text)
    {
        mainToolbarTitle.horizontalAlignment = Qt.AlignHCenter
        mainToolbarTitle.text = text
        mainToolbarTitle.Layout.fillWidth = true
        toolbarProgressBar.visible = false
    }

    Item {
        id: signalSource
        visible: false
        signal openPreviousLevel(int currentIndex)
        signal openNextLevel(int currentIndex)
    }

    Backend {
        id: globalBackend
    }

    Timer {
        id: closeTimer
        interval: 2000
        running: false
        repeat: false
    }

    Shortcut {
        sequences: ["Esc", "Back"]
        onActivated: backButton.clicked()
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                icon.source: "assets/actions/open-menu-symbolic.svg"
                display: AbstractButton.IconOnly
                onClicked:
                {
                    mainMenuBar.x = this.x
                    mainMenuBar.y = this.y + 40
                    mainMenuBar.open()
                }
            }

            Label {
                id: mainToolbarTitle
                text: "Course List"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            ProgressBar {
                id: toolbarProgressBar
                visible: false
                from: 0
                to: 0
                value: 0
                indeterminate:  false
                Layout.fillWidth: true
            }

            ToolButton {
                id: backButton
                icon.source: "assets/actions/go-previous.svg"
                display: AbstractButton.IconOnly
                onClicked:
                {
                    if (platformIsMobile)
                    {
                        if (rootStackView.depth > 1)
                            rootStackView.pop()
                        else if (rootStackView.depth === 1)
                            if (!closeTimer.running)
                            {
                                closeTimer.start()
                                showPassiveNotification("Press back again to quit", closeTimer.interval)
                            }
                            else
                                Qt.quit()
                    }
                    else
                        rootStackView.pop()
                }
            }
        }

        Menu {
            id: mainMenuBar
            Action {
                text: "&Options"
                icon.source: "assets/actions/configure.svg"
                shortcut: "Ctrl+p"
                onTriggered:
                {
                    if (rootStackView.currentItem.objectName !== "Options.qml")
                        rootStackView.push("qrc:/Options.qml")
                }
            }
        }
    }

    StackView {
        id: rootStackView
        anchors.fill: parent
        initialItem: CourseList{}

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

    Connections {
        target: globalBackend
        function onShowPassiveNotification(text, duration)
        {
            showPassiveNotification(text, duration)
        }
    }

    PassiveNotification {id: passiveNotification}
}
