.. _install_ceph_manual:

=================================
手工部署Ceph
=================================

.. note::

   本章节采用 ``ceph`` 默认集群名来部署用于 :ref:`priv_cloud_infra` 数据层存储 - 目前尚未解决自定义Ceph集群名，所以 :ref:`install_ceph_manual_zdata` 是 ``尚未成功`` 的实践记录，待后续再构建环境继续研究。

.. toctree::
   :maxdepth: 1

   prepare.rst
   ceph_os_upgrade_ubuntu_22.04.rst
   install_ceph_mon.rst
   install_ceph_mgr.rst
   add_ceph_osds_raw.rst
   add_ceph_osds_lvm.rst
   add_ceph_mons.rst
   mon_clock_sync.rst
   add_ceph_osds_more.rst
   add_ceph_mds.rst
   ceph_var_disk.rst


.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
