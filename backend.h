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

class Backend : public QObject
{
    Q_OBJECT

    QML_ELEMENT

public:
    explicit Backend(QObject *parent = nullptr);

    Q_INVOKABLE void debugFun();

    Q_INVOKABLE QString getLocalFile(QUrl url);

    Q_INVOKABLE void getCourseList();
    Q_INVOKABLE void getCourseLevels(QString directory);

    Q_INVOKABLE void setUserSettings(QVariantMap userSettings);
    Q_INVOKABLE QVariantMap getUserSettings();

    Q_INVOKABLE QString readMediaLevel(QString levelPath);

    Q_INVOKABLE void getLevelItems(QString courseDirectory, QString levelPath);

signals:
    void addCourse(QString directory, QString title, QString author, QString description, QString category, QString icon, int items, int planted, int water, int difficult, int ignored, bool completed);
    void finishedAddingCourses();
    void addCourseLevel(QString levelPath, QString levelTitle, QString testColumnType, QString promptColumnType, bool isLearning, int itemAmount, bool levelCompleted);
    void addLevelItem(QString id, QString test, QString prompt, bool planted, QString nextWatering, bool ignored, bool difficult);
    void finishedAddingLevel();

private:

    QVariantMap userSettings;
};

#endif // BACKEND_H
