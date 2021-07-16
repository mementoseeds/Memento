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
        userSettings["maxPlantingItems"] = maxPlantingItems.value
        userSettings["plantingItemTests"] = plantingItemTestsSpinBox.value
        userSettings["maxWateringItems"] = maxWateringItems.value
        userSettings["maxDifficultItems"] = maxDifficultItems.value
        userSettings["autoRefreshCourses"] = autoRefreshCourses.checked
        userSettings["autoAcceptAnswer"] = autoAcceptAnswerCheckBox.checked
        userSettings["enableTestPromptSwitch"] = enableTestPromptSwitch.checked
        userSettings["showAutoLearnOnTests"] = showAutoLearnOnTests.checked
        userSettings["hideHelpAboutPages"] = hideHelpAboutPages.checked
        userSettings["enableTestChangeAnimation"] = enableTestChangeAnimation.checked
        userSettings["enabledTests"] = {"enabledMultipleChoice": enabledMultipleChoice.checked, "enabledTyping": enabledTyping.checked, "enabledTapping": enabledTapping.checked}

        userSettings["defaultFontSize"] = defaultFontSizeSpinBox.value
        userSettings["mediaFontSize"] = mediaFontSizeSpinBox.value
        userSettings["levelColumnFontSize"] = levelColumnFontSizeSpinBox.value
        userSettings["previewTextFontSize"] = previewTextFontSizeSpinBox.value
        userSettings["testTextFontSize"] = testTextFontSizeSpinBox.value
        userSettings["testAttributesFontSize"] = testAttributesFontSizeSpinBox.value

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
                    font.pointSize: userSettings["defaultFontSize"]
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
                font.pointSize: userSettings["defaultFontSize"]
                Layout.fillWidth: true
                Material.accent: globalGreen
            }

            Label {
                text: "Test countdown timer"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: countdownTimerSpinBox
                from: 1
                to: 100000
                editable: true
                value: userSettings["countdownTimer"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Post-test cooldown timer ms"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: cooldownTimerSpinBox
                from: 50
                to: 100000
                stepSize: 50
                editable: true
                value: userSettings["cooldownTimer"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Items per planting session"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: maxPlantingItems
                from: 1
                to: 100000
                editable: true
                value: userSettings["maxPlantingItems"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Tests per planting item"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: plantingItemTestsSpinBox
                from: 1
                to: 100
                editable: true
                value: userSettings["plantingItemTests"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Items per watering session"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: maxWateringItems
                from: 1
                to: 100000
                editable: true
                value: userSettings["maxWateringItems"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Items per difficult review session"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: maxDifficultItems
                from: 1
                to: 100000
                editable: true
                value: userSettings["maxDifficultItems"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: autoRefreshCourses
                text: "Auto refresh courses on startup"
                font.pointSize: userSettings["defaultFontSize"]
                checked: userSettings["autoRefreshCourses"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: autoAcceptAnswerCheckBox
                text: "Auto accept answer on typing tests"
                font.pointSize: userSettings["defaultFontSize"]
                checked: userSettings["autoAcceptAnswer"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: enableTestPromptSwitch
                text: "Allow test prompt switch on multiple choices"
                font.pointSize: userSettings["defaultFontSize"]
                checked: userSettings["enableTestPromptSwitch"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: showAutoLearnOnTests
                text: "Show auto learn button on planting tests"
                font.pointSize: userSettings["defaultFontSize"]
                checked: userSettings["showAutoLearnOnTests"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: hideHelpAboutPages
                text: "Hide help and about pages"
                font.pointSize: userSettings["defaultFontSize"]
                checked: userSettings["hideHelpAboutPages"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            CheckBox {
                id: enableTestChangeAnimation
                text: "Enable test change animation"
                font.pointSize: userSettings["defaultFontSize"]
                checked: userSettings["enableTestChangeAnimation"]
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
                    font.pointSize: userSettings["defaultFontSize"]
                    checkState: enabledTestsGroup.checkState
                    Material.accent: globalGreen
                }

                CheckBox {
                    id: enabledMultipleChoice
                    checked: userSettings["enabledTests"]["enabledMultipleChoice"]
                    font.pointSize: userSettings["defaultFontSize"]
                    text: qsTr("Multiple Choice")
                    leftPadding: indicator.width
                    ButtonGroup.group: enabledTestsGroup
                    Material.accent: globalGreen
                }

                CheckBox {
                    id: enabledTyping
                    checked: userSettings["enabledTests"]["enabledTyping"]
                    font.pointSize: userSettings["defaultFontSize"]
                    text: qsTr("Typing")
                    leftPadding: indicator.width
                    ButtonGroup.group: enabledTestsGroup
                    Material.accent: globalGreen
                }

                CheckBox {
                    id: enabledTapping
                    checked: userSettings["enabledTests"]["enabledTapping"]
                    font.pointSize: userSettings["defaultFontSize"]
                    text: qsTr("Tapping")
                    leftPadding: indicator.width
                    ButtonGroup.group: enabledTestsGroup
                    Material.accent: globalGreen
                }
            }

            /*----------------------------------------------------------------------------------------------------------------*/

            Rectangle {
                height: 1
                color: "gray"
                Layout.fillWidth: true
            }

            Label {
                text: "Sizes"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Default font size"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: defaultFontSizeSpinBox
                from: 5
                to: 100
                editable: true
                value: userSettings["defaultFontSize"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Media level font size"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: mediaFontSizeSpinBox
                from: 5
                to: 100
                editable: true
                value: userSettings["mediaFontSize"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Level column font size"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: levelColumnFontSizeSpinBox
                from: 5
                to: 100
                editable: true
                value: userSettings["levelColumnFontSize"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Preview text font size"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: previewTextFontSizeSpinBox
                from: 5
                to: 100
                editable: true
                value: userSettings["previewTextFontSize"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Test text font size"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: testTextFontSizeSpinBox
                from: 5
                to: 100
                editable: true
                value: userSettings["testTextFontSize"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Test attributes font size"
                font.pointSize: userSettings["defaultFontSize"]
                Layout.alignment: Qt.AlignCenter
            }

            SpinBox {
                id: testAttributesFontSizeSpinBox
                from: 5
                to: 100
                editable: true
                value: userSettings["testAttributesFontSize"]
                Material.accent: globalGreen
                Layout.alignment: Qt.AlignCenter
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
