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

Backend::Backend(QObject *parent) : QObject(parent) {}

void Backend::debugFun()
{
    qDebug() << "Hello there";
}

QString Backend::getLocalFile(QUrl url)
{
    return url.toLocalFile();
}

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

            emit addCourseLevel(levelPath, levelTitle, "", "", false, 0, false);
        }

        infoFile.close();
    }
}

void Backend::setUserSettings(QVariantMap userSettings)
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "Memento", "config");
    settings.setValue("coursesLocation", userSettings["coursesLocation"]);
}

QVariantMap Backend::getUserSettings()
{
    QSettings settings(QSettings::IniFormat, QSettings::UserScope, "Memento", "config");
    userSettings.insert("coursesLocation", settings.value("coursesLocation").toString());
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
    QJsonDocument levelInfo = QJsonDocument::fromJson(levelContent.toUtf8());
    levelContent.clear();
    QJsonObject levelSeeds = levelInfo["seeds"].toObject();

    //Open the seedbox
    QFile seedboxFile(courseDirectory + "/seedbox.json");
    seedboxFile.open(QIODevice::ReadOnly | QIODevice::Text);
    QString seedboxContent = seedboxFile.readAll();
    seedboxFile.close();
    QJsonDocument seedbox = QJsonDocument::fromJson(seedboxContent.toUtf8());
    seedboxContent.clear();

    //Get testing direction
    QString testColumn = levelInfo["test"].toString();
    QString promptColumn = levelInfo["prompt"].toString();

    foreach (QString id, levelSeeds.keys())
    {
        QJsonObject seed = levelSeeds[id].toObject();

        QString test = seedbox[id][testColumn]["primary"].toString();
        QString prompt = seedbox[id][promptColumn]["primary"].toString();

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

void Backend::loadSeedbox(QString courseDirectory)
{
    QFile seedboxFile(courseDirectory + "/seedbox.json");
    seedboxFile.open(QIODevice::ReadOnly | QIODevice::Text);
    QString seedboxContent = seedboxFile.readAll();
    seedboxFile.close();
    QJsonDocument globalSeedbox = QJsonDocument::fromJson(seedboxContent.toUtf8());
    seedboxContent.clear();
}

void Backend::unloadSeedbox()
{
    globalSeedbox.~QJsonDocument();
}
