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
    width: userSettings["windowWidth"]
    height: userSettings["windowHeight"]
    title: "Memento"
    color: "#333333"
    Material.theme: Material.Dark

    Component.onCompleted:
    {
        globalBackend.debugFun()
        globalBackend.setGlobalBackendInstance()
    }

    property bool _COURSES_REFRESHING_DO_NOT_CLOSE_: false

    property var userSettings: globalBackend.getUserSettings()
    property bool platformIsMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
    property string fileUrlStart: Qt.platform.os === "windows" ? "file:///" : "file://"

    //Control variables
    property bool showBackConfirm: false
    //course categories are placed here because initially the options page is not loaded to receive the signal
    property var allCourseCategories: []

    //Colors
    property color defaultMaterialAccept: globalBlue
    property color globalBlue: Material.color(Material.Indigo)
    property color globalGreen: Material.color(Material.Green)
    property color globalRed: Material.color(Material.Red)
    property color globalOrange: Material.color(Material.DeepOrange, Material.Shade400)
    property color globalAmber: Material.color(Material.Amber)
    property color globalBlueGrey: Material.color(Material.BlueGrey, Material.Shade600)
    property color defaultToolbarColor: Material.color(Material.Teal)

    //Icon font
    property string audioIcon: "\ue900"
    property string backspaceIcon: "\ue901"
    property string difficultIcon: "\ue902"
    property string hintIcon: "\ue903"
    property string ignoreIcon: "\ue904"
    property string plantIcon: "\ue905"
    property string spacebarIcon: "\ue906"
    property string waterIcon: "\ue907"

    FontLoader {
        source: "assets/icons-font/Icons.ttf"
    }

    Item {
        id: signalSource
        visible: false
        signal reloadLearningLevel()
        signal reloadDifficultView()
        signal refreshCourseLevels()
        signal refreshAllCourses()
        signal pauseTest()
        signal resumeTest()
        signal stopAllAudio()
        signal showIgnore()
        signal showDifficult()
        signal setMnemonic(string mnemonicId)
        signal disablePreviousPageConnections()
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

            case "difficult":
                toolbarBackground.color = globalOrange
                toolbarProgressBar.Material.accent = globalAmber
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

    function setToolbarColor(color)
    {
        toolbarBackground.color = color
    }

    function findPageIndex(name)
    {
        for (var i = 0; i < rootStackView.depth; i++)
            if (rootStackView.get(i).objectName === name)
                return i
    }

    onClosing:
    {
        if (_COURSES_REFRESHING_DO_NOT_CLOSE_)
            close.accepted = false

        userSettings["windowHeight"] = root.height
        userSettings["windowWidth"] = root.width
        globalBackend.setUserSettings(userSettings)
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
                    if (rootStackView.currentItem.objectName === "StagingArea.qml" && showBackConfirm)
                    {
                        confirmActionDialog.open()
                        return
                    }

                    if (platformIsMobile)
                    {
                        if (rootStackView.depth > 1)
                            rootStackView.pop()
                        else if (rootStackView.depth === 1)
                            if (!closeTimer.running && !_COURSES_REFRESHING_DO_NOT_CLOSE_)
                            {
                                closeTimer.start()
                                showPassiveNotification("Press back again to quit", closeTimer.interval)
                            }
                            else
                                root.close()
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
                enabled: rootStackView.currentItem.objectName !== "StagingArea.qml" && rootStackView.currentItem.objectName !== "PauseRoom.qml" && rootStackView.currentItem.objectName !== "ResultSummary.qml"
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
                enabled: rootStackView.depth === 1 && !_COURSES_REFRESHING_DO_NOT_CLOSE_
                onTriggered: signalSource.refreshAllCourses()
            }

            Action {
                text: "&Help"
                icon.source: "assets/actions/help.svg"
                enabled: rootStackView.currentItem.objectName !== "HelpPage.qml" && rootStackView.currentItem.objectName !== "AboutPage.qml"
                onTriggered: rootStackView.push("qrc:/HelpPage.qml")
                Component.onCompleted:
                {
                    if (userSettings["hideHelpAboutPages"])
                        mainMenuBar.removeAction(this)
                }
            }

            Action {
                text: "&About"
                icon.source: "assets/actions/about.svg"
                enabled: rootStackView.currentItem.objectName !== "HelpPage.qml" && rootStackView.currentItem.objectName !== "AboutPage.qml"
                onTriggered: rootStackView.push("qrc:/AboutPage.qml")
                Component.onCompleted:
                {
                    if (userSettings["hideHelpAboutPages"])
                        mainMenuBar.removeAction(this)
                }
            }
        }
    }

    Action {
        id: pauseAction
        text: "&Pause"
        icon.source: "assets/actions/pause.svg"
        shortcut: "Alt+p"
        enabled: rootStackView.currentItem.objectName !== "PauseRoom.qml"
        onTriggered: signalSource.pauseTest()
    }

    StackView {
        id: rootStackView
        anchors.fill: parent
        initialItem: CourseList {}

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

        function onCourseRefreshFinished()
        {
            passiveNotification.reduceTimer()
            _COURSES_REFRESHING_DO_NOT_CLOSE_ = false
        }

        function onAddAllCourseCategories(categories)
        {
            allCourseCategories = categories
        }
    }

    Connections {
        target: signalSource

        function onRefreshAllCourses()
        {
            passiveNotification.show("Please do not exit while refreshing courses", Number.MAX_SAFE_INTEGER)
            _COURSES_REFRESHING_DO_NOT_CLOSE_ = true
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
            rootStackView.pop()
            signalSource.reloadLearningLevel()
        }
    }
}
