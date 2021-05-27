.. _deploy_ntp:

========================
部署NTP服务(集群)
========================

在 :ref:`ntp_quickstart` 我介绍了在 RHEL/CentOS 环境中如何快速构建 ``ntpd`` 服务，提供集群以及自身服务器的时间同步。不过， ``ntpd`` 虽然功能强大，并且也是目前最完善实现NTP协议的标准服务，但是，在我们日常服务器运行环境中，已经逐步分化并采用了其他时钟同步方案:

- 主流发行版采用了 ``chrony`` 作为NTP服务器，原因是chrony虽然不如ntpd适合复杂全面的NTP协议，但是对于维护普通数据中心集群已完全满足要求，并且在网络中断后恢复同步时钟更为稳定，也适合支持大规模客户端
- 对于单纯的NTP客户端不在安装沉重的ntpd整套软件，而是采用 :ref:`systemd` 的组件 :ref:`systemd_timesyncd` 实现SNTP客户端，这样不在需要安装ntpd，也不需要ntpdate来实现同步，仅需要简单的一个组件就可以实现客户端时钟同步

  - 采用 ``systemd`` 的各个Linux发行版已经模式采用 :ref:`systemd_timesyncd` 取代了 ``ntpdate`` 以及 ``chrony`` (用于取代 ``ntpd`` 服务) 的客户端。以往通过操作系统启动时运行 ``ntpdate`` 来矫正时间，现在只需要默认启动 ``systemd-timesyncd`` 服务就可以矫正并保持本地时间同步
  - 不过，如果系统再安装 ``chrony`` ，则 ``timedatectl`` 将使用 ``chrony`` 来实现时间同步，这样可以确保不会同时运行两个时间同步服务。
  - ``ntpdate`` 今后将在未来的 ``timedatectl`` (或者 ``chrony`` )中去除，并且默认不在安装。 ``timesyncd`` 用于常规的时钟同步，而 ``chrony`` 则处理更为复杂的案例。

设置网络时间协议的服务
=======================

在Ubuntu平台，有多个软件可以实现网络时间服务，如 ``chrony`` ， ``ntpd`` 和 ``open-ntp`` ，建议使用 ``chrony``

chrony(d)
----------

NTP服务 ``chronyd`` 计算系统时钟的drift和offset并持续修正。如果长时间不能连接网络NTP服务器，也可以保证时钟不偏移。该服务只消耗很少的处理能力和内存，在现代服务器硬件环境这个消耗往往可以忽略。

- 安装::

   sudo apt install chrony

.. note::

   ``chrony`` 软件包包含2个执行程序：

   - ``chronyd`` 通过NTP协议提供时间同步的服务
   - ``chronyc`` 命令行和 ``chrony`` 服务交互的接口

chronyd配置
--------------

- 编辑 ``/etc/chrony/chrony.conf`` 添加服务配置行::

   pool 2.debian.pool.ntp.org offline iburst
   allow 192.168.6.0/24

.. note::

   这里提供内部局域网 ``192.168.6.0/24`` 网段NTP客户端访问，一定需要配置这行，否则 ``chronyd`` 服务启动后不监听端口

- 启动服务::

   sudo systemctl restart chrony.service

- 检查状态::

   chronyc sources

配置ufw
---------

Ubuntu系统使用ufw管理防火墙，对于NTP服务器，需要开放 UDP 端口 123 ::

   sudo ufw allow ntp

   sudo ufw disable
   sudo ufw enable

timesyncd客户端配置
===================

请参考 :ref:`systemd_timesyncd`

参考
======

- `Time Synchronization <https://help.ubuntu.com/lts/serverguide/NTP.html>`_
- `How To Set Up Time Synchronization on Ubuntu 16.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-time-synchronization-on-ubuntu-16-04>`_
