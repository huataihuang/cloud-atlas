.. _ntp_in_studio:

===================
Studio环境中NTP
===================

在操作系统中，有一个非常不起眼但是非常重要的服务，就是时间同步服务，因为操作系统的时钟准确性影响了很多应用程序，甚至会导致系统出现莫名其妙的异常。在我们的Studio环境中，需要模拟数据中心构建集群，确保笔记本电脑的时钟精确是非常关键的。例如，时钟偏移会导致操作系统无法通过apt更新软件。

.. note::

   传统的Unix/Linux系统中，负责主机时钟同步的软件是 ntpd ，这是一个历史悠久的NTP协议软件，并且在稳定性和协议兼容性上优于其他NTP软件（如 chrony ）。不过，很多服务器并不是连接时钟设备作为一级NTP服务器，所以通常采用 chrony 或者 systemd内建的 timesyncd 来实现。

从Ubuntu 16.04开始 ``timedatectl`` 和 ``timesyncd`` （属于 ``systemd`` 的部分）代替了以往常用的 ``ntpdate`` 和 ``ntp`` 工具。 ``timesyncd`` 不仅默认提供，并且取代了 ``ntpdate`` 以及 ``chrony`` （用于取代 ``ntpd`` 的服务）的客户端。以前通过启动时使用 ``ntpdate`` 命令来矫正时间，现在只需要默认启动的 ``timesyncd`` 来完成并保持本地时间同步。

.. note::

   如果安装了 ``chrony`` ，则 ``timedatectl`` 将让 ``chrony`` 来实现时间同步。这样可以确保不会同时运行两个时间同步服务。

   ``ntpdate`` 今后将在未来的 ``timedatectl`` （或者 ``chrony`` ）中去除，并且默认不再安装。 ``timesyncd`` 则用于常规的本地主机时钟同步，而 ``chrony`` 则作为局域网中对外提供NTP服务。

配置timedatectl和timesyncd
=============================

- 使用 ``timedatectl status`` 可以检查时钟情况::

   $ timedatectl status
         Local time: Tue 2018-05-01 21:54:24 CST
     Universal time: Tue 2018-05-01 13:54:24 UTC
           RTC time: Tue 2018-05-01 13:54:24
          Time zone: Asia/Shanghai (CST, +0800)
    Network time on: yes
   NTP synchronized: yes
    RTC in local TZ: no

- 使用 ``systemctl status systemd-timesyncd`` 可以检查时钟同步情况

- 在 ``/etc/systemd/timesyncd.conf`` 设置了 ``timedatectl`` 和 ``timesyncd`` 获取时钟值的名字服务器，并且详细的配置文件可以在 ``/etc/systemd/timesyncd.conf.d/`` 目录下找到。

- 配置 ``timesyncd`` 使用局域网中NTP服务器进行时钟同步 （下文将介绍在局域网中配置 ``chronyd`` 时钟服务方法）::

   [Time]
   NTP=192.168.0.1

然后重启 ``systemd-timesyncd`` 服务::

   sudo systemctl restart systemd-timesyncd

再次检查 ``systemctl status systemd-timesyncd`` 就可以看到主机和指定的NTP服务器同步时间。

设置网络时钟协议的服务（NTP服务器）
====================================

在Ubuntu平台，有多个软件可以实现网络时间服务，如 ``chrony`` ， ``ntpd`` 和 ``open-ntp`` 。建议使用 ``chrony`` 。

chrnoy(d)
-------------

NTP服务 ``chronyd`` 计算系统时钟的drift和offset并持续修正。如果长时间不能连接网络NTP服务器，也可以保证时钟不偏移。该服务只消耗很少的处理能力和内存，在现代服务器硬件环境这个消耗往往可以忽略。

- 安装::

   sudo apt install chrony

``chrony`` 软件包包含2个执行程序：

- ``chronyd`` - 通过NTP协议提供时间同步的服务
- ``chronyc`` - 命令行和 ``chrony`` 服务交互的接口

- chronyd配置

编辑 ``/etc/chrony/chrony.conf`` 添加服务配置行::

   pool 2.debian.pool.ntp.org offline iburst
   allow 192.168.1.0/24

.. note::

   一定要配置一行 ``allow 192.168.`.0/24`` ，否则 ``chronyd`` 服务启动后不会监听任何端口

- 启动服务::

   sudo systemctl restart chrony.service

- 检查状态::

   chronyc sources

配置ufw
----------

对于启动了 ``ufw`` 防火墙配置的Ubuntu服务器，需要添加端口允许::

   sudo ufw allow ntp
   
   sudo ufw disable
   sudo ufw enable

设置时区
===========

默认安装 Ubuntu Server ，时区设置是 UTC ，对于本地时间查看非常不习惯。

- 检查默认时区::

   ls -lh /etc/localtime

输出显示::

   lrwxrwxrwx 1 root root 27 Jun  9 08:41 /etc/localtime -> /usr/share/zoneinfo/Etc/UTC

- 修改成本地时间(Shanghai)::

   sudo unlink /etc/localtime
   sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

然后再使用 ``date`` 命令就可以看到正确的本地时间。

参考
========

- `Time Synchronization <https://help.ubuntu.com/lts/serverguide/NTP.html>`_
- `How To Set Up Time Synchronization on Ubuntu 16.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-time-synchronization-on-ubuntu-16-04>`_
