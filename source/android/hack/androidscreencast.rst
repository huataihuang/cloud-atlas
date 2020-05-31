.. _androidscreencast:

===============================
AndroidScreencast控制Android
===============================

在一些特定的场景下，你可能需要在电脑主机上查看Android手机上的屏幕运行程序，或者通过鼠标键盘远程操作手机。举个例子，我在工作中需要使用的一个企业软件只有Android版本，没有提供Linux版本(对于我个人而言，Linux是我主要的工作平台)，这种运行模式就非常有用：

* 可以在Android手机上运行企业软件，显示投影到自己的笔记本电脑上进行操作
* 电脑屏幕可以放大显示，避免使用Android程序是过小的屏幕无法看清同事共享给你的屏幕
* 如果你的Android已经root过，还能直接使用电脑的键盘鼠标操作Android，非常方便输入文字

.. note::

   AndroidScreencast 是采用Java编写的工具，另外，也有开源基于C编写的Android设备显示和控制软件 :ref:`scrcpy` ，性能可能更好，但是Android要求版本更高一些(Android 5)

AndroidScreencast功能
========================

- 不需要在手机上安装客户端
- 支持点击和滑动操作
- 可以使用PC的键盘写消息
- 支持横屏模式
- 可以在PC上浏览手机文件
- 在浏览时可以录制手机屏幕

准备工作
===========

* 下载安装 `Android SDK <http://developer.android.com/sdk/index.html>`_ ，由于我已经安装了 :ref:`android_develop_env` ，所以已经具备了Andorid SDK。你也可以单独下载SDK部分。
  * 在 ``SDK Manager`` 中，只需要选择 ``Android SDK Platform-Tools`` 就可以满足运行需求
* 下载 `AndroidScreencast官方仓库 <https://xsavikx.github.io/AndroidScreencast/>`_ 提供的JAR或安装包
* 操作系统安装Java运行环境 - 在macOS中，在终端程序中执行 ``java version`` 命令，如果系统没有安装java会提示你直接从Oracle网站下载安装。

连接好手机和主机，执行以下命令确保手机设备就绪::

   adb devices

可以看到输出::

   List of devices attached
   HT6C10200963    device   

* 将下载的 ``androidscrencast.jnlp`` 复制到 ``android-sdk`` 目录，在macOS中，复制到 ``~/Library/Android/sdk/platform-tools/`` 目录下

配置
=======

有两种方法运行应用:

* 自己运行ADB服务器
* 设置正确的 ``app.properties`` 文件

自己运行ADB服务器
-------------------

* 首先确保主机已经安装好了 ``adb`` 然后使用以下命令运行服务器::

   adb start-server

.. note::

   如果在 ``adb.path`` 中填写了 ``app.properties`` ，则 AndroidScreencast会在应用程序终止时也停止ADB server。例如，通过ssh forwarding方式使用远程ADB server，则建议不要使用 ``app.properties`` 或者将该配置文件中的 ``adb.path`` 属性注释掉。

设置正确的 ``app.properties`` 文件
------------------------------------

为了正确运行应用，你需要在 ``app.properties`` 配置中指定正确的 ``adb.path`` ，例如::

   #relative or absolute path to ADB
   adb.path=/Users/huataihuang/Library/Android/sdk/platform-tools/adb

此外， ``app.properties`` 配置还提供了一些有关设置应用程序特性的配置，如启动窗口大小，以及是否让应用运行类似 natively程序。

JNLP
========

AndroidScreencast使用了Java web start技术，下载 `androidscreencast.jnlp <http://xsavikx.github.io/AndroidScreencast/jnlp/androidscreencast.jnlp>`_ 存放到 androidscreecast JAR文件相同目录下。

* 在文件管理器中点击之心 ``androidscreencast.jnlp`` 就会启动AndroidScreencast运行程序。

.. note::

   我在macOS上运行 ``androidscreencast.jnlp`` 发现总是提示需要JRE运行环境，并引导我下载(访问到却是flash.cn网站，像是被劫持了域名)。但是实践发现，在macOS的文件管理器中，直接点解运行 androidscreencast.jar 也是能够正常工作的。

   注意运行时，手机屏幕不能锁屏，否则Java应用的屏幕是完全空白的。手机解锁以后，就能够正常在Java应用页面看到屏幕输出。虽然有些延迟和缓慢，但是可以将这种方式作为投屏解决方案，引对一些屏幕比较静态的应用使用。

.. figure:: ../../_static/android/hack/androidscreencast.png
   :scale: 75

AndroidScreencast使用场景
==========================

虽然AndroidScreencast看起来性能较差，使用体验不佳(毕竟没法在电脑上灵活使用手机屏幕的交互操作)，但是依然有一些特定场景非常有用：

* 公司的商业VPN软件和视频会议系统没有对应的Linux版本，但是可以在Android手机上使用：通过AndroidScreencast可以把手机屏幕放大到电脑屏幕上，可以清晰看清视频会议的共享桌面进行协作
* 在对外演示自己的Android上应用操作，可以通过电脑屏幕投影出来做演示，特别是一些会议投屏不支持手机直连，只能通过笔记本电脑输出。

.. note::

   结合 :ref:`vpn_hotspot` ，你可以随时随地移动办公 ^_^

参考
========

- `How to Remote View and Control Your Android Phone <https://www.howtogeek.com/howto/42491/how-to-remote-view-and-control-your-android-phone/>`_
- `AndroidScreencast GitHub网站 <https://github.com/xSAVIKx/AndroidScreencast>`_
