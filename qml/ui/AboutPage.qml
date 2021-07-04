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
    property int marginBase: 10

    objectName: "AboutPage.qml"

    property string aboutMemento: "## About Memento\n
### Version 0.5\n
Memento is a cross-platform, offline, spaced-repetition learning application. It is made with the intent to be clean, simple to use and easily configurable to one's needs.\n
It uses courses stored locally on the user's device. These courses are comprised of plaintext json or markdown files that are easy to edit or share.\n
There are two types of levels in every course - learning levels and media levels.\n
Media: simple reading levels stored as markdown files\n
Learning: levels that contain a specified amount of seeds (items) from a courses's seedbox (database) that are meant to be learned in that level\n
\n
The user initiates a learning session by pressing the \"Plant\" button in a learning level. They are then shown a preview of the seed what will learn and a test on it afterwards.\n
This repeates for as many items as the user has specified to learn in the application's settings.\n
After they are shown at least one preview and test for all unique items in a session, they will be repeatedly tested on those items in a random order until they answer each one correctly at least 5 times.\n
Afterwards the items will be marked as planted (learned). The user will then be shown the time remaining until they have to water (review) those items.\n
Every time the user answers correctly on an item's review, the subsequent review will be pushed back further and further from the last.\n\n

## Third-party credits\n
- [Nlohmann](https://github.com/nlohmann/json) for his fantastic C++ Json library
- [Svgrepo](https://www.svgrepo.com) for beautiful, free vector graphics art"

    property string aboutQt: "### About Qt\n
This program uses Qt version 5.15.2.\n
Qt is a C++ toolkit for cross-platform application development.\n
Qt provides single-source portability across all major desktop operating systems. It is also available for embedded Linux and other embedded and mobile operating systems.\n
Qt is available under multiple licensing options designed to accommodate the needs of our various users.\n
Qt licensed under our commercial license agreement is appropriate for development of proprietary/commercial software where you do not want to share any source code with third parties or otherwise cannot comply with the terms of GNU (L)GPL.\n
Qt licensed under GNU (L)GPL is appropriate for the development of Qt applications provided you can comply with the terms and conditions of the respective licenses.\n
Please see qt.io/licensing for an overview of Qt licensing.\n
Copyright (C) 2020 The Qt Company Ltd and other contributors.\n
Qt and the Qt logo are trademarks of The Qt Company Ltd.\n
Qt is The Qt Company Ltd product developed as an open source project. See qt.io for more information\n
"

    ScrollView {
        anchors.fill: parent
        contentWidth: root.width

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: marginBase
            anchors.rightMargin: marginBase
            spacing: marginBase

            Image {
                source: "assets/icons/icon.svg"
                sourceSize.height: 200
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: aboutMemento
                font.pointSize: userSettings["defaultFontSize"]
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Image {
                Layout.topMargin: marginBase
                source: "assets/icons/Qt.svg"
                sourceSize.height: 200
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: aboutQt
                font.pointSize: userSettings["defaultFontSize"]
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Image {
                Layout.topMargin: marginBase
                source: "assets/icons/gpl-v3-logo.svg"
                sourceSize.height: 200
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }

            Label {
                text: "Memento is licensed under the GNU General Public License v3\n" + globalBackend.readText(":/COPYING")
                font.pointSize: userSettings["defaultFontSize"]
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter
            }
        }
    }
}
