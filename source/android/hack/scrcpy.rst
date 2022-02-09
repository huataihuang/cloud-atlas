.. _scrcpy:

====================
scrcpy控制Android
====================

scrcpy是提供了通过USB或者TCP/IP连接Android设备的应用程序，可以工作在Linux, Windows, macOS上:

- 请谅解(原生，只显示设备屏幕)
- 性能(达到30~60fps)
- 显示质量(1920x1080或更高)
- 低延迟(35~70ms)
- 快速启动(小于1s)
- 无需root设备

scrcpy要求Android设备支持API 21(Android 5.0)，并确保设备激活了adb debugging

.. figure:: ../../_static/android/hack/scrcpy.jpg
   :scale: 60

安装scrcpy
=============

Linux
--------

在Debian(testing和sid)和Ubuntu(20.04)::

   apt install scrcpy

此外也可通过 snap 包方式安装 `snap包scrcpy <https://snapstats.org/snaps/scrcpy>`_

Arch Linux需要通过 :ref:`archlinux_aur` 安装 scrcpy

甚至可以通过 `源代码编译安装scrcpy <https://github.com/Genymobile/scrcpy/blob/master/BUILD.md>`_

Windows
----------

- 可以直接下载 `scrcpy-win64-v1.14.zip <https://github.com/Genymobile/scrcpy/releases/download/v1.14/scrcpy-win64-v1.14.zip>`_ - 请在官网下载最新版本

- 或者通过 `Chocolatey <https://chocolatey.org/>`_ 安装::

   choco install scrcpy
   choco install adb

- 或者通过 `Scoop <https://scoop.sh/>`_ 安装::

   scoop install scrcpy
   scoop install adb

macOS
--------

- 建议通过 :ref:`homebrew` 安装::

   brew install scrcpy

- 如果系统没有安装adb，则可以安装::

   brew cask install android-platform-tools

运行
======

- 连接Android设备，然后执行::

   scrcpy

默认情况下，可以通过较低的分辨率来提高信工，例如限制高宽1024::

   scrcpy --max-size 1024
   scrcpy -m 1024

- 修改bit率

默认bit率是8Mbps，也可以降低视频bit率，例如降低到2Mbps::

   scrcpy --bit-rate 2M
   scrcpy -b 2M

- 限制帧数

例如限制帧数15fps::

   scrcpy --max-fps 15

上述限制帧数需要Android 10支持

- 截屏

   scrcpy --crop 1224:1440:0:0   # 1224x1440 at offset (0,0)

- 锁定视频方向::

   scrcpy --lock-video-orientation 0   # natural orientation
   scrcpy --lock-video-orientation 1   # 90° counterclockwise
   scrcpy --lock-video-orientation 2   # 180°
   scrcpy --lock-video-orientation 3   # 90° clockwise

- 录屏

可以在镜像屏幕时候录屏::

   scrcpy --record file.mp4
   scrcpy -r file.mkv

要在录屏时候禁止镜像::

   scrcpy --no-display --record file.mp4
   scrcpy -Nr file.mkv
   # interrupt recording with Ctrl+C

连接
=====

scrcpy使用adb和设备通讯，而adb可以通过TCP/IP和设备连接

- 将设备和电脑连接到相同Wi-Fi
- 获取设备IP地址： ``Settings => About phone => Status``
- 在设备上激活adb over TCP/IP::

   adb tcpip 5555

- 断开设备的USB连接

- 通过以下命令以TCP/IP方式连接设备，注意这里DEVICE_IP需要替换成实际IP地址::

   adb connect DEVICE_IP:5555

- 运行scrcpy，可能需要降低比特率::

   scrcpy --bit-rate 2M --max-size 800
   scrcpy -b2M -m800  # short version

多设备连接
------------

- 如果adb显示多个是被，需要指定serial::

   scrcpy --serial 0123456789abcdef
   scrcpy -s 0123456789abcdef  # short version

- 如果设备通过TCP/IP::

   scrcpy --serial 192.168.0.1:5555
   scrcpy -s 192.168.0.1:5555  # short version

- 自动启动设备连接，需要使用 `AutoAdb <https://github.com/rom1v/autoadb>`_ ::

   autoadb scrcpy -s '{}'

SSH tunnel
-------------

要连接远程设备，可以通过本地 ``adb`` 客户端连接远程 ``adb`` 服务器（需要使用相同的adb协议）::

   adb kill-server    # kill the local adb server on 5037
   ssh -CN -L5037:localhost:5037 -R27183:localhost:27183 your_remote_computer
   # keep this open

然后在另一个终端窗口输入::

   scrcpy

要避免激活远程端口转发，需要强制一个转发连接（注意使用 ``-L`` 替换 ``-R`` )::

   adb kill-server    # kill the local adb server on 5037
   ssh -CN -L5037:localhost:5037 -L27183:localhost:27183 your_remote_computer
   # keep this open

然后在另一个窗口执行::

   scrcpy --force-adb-forwrad

类似无线连接，可以降低图形质量提高性能::

   scrcpy -b2M -m800 --max-fps 15

窗口配置
==========

标题
-----

默认窗口标题是设备型号，可以修改::

   scrcpy --window-title 'My device'

位置和大小
-----------

初始窗口位置和大小可以指定::

   scrcpy --window-x 100 --window-y 100 --window-width 800 --window-height 600

边框
-------

可以关闭窗口边框::

   scrcpy --window-borderless

始终在最上面
--------------

可以将scrcpy窗口始终保持在最上面::

   scrcpy --window-borderless

全屏
-------

可以在启动时就全屏::

   scrcpy --fullscreen
   scrcpy -f  # short version

或者通过快捷键切换全屏: ``Ctrl+f``

旋转
-------

窗口可以选装::

   scrcpy --rotation 1

通过以下值指定选装::

   0: no rotation
   1: 90 degrees counterclockwise
   2: 180 degrees
   3: 90 degrees clockwise

可以通过 ``Ctrl + ←`` (左方向键) 和 ``Ctrl + →`` (右方向键)

只读
-------

可以禁止控制，即不通过键盘鼠标操作::

   scrcpy --no-control
   scrcpy -n

显示
-------

如果有多个显示器，可以指定显示屏幕::

   scrcpy --display 1

以下命令可以显示屏幕id::

   adb shell dumpsys display   # search "mDisplayId=" in the output

保持唤醒
-----------

防止设备进入睡眠::

   scrcpy --stay-awake
   scrcpy -w

关闭屏幕
-----------

可以在镜像屏幕时关闭设备屏幕::

   scrcpy --turn-screen-off
   scrcpy -S

或者通过 ``Ctrl + o`` 关闭。

也可以恢复屏幕 ``Ctrl + Shift + o``

通常结合避免设备睡眠::

   scrcpy --turn-screen-off --stay-awake
   scrcpy -Sw

绘制过期帧
-------------

默认情况，为了降低延迟，scrcpy总是只绘制最后解码的帧，并丢弃之前的帧。为了强制绘制所有帧（会导致明显的延迟），则使用::

   scrcpy --render-expired-frames

显示触摸
----------

为了演示，通常显示物理触摸（在物理设备上操作）非常有用，这是Android提供的开发者选项::

   scrcpy --show-touches
   scrcpy -t

注意，这个只显示物理接触（即手指在设备上操作）。

输入控制
-------------

- 旋转设备屏幕： 按下 ``Ctrl + r`` 旋转

- 复制粘贴::

   Ctrl+c copies the device clipboard to the computer clipboard;
   Ctrl+Shift+v copies the computer clipboard to the device clipboard (and pastes if the device runs Android >= 7);
   Ctrl+v pastes the computer clipboard as a sequence of text events (but breaks non-ASCII characters).

文字输入
-----------

有两种输入文字的事件：

- key events, signaling that a key is pressed or released;
- text events, signaling that a text has been entered.

文件投递
===========

安装APK
----------

要安装APK，只需要将APK文件拖放到scrcpy窗口就可以。没有视觉反馈，只是在控制台打印日志。

推送文件到设备
-----------------

要将文件传输到 ``/sdcard/`` 目录，只需要将非APK文件拖放到scrcpy窗口。

音频转发
--------------

scrcpy不支持音频转发，需要使用 `USBaudio <https://github.com/rom1v/usbaudio>`_ （只支持Linux）。

参考
======

- `scrcpy官方github <https://github.com/Genymobile/scrcpy>`_
