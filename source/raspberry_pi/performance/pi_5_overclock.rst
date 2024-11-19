.. _pi_5_overclock:

===================
树莓派5超频
===================

我在 :ref:`pi_5` 上使用 :ref:`intel_optane_m10` ，为了解决启动时稳定识别Intel Optane(傲腾)的问题，考虑通过超频设置提供更大电流来解决Optane初始化识别问题。本文为实施记录

启动配置
==========

- 修订 ``/boot/firmware/config.txt`` :

.. literalinclude:: pi_5_overclock/config.txt
   :caption: ``/boot/firmware/config.txt`` 添加配置
   :emphasize-lines: 42-46,57-63

说明:

- ``over_voltage_delta`` 配置超频电压
- ``arm_freq`` 设置CPU频率为 2.9GHz:

  - 树莓派的Turbo频率可以达到 3.0GHz，不过考虑到稳定性，采用了略低的频率
  - `An important consideration about Pi 5 overclocking  <https://www.jeffgeerling.com/blog/2024/important-consideration-about-pi-5-overclocking>`_ 介绍了博主前后购买过10台 :ref:`pi_5` ，超频测试只有1台8G内存版本能够工作在3.0GHz超频，其余则部分可以工作在2.9GHz、部分则最多2.8GHz

    - 根据Geekbench网站的测试资料， :ref:`pi_5` 提升10%性能会多消耗20%电能，所以超频收益不大
    - 通过使用超级散热风扇以及调整PLLs, OPP tables和DFVS，树莓派5可以超频达到 3.14 GHz ( `Raspberry Pi 5 *can* overclock to 3.14 GHz <https://www.jeffgeerling.com/blog/2024/raspberry-pi-5-can-overclock-314-ghz>`_ )

  - 我的超频2.9GHz看起来比较稳定(没有对GPU超频)，可能是现在批次的树莓派经过一年多工艺改进有了一些提升

    - `New 2GB Pi 5 has 33% smaller die, 30% idle power savings <https://www.jeffgeerling.com/blog/2024/new-2gb-pi-5-has-33-smaller-die-30-idle-power-savings>`_ 介绍了新出品的 :ref:`pi_5` 工艺改进后，已经能够超频到 3.4 GHz (按照该文介绍 3.5GHz 有些稳定性问题，到 3.6GHz已经无法启动)。不过这个世界纪录选择了他从10个pi中挑选的 'golden sample' 以及采用了强力散热加上 `GitHub: geerlingguy/pi-overvolt <https://github.com/geerlingguy/pi-overvolt>`_ 项目提供了移除树莓派内置电压限制功能，可以疯狂超频
    - `Hacking Pi firmware to get the fastest overclock <https://www.jeffgeerling.com/blog/2024/hacking-pi-firmware-get-fastest-overclock>`_ 介绍，2024年3月树莓派官方发布了新的firmware允许解锁超频到 3.0 GHz

- 没有对GPU超频:

  - `Raspberry Pi 5 Overclock CPU/GPU Safety <https://forums.raspberrypi.com/viewtopic.php?t=362296>`_ 提到GPU超频会带来稳定性问题，不过这个讨论式2023年12月底进行的，看起来2024年下半年工艺有所改进(8月发布的新版本2GB型号使用了 ``D0`` 芯片，比前一代 ``C1`` 芯片工艺先进 `New 2GB Pi 5 has 33% smaller die, 30% idle power savings <https://www.jeffgeerling.com/blog/2024/new-2gb-pi-5-has-33-smaller-die-30-idle-power-savings>`_ )，或许可以进一步超频
  - 目前还没有对GPU有强性能需求，后续再做尝试

- ``cooling map`` 设置段落( ``42-46`` 行)调整了树莓派针对不同温度的散热风扇转速，见下文

``cooling map`` 配置
======================

`Changing Pi5 fan (case or active cooler) cooling map <https://forums.raspberrypi.com/viewtopic.php?t=362528>`_ 帖子提供了一个 ``bcm2712-rpi-5-b_dtb_dts.zip`` ，解压缩以后将 ``bcm2712-rpi-5-b.dtb`` 文件复制到 ``/boot/firmware`` 目录下(替换)。然后结合上文 ``/boot/firmware/config.txt`` 配资可以在相同温度下调快散热风扇转速。我实测了一下，在 ``stress`` 全速压测时，可以降低CPU温度 ``8度`` 左右。

参考
========

- `Raspberry Pi 5 Overclock CPU/GPU Safety <https://forums.raspberrypi.com/viewtopic.php?t=362296>`_ 主要参考设置
- `Changing Pi5 fan (case or active cooler) cooling map <https://forums.raspberrypi.com/viewtopic.php?t=362528>`_ 调整风扇转速以降低超频后温度
- `An important consideration about Pi 5 overclocking  <https://www.jeffgeerling.com/blog/2024/important-consideration-about-pi-5-overclocking>`_
- `How to Overclock A Raspberry Pi 5 <https://www.tomshardware.com/how-to/overclock-raspberry-pi-5>`_

