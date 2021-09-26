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

#pragma once
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

//For reading and writing Jsons
#include <3rdparty/nlohmann/json.hpp>
#include <fstream>
using Json = nlohmann::ordered_json;
using String = std::string;

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

//For reading and saving review dates
#include <QDateTime>

//For selecting random Json items
#include <QRandomGenerator>

//For tracking learning duration
#include <QElapsedTimer>

//For offloading expensive tasks to another thread
#include <QThread>
#include "worker.hpp"

//For setting app icon
#include <QIcon>

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

    Q_INVOKABLE void setUserSettings(QVariantMap userSettings);
    Q_INVOKABLE QVariantMap getUserSettings();

    Q_INVOKABLE void getCourseLevels(QString directory);
    Q_INVOKABLE bool loadSeedbox(QString courseDirectory);

    Q_INVOKABLE QString readMediaLevel(QString levelPath);

    Q_INVOKABLE void getLevelItems(QString levelPath);

    Q_INVOKABLE void readItem(QString itemId, QString testColumn, QString promptColumn);

    Q_INVOKABLE QString readCourseTitle();

    Q_INVOKABLE QVariantList readItemAttributes(QString itemId);
    Q_INVOKABLE QVariantList readItemColumn(QString itemId, QString column);

    Q_INVOKABLE bool getLevelCompleted();

    Q_INVOKABLE void setReviewType(bool manualReview, bool mockWater, bool difficultReview);
    Q_INVOKABLE void loadCourseInfo(QString courseDirectory);
    Q_INVOKABLE bool checkAnswer(QString levelPath, QString itemId, QString column, QString answer);
    Q_INVOKABLE void getShowAfterTests(QString itemId, QString testColumn, QString promptColumn);

    Q_INVOKABLE void saveLevel(QString levelPath);
    Q_INVOKABLE void saveLevels();
    Q_INVOKABLE void updateLastLearned(QString coursePath);

    Q_INVOKABLE void getSessionResults(QString levelPath, QVariantList itemArray);

    Q_INVOKABLE void setStartTime();
    Q_INVOKABLE QString getStopTime();

    Q_INVOKABLE void resetCurrentLevel(QString levelPath);

    Q_INVOKABLE void autoLearn(QVariantMap levelAndItems);

    Q_INVOKABLE void refreshCourses();

    Q_INVOKABLE QVariantList getRandomValues(QString itemId, QString column, int count);
    Q_INVOKABLE QVariantList getRandomCharacters(QString itemId, QString column, int count);

    Q_INVOKABLE void ignoreItem(QString levelPath, QString itemId, bool ignored);
    Q_INVOKABLE void ignoreLevel(QString levelPath);

    Q_INVOKABLE void autoLearnItem(QString levelPath, QString itemId, int streakCount);

    Q_INVOKABLE int getCourseLevelAmount(QString courseDirectory);
    Q_INVOKABLE void advancedAutoLevelAdjust(bool learn, QString courseDirectory, int start, int stop, int streak, bool waterRightNow);

    Q_INVOKABLE QVariantMap getFirstIncompleteLevel(QString courseDirectory);

    Q_INVOKABLE void loadLevelJsons(QVariantList levels);

    Q_INVOKABLE QVariantList getLevelColumns(QString levelPath);

    Q_INVOKABLE QVariantMap getCourseWideWateringItems(QString courseDirectory, int count);

    Q_INVOKABLE QVariantMap getAdjacentLevel(QString courseDirectory, int levelIndex);

    Q_INVOKABLE QString readText(QString path);

    Q_INVOKABLE void getCourseDifficultItems(QString courseDirectory);

    Q_INVOKABLE void setDifficult(QString levelPath, QString itemId, bool difficult);

    Q_INVOKABLE void unmarkDifficult(QVariantMap difficultItems);

    Q_INVOKABLE void getAllMnemonics(QString itemId);
    Q_INVOKABLE void setMnemonic(QString levelPath, QString itemId, QString mnemonicId);
    Q_INVOKABLE QVariantMap getMnemonic(QString levelPath, QString itemId);

    enum TestType
    {
        PREVIEW,
        MULTIPLECHOICE,
        TYPING,
        TAPPING
    };
    Q_ENUMS(TestType)

signals:
    void showPassiveNotification(QString text, uint duration = 2000);

    #ifdef Q_OS_ANDROID
    void sendCoursePath(QString path);
    #endif

    void addAllCourseCategories(QList<QString> categories);

    void addCourse(QString directory, QString title, QString author, QString description, QString category, QString icon, int items, int planted, int water, int difficult, int ignored, bool completed);

    void addCourseLevel(QString levelPath, QString levelTitle, QString testColumn, QString promptColumn, QString testColumnType, QString promptColumnType, bool isLearning, int itemAmount, bool levelCompleted);
    void addLevelItem(QString id, QString test, QString prompt, bool planted, QString progress, bool difficult, bool ignored);
    void finishedAddingLevel();

    void addItemDetails(QString type, QString name, QString content);
    void addItemSeparator();

    void addShowAfterTests(QString type, QString content);

    void addItemResults(QString testData, QString testDataType, QString promptData, QString promptDataType, int successes, int failures, int streak);

    void courseRefreshFinished();

    void addDifficultItem(QString levelPath, QString id, QString test, QString prompt, QString testColumnType, QString promptColumnType);

    void finishedGetDifficultItemInfo();

    void addMnemonic(QString mnemonicId, QString author, QString text, QString imagePath);

private slots:

    void getDifficultItemInfo(QString levelPath, QString itemId, QString testColumn, QString promptColumn);

private:
    static Backend *m_instance;

    //Methods
    void correctAnswer(QString levelPath, QString itemId);
    void wrongAnswer(QString levelPath, QString itemId);

    String getWateringTime(int streak);
    QString parseTime(uint seconds, bool fullTime = false);

    const Json getRandom(const Json &json, bool returnKey);

    QString getReviewTime(QString date);

    QString convertMarkdownToRichtext(QString markdownText);

    //globalBackend variables !!!DO NOT USE FROM OTHER QML OBJECTS BESIDES globalBackend!!!
    Json globalSeedbox;
    Json globalMnemonics;
    Json globalLevel;
    Json globalInfo;
    QMap<QString, Json> jsonMap;

    bool manualReview = false;
    bool mockWater = false;
    bool difficultReview = false;
    QMap<QString, QMap<QString, bool>> unlockedItems;

    QVariantMap userSettings;

    QElapsedTimer elapsedTimer;

    //Constants
    const int jsonIndent = 4;

    //Font sizes
    const int levelColumnFontSize = 12;
    const int testTextFontSize = 20;
    const int previewTextFontSize = 20;

    #ifdef PLATFORM_IS_DESKTOP

    const int defaultFontSize = 8;
    const int mediaFontSize = 8;
    const int testAttributesFontSize = 10;

    #elif defined PLATFORM_IS_MOBILE

    const int defaultFontSize = 14;
    const int mediaFontSize = 13;
    const int testAttributesFontSize = 15;

    #endif
};

#endif // BACKEND_H
