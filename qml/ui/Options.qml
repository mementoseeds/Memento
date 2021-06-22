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
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.12

Item {
    property int marginBase: 10

    objectName: "Options.qml"

    Component.onDestruction:
    {
        userSettings["coursesLocation"] = coursesLocationTextField.text
        userSettings["countdownTimer"] = countdownTimerSpinBox.value
        userSettings["cooldownTimer"] = cooldownTimerSpinBox.value
        userSettings["autoRefreshCourses"] = autoRefreshCourses.checked
        userSettings["autoAcceptAnswer"] = autoAcceptAnswerCheckBox.checked
        userSettings["enableTestPromptSwitch"] = enableTestPromptSwitch.checked
        userSettings["enabledTests"] = {"enabledMultipleChoice": enabledMultipleChoice.checked, "enabledTyping": enabledTyping.checked, "enabledTapping": enabledTapping.checked}
        globalBackend.setUserSettings(userSettings)
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: root.width

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: marginBase
            anchors.rightMargin: marginBase
            spacing: marginBase

            RowLayout {
                Layout.alignment: Qt.AlignCenter

                Label {
                    text: "Courses location"
                }

                Button {
                    text: "Browse"
                    onClicked:
                    {
                        if (Qt.platform.os === "android")
                            globalBackend.androidOpenFileDialog()
                        else
                            fileDialog.open()
                    }
                }
            }

            TextField {
                id: coursesLocationTextField
                text: userSettings["coursesLocation"]
                Layout.fillWidth: true
                Material.accent: globalGreen
            }

            Label {
                text: "Test countdown timer"
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: countdownTimerSpinBox
                from: 1
                value: userSettings["countdownTimer"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Post-test cooldown timer ms"
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: cooldownTimerSpinBox
                from: 100
                to: 100000
                stepSize: 100
                value: userSettings["cooldownTimer"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: autoRefreshCourses
                text: "Auto refresh courses on startup"
                checked: userSettings["autoRefreshCourses"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: autoAcceptAnswerCheckBox
                text: "Auto accept answer on typing tests"
                checked: userSettings["autoAcceptAnswer"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: enableTestPromptSwitch
                text: "Enable switching test and prompt"
                checked: userSettings["enableTestPromptSwitch"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Column {
                Layout.alignment: Qt.AlignCenter

                ButtonGroup {
                    id: enabledTestsGroup
                    exclusive: false
                    checkState: parentBox.checkState
                    onCheckStateChanged:
                    {
                        if (checkState === Qt.Unchecked)
                            enabledMultipleChoice.checked = true
                    }
                }

                CheckBox {
                    id: parentBox
                    text: qsTr("Enabled tests")
                    checkState: enabledTestsGroup.checkState
                    Material.accent: globalGreen
                }

                CheckBox {
                    id: enabledMultipleChoice
                    checked: userSettings["enabledTests"]["enabledMultipleChoice"]
                    text: qsTr("Multiple Choice")
                    leftPadding: indicator.width
                    ButtonGroup.group: enabledTestsGroup
                    Material.accent: globalGreen
                }

                CheckBox {
                    id: enabledTyping
                    checked: userSettings["enabledTests"]["enabledTyping"]
                    text: qsTr("Typing")
                    leftPadding: indicator.width
                    ButtonGroup.group: enabledTestsGroup
                    Material.accent: globalGreen
                }

                CheckBox {
                    id: enabledTapping
                    checked: userSettings["enabledTests"]["enabledTapping"]
                    text: qsTr("Tapping")
                    leftPadding: indicator.width
                    ButtonGroup.group: enabledTestsGroup
                    Material.accent: globalGreen
                }
            }
        }

        FileDialog {
            id: fileDialog
            title: "Choose courses directory"
            folder: shortcuts.home
            selectExisting: true
            selectFolder: true
            selectMultiple: false
            onAccepted: coursesLocationTextField.text = globalBackend.getLocalFile(fileUrl)
        }
    }

    Connections {
        target: globalBackend
        ignoreUnknownSignals: true
        function onSendCoursePath(path)
        {
            coursesLocationTextField.text = path
        }
    }
}
