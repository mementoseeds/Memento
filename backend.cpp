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

void Backend::getCourseList()
{
    QDirIterator iterator(coursesDir, QDir::Dirs | QDir::NoDotAndDotDot);
    while (iterator.hasNext())
    {
        QString directory = iterator.next();
        QFile infoFile(directory + "/info.json");
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
            courseInfo["seeds"].toInt(),
            courseInfo["planted"].toInt(),
            courseInfo["water"].toInt(),
            courseInfo["difficult"].toInt(),
            courseInfo["ignored"].toInt(),
            courseInfo["completed"].toBool()
                    );
    }
}
