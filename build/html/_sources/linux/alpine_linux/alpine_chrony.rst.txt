.. _alpine_chrony:

=================================
Alpine Linux运行chrony(NTP服务)
=================================

在 :ref:`edge_cloud_infra` 中，部署独立 :ref:`edge_ntp_dns` 以提供整个边缘云的时钟同步(解决 :ref:`alpine_pi_clock_skew` )和提供 :ref:`k3s` 集群主机名解析。

部署说明
=========

在 :ref:`edge_cloud_infra` 中， ``x-k3s-m-1`` 部署 NTP 服务: 

- 实际上，所有 :ref:`raspberry_pi` 在解决 :ref:`alpine_pi_clock_skew` 问题已经全部安装了 :ref:`chrony` ，但是最初部署时候都是作为client运行，借用了 :ref:`priv_ntp` 。
- 现在拆分 :ref:`priv_cloud` 和 :ref:`edge_cloud` 后，则需要升级一台主机同时作为NTP  client 和 server。

安装
=======

- :ref:`alpine_install_pi_usb_boot` 步骤中已经安装 ``chrony`` 软件包并配置解决 :ref:`alpine_pi_clock_skew` ，所以安装步骤可跳过。

chrony配置
===========

- 在服务器 ``x-k3s-m-1`` 上编辑 ``/etc/chrony/chrony.conf`` 添加服务配置行:

.. literalinclude:: alpine_chrony/chrony-server.conf
   :language: bash
   :caption: chrony服务器的/etc/chrony/chrony.conf配置

- 然后在服务器 ``x-k3s-m-1`` 上执行以下命令重启 ``chrony`` 服务，很快就矫正了时间:

.. literalinclude:: alpine_chrony/restart_chronyd
   :language: bash
   :caption: alpine linux系统中重启chronyd服务

- 在 :ref:`edge_cloud_infra` 中其他节点都以 ``x-k3s-m-1`` 为NTP服务器，配置 ``/etc/chrony/chrony.conf`` 如下:

.. literalinclude:: alpine_chrony/chrony-client.conf
   :language: bash
   :caption: chrony服务端的/etc/chrony/chrony.conf配置

异常排查
==========

我遇到一个比较奇怪的问题:

- ``x-k3s-m-1`` 作为NTP服务器启动后，主机的时间立即就调整正确了
- 但是其他节点以 ``x-k3s-m-1`` 为服务器，重启 ``chrony`` 服务却不调整时间，一直显示比实际时间早1周左右

我最初怀疑是时间差异太大导致NTP不能自动调整，但是 ``/var/log/chrony`` 目录下是空的，参考ubuntu linux发行版的 ``chrony.conf`` 配置启用日志::

   # Uncomment the following line to turn logging on.
   log tracking measurements statistics

   # Log files location.
   logdir /var/log/chrony

但是依然没有日志生成 ^_^

**我乌龙了** ，原来我不知道为何鬼迷心窍，在 ``x-k3s-m-1`` 的 ``/etc/chrony/chrony.conf`` 配置行::

   pool pool.ntp.org offline iburst

上面多写了一个 ``offline`` 参数，这个参数应该是导致 ``chrony`` 停止对外服务。修订为::

   pool pool.ntp.org iburst

重启 ``x-k3s-m-1`` NTP服务器之后，网络中其他ntp客户端时间就正常调整了


