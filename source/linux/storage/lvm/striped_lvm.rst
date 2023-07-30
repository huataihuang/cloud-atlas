.. _striped_lvm:

========================
条带化逻辑卷管理(LVM)
========================

``lvdisplay -m``
===================

在我们构建的 LVM 中，数据是如何分布的，可以通过 ``-m`` 参数查看 ( ``--maps`` ):

.. literalinclude:: striped_lvm/lvdisplay_maps
   :caption: 检查LVM磁盘数据分布

.. literalinclude:: striped_lvm/lvdisplay_maps_output
   :caption: 检查LVM磁盘数据分布
   :emphasize-lines: 20,25


可以看到这里的类型是 ``linear`` ，也就是顺序分布
   

参考
=======

- `Striped Logical Volume in Logical volume management (LVM) <https://www.linuxsysadmins.com/create-striped-logical-volume-on-linux/>`_
