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

#include "backend.hpp"
#include "controller.hpp"
#include <iostream>

Backend *Backend::m_instance = nullptr;

Backend::Backend(QObject *parent) : QObject(parent) {}

void Backend::debugFun()
{

}

void Backend::setGlobalBackendInstance()
{
    m_instance = this;
}

QString Backend::getLocalFile(QUrl url)
{
    return url.toLocalFile();
}

#ifdef Q_OS_ANDROID
void Backend::androidOpenFileDialog()
{
    QtAndroid::PermissionResult permissionResult = QtAndroid::checkPermission(QString("android.permission.READ_EXTERNAL_STORAGE"));

    if (permissionResult == QtAndroid::PermissionResult::Granted)
        QAndroidJniObject::callStaticMethod<void>("com/seeds/memento/Backend", "androidOpenFileDialog", "(Landroid/app/Activity;)V", QtAndroid::androidActivity().object());
    else
    {
        QtAndroid::requestPermissionsSync(QStringList({"android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE"}));
        QtAndroid::PermissionResult permissionResult = QtAndroid::checkPermission(QString("android.permission.READ_EXTERNAL_STORAGE"));
        if (permissionResult == QtAndroid::PermissionResult::Granted)
            androidOpenFileDialog();
        else
            emit showPassiveNotification("You must allow storage permission to set a course directory");
    }
}
#endif

void Backend::setUserSettings(QVariantMap userSettings)
{
    this->userSettings = userSettings;

    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "MementoSeeds", "config");
    settings.setValue("coursesLocation", userSettings["coursesLocation"]);
    settings.setValue("courseSorting", userSettings["courseSorting"]);
    settings.setValue("countdownTimer", userSettings["countdownTimer"]);
    settings.setValue("cooldownTimer", userSettings["cooldownTimer"]);
    settings.setValue("maxPlantingItems", userSettings["maxPlantingItems"]);
    settings.setValue("plantingItemTests", userSettings["plantingItemTests"]);
    settings.setValue("maxWateringItems", userSettings["maxWateringItems"]);
    settings.setValue("maxDifficultItems", userSettings["maxDifficultItems"]);
    settings.setValue("autoAcceptAnswer", userSettings["autoAcceptAnswer"]);
    settings.setValue("enableTestPromptSwitch", userSettings["enableTestPromptSwitch"]);
    settings.setValue("showAutoLearnOnTests", userSettings["showAutoLearnOnTests"]);
    settings.setValue("hideHelpAboutPages", userSettings["hideHelpAboutPages"]);
    settings.setValue("enableTestChangeAnimation", userSettings["enableTestChangeAnimation"]);
    settings.setValue("enabledTests", userSettings["enabledTests"]);

    settings.setValue("boldTextPrompt", userSettings["boldTextPrompt"]);
    settings.setValue("defaultFontSize", userSettings["defaultFontSize"]);
    settings.setValue("mediaFontSize", userSettings["mediaFontSize"]);
    settings.setValue("levelColumnFontSize", userSettings["levelColumnFontSize"]);
    settings.setValue("previewTextFontSize", userSettings["previewTextFontSize"]);
    settings.setValue("testTextFontSize", userSettings["testTextFontSize"]);
    settings.setValue("testAttributesFontSize", userSettings["testAttributesFontSize"]);

    settings.setValue("windowHeight", userSettings["windowHeight"]);
    settings.setValue("windowWidth", userSettings["windowWidth"]);
}

QVariantMap Backend::getUserSettings()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "MementoSeeds", "config");
    userSettings.insert("coursesLocation", settings.value("coursesLocation").toString());
    userSettings.insert("courseSorting", settings.value("courseSorting").toString());
    userSettings.insert("countdownTimer", settings.value("countdownTimer", 15).toInt());
    userSettings.insert("cooldownTimer", settings.value("cooldownTimer", 1000).toInt());
    userSettings.insert("maxPlantingItems", settings.value("maxPlantingItems", 5).toInt());
    userSettings.insert("plantingItemTests", settings.value("plantingItemTests", 5).toInt());
    userSettings.insert("maxWateringItems", settings.value("maxWateringItems", 50).toInt());
    userSettings.insert("maxDifficultItems", settings.value("maxDifficultItems", 10).toInt());
    userSettings.insert("autoAcceptAnswer", settings.value("autoAcceptAnswer", true).toBool());
    userSettings.insert("enableTestPromptSwitch", settings.value("enableTestPromptSwitch", false).toBool());
    userSettings.insert("showAutoLearnOnTests", settings.value("showAutoLearnOnTests", false).toBool());
    userSettings.insert("hideHelpAboutPages", settings.value("hideHelpAboutPages", false).toBool());

    userSettings.insert("enableTestChangeAnimation", settings.value("enableTestChangeAnimation", true).toBool());

    userSettings.insert("enabledTests", settings.value("enabledTests").toMap());

    userSettings.insert("boldTextPrompt", settings.value("boldTextPrompt", true).toBool());
    userSettings.insert("defaultFontSize", settings.value("defaultFontSize", defaultFontSize).toInt());
    userSettings.insert("mediaFontSize", settings.value("mediaFontSize", mediaFontSize).toInt());
    userSettings.insert("levelColumnFontSize", settings.value("levelColumnFontSize", levelColumnFontSize).toInt());
    userSettings.insert("previewTextFontSize", settings.value("previewTextFontSize", previewTextFontSize).toInt());
    userSettings.insert("testTextFontSize", settings.value("testTextFontSize", testTextFontSize).toInt());
    userSettings.insert("testAttributesFontSize", settings.value("testAttributesFontSize", testAttributesFontSize).toInt());

    userSettings.insert("windowHeight", settings.value("windowHeight", 1000).toInt());
    userSettings.insert("windowWidth", settings.value("windowWidth", 1500).toInt());

    QVariantMap testCheck = userSettings["enabledTests"].toMap();

    if (!testCheck["enabledMultipleChoice"].toBool() && !testCheck["enabledTyping"].toBool() && !testCheck["enabledTapping"].toBool())
    {
        testCheck["enabledMultipleChoice"] = testCheck["enabledTyping"] = testCheck["enabledTapping"] = true;
        userSettings["enabledTests"] = testCheck;
    }

    return userSettings;
}

void Backend::getCourseLevels(QString directory)
{
    QDir levelsDir(directory + "/levels");
    foreach (QString lvl, levelsDir.entryList(QDir::Files))
    {
        QString levelPath = levelsDir.absolutePath() + "/" + lvl;
        std::ifstream infoFile(levelPath.toStdString());

        if (levelPath.endsWith(".json"))
        {
            Json levelInfo;
            infoFile >> levelInfo;

            emit addCourseLevel(
                levelPath,
                QString::fromStdString(levelInfo["title"].get<String>()),
                QString::fromStdString(levelInfo["test"].get<String>()),
                QString::fromStdString(levelInfo["prompt"].get<String>()),
                QString::fromStdString(levelInfo["testType"].get<String>()),
                QString::fromStdString(levelInfo["promptType"].get<String>()),
                true,
                levelInfo["seeds"].size(),
                levelInfo["completed"].get<bool>()
                        );
        }
        else if (levelPath.endsWith(".md"))
        {
            String info;
            std::getline(infoFile, info);
            QString levelTitle = QRegularExpression("\\(.*\\)$").match(QString::fromStdString(info)).captured().replace(QRegularExpression("^\\(|\\)$"), "");

            emit addCourseLevel(levelPath, levelTitle, QString(), QString(), QString(), QString(), false, 0, false);
        }

        infoFile.close();
    }
}

bool Backend::loadSeedbox(QString courseDirectory)
{
    bool seedboxPresent = true;

    //Open the seedbox
    globalSeedbox.clear();
    try
    {
        std::ifstream seedboxFile(QString(courseDirectory + "/seedbox.json").toStdString());
        seedboxFile >> globalSeedbox;
        seedboxFile.close();
    }
    catch (Json::parse_error &e)
    {
        qCritical() << "Cannot read seedbox --> " + courseDirectory;
        seedboxPresent = false;
    }

    //Open mnemonics
    globalMnemonics.clear();
    try
    {
        std::ifstream mnemonicsFile(QString(courseDirectory + "/mnemonics.json").toStdString());
        mnemonicsFile >> globalMnemonics;
        mnemonicsFile.close();
    }
    catch (Json::parse_error &e)
    {
        qWarning() << "No mnemonics file found. Creating an empty file for " + courseDirectory;
        globalMnemonics = R"({})"_json;
        std::ofstream mnemonicsFile(QString(courseDirectory + "/mnemonics.json").toStdString());
        mnemonicsFile << globalMnemonics;
        mnemonicsFile.close();
    }

    return seedboxPresent;
}

QString Backend::readMediaLevel(QString levelPath)
{
    QFile mediaFile(levelPath);
    mediaFile.open(QIODevice::ReadOnly | QIODevice::Text);
    return mediaFile.readAll();
}

void Backend::getLevelItems(QString levelPath)
{
    //Open the level
    std::ifstream levelFile(levelPath.toStdString());
    levelFile >> globalLevel;
    levelFile.close();

    //Get testing direction
    String testColumn = globalLevel["test"].get<String>();
    String promptColumn = globalLevel["prompt"].get<String>();

    for (auto &item : globalLevel["seeds"].items())
    {
        String id = item.key();

        QString test = QString::fromStdString(globalSeedbox[id][testColumn]["primary"].get<String>());
        QString prompt = QString::fromStdString(globalSeedbox[id][promptColumn]["primary"].get<String>());

        emit addLevelItem(
            QString::fromStdString(id),
            test,
            prompt,
            globalLevel["seeds"][id]["planted"].get<bool>(),
            getReviewTime(QString::fromStdString(globalLevel["seeds"][id]["nextWatering"].get<String>())),
            globalLevel["seeds"][id]["difficult"].get<bool>(),
            globalLevel["seeds"][id]["ignored"].get<bool>()
                    );
    }

    emit finishedAddingLevel();
}

void Backend::readItem(QString itemId, QString testColumn, QString promptColumn)
{
    Json item = globalSeedbox[itemId.toStdString()];

    //Add attributes
    for (auto &val : item["attributes"].items())
    {
        String attributeNumber = val.key();
        emit addItemDetails("attributes", QString::fromStdString(item["attributes"][attributeNumber]["label"].get<String>()), QString::fromStdString(item["attributes"][attributeNumber]["value"].get<String>()));
    }
    if (!item["attributes"].empty())
        emit addItemSeparator();

    String stdTestColumn = testColumn.toStdString();
    String stdPromptColumn = promptColumn.toStdString();
    Json testColumnObj = item[stdTestColumn];
    Json promptColumnObj = item[stdPromptColumn];

    QStringList alternatives;

    // Add all test column info first
    emit addItemDetails(QString::fromStdString(testColumnObj["type"].get<String>()), testColumn, QString::fromStdString(testColumnObj["primary"].get<String>()));
    for (auto &val : testColumnObj["alternative"])
    {
        QString string = QString::fromStdString(val.get<String>());
        if (!string.startsWith("_"))
            alternatives.append(string);
    }
    if (!alternatives.isEmpty())
        emit addItemDetails("alternative", "Alternatives", alternatives.join(", "));
    alternatives.clear();
    emit addItemSeparator();

    // Add all prompt column info second
    emit addItemDetails(QString::fromStdString(promptColumnObj["type"].get<String>()), promptColumn, QString::fromStdString(promptColumnObj["primary"].get<String>()));
    for (auto &val : promptColumnObj["alternative"])
    {
        QString string = QString::fromStdString(val.get<String>());
        if (!string.startsWith("_"))
            alternatives.append(string);
    }
    if (!alternatives.isEmpty())
        emit addItemDetails("alternative", "Alternatives", alternatives.join(", "));
    alternatives.clear();
    emit addItemSeparator();

    // Add all remaining column info last
    for (auto &entry : item.items())
    {
        String column = entry.key();

        if (item[column].is_object() && column.compare(stdTestColumn) != 0 && column.compare(stdPromptColumn) != 0 && column.compare("attributes") != 0)
        {
            Json columnData = item[column];
            emit addItemDetails(QString::fromStdString(columnData["type"].get<String>()), QString::fromStdString(column), QString::fromStdString(columnData["primary"].get<String>()));

            for (auto &val : columnData["alternative"])
            {
                QString string = QString::fromStdString(val.get<String>());
                if (!string.startsWith("_"))
                    alternatives.append(string);
            }
            if (!alternatives.isEmpty())
                emit addItemDetails("alternative", "Alternatives", alternatives.join(", "));
            alternatives.clear();
            emit addItemSeparator();
        }
    }
}

QString Backend::readCourseTitle()
{
    return QString::fromStdString(globalInfo["title"].get<String>());
}

QVariantList Backend::readItemAttributes(QString itemId)
{
    QVariantList list;
    String id = itemId.toStdString();
    for (auto &val : globalSeedbox[id]["attributes"].items())
    {
        String attributeNumber = val.key();
        if (globalSeedbox[id]["attributes"][attributeNumber]["showAtTests"].get<bool>())
            list.append(QString::fromStdString(globalSeedbox[id]["attributes"][attributeNumber]["value"].get<String>()));
    }
    return list;
}

QVariantList Backend::readItemColumn(QString itemId, QString column)
{
    QVariantList list;
    Json item = globalSeedbox[itemId.toStdString()][column.toStdString()];
    list.append(QString::fromStdString(item["type"].get<String>()));
    list.append(QString::fromStdString(item["primary"].get<String>()));
    return list;
}

bool Backend::getLevelCompleted()
{
    return globalLevel["completed"].get<bool>();
}

void Backend::setReviewType(bool manualReview, bool mockWater, bool difficultReview)
{
    this->manualReview = manualReview;
    this->mockWater = mockWater;
    this->difficultReview = difficultReview;
    unlockedItems.clear();
}

void Backend::loadCourseInfo(QString courseDirectory)
{
    std::ifstream infoFile(QString(courseDirectory + "/info.json").toStdString());
    infoFile >> globalInfo;
    infoFile.close();
}

bool Backend::checkAnswer(QString levelPath, QString itemId, QString column, QString answer)
{
    bool result = false;
    answer = answer.trimmed();

    Json item = globalSeedbox[itemId.toStdString()][column.toStdString()];
    if (answer.compare(QString::fromStdString(item["primary"].get<String>()), Qt::CaseInsensitive) == 0)
        result = true;
    else
    {
        for (auto &val : item["alternative"])
        {
            if (answer.compare(QString::fromStdString(val.get<String>()).remove(QRegExp("^_")), Qt::CaseInsensitive) == 0)
            {
                result = true;
                break;
            }
        }
    }

    if (!mockWater && !difficultReview)
    {
        if (result)
            correctAnswer(levelPath, itemId);
        else
            wrongAnswer(levelPath, itemId);
    }

    return result;
}

void Backend::correctAnswer(QString levelPath, QString itemId)
{
    String id = itemId.toStdString();

    Json item = jsonMap[levelPath]["seeds"][id];

    int successes = item["successes"].get<int>() + 1;
    item["successes"] = successes;

    if ((item["planted"].get<bool>() || successes >= userSettings["plantingItemTests"].toInt()) && (unlockedItems[levelPath][itemId] || !manualReview))
    {
        unlockedItems[levelPath][itemId] = !manualReview;

        item["planted"] = true;

        int streak = item["streak"].get<int>() + 1;
        item["streak"] = streak;

        item["nextWatering"] = getWateringTime(streak);
    }

    jsonMap[levelPath]["seeds"][id] = item;
}

void Backend::wrongAnswer(QString levelPath, QString itemId)
{
    String id = itemId.toStdString();

    Json item = jsonMap[levelPath]["seeds"][id];
    item["failures"] = item["failures"].get<int>() + 1;
    item["difficult"] = item["planted"].get<bool>();
    item["streak"] = 0;

    unlockedItems[levelPath][itemId] = true;

    jsonMap[levelPath]["seeds"][id] = item;
}

void Backend::getShowAfterTests(QString itemId, QString testColumn, QString promptColumn)
{
    String id = itemId.toStdString();
    for (auto &item : globalSeedbox[id].items())
    {
        String entry = item.key();
        QString qEntry = QString::fromStdString(entry);

        if (globalSeedbox[id][entry].is_object() && qEntry.compare(testColumn) != 0 && qEntry.compare(promptColumn) != 0
            && (std::find(globalInfo["showAfterTests"].begin(), globalInfo["showAfterTests"].end(), entry) != globalInfo["showAfterTests"].end()))
            emit addShowAfterTests(QString::fromStdString(globalSeedbox[id][entry]["type"].get<String>()), QString::fromStdString(globalSeedbox[id][entry]["primary"].get<String>()));
    }
}

String Backend::getWateringTime(int streak)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    uint newTime = 0;

    if (streak <= 0)
        streak = 1;

    if (streak >= 11)
        newTime = 31104000;
    else if (streak >= 10)
        newTime = 23328000;
    else if (streak >= 9)
        newTime = 15552000;
    else if (streak >= 8)
        newTime = 8294400;
    else if (streak >= 7)
        newTime = 4147200;
    else if (streak >= 6)
        newTime = 2073600;
    else if (streak >= 5)
        newTime = 1036800;
    else if (streak >= 4)
        newTime = 518400;
    else if (streak >= 3)
        newTime = 86400;
    else if (streak >= 2)
        newTime = 43200;
    else
        newTime = 18000;

    return currentTime.addSecs(newTime).toString().toStdString();
}

void Backend::saveLevel(QString levelPath)
{
    uint completedSeeds = 0;
    uint ignoredSeeds = 0;
    uint seedAmount = globalLevel["seeds"].size();
    for (auto &item : globalLevel["seeds"].items())
    {
        if (globalLevel["seeds"][item.key()]["planted"].get<bool>())
            completedSeeds++;
        else if (globalLevel["seeds"][item.key()]["ignored"].get<bool>())
            ignoredSeeds++;
    }

    globalLevel["completed"] = ((completedSeeds + ignoredSeeds) == seedAmount);

    std::ofstream level(levelPath.toStdString());
    level << globalLevel.dump(jsonIndent) << std::endl;
    level.close();
}

void Backend::saveLevels()
{
    foreach (QString levelPath, jsonMap.keys())
    {
        uint completedSeeds = 0;
        uint ignoredSeeds = 0;
        uint seedAmount = jsonMap[levelPath]["seeds"].size();
        for (auto &item : jsonMap[levelPath]["seeds"].items())
        {
            String id = item.key();

            if (jsonMap[levelPath]["seeds"][id]["planted"].get<bool>())
                completedSeeds++;
            else if (jsonMap[levelPath]["seeds"][id]["ignored"].get<bool>())
                ignoredSeeds++;
        }

        jsonMap[levelPath]["completed"] = ((completedSeeds + ignoredSeeds) == seedAmount);

        std::ofstream level(levelPath.toStdString());
        level << jsonMap[levelPath].dump(jsonIndent) << std::endl;
        level.close();
    }
}

void Backend::updateLastLearned(QString coursePath)
{
    Json info;
    String infoPath = QString(coursePath + "/info.json").toStdString();

    {
        std::ifstream infoFile(infoPath);
        infoFile >> info;
        infoFile.close();
    }

    info["lastLearned"] = QDateTime::currentDateTime().toString().toStdString();

    std::ofstream infoFile(infoPath);
    infoFile << info.dump(jsonIndent) << std::endl;
    infoFile.close();
}

const Json Backend::getRandom(const Json &json, bool returnKey)
{
    auto it = json.cbegin();
    int random = QRandomGenerator::global()->generate() % json.size();
    std::advance(it, random);
    if (returnKey)
        return it.key();
    else
        return *it;
}

void Backend::getSessionResults(QString levelPath, QVariantList itemArray)
{
    String test = jsonMap[levelPath]["test"].get<String>();
    String prompt = jsonMap[levelPath]["prompt"].get<String>();
    foreach (QVariant itemId, itemArray)
    {
        String id = itemId.toString().toStdString();

        emit addItemResults(
            QString::fromStdString(globalSeedbox[id][test]["primary"].get<String>()),
            QString::fromStdString(globalSeedbox[id][test]["type"].get<String>()),
            QString::fromStdString(globalSeedbox[id][prompt]["primary"].get<String>()),
            QString::fromStdString(globalSeedbox[id][prompt]["type"].get<String>()),
            jsonMap[levelPath]["seeds"][id]["successes"].get<int>(),
            jsonMap[levelPath]["seeds"][id]["failures"].get<int>(),
            jsonMap[levelPath]["seeds"][id]["streak"].get<int>()
                    );
    }
}

void Backend::setStartTime()
{
    elapsedTimer.start();
}

QString Backend::getStopTime()
{
    uint duration = elapsedTimer.elapsed() / 1000;
    return parseTime(duration, true);
}

QString Backend::parseTime(uint seconds, bool fullTime)
{
    if (seconds >= 2629746)
        return QString::number(seconds / 2629746) + " months";
    else if (seconds >= 604800)
        return QString::number(seconds / 604800) + " weeks";
    else if (seconds >= 86400)
        return QString::number(seconds / 86400) + " days";
    else if (seconds >= 3600)
        return QString::number(seconds / 3600) + " hours";
    else if (seconds >= 60)
        return QString::number(seconds / 60) + " minutes" + (fullTime ? " : " + QString::number(seconds & 60) + " seconds" : "");
    else
        return QString::number(seconds) + " seconds";

    return "Unknown";
}

void Backend::resetCurrentLevel(QString levelPath)
{
    //Called from learning level view
    globalLevel["completed"] = false;
    for (auto &item : globalLevel["seeds"].items())
    {
        String id = item.key();
        globalLevel["seeds"][id]["planted"] = false;
        globalLevel["seeds"][id]["nextWatering"] = "";
        globalLevel["seeds"][id]["ignored"] = false;
        globalLevel["seeds"][id]["difficult"] = false;
        globalLevel["seeds"][id]["successes"] = 0;
        globalLevel["seeds"][id]["failures"] = 0;
        globalLevel["seeds"][id]["streak"] = 0;
    }

    std::ofstream level(levelPath.toStdString());
    level << globalLevel.dump(jsonIndent) << std::endl;
    level.close();
}

void Backend::autoLearn(QVariantMap levelAndItems)
{
    QString levelPath = levelAndItems.keys()[0];
    QVariantList itemArray = levelAndItems[levelPath].toList();

    //Called from learning level view
    foreach (QVariant item, itemArray)
    {
        String id = item.toString().toStdString();

        globalLevel["seeds"][id]["planted"] = true;
        globalLevel["seeds"][id]["nextWatering"] = getWateringTime(1);
        globalLevel["seeds"][id]["ignored"] = false;
        globalLevel["seeds"][id]["difficult"] = false;
        globalLevel["seeds"][id]["successes"] = userSettings["plantingItemTests"].toInt();
        globalLevel["seeds"][id]["failures"] = 0;
        globalLevel["seeds"][id]["streak"] = 1;
    }

    saveLevel(levelPath);
}

void Backend::refreshCourses()
{
    //Pass this operation to another thread
    Controller *threadController = new Controller;
    connect(threadController, &Controller::controllerAddAllCourseCategories, this, &Backend::addAllCourseCategories);
    connect(threadController, &Controller::controllerAddCourse, this, &Backend::addCourse);
    connect(threadController, &Controller::controllerCourseRefreshFinished, this, &Backend::courseRefreshFinished);
    emit threadController->requestCourseRefresh(userSettings["coursesLocation"].toString(), userSettings["courseSorting"].toString());
}

QString Backend::getReviewTime(QString date)
{
    QDateTime now = QDateTime::currentDateTime();
    QDateTime reviewTime = QDateTime::fromString(date);

    if (reviewTime > now)
        return parseTime(now.secsTo(reviewTime));
    else
        return "Now";
}

QVariantList Backend::getRandomValues(QString itemId, QString column, int count)
{
    QVariantList list;
    String itemColumn = column.toStdString();

    //Get correct answer
    list.append(QString::fromStdString(globalSeedbox[itemId.toStdString()][itemColumn]["primary"].get<String>()));

    for (int i = 0; i < count - 1; i++)
    {
        QString value;

        while (value.isEmpty())
        {
            String key = getRandom(globalSeedbox, true);

            if (globalSeedbox[key][itemColumn].is_object())
            {
                value = QString::fromStdString(globalSeedbox[key][itemColumn]["primary"].get<String>());

                //Guarantee unique values as long as there are enough in the seedbox
                if (globalSeedbox.size() > (ulong)count && list.contains(value))
                {
                    value.clear();
                    continue;
                }
            }
            else
                continue;
        }

        list.append(value);
    }

    return list;
}

QVariantList Backend::getRandomCharacters(QString itemId, QString column, int count)
{
    String itemColumn = column.toStdString();

    //Get correct answer
    QStringList answerChars = QString::fromStdString(globalSeedbox[itemId.toStdString()][itemColumn]["primary"].get<String>()).remove(" ").toLower().split("", Qt::SkipEmptyParts);
    answerChars.removeDuplicates();

    //Fill up remaining space if count is not reached
    while (answerChars.size() < count)
    {
        String key = getRandom(globalSeedbox, true);
        QStringList randomChars;
        try
        {
            randomChars = QString::fromStdString(globalSeedbox[key][itemColumn]["primary"].get<String>()).remove(" ").toLower().split("", Qt::SkipEmptyParts);
        }
        catch (Json::type_error &e)
        {
            //Requested column does not exist for this item
            continue;
        }

        foreach (QString randChar, randomChars)
            if (!answerChars.contains(randChar))
                answerChars.append(randChar);
    }

    //Convert to QVariantList
    QVariantList list;
    foreach (QString character, answerChars)
        list << character;

    return list;
}

void Backend::ignoreItem(QString levelPath, QString itemId, bool ignored)
{
    globalLevel["seeds"][itemId.toStdString()]["ignored"] = ignored;
    saveLevel(levelPath);
}

void Backend::ignoreLevel(QString levelPath)
{
    for (auto &item : globalLevel["seeds"].items())
        globalLevel["seeds"][item.key()]["ignored"] = true;

    saveLevel(levelPath);
}

void Backend::autoLearnItem(QString levelPath, QString itemId, int streakCount)
{
    //Called from button during planting
    String id = itemId.toStdString();
    jsonMap[levelPath]["seeds"][id]["planted"] = true;
    jsonMap[levelPath]["seeds"][id]["nextWatering"] = getWateringTime(streakCount);
    jsonMap[levelPath]["seeds"][id]["ignored"] = false;
    jsonMap[levelPath]["seeds"][id]["difficult"] = false;
    jsonMap[levelPath]["seeds"][id]["successes"] = userSettings["plantingItemTests"].toInt();
    jsonMap[levelPath]["seeds"][id]["failures"] = 0;
    jsonMap[levelPath]["seeds"][id]["streak"] = streakCount;
}

int Backend::getCourseLevelAmount(QString courseDirectory)
{
    QDir levelsDir(courseDirectory + "/levels");
    return levelsDir.entryList({"*.json", "*.md"}, QDir::Files).size();
}

void Backend::advancedAutoLevelAdjust(bool learn, QString courseDirectory, int start, int stop, int streak, bool waterRightNow)
{
    QDir levelsDir(courseDirectory + "/levels");
    QString absolutePath = levelsDir.absolutePath() + "/";
    QStringList levelList = levelsDir.entryList({"*.json", "*.md"}, QDir::Files | QDir::NoDotAndDotDot);

    int successAmount = userSettings["plantingItemTests"].toInt() + streak;

    for (int i = start - 1; i < stop; i++)
    {
        QString level = levelList[i];

        if (level.endsWith(".md"))
            continue;

        Json levelJson;
        String levelPath = QString(absolutePath + level).toStdString();
        {
            std::ifstream levelFile(levelPath);
            levelFile >> levelJson;
            levelFile.close();
        }

        levelJson["completed"] = learn;
        for (auto &item : levelJson["seeds"].items())
        {
            String id = item.key();

            levelJson["seeds"][id]["planted"] = learn;
            levelJson["seeds"][id]["nextWatering"] = learn ? (waterRightNow ? QDateTime::currentDateTime().toString().toStdString() : getWateringTime(streak)) : "";
            levelJson["seeds"][id]["ignored"] = learn ? levelJson["seeds"][id]["ignored"].get<bool>() : false;
            levelJson["seeds"][id]["difficult"] = learn ? levelJson["seeds"][id]["difficult"].get<bool>() : false;
            levelJson["seeds"][id]["successes"] = learn ? successAmount : 0;
            levelJson["seeds"][id]["failures"] = learn ? levelJson["seeds"][id]["failures"].get<int>() : 0;
            levelJson["seeds"][id]["streak"] = learn ? streak : 0;
        }

        std::ofstream levelFile(levelPath);
        levelFile << levelJson.dump(jsonIndent) << std::endl;
        levelFile.close();
    }
}

QVariantMap Backend::getFirstIncompleteLevel(QString courseDirectory)
{
    QDir levelsDir(courseDirectory + "/levels");
    QString absolutePath = levelsDir.absolutePath() + "/";
    QStringList levelList = levelsDir.entryList(QDir::Files);

    for (int i = 0; i < levelList.size(); i++)
    {
        QString levelPath = absolutePath + levelList[i];
        if (levelPath.endsWith(".md"))
            continue;

        std::ifstream levelFile(levelPath.toStdString());
        Json levelJson;
        levelFile >> levelJson;
        levelFile.close();

        if (!levelJson["completed"].get<bool>())
        {
            QVariantMap levelVariables
            {
                {"courseDirectory", courseDirectory},
                {"levelPath", levelPath},
                {"levelNumber", i + 1},
                {"levelTitle", QString::fromStdString(levelJson["title"].get<String>())},
                {"testColumn", QString::fromStdString(levelJson["test"].get<String>())},
                {"promptColumn", QString::fromStdString(levelJson["prompt"].get<String>())},
                {"testColumnType", QString::fromStdString(levelJson["testType"].get<String>())},
                {"promptColumnType", QString::fromStdString(levelJson["promptType"].get<String>())},
                {"itemAmount", QVariant::fromValue(levelJson["seeds"].size())}
            };

            return levelVariables;
        }
    }

    return QVariantMap();
}

void Backend::loadLevelJsons(QVariantList levels)
{
    jsonMap.clear();

    foreach (QVariant levelVar, levels)
    {
        QString levelPath = levelVar.toString();

        std::ifstream levelFile(levelPath.toStdString());
        Json levelJson;
        levelFile >> levelJson;
        levelFile.close();
        jsonMap.insert(levelPath, levelJson);
    }
}

QVariantList Backend::getLevelColumns(QString levelPath)
{
    QVariantList list;
    list.append(QString::fromStdString(jsonMap[levelPath]["test"].get<String>()));
    list.append(QString::fromStdString(jsonMap[levelPath]["prompt"].get<String>()));
    return list;
}

QVariantMap Backend::getCourseWideWateringItems(QString courseDirectory, int count)
{
    QVariantMap testingContentOriginal;
    QString levelsDir = courseDirectory + "/levels/";
    int totalItems = 0;
    bool manualReview = false;

    std::ifstream reviewFile(QString(courseDirectory + "/review.json").toStdString());
    Json review;
    reviewFile >> review;
    reviewFile.close();

    //Randomize level selection for watering
    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(review.begin(), review.end(), g);

    for (auto &levelName : review)
    {
        if (totalItems < count)
        {
            String name = levelName.get<String>();
            std::ifstream levelFile(QString(levelsDir).toStdString() + name);
            Json levelJson;
            levelFile >> levelJson;
            levelFile.close();

            QVariantList itemsToWater;
            for (auto &item : levelJson["seeds"].items())
            {
                String id = item.key();

                if (totalItems < count
                    && levelJson["seeds"][id]["planted"].get<bool>()
                    && QDateTime::currentDateTime() > QDateTime::fromString(QString::fromStdString(levelJson["seeds"][id]["nextWatering"].get<String>())))
                {
                    itemsToWater.append(QString::fromStdString(id));
                    totalItems++;
                }
            }

            testingContentOriginal.insert(levelsDir + QString::fromStdString(name), itemsToWater);
            itemsToWater.clear();
        }
    }

    if (totalItems == 0)
    {
        manualReview = true;

        QDir levelsDirectory(levelsDir);
        QStringList levelList = levelsDirectory.entryList({"*.json"}, QDir::Files);
        std::shuffle(levelList.begin(), levelList.end(), g);

        foreach (QString name, levelList)
        {
            std::ifstream levelFile(QString(levelsDir + name).toStdString());
            Json levelJson;
            levelFile >> levelJson;
            levelFile.close();


            QVariantList itemsToWater;
            for (auto &item : levelJson["seeds"].items())
            {
                String id = item.key();

                if (totalItems < count && levelJson["seeds"][id]["planted"].get<bool>())
                {
                    itemsToWater.append(QString::fromStdString(id));
                    totalItems++;
                }
            }

            testingContentOriginal.insert(levelsDir + name, itemsToWater);
            itemsToWater.clear();
        }
    }

    if (totalItems != 0)
        return QVariantMap {{"totalItems", totalItems}, {"manualReview", manualReview}, {"testingContentOriginal", testingContentOriginal}};
    else
        return QVariantMap();
}

QVariantMap Backend::getAdjacentLevel(QString courseDirectory, int levelIndex)
{
    QDir levelsDir(courseDirectory + "/levels");
    QStringList levelList = levelsDir.entryList(QDir::Files);

    if (levelIndex < 0 || levelIndex >= levelList.size())
        return QVariantMap();
    else
    {
        QString fullPath = levelsDir.absolutePath() + "/" + levelList[levelIndex];
        std::ifstream levelFile(fullPath.toStdString());

        if (levelList[levelIndex].endsWith(".json"))
        {
            Json levelJson;
            levelFile >> levelJson;

            QVariantMap levelInfo
            {
                {"courseDirectory", courseDirectory},
                {"levelPath", fullPath},
                {"levelNumber", levelIndex + 1},
                {"levelTitle", QString::fromStdString(levelJson["title"].get<String>())},
                {"testColumn", QString::fromStdString(levelJson["test"].get<String>())},
                {"promptColumn", QString::fromStdString(levelJson["prompt"].get<String>())},
                {"testColumnType", QString::fromStdString(levelJson["testType"].get<String>())},
                {"promptColumnType", QString::fromStdString(levelJson["promptType"].get<String>())},
                {"itemAmount", QVariant::fromValue(levelJson["seeds"].size())}
            };

            return QVariantMap {{"type", "json"}, {"levelInfo", levelInfo}};
        }
        else if (levelList[levelIndex].endsWith(".md"))
        {
            String info;
            std::getline(levelFile, info);
            QString levelTitle = QRegularExpression("\\(.*\\)$").match(QString::fromStdString(info)).captured().replace(QRegularExpression("^\\(|\\)$"), "");

            QVariantMap levelInfo
            {
                {"courseDirectory", courseDirectory},
                {"levelTitle", levelTitle},
                {"levelNumber", levelIndex + 1},
                {"levelContent", readMediaLevel(fullPath)}
            };

            return QVariantMap {{"type", "md"}, {"levelInfo", levelInfo}};
        }

        levelFile.close();
    }

    return QVariantMap();
}

QString Backend::readText(QString path)
{
    QFile file(path);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream text(&file);
        return text.readAll();
    }
    else
        return QString();
}

void Backend::getCourseDifficultItems(QString courseDirectory)
{
    //Pass this operation to another thread
    Controller *threadController = new Controller;
    connect(threadController, &Controller::controllerGetDifficultItemInfo, this, &Backend::getDifficultItemInfo);
    connect(threadController, &Controller::finishedGetDifficultItemInfo, this, &Backend::finishedGetDifficultItemInfo);
    emit threadController->requestGetCourseDifficultItems(courseDirectory);
}

void Backend::getDifficultItemInfo(QString levelPath, QString itemId, QString testColumn, QString promptColumn)
{
    String id = itemId.toStdString();
    String stdTestColumn = testColumn.toStdString();
    String stdPromptColumn= promptColumn.toStdString();
    emit addDifficultItem(levelPath, itemId,
        QString::fromStdString(globalSeedbox[id][stdTestColumn]["primary"].get<String>()), QString::fromStdString(globalSeedbox[id][stdPromptColumn]["primary"].get<String>()),
        QString::fromStdString(globalSeedbox[id][stdTestColumn]["type"].get<String>()), QString::fromStdString(globalSeedbox[id][stdPromptColumn]["type"].get<String>()));
}

void Backend::setDifficult(QString levelPath, QString itemId, bool difficult)
{
    Json levelJson;
    {
        std::ifstream levelFile(levelPath.toStdString());
        levelFile >> levelJson;
        levelFile.close();
        levelJson["seeds"][itemId.toStdString()]["difficult"] = difficult;
    }

    std::ofstream levelFile(levelPath.toStdString());
    levelFile << levelJson.dump(jsonIndent) << std::endl;
}

void Backend::unmarkDifficult(QVariantMap difficultItems)
{
    foreach (QString levelPath, difficultItems.keys())
    {
        QVariantList idList = difficultItems[levelPath].toList();

        if (idList.isEmpty())
            continue;

        foreach (QVariant itemIdVar, idList)
            jsonMap[levelPath]["seeds"][itemIdVar.toString().toStdString()]["difficult"] = false;
    }
}

void Backend::getAllMnemonics(QString itemId)
{
    String stdItemId = itemId.toStdString();

    for (auto &item : globalMnemonics[stdItemId].items())
    {
        String mnemonicId = item.key();
        emit addMnemonic(QString::fromStdString(mnemonicId), QString::fromStdString(globalMnemonics[stdItemId][mnemonicId]["author"].get<String>()),
            convertMarkdownToRichtext(QString::fromStdString(globalMnemonics[stdItemId][mnemonicId]["text"].get<String>())),
            QString::fromStdString(globalMnemonics[stdItemId][mnemonicId]["image"].get<String>()));
    }
}

void Backend::setMnemonic(QString levelPath, QString itemId, QString mnemonicId)
{
    String stdItemId = itemId.toStdString();
    Json levelJson;
    {
        std::ifstream levelFile(levelPath.toStdString());
        levelFile >> levelJson;
        levelFile.close();
    }

    QString existingMnemonic = QString::fromStdString(levelJson["seeds"][stdItemId]["mnemonic"].get<String>());

    String newMnemonic;
    QString message;
    if (existingMnemonic.compare(mnemonicId) != 0)
    {
        newMnemonic = mnemonicId.toStdString();
        message = "Set mnemonic";
    }
    else
    {
        newMnemonic = "";
        message = "Unset mnemonic";
    }

    levelJson["seeds"][itemId.toStdString()]["mnemonic"] = newMnemonic;
    jsonMap[levelPath]["seeds"][itemId.toStdString()]["mnemonic"] = newMnemonic;

    std::ofstream levelFile(levelPath.toStdString());
    levelFile << levelJson.dump(jsonIndent) << std::endl;
    levelFile.close();

    emit showPassiveNotification(message);
}

QVariantMap Backend::getMnemonic(QString levelPath, QString itemId)
{
    String id = itemId.toStdString();
    QString mnemonicId = QString::fromStdString(jsonMap[levelPath]["seeds"][id]["mnemonic"].get<String>());
    if (!mnemonicId.isEmpty())
    {
        String stdMnemonicId = mnemonicId.toStdString();
        QVariantMap mnemonicData
        {
            {"mnemonicId", mnemonicId},
            {"mnemonicAuthor", QString::fromStdString(globalMnemonics[id][stdMnemonicId]["author"].get<String>())},
            {"mnemonicText", convertMarkdownToRichtext(QString::fromStdString(globalMnemonics[id][stdMnemonicId]["text"].get<String>()))},
            {"mnemonicImagePath", QString::fromStdString(globalMnemonics[id][stdMnemonicId]["image"].get<String>())}
        };

        return mnemonicData;
    }
    else
        return QVariantMap();
}

QString Backend::convertMarkdownToRichtext(QString markdownText)
{
    return markdownText.replace(QRegularExpression("<tt><br>[^<>].*?<br></tt>(*SKIP)(*F)|\\*\\*\\*(.*?)\\*\\*\\*(?=[^>]*(?:<|$))"), "<b><i>\\1</i></b>")
        .replace(QRegularExpression("<tt><br>[^<>].*?<br></tt>(*SKIP)(*F)|\\*\\*(.*?)\\*\\*(?=[^>]*(?:<|$))"), "<b>\\1</b>")
        .replace(QRegularExpression("<tt><br>[^<>].*?<br></tt>(*SKIP)(*F)|\\*(.*?)\\*(?=[^>]*(?:<|$))"), "<i>\\1</i>")
        .replace(QRegularExpression("<tt><br>[^<>].*?<br></tt>(*SKIP)(*F)|__(.*?)__(?=[^>]*(?:<|$))"), "<u>\\1</u>")
        .replace(QRegularExpression("<tt><br>[^<>].*?<br></tt>(*SKIP)(*F)|~~(.*?)~~(?=[^>]*(?:<|$))"), "<s>\\1</s>");
}
