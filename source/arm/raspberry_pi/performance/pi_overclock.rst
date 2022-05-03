.. _pi_overclock:

=================
树莓派超频
=================

我有 :ref:`pi_4` 和 :ref:`pi_400` 设备若干( :ref:`edge_cloud_infra` )，例如我使用 :ref:`pi_400` :ref:`run_sway` 作为日常开发运维桌面，对于轻量级使用完全没有问题。不过，我也发现，在播放高分辨率的视频时，有轻微的卡顿，CPU使用率大约是150%左右。

考虑到树莓派为了低功耗有意限制了主频，实际上在保证散热情况下，可以调整主频进行超频，或许能够解决这个性能的些微不足。

默热情况下， :ref:`pi_4` 和 :ref:`pi_400` 主频为 1.8GHz ，根据网上资料，实际上主频可以提高到 2.2GHz

- 检查默认CPU主频::

   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

可以看到我的 :ref:`pi_400` 显示 ``1.8GHz`` ::

   1800000

检查 ``lscpu`` 输出看到:

.. literalinclude:: pi_overclock/lscpu
   :language: bash
   :caption: 树莓派400的lscpu显示CPU主频
   :emphasize-lines: 13-14

- 执行以下命令可以获得当前处理器的实际主频::

   watch -n 2 vcgencmd measure_clock arm

多次刷新可以看到主频实际是波动的(以下执行3次的输出信息)::

   frequency(48)=1000212864
   frequency(48)=800191424
   frequency(48)=1800404352

- 执行以下命令可以获得当前处理器的温度::

   watch -n 2 vcgencmd measure_temp

可以看到大约40‘C(以下执行3次的输出信息)::

   temp=39.4'C
   temp=40.9'C
   temp=39.9'C

性能测试
=========

参考 `The Raspberry Pi 400 can be overclocked to 2.2 GHz <https://www.jeffgeerling.com/blog/2020/raspberry-pi-400-can-be-overclocked-22-ghz>`_ 测试方法，采用 :ref:`pts_startup` 中简易测试方法对比

超频
=====

参考 `Maximum stable overclocking speed of a Pi 4 or 400 <https://forums.raspberrypi.com/viewtopic.php?t=313280>`_ 对于 :ref:`pi_4` 和 :ref:`pi_400` 的经验，大致可以了解到:

- 通过加大电压 :ref:`pi_4` 可以稳定工作在 2.35GHz ，但是需要非常强的冷却 - 需要注意这种超频可能会导致硬件损耗，所以我不会采用这么极端

::

   arm_64bit=1
   initial_turbo=60
   hdmi_enable_4kp60=1
   over_voltage=15
   arm_freq_min=100
   arm_freq=2360
   gpu_freq=750
   gpu_mem=256

- ``over_voltage=15`` 已经是设置超频极限，当设置 ``over_voltage=16`` 时 :ref:`pi_4` 已经无法启动

- 通过适当加压 ``over_voltage=6`` :ref:`pi_4` 设置 ``arm_freq=2000`` 或者更高 ``arm_freq=2147``

- 当 ``over_voltage`` 设置值高于 ``6`` 的时候，就需要设置 ``force_turbo=1`` ，例如配置::

   force_turbo=1
   over_voltage=8
   arm_freq=2200

我的配置
---------

- 我采用较为折中的配置::

   over_voltage=6
   arm_freq=2147
   gpu_freq=750

使用体验:

- 轻量级的使用(打开falkon浏览器浏览网页)，检查处理器温度大约 ``41'C`` ，主频保持在 ``2147554560``
- ``HDMI0`` 无视频信号输出，并且如果显示器接在 ``HDMI0`` 上会系统卡死
- 但是可以将显示器接在 ``HDMI1`` 上稳定使用，看起来是GPU输出限制 - 我尚未解决 :ref:`pi_400_display_config` 如何正在 ``HDMI1`` 接口输出音频
- 作为桌面电脑 :ref:`pi_400` 超频到 2.147GHz 非常稳定，并且肉眼可见的性能提升，所以还是非常值得做超频 - 后续我准备给 :ref:`edge_cloud_infra` 所使用的 :ref:`pi_4` 配置overclock，以提升 :ref:`k3s` 性能

- 当前完整配置结合了 :ref:`pi_400_display_config` 中的 ``精简配置`` 如下:

.. literalinclude:: pi_overclock/config.txt
   :language: bash
   :caption: 树莓派400超频2147Hz，尚未解决HDMI1接口音频输出
   :emphasize-lines: 16-18

参考
=====

- `How to Safely Overclock Raspberry Pi 4 (A Comprehensive Guide) <https://raspberryexpert.com/overclock-raspberry-pi-4/>`_
- `Overclocker doubles Raspberry Pi's clock speed to an incredible 3GHz <https://www.pcgamer.com/raspberry-pi-overclock-3ghz/>`_
- `How to overclock Raspberry Pi 4 <https://magpi.raspberrypi.com/articles/how-to-overclock-raspberry-pi-4>`_
- `Overclock Raspberry Pi 400 to 2.147GHz for Raspberry Pi OS <https://tutorial.cytron.io/2021/03/11/overclock-raspberry-pi-400-to-2-147ghz-for-raspberry-pi-os/>`_
- `Overclocking the Raspberry Pi 400 <https://www.raspberrypi-spy.co.uk/2020/11/overclocking-the-raspberry-pi-400/>`_
- `The Raspberry Pi 400 can be overclocked to 2.2 GHz <https://www.jeffgeerling.com/blog/2020/raspberry-pi-400-can-be-overclocked-22-ghz>`_
- `Maximum stable overclocking speed of a Pi 4 or 400 <https://forums.raspberrypi.com/viewtopic.php?t=313280>`_
