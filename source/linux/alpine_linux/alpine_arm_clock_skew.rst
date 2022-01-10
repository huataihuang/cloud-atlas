.. _alpine_arm_clock_skew:

==========================================
Alpine Linux在树莓派启动"clock skew"报错
==========================================

我在 :ref:`alpine_install_arm` 遇到一个问题，树莓派自身没有RTC时钟设备，重启系统的时钟不准确，导致启动时提示时钟扭曲(时钟比文件系统的时间戳要早很多)::

   Clock skew detected with `(null)'
   Adjusting mtime of '/run/openrc/deptree' to Mon Jan 10 21:44:22 2022
   WARNING: clock skew detected!
   ...
   Checking local filesystems ...
   Filesystems couldn't be fixed
   rc: Aborting!
   fsck: caught SIGTERM, aborting
   WARNING: clock skew detected!

这个问题导致启动后使用 ``date`` 检查时间显示的是上一次 ``date`` 启动时设置时间，这个时间和当前重启启动时间相去甚远，所以系统会显示时钟错误，无法读写挂载文件系统，也就导致后续一系列网卡无法启动，服务也无法
启动。问题是树莓派没有本地 ``rtc`` 设备，所以无法执行 ``hwclock -w --localtime`` 将手工修正的时间记录到BIOS。

这里有一个 ``悖论`` :

- Alpine Linux启动时会检查系统时间和文件系统时间戳，如果时钟不准确，就会拒绝以 ``读写模式`` 挂载文件系统(即使已经在 ``/etc/fstab`` 中配置根文件 ``rw`` 挂载)
- 由于文件系统只读挂载， 就会拒绝运行 ``/etc/init.d`` 目录下的自动配置启动服务，包括网卡配置IP服务，无线网卡启动配置，同时 ``chronyd`` 服务无法启动(需要写入磁盘)，这一系列不能启动网络和NTP客户端也就导致了系统无法自动校准时间
- 无法自动校准时间，也就不能以读写模式挂载根文件系统，所以一切就只是只读，只能让用户手工从终端登陆(因为sshd服务也无法启动，没有网络)

手工恢复网络和服务
====================

- 先手工修正以下时间::

   date -s "2022-01-10 22:36:04"

- 然后重启一次 ``chronyd`` 服务，让服务能够本地保留一份时钟矫正(注意，需要首先把文件系统改正为读写模式再启动)::

   mount -o remount,rw /
   /etc/init.d/chronyd restart

- 此时会提示检查文件系统(并挂载)以及启动网络::

   * Checking local filesystems ...
   * Remounting filesystems ...
   * Mounting local filesystems ...
   * Starting networking ...
   *   lo ...
   *   eth0 ...
   * Starting chronyd ...

- 然后启动 :ref:`alpine_wireless` 通过internet矫正时间

我以为一切都解决了，毕竟 ``chronyd`` 也生成了 ``/var/lib/chrony/chrony.drift`` ，但是没有想到，树莓派系统重启依然出现 ``clock skew`` 报错，同样的问题再次出现

为树莓派添加 ``rtc`` 设备
============================

我使用的树莓派是 :ref:`pi_3` ，这个设备没有提供RTC(Real Time Clock Module)，所以树莓派关闭后时钟无法保持。 `Alpine Linux on a Raspberry Pi 3 B+ with a RTC module <https://community.riocities.com/alpine_rpi_rtc.html>`_ 介绍了一种方法，是在 ``Raspberry Pi 3 B+`` 的 GPIO pins 1, 3, 5, 7 & 9 插上一个 RTC 模块:

.. figure:: ../../_static/linux/alpine_linux/ds3231-rtc-module-for-raspberry-pi.jpg
   :scale: 50

然后编辑 ``usercfg.txt`` 添加::

   dtoverlay=i2c-rtc,ds3231

再重启就行(对于Alpine v3.13)。如果是早期版本，还需要执行以下步骤

- 安装 ``mkinitfs`` 软件包::

   apk add mkinitfs

- 在 ``/etc/mkinitfs/mkinitfs.conf`` 添加 ``rpirtc`` ，类似::

   features="ata base cdrom ext4 keymap kms mmc raid scsi usb virtio rpirtc"

然后重新制作 ``initramfs`` 来添加 ``ds3231`` 设备内核模块::

   # . /etc/lbu/lbu.conf
   # ln -s /media/$LBU_MEDIA/boot /boot
   # mount /media/$LBU_MEDIA -o remount,rw

   # . /etc/mkinitfs/mkinitfs.conf
   # mkinitfs -F "$features base squashfs"

   # mount /media/$LBU_MEDIA -o remount,ro

- 并激活 ``hwclock`` 服务::

   # rc-update del swclock boot
   # rc-update add hwclock boot
   # hwclock -w
   # lbu commit

没有 ``rtc`` 的软件解决方法
=============================

实际上树莓派硬件都没有包含硬件时钟设备，为何其他操作系统，例如 :ref:`ubuntu64bit_pi` 没有遇到类似问题？我检查了 :ref:`pi_4` 上运行的 Ubuntu 系统::

   dmesg -T | grep rtc

结果显示也没有硬件rtc，但是内核参数有一个 ``fixrtc`` 参数::

   [    0.000000 ] Kernel command line:  coherent_pool=1M 8250.nr_uarts=1 snd_bcm2835.enable_compat_alsa=0 snd_bcm2835.enable_hdmi=1 bcm2708_fb.fbwidth=656 bcm2708_fb.fbheight=416 bcm2708_fb.fbswap=1 vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000  net.ifnames=0 dwc_otg.lpm_enable=0 console=ttyS0,115200 console=tty1 root=LABEL=writable rootfstype=ext4 elevator=deadline rootwait fixrtc cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1 quiet splash

仔细看了

- 需要激活软件时钟关闭硬件时钟::

   rc-update add swclock boot    # enable the software clock
   rc-update del hwclock boot    # disable the hardware clock

但是我实际执行发现原本就是如此::

   # rc-update add swclock boot
    * rc-update: swclock already installed in runlevel `boot'; skipping
   # rc-update del hwclock boot
    * rc-update: service `hwclock' is not in the runlevel `boot'

我在 `Add hardware clock earlier Raspberry Pi <https://gitlab.alpinelinux.org/alpine/aports/-/issues/9032>`_ 有一个提示，检查 ``/run/openrc/*`` 文件时间戳::

   stat -c "%y %s %n" /run/openrc/*

我发现确实有一些文件时间差异很大::

   1970-01-01 08:00:06.972999997 +0800 7 /run/openrc/clock-skewed
   2022-01-11 06:05:33.950517700 +0800 120 /run/openrc/daemons
   1970-01-01 08:00:06.965999997 +0800 11 /run/openrc/depconfig
   2022-01-11 04:56:35.000000000 +0800 20183 /run/openrc/deptree
   2022-01-11 06:05:33.977517440 +0800 40 /run/openrc/exclusive
   1970-01-01 08:00:04.949999998 +0800 40 /run/openrc/failed
   1970-01-01 08:00:04.950999998 +0800 40 /run/openrc/hotplugged
   1970-01-01 08:00:04.949999998 +0800 40 /run/openrc/inactive
   2022-01-11 06:05:33.962517585 +0800 100 /run/openrc/options
   1970-01-01 08:00:04.950999998 +0800 40 /run/openrc/scheduled
   2022-01-11 05:46:27.000000000 +0800 0 /run/openrc/shutdowntime
   2022-01-11 05:46:27.594999999 +0800 7 /run/openrc/softlevel
   2022-01-11 06:05:33.976517450 +0800 360 /run/openrc/started
   2022-01-11 06:05:33.977517440 +0800 40 /run/openrc/starting
   2022-01-11 05:51:21.307224589 +0800 40 /run/openrc/stopping
   2022-01-11 05:51:01.161414046 +0800 0 /run/openrc/supervise-wpa_supplicant.ctl
   1970-01-01 08:00:04.950999998 +0800 40 /run/openrc/tmp
   1970-01-01 08:00:04.949999998 +0800 40 /run/openrc/wasinactive

其中最主要报错应该是 ``/run/openrc/deptree```



参考
=======

- `Add hardware clock earlier Raspberry Pi <https://gitlab.alpinelinux.org/alpine/aports/-/issues/9032>`_
- `Alpine Linux on a Raspberry Pi 3 B+ with a RTC module <https://community.riocities.com/alpine_rpi_rtc.html>`_
- `Clock skew detected with '(null)' on Raspberry pi <https://www.reddit.com/r/AlpineLinux/comments/kprx4x/clock_skew_detected_with_null_on_raspberry_pi/>`_
