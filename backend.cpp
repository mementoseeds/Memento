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

#include "backend.h"

Backend *Backend::m_instance = nullptr;

Backend::Backend(QObject *parent) : QObject(parent) {}

void Backend::debugFun()
{
    qDebug() << globalLevelSeeds;
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
        QFile infoFile(directory + "/info.json");

        if (!infoFile.exists())
            continue;

        infoFile.open(QIODevice::ReadOnly | QIODevice::Text);
        QString info = infoFile.readAll();
        infoFile.close();
        QJsonDocument courseInfo = QJsonDocument::fromJson(info.toUtf8());

        emit addCourse(
            directory,
            courseInfo["title"].toString(),
            courseInfo["author"].toString(),
            courseInfo["description"].toString(),
            courseInfo["category"].toString(),
            directory + "/" + courseInfo["icon"].toString(),
            courseInfo["items"].toInt(),
            courseInfo["planted"].toInt(),
            courseInfo["water"].toInt(),
            courseInfo["difficult"].toInt(),
            courseInfo["ignored"].toInt(),
            courseInfo["completed"].toBool()
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
        QFile infoFile(levelPath);
        infoFile.open(QIODevice::ReadOnly | QIODevice::Text);

        if (levelPath.endsWith(".json"))
        {
            QString info = infoFile.readAll();
            QJsonDocument levelInfo = QJsonDocument::fromJson(info.toUtf8());

            emit addCourseLevel(
                levelPath,
                levelInfo["title"].toString(),
                levelInfo["test"].toString(),
                levelInfo["prompt"].toString(),
                levelInfo["testType"].toString(),
                levelInfo["promptType"].toString(),
                true,
                levelInfo["seeds"].toObject().count(),
                levelInfo["completed"].toBool()
                        );
        }
        else if (levelPath.endsWith(".md"))
        {
            QString info = infoFile.readLine();
            QString levelTitle = QRegularExpression("\\(.*\\)$").match(info).captured().replace(QRegularExpression("^\\(|\\)$"), "");

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
    settings.setValue("autoAcceptAnswer", userSettings["autoAcceptAnswer"]);
}

QVariantMap Backend::getUserSettings()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "Memento", "config");
    userSettings.insert("coursesLocation", settings.value("coursesLocation").toString());
    userSettings.insert("countdownTimer", settings.value("countdownTimer", 10).toInt());
    userSettings.insert("autoAcceptAnswer", settings.value("autoAcceptAnswer", true).toBool());
    return userSettings;
}

QString Backend::readMediaLevel(QString levelPath)
{
    QFile mediaFile(levelPath);
    mediaFile.open(QIODevice::ReadOnly | QIODevice::Text);
    QString content = mediaFile.readAll();
    mediaFile.close();
    return content;
}

void Backend::getLevelItems(QString courseDirectory, QString levelPath)
{
    //Open the level
    QFile levelFile(levelPath);
    levelFile.open(QIODevice::ReadOnly | QIODevice::Text);
    QString levelContent = levelFile.readAll();
    levelFile.close();
    globalLevel = QJsonDocument::fromJson(levelContent.toUtf8());
    globalLevelSeeds = globalLevel["seeds"].toObject();
    levelContent.clear();
    QJsonObject levelSeeds = globalLevel["seeds"].toObject();

    //Open the seedbox
    QFile seedboxFile(courseDirectory + "/seedbox.json");
    seedboxFile.open(QIODevice::ReadOnly | QIODevice::Text);
    QString seedboxContent = seedboxFile.readAll();
    seedboxFile.close();
    globalSeedbox = QJsonDocument::fromJson(seedboxContent.toUtf8());
    seedboxContent.clear();

    //Get testing direction
    QString testColumn = globalLevel["test"].toString();
    QString promptColumn = globalLevel["prompt"].toString();

    foreach (QString id, levelSeeds.keys())
    {
        QJsonObject seed = levelSeeds[id].toObject();

        QString test = globalSeedbox[id][testColumn]["primary"].toString();
        QString prompt = globalSeedbox[id][promptColumn]["primary"].toString();

        emit addLevelItem(
            id,
            test,
            prompt,
            seed["planted"].toBool(),
            seed["nextWatering"].toString(),
            seed["ignored"].toBool(),
            seed["difficult"].toBool()
                    );
    }

    emit finishedAddingLevel();
}

void Backend::unloadGlobalLevel()
{
    globalLevel = QJsonDocument();
    globalLevelSeeds = QJsonObject();
}

void Backend::unloadSeedbox()
{
    globalSeedbox = QJsonDocument();
}

void Backend::readItem(QString itemId, QString testColumn, QString promptColumn)
{
    QJsonObject item = globalSeedbox[itemId].toObject();

    //Add audio
    QJsonArray audioArray = item["audio"].toArray();
    if (audioArray.count() > 0)
    {
        QStringList audioList;
        foreach (QJsonValue val, audioArray)
            audioList.append(val.toString());

        emit addItemDetails("audio", "Audio", audioList.join(":"));
    }

    //Add attributes
    QString attributes = item["attributes"].toString();
    if (attributes.length() > 0)
    {
        emit addItemDetails("attributes", "Attributes", attributes);
        emit addItemSeparator();
    }

    QJsonObject testColumnObj = item[testColumn].toObject();
    QJsonObject promptColumnObj = item[promptColumn].toObject();

    QStringList alternatives;

    // Add all test column info first
    emit addItemDetails(testColumnObj["type"].toString(), testColumn, testColumnObj["primary"].toString());
    foreach (QJsonValue val, testColumnObj["alternative"].toArray())
    {
        QString string = val.toString();
        if (!string.startsWith("_"))
            alternatives.append(string);
    }
    if (alternatives.length() > 0)
        emit addItemDetails("alternative", "Alternatives", alternatives.join(", "));
    alternatives.clear();
    emit addItemSeparator();

    // Add all prompt column info second
    emit addItemDetails(promptColumnObj["type"].toString(), promptColumn, promptColumnObj["primary"].toString());
    foreach (QJsonValue val, promptColumnObj["alternative"].toArray())
    {
        QString string = val.toString();
        if (!string.startsWith("_"))
            alternatives.append(string);
    }
    if (alternatives.length() > 0)
        emit addItemDetails("alternative", "Alternatives", alternatives.join(", "));
    alternatives.clear();
    emit addItemSeparator();

    // Add all remaining column info last
    foreach (QString column, item.keys())
    {
        if (item[column].isObject() && column.compare(testColumn) != 0 && column.compare(promptColumn) != 0)
        {
            QJsonObject columnData = item[column].toObject();
            emit addItemDetails(columnData["type"].toString(), column, columnData["primary"].toString());

            foreach (QJsonValue val, columnData["alternative"].toArray())
            {
                QString string = val.toString();
                if (!string.startsWith("_"))
                    alternatives.append(string);
            }
            if (alternatives.length() > 0)
                emit addItemDetails("alternative", "Alternatives", alternatives.join(", "));
            alternatives.clear();
            emit addItemSeparator();
        }
    }
}

QString Backend::readCourseTitle(QString courseDirectory)
{
    QFile infoFile(courseDirectory + "/info.json");
    infoFile.open(QIODevice::ReadOnly | QIODevice::Text);
    QString info = infoFile.readAll();
    infoFile.close();
    QJsonDocument courseInfo = QJsonDocument::fromJson(info.toUtf8());
    return courseInfo["title"].toString();
}

QString Backend::readItemAttributes(QString itemId)
{
    return globalSeedbox[itemId].toObject()["attributes"].toString();
}

QVariantList Backend::readItemColumn(QString itemId, QString column)
{
    QVariantList list;
    QJsonObject item = globalSeedbox[itemId].toObject()[column].toObject();
    list.append(item["type"].toString());
    list.append(item["primary"].toString());
    return list;
}

bool Backend::checkAnswer(QString itemId, QString column, QString answer)
{
    bool result = false;
    answer = answer.trimmed();

    QJsonObject item = globalSeedbox[itemId].toObject()[column].toObject();
    if (answer.compare(item["primary"].toString(), Qt::CaseInsensitive) == 0)
        result = true;
    else
    {
        foreach (QJsonValue val, item["alternative"].toArray())
        {
            if (val.toString().remove(QRegExp("^_")).compare(answer, Qt::CaseInsensitive) == 0)
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
    QJsonObject item = globalLevelSeeds[itemId].toObject();

    int successes = item["successes"].toInt() + 1;
    item["successes"] = successes;

    if (successes >= 5)
    {
        item["planted"] = true;

        int streak = item["streak"].toInt() + 1;
        item["streak"] = streak;

        item["nextWatering"] = getWateringTime(streak);
    }

    globalLevelSeeds[itemId] = item;
}

void Backend::wrongAnswer(QString itemId)
{
    QJsonObject item = globalLevelSeeds[itemId].toObject();
    item["failures"] = item["failures"].toInt() + 1;
    item["difficult"] = item["planted"].toBool();
    item["streak"] = 0;
    globalLevelSeeds[itemId] = item;
}

QString Backend::getWateringTime(int streak)
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

    return currentTime.addSecs(newTime).toString();
}
