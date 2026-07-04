.. _bt-keyboard-switcher:

==============================
bt-keyboard-switcher
==============================

我现在为了方便移动工作，又重新使用我十六年前购买的 :ref:`mba11_late_2010` ，原因无他，最近几年消费电子产品价格暴涨加上自己失业，没一分钱都要考虑花费是否值得。

另外，我也在思考如何充分发挥我购买到的众多电子产品的价值，通过软件结合巧妙的使用方式来完成更多更强的任务。

但是十六年前的 :ref:`mba11_late_2010` 再怎么设计精良制造完美，毕竟无法承受现代复杂的WEB页面和视频多媒体，所以我决定扬长避短，结合我已经拥有的 :ref:`iphone12_mini` 和 :ref:`ipad_mini5` :

- :ref:`mba11_late_2010` 安装 :ref:`alpine_linux` (未来自己编译 :ref:`gentoo_linux` )，以轻量级终端操作为主，主攻开发任务
- :ref:`iphone12_mini` 和 :ref:`ipad_mini5` 负责现代化的WEB访问和大量的桌面应用，因为大多数常用软件都有iOS版本，完全可以享受到最新的应用
- 通过Linux模拟蓝牙键盘和鼠标来实现对iOS设备的输入，充分发挥键盘的输入优势同时能够使用最新的软件

:ref:`hidclient` 由于以来BlueZ 4时代的过时API，导致在现代Linux上已经无法编译。那么在Alpine Linux (OpenRC + Wayland/Sway) 环境下，目前最完美的替代方案是使用基于 Python 3 + BlueZ 5 (DBus) + evdev 的开源项目： `Github: bt-keyboard-switcher <https://github.com/nutki/bt-keyboard-switcher>`_ :

- 绕过 Wayland 安全限制：在 Sway (Wayland) 下，普通的截屏、按键监听软件（如 X11 下的 xdotool）会因为安全协议被彻底禁用。而这个方案使用 Python 的 evdev 库，直接读取内核级的 ``/dev/input/event*`` 原始设备节点，完全不依赖图形显示服务（无论在 TTY 还是 Sway 下都能完美运行）
- 原生支持 iOS/iPadOS：该项目专门针对 iOS 的蓝牙 HID 协议进行了适配，不仅支持键盘，还支持鼠标/触控板的同步模拟
- 支持多设备热切换：可以通过快捷键（如 Ctrl + F1 切换到 iPad，Ctrl + F2 切换到 iPhone，Ctrl + F12 切回本地）

安装
=====

- 安装必要的系统组件、Python 环境及蓝牙工具

.. literalinclude:: bt-keyboard-switcher/install
   :caption: 安装

- 加载 uhid 内核模块（蓝牙 HID 模拟必须）

.. literalinclude:: bt-keyboard-switcher/modprobe
   :caption: 加载uhid模块

- 为了确保每次开机自动加载，将其写入配置

.. literalinclude:: bt-keyboard-switcher/uhid.conf
   :caption: 配置自动加载

配置
=======

BlueZ 默认的 input 插件会尝试作为一个“输入接收端”（去连接外部键盘），这会与“模拟发送端”发生冲突，所以必须在启东市禁用 ``input`` 。

- (放弃这步)修改 ``/etc/bluetooth/main.conf`` :

.. literalinclude:: bt-keyboard-switcher/main.conf
   :caption: ``/etc/bluetooth/main.conf``

.. warning::

   现在修改 ``/etc/bluetooth/main.conf`` 配置不生效

   注意，这里一定要想办法 disable 掉 input ，并且要使得 bluetoothctl 中执行 show 的时候，看到 ``Class = 0x002540`` 而不是默认 ``0x00010c`` (Computer类型会导致iOS扫描自称为Computer类型的设备时自动忽略)

由于我尝试编辑配置文件没有生效，所以按照gemini提示，改成命令行运行:

.. literalinclude:: bt-keyboard-switcher/bluetoothd
   :caption: 在命令行disable掉input,hostname

为什么要 ``--noplugin`` 掉 ``input`` 和 ``hostname`` 呢?

原因是，如果不禁止 ``input`` ，那么在执行下文的 ``keyboardswitcher.py`` 会出现报错显示设备已经注册:

.. literalinclude:: bt-keyboard-switcher/keyboardswitcher_err
   :caption: 如果不禁止 ``input`` 就会报错
   :emphasize-lines: 10

如果只禁止 ``input`` 但没有禁止 ``hostname`` 那么iPad或iPhone在执行谰言配对扫描时就因为bluetootd默认读取Linux主机名而申明自己是 ``0x0000010c`` ，也就是Computer类型，这会导致iPad/iPhone静默忽略掉申明计算机类型的蓝牙设备配对，也就是完全看不到Linux模拟蓝牙键盘设备。这里可以通过 ``bluetoothctl`` 命令中的 ``show`` 指令看到如下状态:

.. literalinclude:: bt-keyboard-switcher/show_computer
   :caption: 当没有禁止hostname时候 ``bluetoothctl show`` 看到的是 ``0x0000010c`` 类型
   :emphasize-lines: 7

- 下载 ``bt-keyboard-switcher`` :

.. literalinclude:: bt-keyboard-switcher/git
   :caption: 下载

- 获取本地输入设备路径:

运行以下命令，找出物理键盘和触控板的 /dev/input/eventX 编号(我这里是 :ref:`mba11_late_2010` )

.. literalinclude:: bt-keyboard-switcher/cat
   :caption: 获取本地输入设备路径

不过，这个寻找event方法有一个缺陷就是每次启动系统内核加载驱动的顺序可能发生变化。今天键盘是 event1，明天重启后可能就变成了 event2，这会导致你的配置文件失效。

所以改进为使用 Linux udev 服务自动创建的持久化设备软链接

执行:

.. literalinclude:: bt-keyboard-switcher/ls
   :caption: 检查 ``/dev/input/by-id/``

输出显示中:

- 含有 ``-event-kbd`` 结尾的文件就是键盘
- 含有 ``-event-mouse`` 或 ``-mouse`` 结尾的文件就是触控板/鼠标

.. literalinclude:: bt-keyboard-switcher/ls_output
   :caption: 检查 ``/dev/input/by-id/``
   :emphasize-lines: 2,3

在我的实践中，上述 ``event1`` 和 ``event9`` 代表了当前的键盘和touchpad

- 配置 ``bt-key-board-switcher`` 目录下的 ``config.ini`` ，我的配置如下

.. literalinclude:: bt-keyboard-switcher/config.ini
   :caption: 配置 config.ini 填写输入设备的id

- 运行 ``keyboardswitcher.py`` :

.. literalinclude:: bt-keyboard-switcher/keyboardswitcher
   :caption: 运行 ``keyboardswitcher.py``

- 执行 ``hciconfig`` 强行向蓝牙天线写入参数：

.. literalinclude:: bt-keyboard-switcher/hciconfig
   :caption: 写入配置

修改完成后，执行检查:

.. literalinclude:: bt-keyboard-switcher/hciconfig_class
   :caption: 检查配置

此时应该看到 明确显示为 ``Class: 0x002540``

.. literalinclude:: bt-keyboard-switcher/hciconfig_class_output
   :caption: 检查配置显示 ``Class: 0x002540``
   :emphasize-lines: 3

- 输入以下命令使得自己的电脑蓝牙设备处于可发现状态:

.. literalinclude:: bt-keyboard-switcher/bluetoothctl
   :caption: 运行 bluetoothctl
   :emphasize-lines: 1,5,7,13

- 现在在iPad/iPhone上扫描配对设备，就会看到有一个 ``Pi Keyboard/Mouse`` 可以配对，请在iOS设备端选择配对

- 此时在 ``bluetoothctl`` 交互终端中有提示iOS设备配对信息，请确认输入 ``yes`` :

.. literalinclude:: bt-keyboard-switcher/bluetoothctl_pair
   :caption: 配置设置
   :emphasize-lines: 7,10

完成配对

**现在就可以开始在iPad上输入** ，使用 ``ctrl+F12`` 切换回本机，输入 ``ctrl+F1`` 切换到iPad输入，非常流畅。

配置和脚本
===========

上述通过命令行完成了蓝牙配对和连接，显然每次都命令行切换蓝牙类型并连接是非常麻烦的。所以执行以下配方法:

- 永久配置 OpenRC 蓝牙后台，确保在 Alpine 系统后台启动蓝牙时，默认就彻底禁用 input 和 hostname 插件: 编辑 ``/etc/conf.d/bluetooth``

.. literalinclude:: bt-keyboard-switcher/bluetooth
   :caption: ``/etc/conf.d/bluetooth`` 关闭input,hostname插件

- 重启蓝牙服务

.. literalinclude:: bt-keyboard-switcher/restart
   :caption: 重启bluetooth

此时检查 ``ps aux | grep bluetoothd`` 应该看到运行参数带上了 ``--noplugin=input,hostname``

.. warning::

   我在实践中遇到了配置 ``/etc/conf.d/bluetooth`` 无效的问题，所以最终实际上改用脚本方式来修改bluetoothd的运行参数，见下文。

- 配置 ``share-hid.sh`` 脚本

.. literalinclude:: bt-keyboard-switcher/share-hid.sh
   :caption: (如果能够调整bluetoothd参数) ``share-hid.sh`` 脚本一键配置蓝牙

由于我的实践发现没有正确调整bluetoothd运行参数，所以我改为许下脚本(也就是脚本来调整bluetothd参数):

.. literalinclude:: bt-keyboard-switcher/share-hid_bluetooth.sh
   :caption: ``share-hid.sh`` 脚本一键配置蓝牙(脚本包含调整bluetoolthd运行参数)

- 在 :ref:`sway` 中使用 :ref:`foot` ，这里配置 ``~/.config/sway/config`` 设置一个浮动小窗口运行:

.. literalinclude:: bt-keyboard-switcher/sway_config
   :caption: sway配置

现在按下 ``Mod+Ctrl+B`` 就开启蓝牙连接，按下 ``Mod+Shift+B`` 就把隐藏的窗口掉到前台，此时按下 ``Ctrl+C`` 就能终止程序。

配对第2个设备
==============

``bt-keyboard-switcher`` 能够配对多个设备，以下是配对第2个设备方法:

- 继续保持上述运行状态(即 ``Command+Control+B`` 已经在后台运行了程序)

- 在Linux主机键盘上按下内置的 ``开启配对广播`` 快捷键 ``Left Ctrl + Esc`` (左 Ctrl 键 + Esc 键)，脚本在获到此组合键后，会自动向芯片发送指令，使主机再次处于可发现的配对状态

需要注意要在一个终端中执行 ``bluetoochctl`` 交互命令，这样才能看到iOS配对数字字符串并进行确认!

完成配对以后，就可以通过 ``Left Ctrl + F1`` 连接第一个设备， ``Left Ctrl + F2`` 连接第二个设备...最后通过 ``Left Ctrl + F12`` 返回本地输入

.. note::

   完成多个设备配对以后，在 ``bt-keyboard-switcher`` 目录下有一个名为 ``keyboardswitcher.ini`` 的配置文件，包含了连接配对的设备的蓝牙地址，也就是可以微调绑定的F1,F2等快捷键顺序。
