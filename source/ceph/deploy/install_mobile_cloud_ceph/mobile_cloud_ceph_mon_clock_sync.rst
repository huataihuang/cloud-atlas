.. _mobile_cloud_ceph_mon_clock_sync:

===============================
移动云计算Ceph Monitor时钟同步
===============================

为避免 :ref:`mon_clock_sync` 曾经出现过的虚拟机时钟不同步问题，在开始第二个节点部署之前，先完成所有虚拟机的时钟同步部署:

- 在物理主机 ``acloud`` 上面向整个 :ref:`mobile_cloud_kvm` 集群 :ref:`deploy_ntp`
- 所有虚拟机都启用 :ref:`systemd_timesyncd` 同步时钟

部署 chrony 服务器
=======================

- ``acloud`` 物理主机(也就是苹果Apple Silocon笔记本Macbook Pro的 :ref:`asahi_linux` )，执行以下命令安装::

   sudo pacman -S chrony

- 编辑 ``/etc/chrony.conf`` 添加服务配置::

   allow 192.168.8.0/24

.. note::

   其他配置保持默认

- 启动服务::

   sudo systemctl restart chronyd.service
   sudo systemctl enable chronyd.service

- 检查服务状态正常::

   sudo systemctl status chronyd.service

配置客户机Systemd Timesyncd服务
==================================

.. note::

   详情参考 :ref:`systemd_timesyncd`

- Fedora 37默认已经安装了 ``systemd-timesyncd`` (但是我没有找到安装软件包)

.. note::

   操作系统默认已经安装和启动 ``systemd-timesyncd`` ，但是需要配置采用前述部署的局域网内部NTP服务器

- ``/etc/systemd/timesyncd.conf`` 修改::

   [Time]
   NTP=192.168.8.1

- 重启 ``systemd-timesyncd`` 服务::

   systemctl restart systemd-timesyncd
   systemctl enable systemd-timesyncd

然后检查同步配置::

   timedatectl show-timesync --all

时钟服务器已经指向 ``192.168.8.1`` 也就是 ``acloud`` 服务器上自建的NTP服务器
