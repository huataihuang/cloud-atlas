.. _iptables_persistent:

=====================
iptables配置持久化
=====================

iptables的配置持久化，实际是通过 ``iptables-save`` / ``iptables-restore`` 实现的，简单来说:

.. literalinclude:: iptables_persistent/iptables_save_restore
   :language: bash
   :caption: iptables-save 和 iptables-restore 结合实现iptables规则持久化

不过实际使用，约定俗成会结合网络管理工具来执行

RHEL/CentOS
=============

RHEL/CentOS使用 ``iptables-services`` 软件包来实现iptables规则持久化

- 安装:

.. literalinclude:: iptables_persistent/iptables-services_install
   :language: bash
   :caption: RHEL/CentOS安装iptables-services实现持久化

安装完成后，有两个相应的iptables规则配置文件:

.. literalinclude:: iptables_persistent/iptables-services_sysconfig
   :language: bash
   :caption: RHEL/CentOS iptables-services持久化配置文件

- 确保 :ref:`systemd` 关闭 firewalld 然后激活 iptables 服务:

.. literalinclude:: iptables_persistent/iptables-services_enable
   :language: bash
   :caption: RHEL/CentOS安装激活iptables-services

- 检查iptables服务:

.. literalinclude:: iptables_persistent/iptables-services_status
   :language: bash
   :caption: RHEL/CentOS iptables-services 服务状态

- 保存iptables规则:

.. literalinclude:: iptables_persistent/iptables-services_save
   :language: bash
   :caption: RHEL/CentOS 保存iptables规则

然后重启系统也可以确保iptables规则恢复

Debian/Ubuntu
===============

Debian/Ubuntu系统可以使用 ``iptables-persistent`` 软件包来实现iptables规则持久化(不过安装 :ref:`docker` 等应用，也会在各自启动服务中配置自己的iptables规则)

- 安装:

.. literalinclude:: iptables_persistent/iptables-persistent_install
   :language: bash
   :caption: Debian/Ubuntu安装iptables-persistent实现持久化

- Debian/Ubuntu的iptables-persistent使用以下2个配置文件:

.. literalinclude:: iptables_persistent/iptables-persistent_config
   :language: bash
   :caption: Debian/Ubuntu iptables-persistent持久化配置文件

- 所以在Debian/Ubuntu系统上iptalbes规则保存方法如下:

.. literalinclude:: iptables_persistent/iptables-persistent_save
   :language: bash
   :caption: Debian/Ubuntu 保存iptables规则

参考
==========

- `How to make iptables persistent after reboot on Linux <https://linuxconfig.org/how-to-make-iptables-rules-persistent-after-reboot-on-linux>`_
- `How To Install iptables-persistent on Ubuntu 20.04 <https://installati.one/ubuntu/20.04/iptables-persistent/>`_
