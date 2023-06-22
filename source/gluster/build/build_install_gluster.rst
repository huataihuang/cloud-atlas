.. _build_install_gluster:

===========================
源代码编译安装GlusterFS
===========================

编译GlusterFS环境
==================

编译GlusterFS需要以下软件包:

.. literalinclude:: build_install_gluster/build_require
   :caption: 编译GlusterFS需要的软件包列表

Fedora编译需要
---------------

- 使用dnf在Fedora上安装以下编译环境:

.. literalinclude:: build_install_gluster/build_requirements_for_fedora
   :caption: 在Fedora编译GlusterFS需要的软件包

Ubuntu编译需要
----------------

- 使用apt在Ubuntu上安装编译环境:

.. literalinclude:: build_install_gluster/build_requirements_for_ubuntu
   :caption: 在Ubuntu编译GlusterFS需要的软件包

CentOS/Enterprise Linux v7
----------------------------

.. note::

   实际安装编译依赖环境需要激活多个仓库，见 :ref:`build_glusterfs_11_for_centos_7`

- 使用 yum 在CentOS / Enterprise Linux 7上安装编译环境:

.. literalinclude:: build_install_gluster/build_requirements_for_centos7
   :caption: 在Ubuntu编译GlusterFS需要的软件包

.. note::

   我的实践在这一步参考原文安装依赖包有一些缺少提示，显示没有以下软件包可以安装::

      cmockery2-devel
      python-eventlet
      python-paste-deploy
      python-simplejson

   原因是是:

   - ``cmockery2-devel`` 需要激活EPEL
   - ``python-paste-deploy`` / ``python-eventlet``  是 :ref:`openstack` 仓库提供，不使用OpenStack可能可以忽略，不过我参考 `phone.net <http://rpm.pbone.net/>`_ 搜索对应于不同 :ref:`centos` 的 :ref:`openstack` 版本，例如对于 CentOS 7.9.2009 有多个版本，即 ``rocky`` , ``train`` , ``queens`` , ``stein`` ，激活仓库
   - ``python-simplejson`` 改名成 ``python2-simplejson`` 也是 :ref:`openstack` 仓库提供

   

参考
======

- `Building GlusterFS <https://docs.gluster.org/en/latest/Developer-guide/Building-GlusterFS/>`_
