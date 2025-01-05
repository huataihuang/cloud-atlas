.. _vnet_jail:

====================
FreeBSD VNET Jail
====================

FreeBSD VNET Jail是一种 **虚拟化** 环境，对其中运行的进程的网络资源进行隔离和控制:

- 通过对VNET Jail创建单独的网络堆栈，确保Jail内网络流量与主机系统和其他Jail隔离
- 确保高级别网络隔离和安全性
- 可以为VNET Jail创建成 :ref:`thick_jail` 或 :ref:`thin_jail` 

VNET Jail是一种专门针对网络的Jail，可以补充 ``thick jail`` 和 ``thin jail`` 的不足
