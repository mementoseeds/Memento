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
    QDirIterator iterator(userSettings["coursesLocation"].toString(), QDir::Dirs | QDir::NoDotAndDotDot);
    while (iterator.hasNext())
    {
        QString directory = iterator.next();
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
    QDirIterator iterator(directory + "/levels", QDir::Files);
    while (iterator.hasNext())
    {
        QString levelPath = iterator.next();
        QFile infoFile(levelPath);
        infoFile.open(QIODevice::ReadOnly | QIODevice::Text);

        if (levelPath.endsWith(".json", Qt::CaseInsensitive))
        {
            QString info = infoFile.readAll();
            QJsonDocument levelInfo = QJsonDocument::fromJson(info.toUtf8());

            emit addCourseLevel(
                levelPath,
                levelInfo["title"].toString(),
                true,
                levelInfo["seeds"].toArray().count(),
                levelInfo["completed"].toBool()
                        );
        }
        else if (levelPath.endsWith(".md", Qt::CaseInsensitive))
        {
            QString info = infoFile.readLine();
            QString levelTitle = QRegularExpression("\\(.*\\)$").match(info).captured().replace(QRegularExpression("^\\(|\\)$"), "");

            emit addCourseLevel(levelPath, levelTitle, false, 0, false);
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
