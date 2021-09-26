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

void Worker::doCourseRefresh(QString coursesLocation, QString courseSorting)
{
    QDir coursesDir(coursesLocation);
    QStringList allCourses = coursesDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    QMultiMap<QString, QString> courseCategories;
    QMultiMap<quint64, QString> courseTimes;
    QStringList courseSelection;

    foreach (QString course, allCourses)
    {
        QString coursePath = coursesLocation + "/" + course;

        if (!QFile::exists(coursePath + "/info.json"))
            continue;

        Json info;
        try
        {
            std::ifstream infoFile(QString(coursePath + "/info.json").toStdString());
            infoFile >> info;
            infoFile.close();
        }
        catch (Json::parse_error &e)
        {
            qCritical() << "Error reading info.json --> " + coursePath;
            continue;
        }

        courseCategories.insert(QString::fromStdString(info["category"].get<String>()), course);

        try
        {
            courseTimes.insert(QDateTime::fromString(QString::fromStdString(info["lastLearned"].get<String>())).toSecsSinceEpoch(), course);
        }
        catch (Json::type_error &e)
        {
            courseTimes.insert(0, course);
        }
    }

    //Send list of categories to QML
    QList<QString> categories = courseCategories.uniqueKeys();
    emit workerAddAllCourseCategories(categories);

    if (courseSorting.compare("Recently learned") == 0)
    {
        //Sort by last learned time
        foreach (quint64 time, courseTimes.uniqueKeys())
            courseSelection.append(courseTimes.values(time));

        std::reverse(courseSelection.begin(), courseSelection.end());
    }
    else if (courseSorting.compare("Category") == 0)
    {
        //Sort by category
        foreach (QString category, categories)
        {
            QList<QString> coursesByCategory = courseCategories.values(category);
            std::reverse(coursesByCategory.begin(), coursesByCategory.end());
            courseSelection.append(coursesByCategory);
        }
    }
    else if (courseSorting.compare("Name") == 0)
    {
        //Sort by course names
        courseSelection = allCourses;
    }
    else
    {
        QList<QString> filteredCourses = courseCategories.values(courseSorting);
        std::reverse(filteredCourses.begin(), filteredCourses.end());
        courseSelection.append(filteredCourses);
    }


    foreach (QString course, courseSelection)
    {
        QString coursePath = coursesLocation + "/" + course;

        try
        {
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
                String stdLvl = lvl.toStdString();
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

                            if (std::find(review.begin(), review.end(), stdLvl) == review.end())
                                review.push_back(stdLvl);
                        }
                    }

                    bool itemIgnored = level["seeds"][id]["ignored"].get<bool>();

                    if (!itemIgnored)
                        difficult += (int)level["seeds"][id]["difficult"].get<bool>();

                    ignored += (int)itemIgnored;
                }
            }

            std::ofstream reviewFile(QString(coursePath + "/review.json").toStdString());
            reviewJson = review;
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

            emit workerAddCourse(
                coursePath,
                QString::fromStdString(info["title"].get<String>()),
                QString::fromStdString(info["author"].get<String>()),
                QString::fromStdString(info["description"].get<String>()),
                QString::fromStdString(info["category"].get<String>()),
                coursePath + "/" + QString::fromStdString(info["icon"].get<String>()),
                info["items"].get<int>(),
                info["planted"].get<int>(),
                info["water"].get<int>(),
                info["difficult"].get<int>(),
                info["ignored"].get<int>(),
                info["completed"].get<bool>()
                        );
        }
        catch (Json::parse_error &e)
        {
            qCritical() << "Error reading course directory --> " + coursePath;
            continue;
        }
    }

    emit workerCourseRefreshFinished();
}

void Worker::doGetCourseDifficultItems(QString courseDirectory)
{
    QDir courseDir(courseDirectory + "/levels");
    QString absolutePath = courseDir.absolutePath() + "/";
    foreach (QString lvl, courseDir.entryList({"*.json"}, QDir::Files))
    {
        QString levelPath = absolutePath + lvl;

        std::ifstream levelFile(levelPath.toStdString());
        Json levelJson;
        levelFile >> levelJson;
        levelFile.close();

        for (auto &item : levelJson["seeds"].items())
        {
            String id = item.key();

            if (levelJson["seeds"][id]["difficult"].get<bool>() && !levelJson["seeds"][id]["ignored"].get<bool>())
                emit workerGetDifficultItemInfo(levelPath, QString::fromStdString(id), QString::fromStdString(levelJson["test"].get<String>()), QString::fromStdString(levelJson["prompt"].get<String>()));
        }
    }

    emit finishedGetDifficultItemInfo();
}
