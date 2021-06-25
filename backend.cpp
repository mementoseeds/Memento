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

void Backend::getCourseList()
{
    QDir coursesDir(userSettings["coursesLocation"].toString());
    foreach (QString dir, coursesDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
        QString directory = coursesDir.absolutePath() + "/" + dir;
        std::ifstream infoFile(QString(directory + "/info.json").toStdString());

        if (infoFile.fail())
            continue;

        Json courseInfo;
        infoFile >> courseInfo;
        infoFile.close();


        emit addCourse(
            directory,
            QString::fromStdString(courseInfo["title"].get<String>()),
            QString::fromStdString(courseInfo["author"].get<String>()),
            QString::fromStdString(courseInfo["description"].get<String>()),
            QString::fromStdString(courseInfo["category"].get<String>()),
            directory + "/" + QString::fromStdString(courseInfo["icon"].get<String>()),
            courseInfo["items"].get<int>(),
            courseInfo["planted"].get<int>(),
            courseInfo["water"].get<int>(),
            courseInfo["difficult"].get<int>(),
            courseInfo["ignored"].get<int>(),
            courseInfo["completed"].get<bool>()
                    );
    }

    emit finishedAddingCourses();
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

void Backend::setUserSettings(QVariantMap userSettings)
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "Memento", "config");
    settings.setValue("coursesLocation", userSettings["coursesLocation"]);
    settings.setValue("countdownTimer", userSettings["countdownTimer"]);
    settings.setValue("cooldownTimer", userSettings["cooldownTimer"]);
    settings.setValue("maxPlantingItems", userSettings["maxPlantingItems"]);
    settings.setValue("autoRefreshCourses", userSettings["autoRefreshCourses"]);
    settings.setValue("autoAcceptAnswer", userSettings["autoAcceptAnswer"]);
    settings.setValue("enableTestPromptSwitch", userSettings["enableTestPromptSwitch"]);
    settings.setValue("showAutoLearnOnTests", userSettings["showAutoLearnOnTests"]);
    settings.setValue("enabledTests", userSettings["enabledTests"]);
}

QVariantMap Backend::getUserSettings()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "Memento", "config");
    userSettings.insert("coursesLocation", settings.value("coursesLocation").toString());
    userSettings.insert("countdownTimer", settings.value("countdownTimer", 10).toInt());
    userSettings.insert("cooldownTimer", settings.value("cooldownTimer", 2000).toInt());
    userSettings.insert("maxPlantingItems", settings.value("maxPlantingItems", 5).toInt());
    userSettings.insert("autoRefreshCourses", settings.value("autoRefreshCourses", false).toBool());
    userSettings.insert("autoAcceptAnswer", settings.value("autoAcceptAnswer", true).toBool());
    userSettings.insert("enableTestPromptSwitch", settings.value("enableTestPromptSwitch", false).toBool());
    userSettings.insert("showAutoLearnOnTests", settings.value("showAutoLearnOnTests", false).toBool());
    userSettings.insert("enabledTests", settings.value("enabledTests").toMap());

    QVariantMap testCheck = userSettings["enabledTests"].toMap();

    if (!testCheck["enabledMultipleChoice"].toBool() && !testCheck["enabledTyping"].toBool() && !testCheck["enabledTapping"].toBool())
    {
        testCheck["enabledMultipleChoice"] = testCheck["enabledTyping"] = testCheck["enabledTapping"] = true;
        userSettings["enabledTests"] = testCheck;
    }

    return userSettings;
}

QString Backend::readMediaLevel(QString levelPath)
{
    QFile mediaFile(levelPath);
    mediaFile.open(QIODevice::ReadOnly | QIODevice::Text);
    return mediaFile.readAll();
}

void Backend::getLevelItems(QString courseDirectory, QString levelPath)
{
    //Open the level
    std::ifstream levelFile(levelPath.toStdString());
    levelFile >> globalLevel;
    levelFile.close();
    globalLevelSeeds = globalLevel["seeds"];
    globalSeedsAmount = globalLevelSeeds.size();

    //Open the seedbox
    std::ifstream seedboxFile(QString(courseDirectory + "/seedbox.json").toStdString());
    seedboxFile >> globalSeedbox;
    seedboxFile.close();

    //Get testing direction
    String testColumn = globalLevel["test"].get<String>();
    String promptColumn = globalLevel["prompt"].get<String>();

    for (auto &item : globalLevelSeeds.items())
    {
        String id = item.key();

        QString test = QString::fromStdString(globalSeedbox[id][testColumn]["primary"].get<String>());
        QString prompt = QString::fromStdString(globalSeedbox[id][promptColumn]["primary"].get<String>());

        emit addLevelItem(
            QString::fromStdString(id),
            test,
            prompt,
            globalLevelSeeds[id]["planted"].get<bool>(),
            getReviewTime(QString::fromStdString(globalLevelSeeds[id]["nextWatering"].get<String>())),
            globalLevelSeeds[id]["ignored"].get<bool>(),
            globalLevelSeeds[id]["difficult"].get<bool>()
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

void Backend::setReviewType(bool manualReview, bool mockWater)
{
    this->manualReview = manualReview;
    this->mockWater = mockWater;
}

void Backend::loadCourseInfo(QString courseDirectory)
{
    std::ifstream infoFile(QString(courseDirectory + "/info.json").toStdString());
    infoFile >> globalInfo;
    infoFile.close();
}

bool Backend::checkAnswer(QString itemId, QString column, QString answer)
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

    if (!mockWater)
    {
        if (result)
            correctAnswer(itemId);
        else
            wrongAnswer(itemId);
    }

    return result;
}

void Backend::correctAnswer(QString itemId)
{
    String id = itemId.toStdString();

    Json item = globalLevelSeeds[id];

    int successes = item["successes"].get<int>() + 1;
    item["successes"] = successes;

    if (successes >= 5 && (unlockedItems[itemId] || !manualReview))
    {
        unlockedItems[itemId] = !manualReview;

        item["planted"] = true;

        int streak = item["streak"].get<int>() + 1;
        item["streak"] = streak;

        item["nextWatering"] = getWateringTime(streak);
    }

    globalLevelSeeds[id] = item;
}

void Backend::wrongAnswer(QString itemId)
{
    String id = itemId.toStdString();

    Json item = globalLevelSeeds[id];
    item["failures"] = item["failures"].get<int>() + 1;
    item["difficult"] = item["planted"].get<bool>();
    item["streak"] = 0;

    unlockedItems[itemId] = true;

    globalLevelSeeds[id] = item;
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
    int completedSeeds = 0;
    for (auto &item : globalLevelSeeds.items())
    {
        if (globalLevelSeeds[item.key()]["planted"].get<bool>())
            completedSeeds++;
    }
    globalLevel["completed"] = (completedSeeds == globalSeedsAmount);

    globalLevel["seeds"] = globalLevelSeeds;

    std::ofstream level(levelPath.toStdString());
    level << globalLevel.dump(jsonIndent) << std::endl;
    level.close();
}

const Json Backend::getRandom(const Json json, bool returnKey)
{
    auto it = json.cbegin();
    int random = QRandomGenerator::global()->generate() % json.size();
    std::advance(it, random);
    if (returnKey)
        return it.key();
    else
        return *it;
}

void Backend::getLevelResults(QString  testColumn, QString  promptColumn, QVariantList itemArray)
{
    String test = testColumn.toStdString();
    String prompt = promptColumn.toStdString();
    foreach (QVariant itemId, itemArray)
    {
        String id = itemId.toString().toStdString();

        emit addItemResults(
            QString::fromStdString(globalSeedbox[id][test]["primary"].get<String>()),
            QString::fromStdString(globalSeedbox[id][test]["type"].get<String>()),
            QString::fromStdString(globalSeedbox[id][prompt]["primary"].get<String>()),
            QString::fromStdString(globalSeedbox[id][prompt]["type"].get<String>()),
            globalLevelSeeds[id]["successes"].get<int>(),
            globalLevelSeeds[id]["failures"].get<int>(),
            globalLevelSeeds[id]["streak"].get<int>()
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

void Backend::autoLearn(QVariantList itemArray, QString levelPath)
{
    foreach (QVariant item, itemArray)
    {
        String id = item.toString().toStdString();

        globalLevelSeeds[id]["planted"] = true;
        globalLevelSeeds[id]["nextWatering"] = getWateringTime(1);
        globalLevelSeeds[id]["ignored"] = false;
        globalLevelSeeds[id]["difficult"] = false;
        globalLevelSeeds[id]["successes"] = 5;
        globalLevelSeeds[id]["failures"] = 0;
        globalLevelSeeds[id]["streak"] = 1;
    }

    saveLevel(levelPath);
}

void Backend::refreshCourses(QVariantList courses)
{
    //Pass this operation to another thread
    Controller *threadController = new Controller;
    connect(threadController, &Controller::workFinished, this, &Backend::finishedRefreshingCourses);
    emit threadController->requestCourseRefresh(courses);
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
        QStringList randomChars = QString::fromStdString(globalSeedbox[key][itemColumn]["primary"].get<String>()).remove(" ").toLower().split("", Qt::SkipEmptyParts);

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
    globalLevelSeeds[itemId.toStdString()]["ignored"] = ignored;
    saveLevel(levelPath);
}

void Backend::autoLearnItem(QString itemId, int streakCount)
{
    //Called from button during planting
    String id = itemId.toStdString();
    globalLevelSeeds[id]["planted"] = true;
    globalLevelSeeds[id]["nextWatering"] = getWateringTime(streakCount);
    globalLevelSeeds[id]["ignored"] = false;
    globalLevelSeeds[id]["difficult"] = false;
    globalLevelSeeds[id]["successes"] = 5;
    globalLevelSeeds[id]["failures"] = 0;
    globalLevelSeeds[id]["streak"] = streakCount;
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
            levelJson["seeds"][id]["successes"] = learn ? 5 + streak : 0;
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

QVariantMap Backend::getWateringItems(QString courseDirectory, int count)
{
    count = 10;

    std::ifstream reviewFile(QString(courseDirectory + "/review.json").toStdString());
    Json review;
    reviewFile >> review;
    reviewFile.close();

//    QVariantMap test{{"234798234", 2}};
//    QVariantList tests = {test};
//    QVariantMap testmap{{"1.json", tests}};
//    qDebug() << testmap;

    for (auto &levelName : review)
    {
        String name = levelName.get<String>();
        std::ifstream levelFile(QString(courseDirectory + "/levels/").toStdString() + name);
        Json levelJson;
        levelFile >> levelJson;
        levelFile.close();
        jsonMap.insert(QString::fromStdString(name), levelJson);
    }

    //qDebug() << QString::fromStdString(jsonMap["00001.json"]["seeds"]["67742555"]["nextWatering"].get<String>());



    return QVariantMap();
}
