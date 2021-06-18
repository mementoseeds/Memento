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

#include "worker.hpp"

Worker::Worker(QObject *parent) : QObject(parent) {}

void Worker::doCourseRefresh(QVariantList courses)
{
    foreach (QVariant course, courses)
    {
        QString coursePath = course.toString();

        QDir courseDir(coursePath + "/levels");

        bool completed = true;
        unsigned int totalItems = 0;
        unsigned int planted = 0;
        unsigned int water = 0;
        unsigned int difficult = 0;
        unsigned int ignored = 0;

        Json reviewJson;
        std::vector<String> review;

        foreach (QString lvl, courseDir.entryList({"*.json"}, QDir::Files))
        {
            QString levelPath = coursePath + "/levels/" + lvl;
            std::ifstream levelFile(levelPath.toStdString());
            Json level;
            levelFile >> level;
            levelFile.close();

            if (!level["completed"].get<bool>())
                completed = false;

            totalItems += level["seeds"].size();

            for (auto &item : level["seeds"].items())
            {
                String id = item.key();

                bool itemPlanted = level["seeds"][id]["planted"].get<bool>();

                planted += (int)itemPlanted;

                if (itemPlanted)
                {
                    QDateTime nextWatering = QDateTime::fromString(QString::fromStdString(level["seeds"][id]["nextWatering"].get<String>()));

                    if (QDateTime::currentDateTime() > nextWatering)
                    {
                        water++;
                        review.push_back(id);
                    }
                }

                difficult += (int)level["seeds"][id]["difficult"].get<bool>();

                ignored += (int)level["seeds"][id]["ignored"].get<bool>();
            }

            reviewJson[lvl.toStdString()] = review;
            review.clear();
        }

        std::ofstream reviewFile(QString(coursePath + "/review.json").toStdString());
        reviewFile << reviewJson.dump(jsonIndent) << std::endl;
        reviewFile.close();

        String infoPath = QString(coursePath + "/info.json").toStdString();
        Json info;
        //Open a mini scope to prevent infoFile naming conflict
        {
            std::ifstream infoFile(infoPath);
            infoFile >> info;
            infoFile.close();

            info["items"] = totalItems;
            info["planted"] = planted;
            info["water"] = water;
            info["difficult"] = difficult;
            info["ignored"] = ignored;
            info["completed"] = completed;
        }

        std::ofstream infoFile(infoPath);
        infoFile << info.dump(jsonIndent) << std::endl;
        infoFile.close();
    }

    emit refreshFinished();
}
