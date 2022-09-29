.. _upgrade_ubuntu_20.04_to_22.04:

=================================
升级Ubuntu 22.04 LTS到22.04 LTS
=================================

按照 `Ubuntu发布周期 <https://ubuntu.com/about/release-cycle#ubuntu>`_ 每2年会发布一个 "长期支持版" (LTS, Long Term Support)。具体来说，就是每2年的4月份会发布一个支持周期长达5年的稳定版本，如: 20.04 和 22.04 分别代表 2020年4月 和 2022年4月 发布的长期支持版本.

.. figure:: ../../../_static/linux/ubuntu_linux/admin/ubuntu_release_cycle.png
   :scale: 70

当前(2022年9月)，Ubuntu 22.04 LTS发布已经将近半年，我准备将 :ref:`priv_cloud_infra` 的 :ref:`hpe_dl360_gen9` 底层操作系统Ubuntu Linux升级到最新长期稳定版本。

由于Ubuntu跨版本升级可能需要较多的磁盘空间，而我在构建 :ref:`priv_cloud_infra` 时为了能够尽可能将存储空间保留给 :ref:`docker_btrfs_driver` ，操作系统的根目录磁盘空间只有 32G (日常运行只有3G空闲)，所以首先需要在虚拟机环境模拟升级，充分验证升级可行性。

.. note::

   实际磁盘空间分配可以采用 :ref:`trace_disk_space_usage` 进行分析，我通过这种方法将系统中占用大量磁盘的数据文件全部迁移到独立挂载磁盘分区的 :ref:`btrfs` 卷中，最终可以将日常根目录10G以下(空闲22G)。

   之前在 :ref:`upgrade_ubuntu` 是非稳定版本升级，本次实践则完整记录LTS稳定版本升级。

升级系统包
============

- 在进行大版本升级之前，首先要将当前版本升级到最新::

   sudo apt update && sudo apt upgrade -y

- 清理无用包::

   sudo apt autoremove -y

- 重启系统::

   sudo reboot

准备后备SSH端口
=================

如果使用ssh登录到服务器上进行版本升级，升级过程中ssh网络链接会断开。Ubuntu升级工具会在默认SSH端口22断开连接时提供一个fallback端口 ``1022`` 。但是需要注意，如果使用了Ubuntu的防火墙 :ref:`ufw` 则需要先允许该端口访问::

   sudo ufw allow 1022/tcp
   sudo ufw reload

并检查端口打开情况::

   sudo ufw status

升级
======

- 首先安装版本升级工具 ``do-release-upgrade`` ::

   sudo apt install update-manager-core

- 执行以下命令开始升级::

   sudo do-release-upgrade -d

提示信息::

   Reading cache

   Checking package manager

   Continue running under SSH?

   This session appears to be running under ssh. It is not recommended
   to perform a upgrade over ssh currently because in case of failure it
   is harder to recover.

   If you continue, an additional ssh daemon will be started at port
   '1022'.
   Do you want to continue?

   Continue [yN]

可以看到不推荐通过SSH升级: 当然，对于我所使用的 :ref:`hpe_dl360_gen9` 实际上可以通过 :ref:`hp_ilo` 的控制台进行升级，这样更为保险。

- 由于这里案例采用SSH方式访问服务器进行升级，所以按照提示输入 ``y`` 继续

.. note::

   ``do-release-upgrade`` 实际上启动了一个 ``screen`` 工具来保证网络断开时不影响升级过程。

此时提示::

   Starting additional sshd

   To make recovery in case of failure easier, an additional sshd will
   be started on port '1022'. If anything goes wrong with the running
   ssh you can still connect to the additional one.
   If you run a firewall, you may need to temporarily open this port. As
   this is potentially dangerous it's not done automatically. You can
   open the port with e.g.:
   'iptables -I INPUT -p tcp --dport 1022 -j ACCEPT'

   To continue please press [ENTER]

- 按下回车继续

- 提示信息显示会禁止第三方软件仓库::

   Reading package lists... Done
   Building dependency tree
   Reading state information... Done
   Hit http://archive.ubuntu.com/ubuntu focal InRelease
   Get:1 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
   Get:2 http://archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
   Get:3 http://archive.ubuntu.com/ubuntu focal-security InRelease [114 kB]
   Get:4 http://archive.ubuntu.com/ubuntu focal-security/universe amd64 Packages [729 kB]
   Ign http://downloads.linux.hpe.com/SDR/repo/mcp bionic/current-gen9 InRelease
   Hit http://downloads.linux.hpe.com/SDR/repo/mcp bionic/current-gen9 Release
   Get:5 http://archive.ubuntu.com/ubuntu focal-security/universe Translation-en [135 kB]
   Get:6 http://archive.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [15.1 kB]
   Fetched 1,215 kB in 6s (103 kB/s)
   Reading package lists... Done
   Building dependency tree
   Reading state information... Done

   Updating repository information

   Third party sources disabled

   Some third party entries in your sources.list were disabled. You can
   re-enable them after the upgrade with the 'software-properties' tool
   or your package manager.

   To continue please press [ENTER]

- 继续回车

此时会下载仓库软件索引信息

然后提示信息::

   Do you want to start the upgrade?


   12 packages are going to be removed. 187 new packages are going to be
   installed. 1015 packages are going to be upgraded.

   You have to download a total of 998 M. This download will take about
   6 hours with your connection.

   Installing the upgrade can take several hours. Once the download has
   finished, the process cannot be canceled.

    Continue [yN]  Details [d]

输入 ``y`` 继续

- 升级安装包过程非常顺滑，安装过程会提示一些服务会重启，在这里选择 ``Yes`` 避免重复提示::

   There are services installed on your system which need to be restarted when certain libraries, 
   such as libpam, libc, and libssl, are upgraded. Since these restarts may cause interruptions of service for the system,
   you will normally be prompted on each upgrade for the list of services you wish to restart.
   You can choose this option to avoid being prompted;
   instead, all necessary restarts will be done for you automatically so you can avoid being asked questions on each library upgrade.

   Restart services during package upgrades without asking?

- 在安装过程中会提示修改 ``sshd_config`` 配置文件，可以选择使用软件包维护者版本或保留原先本地配置

- 我修订过 ``/etc/systemd/resolved.conf`` ，所以保留该文件而不是安装的默认配置

- nginx配置也保留原有配置::

   Configuration file '/etc/nginx/nginx.conf'
    ==> Modified (by you or by a script) since installation.
    ==> Package distributor has shipped an updated version.
      What would you like to do about it ?  Your options are:
       Y or I  : install the package maintainer's version
       N or O  : keep your currently-installed version
         D     : show the differences between the versions
         Z     : start a shell to examine the situation
    The default action is to keep your current version.
   *** nginx.conf (Y/I/N/O/D/Z) [default=N] ?
   Installing new version of config file /etc/nginx/sites-available/default ...

- sudo 配置和 sysctl.conf / chrony.conf / sshd.conf / squid.conf

- 最后会提示是否移除安装包，回答 ``y`` ，并重启

- 重启后检查版本::

   lsb_release -a

输出显示升级成功::

   No LSB modules are available.
   Distributor ID:	Ubuntu
   Description:	Ubuntu 22.04.1 LTS
   Release:	22.04
   Codename:	jammy

Linux版本检查::

   uname -mrs

可以看到内核从 ``5.4`` 跃升到 ``5.15`` ::

   Linux 5.15.0-48-generic x86_64

- 重新激活第三方软件仓库: 第三方软件仓库配置被集中到 ``/etc/apt/sources.list.d`` 目录下

- 最后清理磁盘空间，删除不需要的文件::

   sudo apt autoremove --purge

参考
======

- `How to Upgrade from Ubuntu 20.04 LTS to Ubuntu 22.04 LTS <https://jumpcloud.com/blog/how-to-upgrade-ubuntu-20-04-to-ubuntu-22-04>`_ 
- `How to upgrade from Ubuntu 20.04 LTS to 22.04 LTS <https://www.cyberciti.biz/faq/upgrade-ubuntu-20-04-lts-to-22-04-lts/>`_
- `How To Upgrade Ubuntu To 22.04 LTS Jammy Jellyfish <https://linuxconfig.org/how-to-upgrade-ubuntu-to-22-04-lts-jammy-jellyfish>`_
