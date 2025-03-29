.. _jetson_ext4-fs_err:

===================================
Jetson Nano EXT4-fs文件系统错误
===================================

在我的Jetson Nano解决了 :ref:`jetson_pcie_err` 之后，长期运行，依然发现有文件系统错误

.. literalinclude:: jetson_ext4-fs_err/dmesg_ext4-fs-error.txt

EXT4文件系统fsck
====================

采用 :ref:`ext4_fsck` 进行修复，实践最终修复是通过将TF卡取下，通过USB转接器，插入到另外一个主机上执行 ``fsck`` 修复。修复完成后，上述Ext4文件系统错误不再出现，系统运行稳定。
