.. _androidscreencast:

===============================
AndroidScreencast控制Android
===============================

在一些特定的场景下，你可能需要在电脑主机上查看Android手机上的屏幕运行程序，或者通过鼠标键盘远程操作手机。举个例子，我在工作中需要使用的一个企业软件只有Android版本，没有提供Linux版本(对于我个人而言，Linux是我主要的工作平台)，这种运行模式就非常有用：

* 可以在Android手机上运行企业软件，显示投影到自己的笔记本电脑上进行操作
* 电脑屏幕可以放大显示，避免使用Android程序是过小的屏幕无法看清同事共享给你的屏幕
* 如果你的Android已经root过，还能直接使用电脑的键盘鼠标操作Android，非常方便输入文字

准备工作
===========

* 下载安装 `Android SDK <http://developer.android.com/sdk/index.html>`_ ，由于我已经安装了 :ref:`android_develop_env` ，所以已经具备了Andorid SDK。你也可以单独下载SDK部分。
* 下载 `AndroidScreencast官方仓库 <https://xsavikx.github.io/AndroidScreencast/>`_ 提供的JAR或安装包
* 操作系统安装Java运行环境 - 在macOS中，在终端程序中执行 ``java version`` 命令，如果系统没有安装java会提示你直接从Oracle网站下载安装。



参考
========

- `How to Remote View and Control Your Android Phone <https://www.howtogeek.com/howto/42491/how-to-remote-view-and-control-your-android-phone/>`_
