.. _centos_gluster_init:

===============================
为GlusterFS部署准备CentOS环境
===============================

CentOS目前依然是生产环境中常用的操作系统，虽然由于 :ref:`redhat_linux` 产品策略变化，CentOS已经不再作为Red Hat Enterprise Linux的下游产品，而是作为上游产品的滚动(stream)版本，稳定性和可靠性有所下降。目前很多遗留生产环境依然在使用CentOS 7系列，这里我将实践部署的完整过程。

说明
=======

- 根据 `Gluster Community Packages <https://docs.gluster.org/en/latest/Install-Guide/Community-Packages/>`_ 信息可以知道社区现在已经不再提供停止更新的CentOS 7系列的GlusterFS软件包，所以面对的第一个挑战就是自己 :ref:`build_glusterfs_11_for_centos_7`

准备
======

- 安装 :ref:`pssh` 帮助批量执行命令:
