.. _freebsd_multimedia:

============================
FreeBSD 多媒体
============================

FreeBSD提供了广泛的多媒体硬件和软件支持，需要设置声卡驱动以及调整音量

设置声卡
==========

当不知道系统使用了什么声卡或模块，则通过以下命令加载 ``snd_driver`` 元数据驱动:

.. literalinclude:: freebsd_multimedia/snd_driver
   :caption: 加载 ``snd_driver`` 驱动

为了在启动时加载上述模块，则配置 ``/boot/loader.conf`` :

.. literalinclude:: freebsd_multimedia/loader.conf
   :caption: 启动时加载 ``snd_driver`` 驱动

- 检查dmesg确定声卡已经被检测到:

.. literalinclude:: freebsd_multimedia/dmesg
   :caption: dmesg检查pcm

输出类似:

.. literalinclude:: freebsd_multimedia/dmesg_output
   :caption: dmesg检查pcm

- 检查声卡状态:

.. literalinclude:: freebsd_multimedia/sndstat
   :caption: 检查声卡状态

输出类似

.. literalinclude:: freebsd_multimedia/sndstat_output
   :caption: 检查声卡状态
   :emphasize-lines: 2

通过 ``beep`` 命令可以发出一些声音来确认声卡是否工作

Mixer
=======

FreeBSD 提供了一些工具来设置声卡音量:

- ``mixer`` 默认安装的命令行工具(我没有研究实践)
- ``mixertui`` 字符终端的交互界面工具，非常类似 :ref:`archlinux_alsa` 中使用的 ``alsamixer``

软件安装
==========

在FreeBSD中，现在似乎使用 ``PipeWire`` 来替代传统的 ALSA，我没有详细研究。不过，系统默认就安装了 ``pipewire`` 和 ``wireplumber`` (一种管理PipeWire的会话和策略管理器)。

.. note::

   实际上我在 ThinkPad X220 上使用 ``mixertui`` 可以非常方便调整音量。

笔记本喇叭无声问题排查
========================

.. note::

   本段排查过程在Google Gemini指导下完成

虽然在X220上FreeBSD非常容易使用声卡硬件，但是我发现只有耳机能够听到声音，而外放的喇叭是没有声音的，即使我通过 ``mixertui`` 将 ``speaker`` 音量设置到最大也没有效果。

Gemini提示: 音频输出的 "引脚映射" (Pin Mapping) 或 "自动静音" (Auto-mute) 逻辑在ThinkPad X220上没有正确识别。在FreeBSD中，ThinkPad这种"耳机响，喇叭不响"通常是因为内核认为耳机始终插着，或者没有正确切换到喇叭引脚。

- 检查 ``cat /dev/sndstat`` 输出如下:

.. literalinclude:: freebsd_multimedia/sndstat_output
   :caption: 检查声卡状态
   :emphasize-lines: 2

ThinkPad X220使用了 Conexant CX20590 芯片，这里显示的 ``pcm0`` 行中 ``Anolog 2.0`` 指的是内置扬声器(Speaker)，而 ``HP`` 指的是 Headphone (耳机)。由于共享同一个编解码芯片(Conexant CX20590)，所以驱动程序默认将它们视为"模拟输出"。

解决FreeBSD下ThinkPad喇叭的标准方法是手动告诉内核如何定义引脚(Pin)

- 检查默认音频设备的默认配置:

.. literalinclude:: freebsd_multimedia/sysctl_hdaa.0_original
   :caption: 检查默认配置

输出显示

.. literalinclude:: freebsd_multimedia/sysctl_hdaa.0_original_output
   :caption: 检查默认配置

导致喇叭不响的原因：

- Speaker (喇叭) 在 nid31，它的关联组是 as=1。
- Headphones (耳机) 在 nid25，它的关联组是 as=4。

喇叭和耳机不在同一个 as (Association) 组。在 FreeBSD 的 HDA 驱动逻辑中，只有当它们在同一个组时，驱动才能正确处理“插入耳机自动静音喇叭，拔掉耳机自动开启喇叭”的逻辑。目前由于它们相互独立，系统可能默认关闭了 as=1 的放大器。

- 有可能是喇叭被系统级静音，需要检查和修改特定的寄存器。执行以下命令查看所有音频相关的 ``sysctl`` 变量:

.. literalinclude:: freebsd_multimedia/sysctl_hdaa.0
   :caption: 检查音频相关的 ``sysctl`` 变量

输出:

.. literalinclude:: freebsd_multimedia/sysctl_hdaa.0_output
   :caption: 检查音频相关的 ``sysctl`` 变量
   :emphasize-lines: 4,11,12,14,18,20,26

可以看到 ``speaker`` 对应的是 ``nid31`` ，其中关联的是 ``nid17`` ( **disabled** ) 和 ``nid16`` 都设置了 ``mute=1`` 表示静音

在 X220 上，喇叭通常对应 nid 31，耳机对应 nid 25。如果它们没能自动切换，我们需要强制将它们分配到同一个“关联组（Association）”

- 编辑 ``/boot/devices.hints`` :

.. literalinclude:: freebsd_multimedia/device.hints
   :caption: 配置喇叭和耳机自动切换

.. warning::

   没有解决，暂时不折腾了

参考
========

- `FreeBSD Handbook: Chapter 9. Multimedia <https://docs.freebsd.org/en/books/handbook/multimedia/>`_
