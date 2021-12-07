.. _install_ceph_manual_zdata:

=================================
Ceph 手工部署zdata集群(暂未成功)
=================================

我在为 :ref:`real` 构建 :ref:`priv_cloud_infra` 数据存储层(基于Ceph)，采用了自定义Ceph名字 ``zdata`` 。虽然 :ref:`install_ceph_mon_zdata` 和 :ref:`install_ceph_mgr_zdata` 都可以顺利完成，但是在 :ref:`add_ceph_osds_zdata` 遇到了 ``ceph_volume`` 不能正常传递集群名称的问题。我暂时没有找到解决方法，但是又有太多其他部署实践需要完成，所以暂时回归采用 :ref:`install_ceph_manual` 部署默认 ``ceph`` 作为集群名称。此项自定义安装实践，我准备后续在虚拟化集群中再做实践尝试。

.. note::

   我在部署 :ref:`ceph_rbd_libvirt` 实践发现环境变量 ``CEPH_ARGS`` ( :ref:`ceph_args` )可以传递参数，也就是可以在自定义集群名称传递参数。我后续实践将尝试部署自定义集群

.. toctree::
   :maxdepth: 1

   prepare_zdata.rst
   install_ceph_mon_zdata.rst
   install_ceph_mgr_zdata.rst
   add_ceph_osds_zdata.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
