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

#pragma once
#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "backend.hpp"

class Controller : public QObject
{
    Q_OBJECT

    QThread workerThread;

public:
    Controller()
    {
        Worker *worker = new Worker;
        worker->moveToThread(&workerThread);

        connect(&workerThread, &QThread::finished, worker, &QObject::deleteLater);

        //Courses refresh
        connect(this, &Controller::requestCourseRefresh, worker, &Worker::doCourseRefresh);
        connect(worker, &Worker::refreshFinished, this, &Controller::courseRefreshFinished);

        //Get difficult items
        connect(this, &Controller::requestGetCourseDifficultItems, worker, &Worker::doGetCourseDifficultItems);
        connect(worker, &Worker::workerGetDifficultItemInfo, this, &Controller::controllerGetDifficultItemInfo);
        connect(worker, &Worker::finishedGetDifficultItemInfo, this, &Controller::finishedGetDifficultItemInfo);

        workerThread.start();
    }

    ~Controller()
    {
        if (workerThread.isRunning())
        {
            workerThread.quit();
            workerThread.wait();
        }
    }

public slots:

signals:
    void requestCourseRefresh(QString coursesLocation);
    void courseRefreshFinished();

    void requestGetCourseDifficultItems(QString courseDirectory);
    void controllerGetDifficultItemInfo(QString levelPath, QString itemId, QString testColumn, QString promptColumn);
    void finishedGetDifficultItemInfo();
};


#endif // CONTROLLER_H
