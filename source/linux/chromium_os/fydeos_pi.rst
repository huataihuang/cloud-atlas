.. _fydeos_pi:

==================================
在树莓派上运行Chromium OS(FydeOS)
==================================

`FydeOS <https://fydeos.com/>`_ 是国内团队基于 :ref:`chromium_os` 定制的操作系统，类似于商业版本的Chrome OS，大致的关系如下：

- Chromium OS作为开源操作系统，是一个深度定制的Linux操作系统，主要是面向Web用户
- FydeOS基于Chormium OS编译，并加入了非开源协议软件，所以类似Chrome OS，并不提供源代码
- FydeOS的GitHub网站提供了指导编译Chromium OS的文档，并且提供了在此基础上编译AnBox运行环境的指南。通过Anbox可以实现在Linux上运行Android应用程序，但是需要剥离Goolge Chrome的ARC+。FydeOS提供了一些开发指南。

.. note::

   我不确定FedeOS直接提供的镜像是不是也是采用AnBox来运行Android，也可能有其他解决方案。不过，我比较感兴趣的是实现的底层技术。所以我计划先安装FydeOS，然后自己编译Chromium OS和AnBox，进行对比。

安装FydeOS
============

FydeOS类似Chrome OS，采用了部分商业软件，所以不提供直接源代码。需要从 `FydeOS官方下载 <https://fydeos.com/download>`_ 安装镜像，下载以后解压缩为: ``FydeOS_for_you_Pi400_v11.4_SP2.img``

- 制作TF卡镜像::

   dd if=FydeOS_for_you_Pi400_v11.4_SP2.img of=/dev/sdb bs=100m

参考
======

- `FydeOS, a Tweaked Chromium OS for Chrome OS Fans, Hits the Raspberry Pi 400, Raspberry Pi 4 Range <https://www.hackster.io/news/fydeos-a-tweaked-chromium-os-for-chrome-os-fans-hits-the-raspberry-pi-400-raspberry-pi-4-range-13f678ed7882>`_
- `How to Install & Use Chromium OS on Raspberry Pi? (FydeOS) <https://raspberrytips.com/how-to-install-use-chromium-os-on-raspberry-pi-fydeos/>`_
- `GitHub - FydeOS / chromium_os-raspberry_pi <https://github.com/FydeOS/chromium_os-raspberry_pi>`_
