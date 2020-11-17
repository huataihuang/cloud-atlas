.. _suse_iptables:

===================
SUSE iptables设置
===================

.. note::

   目前我还没有完整实践SuSE iptables: 为了快速搭建服务器，我关闭了 ``SuSEfirewall2_setup`` 服务，也就是停止了iptables防火墙。后续再做实践研究。

SuSEfirewall2_setup
======================

SuSE的配置交互方式都可以通过YaST2来完成，防火墙的配置也不例外。并且，SuSE默认启用了防火墙，导致外部不能访问本机服务，例如ssh。这是一个安全策略，但是也带来初始安装的SuSE虚拟机使用不便。

在SuSE Enterprise Linux又一个 "SuSEfirewall2_setup" 服务用来控制防火墙设置，并且使用 YaST firewall工具配置管理。这个防火墙服务停止就会清空iptables规则，我们在手工配置管理iptables之前，需要先停止这个服务。

- 停止防火墙::

   systemctl stop SuSEfirewall2_setup

- 禁止防火墙启动::

   systemctl disable SuSEfirewall2_setup

提示信息::

   Removed symlink /etc/systemd/system/multi-user.target.wants/SuSEfirewall2.service.
   Removed symlink /etc/systemd/system/multi-user.target.wants/SuSEfirewall2_init.service.
   Removed symlink /etc/systemd/system/SuSEfirewall2_setup.service.

配置基本iptables规则
====================

.. list-table:: iptables基本tables
   :widths: 20 80
   :header-rows: 1

   * - Table
     - 说明
   * - Filter
     - 默认netfilter表就是Filter，如果 iptables 命令没有使用 ``-t`` 参数，则默认也是使用这个表。这个Filter表包含内建的 ``INPUT`` 链(发往本地sockets的数据包)， ``FORWARD`` 链(在主机内部路由的数据包) 和 ``OUTPUT`` 链(本地产生的数据包)
   * - Mangle
     - 这个Mangle表是特殊数据包修改表。从Kernel 2.4.18开始，有3个内建的链路表： ``INPUT`` , ``FORWARD`` 和 ``OUTPUT``
   * - NAT
     - NAT表是在数据包创建新的连接时触发。包含3个内建链路： ``PREROUTING`` (用于在数据包进入时修改) ``OUTPUT`` (用于本地产生的数据包被路由前做修改) 和 ``POSTROUTING`` （当数据包发出去时候修改)
   * - RAW
     - RAW表是具备 ``NOTRACK`` 标签的数据包免除连接跟踪。这个表链在netfilter hooks中使用较高的优先级，并且在 ``ip_conntrack`` 或其他任何 IP表之前调用。提供了以下两个内建链路: ``PREROUTING`` 和 ``OUTPUT``

参考
=====

- `Basic iptables Tutorial <https://www.suse.com/c/basic-iptables-tutorial/>`_
