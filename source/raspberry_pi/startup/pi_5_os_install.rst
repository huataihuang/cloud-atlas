.. _pi_5_os_install:

=======================
树莓派5系统安装
=======================

我现在(2026年8月底)准备重新构建 :ref:`autodeploy_pi_os` 实现 :ref:`pi_soft_storage_cluster` ，所以全新安装 :ref:`pi_os`

- 下载最新 :ref:`pi_os` lite版本并写入 U盘:

.. literalinclude:: pi_5_os_install/umount
   :caption: 卸载已经自动挂载的磁盘为后续写入镜像做准备

.. literalinclude:: pi_5_os_install/xz
   :caption: 解压缩下载的xz压缩文件

.. literalinclude:: pi_5_os_install/dd
   :caption: 写入镜像
