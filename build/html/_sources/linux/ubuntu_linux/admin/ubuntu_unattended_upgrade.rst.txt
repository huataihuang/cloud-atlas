.. _ubuntu_unattended_upgrade:

==================
Ubuntu无人值守升级
==================

首次安装 :ref:`ubuntu64bit_pi` 之后，执行升级命令::

   apt install screen

提示错误::

   Waiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 2542 (unattended-upgr)

可以看到系统中有一个进程::

   /usr/bin/python3 /usr/bin/unattended-upgrade

也可能有多个进程::

   root        1317  0.0  0.2 107792 19076 ?        Ssl  00:34   0:00 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
   root        2542 33.4  1.6 296300 134172 ?       Sl   00:39   1:19 /usr/bin/python3 /usr/bin/unattended-upgrade
   root        4534  1.0  1.0 296300 87332 ?        S    00:42   0:00 /usr/bin/python3 /usr/bin/unattended-upgrade

- 检查状态::

   systemctl status unattended-upgrades

显示::

   ● unattended-upgrades.service - Unattended Upgrades Shutdown
        Loaded: loaded (/lib/systemd/system/unattended-upgrades.service; enabled; vendor preset: enabled)
        Active: active (running) since Wed 2020-04-01 17:25:51 UTC; 6 months 19 days ago
          Docs: man:unattended-upgrade(8)
      Main PID: 1317 (unattended-upgr)
         Tasks: 2 (limit: 9254)
        CGroup: /system.slice/unattended-upgrades.service
                └─1317 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
   
   Apr 01 17:25:51 pi-worker1 systemd[1]: Started Unattended Upgrades Shutdown. 

- 检查 ``apt update`` 命令显示的::

   Reading package lists... Done
   Building dependency tree
   Reading state information... Done
   69 packages can be upgraded. Run 'apt list --upgradable' to see them.

``XX packages can be upgraded`` 数值不断减少，说明后台正在不断更新软件包。

unatted-upgrades简介
======================

``unattended-upgrades`` 服务提供了自动的安全补丁安装。

- 如果 ``unattended-upgrades`` 软件包没有默认安装，可以通过命令安装:

.. literalinclude:: ubuntu_unattended_upgrade/apt_install_unattended-upgrades
   :language: bash
   :caption: 使用apt命令安装unattended-upgrades软件包

- 安装完成后使用以下命令交互激活::

   sudo dpkg-reconfigure --priority=low unattended-upgrades

上述命令会创建 ``/etc/apt/apt.conf.d/20auto-upgrades`` 配置，包含一下内容::

   APT::Periodic::Update-Package-Lists "1";
   APT::Periodic::Unattended-Upgrade "1";

- 如果不使用激活命令，也可以直接使用以下直接生成配置的方式来激活 ``unattended-upgrades`` :

.. literalinclude:: ubuntu_unattended_upgrade/enable_unattended-upgrades
   :language: bash
   :caption: 命令行激活unattended-upgrades

当apt任务启动时，它将随机在 0 到 ``APT::Periodic::RandomSleep`` 秒数之间休眠，默认是1800秒，也就是停止最多30分钟，这样可以避免大量用户同时访问镜像网站而导致压力过大。只有使用本地镜像才可以将这个值设为0。

如果需要更多升级调试信息，则设置 ``APT::Periodic::Verbose "1";``

当前unattended-upgrades配置
----------------------------

执行一下命令可以获得当前apt配置::

   apt-config dump APT::Periodic::Unattended-Upgrade

设置cron和aptitude
===================

- 可以设置每周更新安全补丁，增加一个 ``/etc/cron.weekly/apt-security-updates`` 配置如下::

   echo "**************" >> /var/log/apt-security-updates
   date >> /var/log/apt-security-updates
   aptitude update >> /var/log/apt-security-updates
   aptitude safe-upgrade -o Aptitude::Delete-Unused=false --assume-yes --target-release `lsb_release -cs`-security >> /var/log/apt-security-updates
   echo "Security updates (if any) installed"

然后注意这个文件必须设置为可执行::

   sudo chmod +x /etc/cron.weekly/apt-security-updates

这样就能够每周执行升级

- 还需要配套设置升级日志轮转，编辑 ``/etc/logrotate.d/apt-security-updates`` 内容如下::

   /var/log/apt-security-updates {
     rotate 2
     weekly
     size 250k
     compress
     notifempty
   }

停用unattended-upgrades
========================

在启动或停止Ubuntu时，我注意到启动输出中有一个job会长时间停顿直到超时，类似输出::

   A stop job is running for Unattended Upgrades Shutdown (10s / 30 min)

特别是网络没有配置好，主机无法连接internet时候，这个超时时间非常长。

- 停止::

   systemctl stop unattended-upgrades

停止 ``unattended-upgrades`` 需要一些时间，后台当前在更新的软件包没有完成时不会退出。

- 禁止 ``unattended-upgrades`` ::

   systemctl disable unattended-upgrades

这样今后启动系统时就不会再出现长时间等待升级进程完成的延迟，关机也可以较为迅速。

也可以通过交互方式关闭 ``sudo dpkg-reconfigure unattended-upgrades``

- 如果你确实不需要自动升级，也可以移除这个软件包::

   sudo apt remove unattended-upgrades 

参考
======

- `AutomaticSecurityUpdates <https://help.ubuntu.com/community/AutomaticSecurityUpdates>`_
- `How To Setup And Enable Automatic Security Updates On Ubuntu <https://phoenixnap.com/kb/automatic-security-updates-ubuntu>`_
- `How To Disable Unattended Upgrades On Ubuntu <https://ostechnix.com/how-to-disable-unattended-upgrades-on-ubuntu/>`_
