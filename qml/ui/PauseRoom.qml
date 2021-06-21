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
import QtQuick.Controls.Material 2.12

Item {

    Component.onDestruction: signalSource.resumeTest()

    ColumnLayout {
        width: parent.width
        anchors.centerIn: parent
        spacing: 50

        Label {
            text: "Paused"
            font.pointSize: 20
            font.bold: true
            Layout.alignment: Qt.AlignCenter
        }

        RoundButton {
            text: "Continue"
            icon.source: "assets/actions/continue.svg"
            display: AbstractButton.TextUnderIcon
            radius: 100
            implicitHeight: 150
            implicitWidth: implicitHeight * 1.5
            font.pointSize: 20
            font.capitalization: Font.MixedCase
            Layout.alignment: Qt.AlignCenter
            onClicked: rootStackView.pop()
        }
    }
}
