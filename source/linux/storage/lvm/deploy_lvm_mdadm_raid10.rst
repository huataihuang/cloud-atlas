.. _deploy_lvm_mdadm_raid10:

==================================
在 :ref:`mdadm_raid10` 上部署LVM
==================================

.. note::

   本文实践基于 :ref:`deploy_lvm` ，目标是在 :ref:`mdadm_raid10` 基础上完成 LVM 配置，以便能够灵活划分磁盘空间，为 :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10` 提供基础 ``bricks``

存储设备
==========

- 检查 ``md10`` 设备:

.. literalinclude:: ../software_raid/mdadm_raid10/mdadm_detail
   :caption: 使用 ``mdadm --detail`` 检查 ``md10`` RAID详情

可以看到存储情况:

.. literalinclude:: ../software_raid/mdadm_raid10/mdadm_detail_output
   :caption: 使用 ``mdadm --detail`` 检查RAID详情输出

部署LVM
==========

.. note::

   一点思考: :ref:`lvm_partion_vs_disk`

.. note::

   生产环境，我实际上做了简化，去掉了本文实践的 :ref:`linux_lvm` 层。主要是业务上没有这种灵活的安全数据隔离要求， ``过度`` 优化的方案对后续运维也是负担。

   不过，我自己的部署可能还是会做这个多层方案。待续...
