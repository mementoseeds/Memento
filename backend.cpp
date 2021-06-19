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
    //toStdString() = QString --> std::string
    //QString::fromStdString(std::string) = std::string --> QString
    //qDebug() << globalLevelSeeds;
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
    settings.setValue("autoRefreshCourses", userSettings["autoRefreshCourses"]);
    settings.setValue("autoAcceptAnswer", userSettings["autoAcceptAnswer"]);
    settings.setValue("enableTestPromptSwitch", userSettings["enableTestPromptSwitch"]);
    settings.setValue("enabledTests", userSettings["enabledTests"]);
}

QVariantMap Backend::getUserSettings()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "Memento", "config");
    userSettings.insert("coursesLocation", settings.value("coursesLocation").toString());
    userSettings.insert("countdownTimer", settings.value("countdownTimer", 10).toInt());
    userSettings.insert("autoRefreshCourses", settings.value("autoRefreshCourses", false).toBool());
    userSettings.insert("autoAcceptAnswer", settings.value("autoAcceptAnswer", true).toBool());
    userSettings.insert("enableTestPromptSwitch", settings.value("enableTestPromptSwitch", true).toBool());
    userSettings.insert("enabledTests", settings.value("enabledTests").toMap());
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

    //Add audio
    Json audioArray = item["audio"];

    if (!audioArray.empty())
    {
        QStringList audioList;
        for (auto &val : audioArray)
            if (!val.is_null())
                audioList.append(QString::fromStdString(val.get<String>()));

        if (!audioList.isEmpty())
            emit addItemDetails("audio", "Audio", audioList.join(":"));
    }

    //Add attributes
    QString attributes = QString::fromStdString(item["attributes"].get<String>());
    if (!attributes.isEmpty())
    {
        emit addItemDetails("attributes", "Attributes", attributes);
        emit addItemSeparator();
    }

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

        if (item[column].is_object() && column.compare(stdTestColumn) != 0 && column.compare(stdPromptColumn) != 0)
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

QString Backend::readCourseTitle(QString courseDirectory)
{
    std::ifstream infoFile(QString(courseDirectory + "/info.json").toStdString());
    Json courseInfo;
    infoFile >> courseInfo;
    infoFile.close();
    return QString::fromStdString(courseInfo["title"].get<String>());
}

QString Backend::readItemAttributes(QString itemId)
{
    return QString::fromStdString(globalSeedbox[itemId.toStdString()]["attributes"].get<String>());
}

QVariantList Backend::readItemColumn(QString itemId, QString column)
{
    QVariantList list;
    Json item = globalSeedbox[itemId.toStdString()][column.toStdString()];
    list.append(QString::fromStdString(item["type"].get<String>()));
    list.append(QString::fromStdString(item["primary"].get<String>()));
    return list;
}

QString Backend::readItemAudio(QString itemId)
{
    QString itemAudio = "";
    Json audio = globalSeedbox[itemId.toStdString()]["audio"][0];
    if (audio.is_string())
        itemAudio = QString::fromStdString(audio.get<String>());

    return itemAudio;
}

bool Backend::getLevelCompleted()
{
    return globalLevel["completed"].get<bool>();
}

void Backend::setManualReview(bool manualReview)
{
    this->manualReview = manualReview;
    streakUnlocked = !manualReview;
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

    if (result)
        correctAnswer(itemId);
    else
        wrongAnswer(itemId);

    return result;
}

void Backend::correctAnswer(QString itemId)
{
    String id = itemId.toStdString();

    Json item = globalLevelSeeds[id];

    int successes = item["successes"].get<int>() + 1;
    item["successes"] = successes;

    if (successes >= 5 && streakUnlocked)
    {
        streakUnlocked = !manualReview;

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

    streakUnlocked = true;

    globalLevelSeeds[id] = item;
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
    return parseTime(duration);
}

QString Backend::parseTime(uint seconds)
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
        return QString::number(seconds / 60) + " minutes : " + QString::number(seconds % 60) + " seconds";
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
                if (list.contains(value))
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
