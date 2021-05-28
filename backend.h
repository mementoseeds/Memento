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
#include <QDirIterator>

//For reading Jsons
#include <QJsonArray>
#include <QJsonDocument>

class Backend : public QObject
{
    Q_OBJECT

    QML_ELEMENT

public:
    explicit Backend(QObject *parent = nullptr);

    Q_INVOKABLE void debugFun();

    Q_INVOKABLE void getCourseList();

signals:
    void addCourse(QString directory, QString title, QString author, QString description, QString category, QString icon, int seeds, int levels, int planted, int water, int difficult, int ignored, bool completed);

private:

    //Const values
    const QString coursesDir = "/tmp/test/courses/";
};

#endif // BACKEND_H
