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
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15

Kirigami.ScrollablePage {

    property alias levelTitle: levelContentHeading.text
    property int levelNumber: 0
    property alias levelContent: levelContentText.text

    actions {
        main: Kirigami.Action {
            text: "Close"
            iconName: "dialog-close"
            onTriggered: rootPageStack.pop()
        }
    }

    ColumnLayout {

        RowLayout {
            Layout.bottomMargin: 50

            ColumnLayout {

                Kirigami.Heading {
                    text: "Level " + levelNumber
                    font.bold: true
                    level: 1
                    Layout.alignment: Qt.AlignHCenter
                }

                Image {
                    source: "assets/icons/media.svg"
                    sourceSize.width: 80
                    sourceSize.height: 100
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            ColumnLayout {

                Kirigami.Heading {
                    id: levelContentHeading
                    text: "Title"
                    font.bold: true
                    level: 1
                    font.pointSize: 30
                    textFormat: Text.MarkdownText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    Layout.leftMargin: 10
                }

                Rectangle {
                    color: "gray"
                    height: 2
                    Layout.fillWidth: true
                    radius: 50
                }
            }
        }

        Kirigami.Heading {
            id: levelContentText
            text: levelContent
            level: 3
            textFormat: Text.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
