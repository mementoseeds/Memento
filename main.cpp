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
#include "backend.h"

#ifdef Q_OS_ANDROID
static void sendCoursePath(JNIEnv *env, jobject thiz, jstring path)
{
    Q_UNUSED(thiz);

    QString fakePath = env->GetStringUTFChars(path, nullptr);
    QStringList paths = fakePath.split(":");
    QString startLocation = paths[0].split("/").last();
    if (startLocation.compare("primary") == 0)
        emit Backend::getGlobalBackendInstance()->sendCoursePath("/storage/emulated/0/" + paths[1]);
    else
        emit Backend::getGlobalBackendInstance()->sendCoursePath("/storage/" + startLocation + "/" + paths[1]);
}

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
    Q_UNUSED(reserved);

    JNIEnv* env;
    // get the JNIEnv pointer.
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK)
        return JNI_ERR;

    // search for the Java class which declares the native methods
    jclass mainActivityClass = env->FindClass("com/seeds/memento/MainActivity");
    if (!mainActivityClass)
        return JNI_ERR;

    //Set native method arrays
    JNINativeMethod mainActivityMethods[] = {
        {"javaSendCoursePath", "(Ljava/lang/String;)V", (void *)sendCoursePath}
    };

    // register the native methods
    if (env->RegisterNatives(mainActivityClass, mainActivityMethods, sizeof(mainActivityMethods) / sizeof(mainActivityMethods[0])) < 0)
        return JNI_ERR;

    return JNI_VERSION_1_6;
}
#endif

int main(int argc, char *argv[])
{
    #if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    #endif

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QCoreApplication::setApplicationName(QLatin1String("Memento"));
    QCoreApplication::setOrganizationName(QLatin1String("Memento Seeds"));

    QQuickStyle::setStyle("Material");

    qmlRegisterType<Backend>("TestType", 1, 0, "TestType");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
