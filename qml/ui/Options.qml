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

ScrollView {
    anchors.fill: parent
    contentHeight: optionsColumnLayout.height + 50
    contentWidth: root.width

    ColumnLayout {
        id: optionsColumnLayout
        anchors.left: parent.left
        anchors.right: parent.right

        RowLayout {
            Layout.alignment: Qt.AlignCenter

            Label {
                text: "Courses location"
            }

            Button {
                text: "Browse"
                onClicked: fileDialog.open()
            }

            Button {
                text: "Apply"
                onClicked:
                {
                    userSettings["coursesLocation"] = coursesLocationTextField.text
                    globalBackend.setUserSettings(userSettings)
                }
            }
        }

        TextField {
            id: coursesLocationTextField
            text: userSettings["coursesLocation"]
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
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
