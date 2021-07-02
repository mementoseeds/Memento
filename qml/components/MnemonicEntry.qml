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
import QtQuick.Controls.Material.impl 2.12

Item {
    property int marginBase: 10

    property bool textPresent: mnemonicText.length > 0
    property bool imagePresent: mnemonicImagePath.length > 0

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Image {
            id: mnemonicImage
            anchors {top: parent.top; left: parent.left; right: parent.right}
            source: imagePresent ? Qt.resolvedUrl("file:/" + courseDirectory + "/" + mnemonicImagePath) : ""
            sourceSize.height: parent.height - (textPresent ? parent.height / 2 : 0)
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            id: separator
            visible: textPresent && imagePresent
            anchors {top: mnemonicImage.bottom; left: parent.left; right: parent.right}
            height: 2
            color: "gray"
        }

        Label {
            anchors {top: separator.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
            text: mnemonicText
            font.pointSize: 40
            fontSizeMode: Text.Fit
            minimumPointSize: 5
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }

        Ripple {
            id: ripple
            anchors.fill: parent
            clipRadius: 4
            active: mnemonicMouseArea.containsMouse
            pressed: mnemonicMouseArea.pressed
            color: "#20FFFFFF"
        }
    }

    MouseArea {
        id: mnemonicMouseArea
        anchors.fill: parent
        onClicked: signalSource.setMnemonic(mnemonicId)
    }
}
