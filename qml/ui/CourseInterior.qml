import QtQuick 2.0
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.15

Kirigami.ScrollablePage {
    actions {
        left: Kirigami.Action {
            text: "Go back"
            icon.name: "go-previous"
            onTriggered: rootPageStack.pop()
        }
        right: Kirigami.Action {
            text: "Home"
            iconName: "go-home"
            onTriggered: showPassiveNotification("Home")
        }
    }

    Rectangle {
        width: root.width
        height: 4000
        color: rootColor
    }
}
