.. _priv_ntp:

===================
私有云NTP服务
===================

我在部署 :ref:`priv_cloud_infra` 的数据层存储 :ref:`ceph` 时， :ref:`add_ceph_osds_lvm` 第二个mon节点，Ceph Dashboard的系统Health就提示::

   clock skew detected on mon.z-b-data-2

实际上2个虚拟机的时间差只有2秒钟，但是对于分布式存储系统，时钟不同步会导致很多系统异常。这也提醒我，在部署大规模分布式系统( 可以参考 :ref:`openstack` 的 :ref:`openstack_environment` 基础设置需求)

由于只有一台物理主机，实际上最准确的也最容易保持的时钟的服务器就是 ``zcloud`` 物理主机:

- 物理主机有硬件时钟(通过主板电池保证BIOS时钟不会偏差)
- 物理主机只要启动就容易连接Internet(无需复杂的虚拟化)，可以随时完成时间同步

通过 :ref:`deploy_ntp` 可以提供整个 :ref:`priv_cloud_infra` 所有虚拟机时钟同步

安装chrony服务
=================

- 安装 ``chrony`` ::

   sudo apt install chrony

- 修改 ``/etc/chrony/chrony.conf`` 添加服务配置行::

   allow 192.168.6.0/24
   allow 192.168.7.0/24

默认配置中已经有和上级NTP服务器同步配置，所以不需要再指定上级NTP::

   pool ntp.ubuntu.com        iburst maxsources 4
   pool 0.ubuntu.pool.ntp.org iburst maxsources 1
   ...

- 启动 ``chrony`` ::

   sudo systemctl start chrony
   sudo systemctl enable chrony

客户端
===========

systemd-timesyncd客户端
------------------------

所有虚拟机发行版基本都采用了 :ref:`systemd` ，内置了 :ref:`systemd_timesyncd` 可以和NTP服务器进行时钟同步

- 修订客户机 ``/etc/systemd/timesyncd.conf`` ::

   [Time]
   NTP=192.168.6.200

- 启动和激活 ``systemd-timesyncd`` ::

   sudo systemctl enable systemd-timesyncd.service
   sudo systemctl start systemd-timesyncd.service

- 然后监测服务::

   sudo systemctl status systemd-timesyncd

- 为方便查看本地时间，检查 ``/etc/localtime`` 软链接，确保::

   /etc/localtime -> ../usr/share/zoneinfo/Asia/Shanghai

.. _chrony_client:

chrony客户端
----------------

在 :ref:`edge_cloud` 的 :ref:`pi_4` 上部署 :ref:`alpine_linux` 构建 :ref:`k3s` 。树莓派没有硬件时钟，配置 :ref:`chrony` 同步时钟:

- 配置 ``/etc/chrony/chrony.conf`` 设置 ``192.168.7.200`` 作为NTP服务器:

.. literalinclude:: ../../infra_service/ntp/deploy_ntp/chrony-client.conf
   :language: bash
   :caption: chrony客户端配置 /etc/chrony/chrony.conf
