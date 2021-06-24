import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: notification
    function show(text, duration = 3000)
    {
        y = root.height - 150
        notificationLabel.text = text
        notificationHideTimer.interval = duration
        notificationHideTimer.running = true
    }

    function hide()
    {
        y = root.height
        notificationHideTimer.running = false
    }

    function reduceTimer()
    {
        notificationHideTimer.interval = 1000
    }

    width: root.width / 2
    x: root.width / 2 - notificationLabel.contentWidth / 2
    y: root.height

    Behavior on y {
        NumberAnimation {duration: 400}
    }

    Rectangle {
        id: notificationBody
        width: notificationLabel.contentWidth + 20
        height: notificationLabel.contentHeight + 20
        color: "#266FAB"
        radius: 10

        Label {
            id: notificationLabel
            anchors.centerIn: parent
            text: "Notification"
            font.pointSize: 15
            font.bold: true
            width: notification.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        MouseArea {
            anchors.fill: parent
            onClicked: hide()
        }
    }

    Timer {
        id: notificationHideTimer
        repeat: false
        running: false
        onTriggered: hide()
    }
}
