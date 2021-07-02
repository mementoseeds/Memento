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

Item {
    id: mnemonic

    width: root.width / 2
    height: 300

    Rectangle {
        anchors.fill: parent
        color: "red"

        Image {
            id: mnemonicImage
            anchors {top: parent.top; left: parent.left; right: parent.right}
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + mnemonicImagePath)
            sourceSize.height: parent.height - 100
            fillMode: Image.PreserveAspectFit
        }

        Label {
            anchors {top: mnemonicImage.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
            text: mnemonicText
            font.pointSize: 40
            fontSizeMode: Text.Fit
            minimumPointSize: 5
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: console.debug("Chosen")
    }
}
