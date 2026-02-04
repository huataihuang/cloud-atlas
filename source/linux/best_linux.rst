.. _best_linux:

===============
最佳Linux
===============

Linux是完全开源的操作系统，任何人都能够定制自己的发行版，并且可以面向不同的细分目标，各有特色、精彩纷呈。

没有最佳，只有最合适...

市场份额统计
==============

- ``服务器网站视角`` : 从 `W3Techs的年度WEB网站Linux统计 <https://w3techs.com/technologies/history_details/os-linux/all/y>`_ Ubuntu使用率最高，这应该和Ubuntu社区活跃安装使用方便有关，其次是CentOS则在大型互联网公司使用较为广泛。总体来说，熟悉这两种主流发行版本对于Linux工作还是非常必要的。知乎上 `互联网公司选择 Debian、Ubuntu 和 CentOS 哪一个发行版运维成本最低? <https://www.zhihu.com/question/29195044/answer/865305122>`_ 同样引用了W3Techs的报告，可以看出:

  - Ubuntu使用的网站数量高于CentOS，但是更多的网站使用的是Windows以及Unix系统，不过总体来看在Linux范围内Ubuntu的市场份额是CentOS的2倍
  - 大型互联网公司使用CentOS/Ubuntu/Windows的比例差不多
  - 综上：如果是小型互联网公司趋向于使用Ubuntu，(国内)大型互联网公司则两者基本持平

.. note::

   我觉得在企业级Linux市场， :ref:`redhat_linux` 占据了极大优势。这点我在 :ref:`hpe_dl360_firmware_upgrade` 时特别有感触，因为在HP的服务器支持驱动和firmware更新下载中，只提供Windows安装包和RPM包，压根就没有提供给Ubuntu/Debian系可用的安装包。这也侧面反映了Linux企业市场的格局。

- ``桌面视角`` : `DistroWatch Page Hit Ranking <https://distrowatch.com/dwres.php?resource=popularity>`_ 是 DistroWatch.com 统计访问发行版页面点击数来反映网站访客使用Linux发行版和其他免费操作系统(如 :ref:`freebsd` )的情况，可以管窥Linux **桌面发行版** 流程程度。观察基于 :ref:`debian` 和 :ref:`arch_linux` 的再发行版比较流行。 

- ``B2B服务视角`` : B2B服务公司 `enlyft <https://enlyft.com/>`_ 是为微软等世界五百强提供技术服务的B2B公司，统计了超过300w公司使用 `B2B服务公司enlyft的客户所使用操作系统的市场份额 <https://enlyft.com/tech/operating-systems>`_ :

  - Ubuntu占据了28%份额，几乎是CentOS+RHEL的两倍
  - enlyft统计是每日采集，统计了其服务于客户的主机操作系统数量，可以反映出大型计算机软件公司(如微软)以及云计算公司(如Pax8)等公司内使用操作系统等比例

个人最佳
===========

对于我个人来说，最佳Linux分别是:

- :ref:`gentoo_linux` 源代码编译，最大限度发挥硬件性能，对操作系统原理需要深入学习，是磨炼技术最佳平台
- :ref:`arch_linux` 精巧的滚动发行版本，时刻保持软件最新并且Arch Linux文档是开源社区最完备的发行版之一(另一个是 :ref:`gentoo_linux` )，对于学习非常有利
- :ref:`alpine_linux` 专注于轻量级，适合 :ref:`arm` 架构，对硬件要求低，更为安全

目前我主要使用:

- :ref:`ubuntu_linux` - 构建 :ref:`priv_cloud_infra`
- :ref:`alpine_linux` - 构建 :ref:`edge_cloud_infra`
- :ref:`fedora` - 开发

我感兴趣并且想尝试的版本
=========================

- `Rescatux <https://www.supergrubdisk.org/rescatux/>`_ 专用于修复Linux或Windows主机的发行版，使用轻量级LXDE桌面，可以修复bootloader，文件系统，分区表以及重置Linux和Windows密码
- `Parrot Security <https://parrotlinux.org/>`_ 渗透测试和漏洞评估的Linux发行版，类似 :ref:`kali_linux` ，从USB启动，可以用来搜集信息，漏洞分析，密码攻击，数字取证
- `OpenMediaVault <https://www.openmediavault.org/>`_ 基于Debian的构建NAS的发行版，提供SSH, SMB/CIFS, FTP, Rsync
- `Porteus <http://porteus.org/>`_ 从USB启动的微型Linux 版本，目前稳定版本还是2018年，但是正在构建下一代版本
- `Puppy Linux <http://puppylinux.com/>`_ 轻量级适合旧设备发行版
- `Solus <https://getsol.us/>`_ 面向开发者的滚动版本，提供了众多开发环境
- `NethServer <https://www.nethserver.org/>`_ 面向小型企业的易于管理的服务器版本，提供了大量服务，易于配置，基于CentOS的发行版
- `OPNsense <https://opnsense.org/>`_ 实际上这个版本并非基于Linux，而是基于FreeBSD的一个安全分支HardenedBSD，提供了入侵保护功能的最佳防火墙发行版，值得研究
- `DietPi <https://dietpi.com/>`_ 基于Debian定制的面向有限硬件资源(最小化CPU和内存使用)的SBC的Linux发行版，提供了种类繁多的针对不同SBC(包括 :ref:`raspberry_pi` 、 :ref:`pine64` )

参考
=======

- `Best Linux distros of 2021 for beginners, mainstream and advanced users <https://www.techradar.com/best/best-linux-distros>`_
