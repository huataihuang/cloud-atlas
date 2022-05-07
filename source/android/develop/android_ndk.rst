.. _android_ndk:

=================
Android NDK
=================

Native Development Kit(NDK)是在Android中提供使用C和C++开发的工具集，提供了平台库用于管理原生活动以及访问物理设备组件，例如传感器和触摸输入设备。NDK可能适合大多数只使用Java以及框架API开发Android应用的新手，但是NDK在以下情况下非常有用:

- 需要达到极低延迟的设备性能，或者计算敏感应用，如游戏和物理模拟
- 重用你自己或其他开发者的C或C++库

从Android Studio 2.2或更高版本开始，可以通过Gradle(IDE集成编译系统)使用NDK来编译C和C++代码成原生库和软件包用于自己的APK。这样你的Java代码就能通过Java Native Interface(Java原生接口, JNI)框架来调用你的原生库功能。

`Cross compiling A simple C++ application <http://janos.io/articles/cross-compile.html>`_ 提供了一个案例，介绍如何交叉编译用于Android ARM架构的C++应用程序，可以借鉴这个步骤来开发用于Android的C程序。 
参考
=====

- `Get started with the NDK <https://developer.android.com/ndk/guides>`_
- `Cross compiling A simple C++ application <http://janos.io/articles/cross-compile.html>`_
- `Cross-compiling and debugging for ARM/Android <https://v8.dev/docs/cross-compile-arm>`_
