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
#ifndef WORKER_H
#define WORKER_H

#include "backend.hpp"

class Worker : public QObject
{
    Q_OBJECT

public:
    explicit Worker(QObject *parent = nullptr);

public slots:

    void doCourseRefresh(QString coursesLocation);

    void doGetCourseDifficultItems(QString courseDirectory);

private:

    //Constants
    const int jsonIndent = 4;

signals:
    void refreshFinished();

    void workerGetDifficultItemInfo(QString levelPath, QString itemId, QString testColumn, QString promptColumn);
    void finishedGetDifficultItemInfo();
};

#endif // WORKER_H
