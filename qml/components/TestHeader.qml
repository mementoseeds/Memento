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

ColumnLayout {
    property alias cooldownTimer: cooldownTimer
    property alias countdownTimer: countdownTimer

    signal countdownReached()

    spacing: 20

    RadialBar {
        id: radialBar
        minValue: 0
        maxValue: 100
        value: maxValue
        showText: "Countdown"
        Layout.topMargin: 10
        Layout.alignment: Qt.AlignCenter
    }

    Loader {
        Layout.fillWidth: true
        property var columnData: globalBackend.readItemColumn(itemId, promptColumn)
        sourceComponent: columnData[0] === "text" ? textComponent : imageComponent
    }

    Rectangle {
        width: attributes.contentWidth + 10
        height: attributes.contentHeight + 5
        Layout.alignment: Qt.AlignCenter
        color: "gray"
        radius: 100
        visible: attributes.text.length > 0

        Label {
            id: attributes
            text: globalBackend.readItemAttributes(itemId)
            font.pointSize: platformIsMobile ? 15 : 10
            anchors.centerIn: parent
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Label {
        text: "Type the <b>" + testColumn + "</b> for the <b>" + promptColumn + "</b> above"
        font.pointSize: platformIsMobile ? 15 : 12
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
    }

    Component {
        id: textComponent

        Label {
            id: prompt
            text: columnData[1]
            font.pointSize: platformIsMobile ? 20 : 15
            font.bold: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Component {
        id: imageComponent

        Image {
            source: Qt.resolvedUrl("file:/" + courseDirectory + "/" + columnData[1])
            sourceSize.width: 200
            fillMode: Image.PreserveAspectFit
            Layout.alignment: Qt.AlignCenter
        }
    }

    Timer {
        id: countdownTimer
        property int maxSeconds: 10
        property int currentSeconds: 0
        interval: 1000
        running: true
        repeat: true
        onTriggered:
        {
            currentSeconds++
            if (currentSeconds <= maxSeconds)
            {
                radialBar.value = radialBar.maxValue - (Math.floor(currentSeconds / maxSeconds * 100))
            }
            else
            {
                running = false
                countdownReached()
            }
        }
    }

    Timer {
        id: cooldownTimer
        interval: 1500
        running: false
        repeat: false
        onTriggered: triggerNextItem()
    }
}
