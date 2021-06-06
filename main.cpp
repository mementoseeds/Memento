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

#include <QApplication>
#include <QQmlApplicationEngine>
#ifdef Q_OS_ANDROID
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
Q_IMPORT_PLUGIN(KirigamiPlugin)
#endif
#include "backend.h"

int main(int argc, char *argv[])
{
    #if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    #endif

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QCoreApplication::setApplicationName(QLatin1String("Memento"));
    QCoreApplication::setOrganizationName(QLatin1String("Memento Seeds"));

    #ifdef Q_OS_ANDROID
    KirigamiPlugin::getInstance().registerTypes(&engine);
    #endif

    Backend::registerTestTypeInQML();

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
