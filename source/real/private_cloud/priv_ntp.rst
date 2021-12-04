.. _priv_ntp:

===================
私有云NTP服务
===================

我在部署 :ref:`priv_cloud_infra` 的数据层存储 :ref:`ceph` 时， :ref:`add_ceph_osds_lvm` 第二个mon节点，Ceph Dashboard的系统Health就提示::

   clock skew detected on mon.z-b-data-2

实际上2个虚拟机的时间差只有2秒钟，但是对于分布式存储系统，时钟不同步会导致很多系统异常。这也提醒我，在部署大规模分布式系统( 可以参考 :ref:`openstack` 的 :ref:`openstack_environment` 基础设置需求)

