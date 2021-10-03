QT += quick core quickcontrols2 widgets svg

CONFIG += c++11 qmltypes

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        backend.cpp \
        main.cpp \
        worker.cpp

HEADERS += \
    Objective_C_Interface.h \
    backend.hpp \
    3rdparty/nlohmann/json.hpp \
    controller.hpp \
    worker.hpp

RESOURCES += qml.qrc

# C++ Backend
QML_IMPORT_NAME = Memento.Backend
QML_IMPORT_MAJOR_VERSION = 1

# Set name
TARGET = Memento

# Set Windows icon
win32: RC_ICONS = assets/icons/winicon.ico

# Set Mac OSX icon
macx: ICON = assets/icons/macos_icon.icns

# Android specifics
android {

    QT += androidextras

    # armeabi-v7a arm64-v8a x86 x86_64
    ANDROID_ABIS += arm64-v8a

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/Android-source

    DISTFILES += \
    Android-source/AndroidManifest.xml \
    Android-source/build.gradle \
    Android-source/gradle.properties \
    Android-source/gradle/wrapper/gradle-wrapper.jar \
    Android-source/gradle/wrapper/gradle-wrapper.properties \
    Android-source/gradlew \
    Android-source/gradlew.bat \
    Android-source/res/values/libs.xml \
    Android-source/src/com/seeds/memento/Backend.java \
    Android-source/src/com/seeds/memento/MainActivity.java
}

# iOS specifics
ios {

    OBJECTIVE_HEADERS += iOS-source/src/Backend.h
    OBJECTIVE_SOURCES += iOS-source/src/Backend.mm

    QMAKE_INFO_PLIST = $$PWD/iOS-source/Info.plist

    ios_icon.files = $$files($$PWD/iOS-source/Icon/*.png)
    QMAKE_BUNDLE_DATA += ios_icon
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin

unix:!android {
    # Set path
    TARGET = memento
    OUTPUT_TARGET = output/$$TARGET
    target.path = $$OUTPUT_TARGET

    # Copy desktop file and icon
    linuxDesktopFile.path = $$OUTPUT_TARGET
    linuxDesktopFile.files = assets/memento.desktop

    linuxIcon.path = $$OUTPUT_TARGET
    linuxIcon.files = assets/icons/icon.svg

    INSTALLS += linuxDesktopFile linuxIcon
}

!isEmpty(target.path): INSTALLS += target
