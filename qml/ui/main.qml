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
import QtQuick.Dialogs 1.3

ApplicationWindow {
    id: root
    visible: true
    width: !platformIsMobile ? 1500 : undefined
    height: !platformIsMobile ? 1000 : undefined
    title: "Memento"
    color: "#333333"
    Material.theme: Material.Dark

    Component.onCompleted:
    {
        globalBackend.debugFun()
        globalBackend.setGlobalBackendInstance()
    }

    property var userSettings: globalBackend.getUserSettings()
    property bool platformIsMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    //Colors
    property color defaultMaterialAccept: globalBlue
    property color globalBlue: Material.color(Material.Indigo)
    property color globalGreen: Material.color(Material.Green)
    property color globalRed: Material.color(Material.Red)
    property color globalOrange: Material.color(Material.DeepOrange, Material.Shade400)
    property color defaultToolbarColor: Material.color(Material.Teal)
    property var testColor: {"plant": globalGreen, "water": globalBlue}

    //Icon font
    property string difficultIcon: "\ue900"
    property string plantIcon: "\ue901"
    property string waterIcon: "\ue902"

    FontLoader {
        source: "assets/icons-font/Icons.ttf"
    }

    Item {
        id: signalSource
        visible: false
        signal reloadLearningLevel()
        signal refreshCourseLevels()
        signal refreshAllCourses()
        signal openPreviousLevel(int currentIndex)
        signal openNextLevel(int currentIndex)
    }

    function showPassiveNotification(text, duration)
    {
        passiveNotification.show(text, duration)
    }

    function replaceToolbar(text, amount, total, progress, actionType)
    {
        mainToolbarTitle.horizontalAlignment = Qt.AlignLeft
        mainToolbarTitle.text = text + amount + " seeds"
        mainToolbarTitle.Layout.fillWidth = false

        toolbarProgressBar.visible = true
        toolbarProgressBar.to = total
        toolbarProgressBar.value = progress

        switch (actionType)
        {
            case "preview":
                toolbarProgressBar.Material.accent = "#00FFE7"
                break
            case "plant":
                toolbarBackground.color = globalGreen
                toolbarProgressBar.Material.accent = "#00FB0A"
                break
            case "water":
                toolbarBackground.color = globalBlue
                toolbarProgressBar.Material.accent = "#00BCD4"
                break
        }
    }

    function restoreToolbar(text)
    {
        mainToolbarTitle.horizontalAlignment = Qt.AlignHCenter
        mainToolbarTitle.text = text
        mainToolbarTitle.Layout.fillWidth = true
        toolbarProgressBar.visible = false
        toolbarBackground.color = defaultToolbarColor
    }

    function findPageIndex(name)
    {
        for (var i = 0; i < rootStackView.depth; i++)
            if (rootStackView.get(i).objectName === name)
                return i
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
        background: Rectangle {
            id: toolbarBackground
            color: defaultToolbarColor
        }

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
                    if (rootStackView.currentItem.objectName === "StagingArea.qml")
                    {
                        confirmActionDialog.open()
                        return
                    }

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
                enabled: rootStackView.currentItem.objectName !== "StagingArea.qml"
                onTriggered:
                {
                    if (rootStackView.currentItem.objectName !== "Options.qml")
                        rootStackView.push("qrc:/Options.qml")
                }
            }

            Action {
                text: "&Refresh courses"
                icon.source: "assets/actions/refresh.svg"
                shortcut: "Alt+r"
                enabled: rootStackView.depth === 1
                onTriggered: signalSource.refreshAllCourses()
            }

            Action {
                text: "debug"
                onTriggered: console.debug(rootStackView.currentItem.objectName)
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

    MessageDialog {
        id: confirmActionDialog
        icon: StandardIcon.Question
        title: "Are you sure you want to go back?"
        text: "Unsaved progress will be lost"
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes:
        {
            rootStackView.pop(StackView.Immediate)
            signalSource.reloadLearningLevel()
        }
    }
}
