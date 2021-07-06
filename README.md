
# Memento
Memento is a cross-platform, offline, spaced-repetition learning application. It is made with the intent to be clean, simple to use and easily configurable to one's needs.

# Video demonstration
[Memento v0.5 PC](https://www.youtube.com/watch?v=YV9dPNs5yjI)

# Downloading Memrise courses
To download a Memrise course and convert it to a Mememto-compatible format, you must run the Python script in the folder `helper_scripts`. This works best through a PC.
1. Install Python for your PC
- Windows or OS X - https://www.python.org/downloads
- Linux - install it from your distro's package manager
2. Install the Python dependencies `requests`, `lxml` and `beautifulsoup4` for example from pip.
- How to get pip for Windows if you do not have it already - [https://phoenixnap.com/kb/install-pip-windows](https://phoenixnap.com/kb/install-pip-windows)
- Install dependencies like this
```bash
python -m pip install requests lxml beautifulsoup4
```
3. Download the two Python scripts in the `helper_scripts` folder, run the script called `scrape_memrise.py` and follow its instructions.

# Build instructions:

# Linux:
1. Install the dependency `qt5-base` for your distribution
2. Execute the following:
```bash
git clone "https://github.com/mementoseeds/Memento"
cd Memento
mkdir build-dir && cd build-dir
qmake  ../memento.pro -spec linux-g++ CONFIG+=qtquickcompiler
make install
```

Memento, its icon and desktop file will now be placed in an `output` directory in the source code directory. You can now place these files wherever you wish.

# Windows 10 64-bit:

1. Download the open source version of Qt from https://www.qt.io/download-qt-installer.
2. Register a Qt account to log into the installer.
3. Start the installer, when you need to select which components to install, open the subdirectory `Qt/Qt 5.15.2`. From there choose the components:
- MinGW 8.1.0 64-bit
4. Continue with the installation and finish it. You should now have Qt and Qt Creator installed on your computer and the main Qt SDK folder should be located in `C:\Qt`.
5. Git clone the source code to a directory. In this example I'll use `C:\Users\YOUR_USER_NAME\Desktop\src`.
6. For this example I'll show how to build the application in two folders on your desktop. Create the folder `C:\Users\YOUR_USER_NAME\Desktop\Build`.
7. Execute the following PowerShell script **after** replacing all instances of `YOUR_USER_NAME` with your Windows username:
```bash
$BUILDDIR = "C:\Users\YOUR_USER_NAME\Desktop\Build"
$SRCDIR = "C:\Users\YOUR_USER_NAME\Desktop\src"

$Env:Path = "C:\Qt\Tools\mingw810_64\bin;C:\Qt\5.15.2\mingw81_64\bin;C:\Qt\Tools\mingw810_64\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\ProgramData\chocolatey\bin;C:\Users\YOUR_USER_NAME\AppData\Local\Microsoft\WindowsApps;"

echo "Compiling"
rm -Recurse -Force "$BUILDDIR\*"
cd "$BUILDDIR"
C:\Qt\5.15.2\mingw81_64\bin\qmake.exe "$SRCDIR\memento.pro" -spec win32-g++ "CONFIG+=qtquickcompiler"
C:\Qt\Tools\mingw810_64\bin\mingw32-make.exe -f "$BUILDDIR/Makefile" qmake_all
C:\Qt\Tools\mingw810_64\bin\mingw32-make.exe -j8

echo "Deploying"
mv "$BUILDDIR\release\Memento.exe" "C:\Users\YOUR_USER_NAME\Desktop"
rm -Recurse -Force "$BUILDDIR\*"
mv "C:\Users\YOUR_USER_NAME\Desktop\Memento.exe" "$BUILDDIR"
C:\Qt\5.15.2\mingw81_64\bin\windeployqt.exe --no-translations --qmldir "$SRCDIR" "$BUILDDIR"
cp "C:\Qt\5.15.2\mingw81_64\bin\libgcc_s_seh-1.dll" "$BUILDDIR"
cp "C:\Qt\5.15.2\mingw81_64\bin\libstdc++-6.dll" "$BUILDDIR"
cp "C:\Qt\5.15.2\mingw81_64\bin\libwinpthread-1.dll" "$BUILDDIR"
```

You will now have a portable version of Memento in the directory `C:\Users\YOUR_USER_NAME\Desktop\Build`.

# Android:
The Android built steps are executed on a Linux host operating system, but they should be the same on Windows too. This will produce a multi-ABI APK for the architectures `armeabi-v7a` and `arm64-v8a`.

1. Download the open source version of Qt from https://www.qt.io/download-qt-installer.
2. Register a Qt account to log into the installer.
3. Start the installer, when you need to select which components to install, open the subdirectory `Qt/Qt 5.15.2`. From there choose the components:
- Desktop gcc 64-bit
- Android
4. The main Qt SDK folder should be located in `$HOME/Qt`.
5. Install Android Studio.
6. Open Android Studio and click on `Configure`, then `SDK Manager` and you should be in the `SDK Platforms` tab.
7. Install an SDK such as `Android 11`. It does not matter which SDK you install as long as it is above Android 5 (API Level 21) because that is the minimum supported version for Qt 5.15
8. Go to the `SDK Tools` tab and click on `Show Package Details` from the bottom of the settings window.
9. Drop down `Android SDK Build-Tools` and select version `30.0.2`.
10. Drop down `NDK (Side by side)` and select exactly version `21.3.*`.
11. Drop down `Android SDK Command-line Tools (latest)` and select `Android SDK Command-line Tools (latest)`.
12. Click ok and let it download and install everything necessary.
13. Open Qt Creator, go to `Tools` from the top menu, click on `Options`, then in the new window select `Devices` from the list on the left and choose the `Android` tab.
14. Check that the `JDK location` is valid. If you do not have JDK, install the latest version such as `jre-openjdk`. If this is ready Qt Creator will display a check mark and output `Java Settings are OK`.
15. Confirm that Qt Creator has successfully found the SDK and NDK by checking `Android SDK location` and `Android NDK list`. If it has not managed to find the correct directories, paste them in manually. If this is ready Qt Creator will display a check mark and output `Android Settings are OK. (SDK Version: 4.0, NDK Version: 21.3.*)`.
16. Make sure Qt Creator has placed a check mark on the following requirements:
- Android SDK path exists.
- Android SDK path writable.
- SDK tools installed.
- Build tools installed.
- SDK mnager runs (SDK Tools versions <= 26.x require exactly Java 1.8).
- Platform SDK installed.
- All essential packages installed for all installed Qt versions.
17. When entering the `Android` tab, if Qt Creator warns you that any packages are missing and offers to install them automatically, accept it.
18. All prerequisites should now be set up. Go to the `Kits` page in the options window and confirm that Qt Creator has automatically created kits for Android.
19. I recommend building the APK on a fast device such as an SSD or in the `/tmp` directory, otherwise the compilation could take multiple minutes on a mechanical hard drive.
20. Execute the following:
```bash
git clone "https://github.com/mementoseeds/Memento"
cd Memento
mkdir build-dir && cd build-dir
ANDROID_NDK_ROOT=$HOME/Android/Sdk/ndk/21.3.6528147 $HOME/Qt/5.15.2/android/bin/qmake ../memento.pro -spec android-clang CONFIG+=qtquickcompiler 'ANDROID_ABIS=armeabi-v7a arm64-v8a'
$HOME/Android/Sdk/ndk/21.3.6528147/prebuilt/linux-x86_64/bin/make -f Makefile qmake_all
$HOME/Android/Sdk/ndk/21.3.6528147/prebuilt/linux-x86_64/bin/make -j$(nproc)
$HOME/Android/Sdk/ndk/21.3.6528147/prebuilt/linux-x86_64/bin/make INSTALL_ROOT="$PWD/output" install
ANDROID_SDK_ROOT=$HOME/Android/Sdk $HOME/Qt/5.15.2/android/bin/androiddeployqt --input "$PWD/android-memento-deployment-settings.json" --output "$PWD/output" --android-platform android-30 --jdk /usr/lib/jvm/java-15-openjdk --gradle
```

You can now find the finished APK file in the directory `output/build/outputs/apk/debug/output-debug.apk` and install it on an Android device.

## Developer's note
Unfortunately I do not have access to any devices running Mac OS X so I cannot build a Memento version for Mac or iOS. If anyone wishes to build it themselves, you can start from these instructions:
- https://doc.qt.io/qt-5/macos-deployment.html
- https://doc.qt.io/qt-5/ios.html