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

#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>
#include <qqml.h>
#include <QDebug>

//Custom definitions
#if (defined Q_OS_WINDOWS || defined Q_OS_MACOS || defined Q_OS_LINUX) && !defined Q_OS_ANDROID
#define PLATFORM_IS_DESKTOP
#elif defined Q_OS_ANDROID || defined Q_OS_IOS
#define PLATFORM_IS_MOBILE
#endif

//For reading courses dir
#include <QDir>

//For reading Jsons
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

//For finding titles in media levels
#include <QRegularExpression>

//For storing user settings
#include <QVariantMap>

//For saving user settings
#include <QSettings>

//For Material style
#include <QQuickStyle>

#ifdef Q_OS_ANDROID

//For Android extras
#include <QtAndroid>

//For executing Java functions from C++, sending and receiving values
#include <QAndroidJniObject>

//For registering native C++ functions that can be called from Java
#include <QAndroidJniEnvironment>

#endif

class Backend : public QObject
{
    Q_OBJECT

    QML_ELEMENT

public:
    explicit Backend(QObject *parent = nullptr);

    static Backend *getGlobalBackendInstance()
    {
        return m_instance;
    }

    Q_INVOKABLE void debugFun();

    Q_INVOKABLE void setGlobalBackendInstance();

    Q_INVOKABLE QString getLocalFile(QUrl url);

    #ifdef Q_OS_ANDROID
    Q_INVOKABLE void androidOpenFileDialog();
    #endif

    Q_INVOKABLE void getCourseList();
    Q_INVOKABLE void getCourseLevels(QString directory);

    Q_INVOKABLE void setUserSettings(QVariantMap userSettings);
    Q_INVOKABLE QVariantMap getUserSettings();

    Q_INVOKABLE QString readMediaLevel(QString levelPath);

    Q_INVOKABLE void getLevelItems(QString courseDirectory, QString levelPath);

    Q_INVOKABLE void loadSeedbox(QString courseDirectory);
    Q_INVOKABLE void unloadSeedbox();

    Q_INVOKABLE void readItem(QString itemId, QString testColumn, QString promptColumn);

    Q_INVOKABLE QString readItemAttributes(QString itemId);
    Q_INVOKABLE QVariantList readItemColumn(QString itemId, QString column);

    Q_INVOKABLE bool checkAnswer(QString itemId, QString column, QString answer);

    enum TestType
    {
        PREVIEW,
        MULTIPLECHOICE,
        TYPING,
        TAPPING
    };
    Q_ENUMS(TestType)

    static void registerTestTypeInQML()
    {
       qmlRegisterType<Backend>("TestType", 1, 0, "TestType");
    }

signals:
    void showPassiveNotification(QString text, uint duration = 2000);

    #ifdef Q_OS_ANDROID
    void sendCoursePath(QString path);
    #endif

    void addCourse(QString directory, QString title, QString author, QString description, QString category, QString icon, int items, int planted, int water, int difficult, int ignored, bool completed);
    void finishedAddingCourses();

    void addCourseLevel(QString levelPath, QString levelTitle, QString testColumn, QString promptColumn, QString testColumnType, QString promptColumnType, bool isLearning, int itemAmount, bool levelCompleted);
    void addLevelItem(QString id, QString test, QString prompt, bool planted, QString nextWatering, bool ignored, bool difficult);
    void finishedAddingLevel();

    void addItemDetails(QString type, QString name, QString content);
    void addItemSeparator();
private:
    static Backend *m_instance;

    QJsonDocument globalSeedbox;
    QVariantMap userSettings;
};

#endif // BACKEND_H
