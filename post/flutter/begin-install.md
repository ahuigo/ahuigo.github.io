---
title: flutter install
date: 2023-04-28
private: true
---
# Config flutter
## install flutter 
    git clone https://github.com/flutter/flutter.git -C ~
    cd ~/flutter
    cat > ~/.profile <<MM
    ################flutter dart###############
    export PUB_HOSTED_URL=https://pub.flutter-io.cn
    export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
    export PATH="$PATH:$HOME/flutter/bin"
    MM

执行:

    $ flutter doctor
    [✗] Android toolchain - develop for Android devices
        ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html

## install android sdk or　android　studio
不一定非要下载 Android Studio，但如果您打算使用 Flutter 开发 Android 应用，那么推荐安装 Android Studio，因为它集成了大量有用的工具和插件

### install android sdk(麻烦)
访问 https://developer.android.com/studio#cmdline-tools 下载合适的版本，并解压到您选择的目录中。

    export ANDROID_SDK_ROOT=~/android/
    export PATH=$PATH:$ANDROID_SDK_ROOT/bin:$ANDROID_SDK_ROOT/platform-tools
    ...
    #（将 <platform> 替换为目标 Android 平台版本，例如 android-33）：
    $ sdkmanager "platform-tools" "platforms;<platform>" "build-tools;<version>"

## android studio
1. download https://developer.android.com/studio
2. 启动android studio.app 下一步会自动下载sdk: `~/Library/Android/sdk`
3. 打开 Android Studio，然后找sdk位置： 打开 "Preferences"（或 "Settings"） 选择 "Appearance & Behavior" > "System Settings" > "Android SDK". 
    1. 切换到sdk tools, 选中android　sdk command-line tools 并下载

sdk包含了以下内容

    $ ls ~/Library/Android/sdk/
    emulator system-images #模拟器与镜像
    platform-tools 
    patcher        platforms
    build-tools    

配置sdk env

    export ANDROID_SDK_ROOT=~/Library/Android/sdk
    export ANDROID_HOME=$ANDROID_SDK_ROOT; #已弃用
    # https://developer.android.com/tools
    export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
    flutter config --android-sdk ~/Library/Android/sdk

    # studio自带了这个java jre
    #export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

再次检测:

    flutter doctor

accept　licences:

    flutter doctor --android-licenses

### AVD(Android Virtual Device Manager)
To configure graphics acceleration for an AVD, follow these steps:

1. Open the `AVD Manager`: via `more actions` in android studio project window.
1. Create a `new AVD` or edit an `existing AVD`.
1. In the **Verify Configuration window**, find the **Emulated Performance** section.
1. Select a value for the **Graphics**: option. 选择 Hardware - GLES 2.0 选项来开启 硬件加速
1. Click Finish.