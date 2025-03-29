.. _android_12_background_limit_termux:

=================================
Android 12对后台运行termux的限制
=================================

Termux确实是Android系统中非常强大的终端工具，可以通过集成大量开源工具，将一台Android设备转换成移动的服务器，方便我们实现 :ref:`mobile_pixel_dev` 。我在使用一段时间发现，当Termux在后台时，非常容易因为启动很多应用而导致后台 ``termux`` 进程被杀死。这对我连续使用Android作为移动开发平台不便，我尝试采用 :ref:`termux_background_running` ，通过配置 ``termux`` 电源管理 ``Unrestricted`` (不限制电能)，果然可以保持 ``termux``
不被系统在后台杀死。

不过，我在之前以为 :ref:`termux_zsh` 启用了 :ref:`oh_my_zsh` 导致相应缓慢。但是偶然发现，只要将termux切换到前台，立即就恢复了快速响应。这说明虽然配置电源管理 ``Unrestricted`` ，但是Android依然降低了后台运行的 ``termux`` 时间片，导致其响应迟钝，不符合我作为移动服务器的响应要求。

Android 12 Phantom Process Killer
===================================

原来，Android 12引入了新的监控进程forked子进程的机制:

- 父进程最多只能启动32个子进程，大大限制了一个应用在后台能够操作的动作数量
- 32个子进程的限制是整个系统全局限制，不是针对每个应用，也就是其他应用的子进程也会影响到termux (原文理解是整个系统父进程 fork 出来的子进程，不管父进程是哪个，都会全局累加起来，并限制不能超过32个)
- 系统存在一种 ``PhantomProcessKiller`` 机制会严重干扰 ``termux`` 运行: 
    - 如果父进程在后台运行，当子进程在后台消耗了太多CPU就会被杀死(这是Google为了避免后台进程疯狂消耗系统资源引入的机制，但是对于后台运行termux非常不利，因为termux在后台不代表不重要，我们很可能会远程ssh进入termux执行大量的编译开发工作)
    - 应用可以使用 ``Runtime.exec()`` 来唤起子进程，但是框架不能感知子进程生命周期
    - 如果父进程在后台运行，它的子进程如果消耗太多CPU资源(通过CPU stats采样)就会被Android系统杀死
    - 默认只允许最多32个子进程(系统全局范围)
    - 如果子进程积累了太多oom adj计分，则它们的 ``父进程`` 被杀掉
- Android臭名昭著的OEM厂商应用，魔改了AOSP的限制；而现在Android 12引入了新的电源管理机制来对抗，目前还找不到如何关闭这种电源限制

如何触发Android 12 Phantom Process Killer
===============================================

- 检查 32 个子进程限制配置::

   adb shell "/system/bin/dumpsys activity settings"

输出中有一个::

   max_phantom_processes=32

- 在temux中执行以下脚本，fork出40个子进程，并且消耗大量资源::

   for i in $(seq 40); do\nsha256sum /dev/zero &\ndone

上述命令会并发40个进程执行 ``sha256sum`` 消耗CPU资源

- 然后将termux放到后台运行

- 过一会就会看到进程被杀死

临时解决方案
=================

如果使用 Android 11 则没有这个  ``PhantomProcessKiller`` 的限制，但是目前在 Android 12上无法关闭这个特性。虽然能够关闭掉电源优化功能，即 :ref:`termux_background_running` 采用的电源设置，但是依然无法禁止 ``PhantomProcessKiller`` 。

目前我临时解决方案是始终把 ``termux`` 放在前台运行，特别是我需要长时间编辑和开发时。如果出现息屏时响应缓慢，则可以尝试开发选项中，连接电源保持屏幕常亮来克服。

修订 ``max_phantom_processes``
--------------------------------

- 使用以下adb命令可以修订::

   adb shell device_config put activity_manager max_phantom_processes 1024

然后检查::

   adb shell device_config get activity_manager max_phantom_processes

就会看到调整后的参数::

   1024

其他详细情况可以参考 `Phantom Process Killing In Android 12 Is Breaking Apps <https://issuetracker.google.com/issues/205156966?pli=1>`_

设置进程运行在Android手机大核
--------------------------------

- 执行以下命令找出 ``termux`` 进程号::

   ps aux | grep termux

假设这里看到父进程号是 ``5903``

- 查看手机处理器大小核::

   cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq

此时输出::

   1766400
   1766400
   1766400
   1766400
   2803200
   2803200
   2803200
   2803200

可以看出手机的后4个核心是 Turbo 。我们把进程绑定较好的 4个CPU核心:

- 添加CPU绑定::

   taskset --pid --all-tasks 4,5,6,7 5903

快速脚本:

.. literalinclude:: android_12_background_limit_termux/termux_tunning
   :language: bash

此时提示::

   pid 5903's current affinity mask: ff
   pid 5903's new affinity mask: 67

不过上述策略可能并不是优化解(我还没有想出更好的方法)，因为Android系统会根据需要做动态频率调整，特别是 ``turbo`` CPU核心，在没有插电的情况下会降频，甚至频率低于小核，使得绑定效果反而更差。例如，以下是手机没有插电时候待机状态CPU当前主频::

   sudo cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq

可以看到大核心有时候会低到825600Hz，甚至比小核心还要低。不过，大多数情况下，大核心的主频还是比小核心要高::

   ➜  ~ sudo cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq
   1766400
   1766400
   1766400
   1766400
   2803200
   2803200
   2803200
   2803200
   ➜  ~ sudo cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq
   652800
   652800
   652800
   652800
   1363200
   1363200
   1363200
   1363200
   ➜  ~ sudo cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq
   1766400
   1766400
   1766400
   1766400
   1286400
   1286400
   1286400
   1286400

参考
=======

- `Android 12’s new background app limitations could be a major headache for power users <https://www.xda-developers.com/android-12-background-app-limitations-major-headache/>`_
- `Phantom Process Killing In Android 12 Is Breaking Apps <https://issuetracker.google.com/issues/205156966?pli=1>`_
- `how to run termux program on power-efficient cpu core? <https://stackoverflow.com/questions/71731060/how-to-run-termux-program-on-power-efficient-cpu-core>`_
