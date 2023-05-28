.. _ceph_rbd_export_import:

==========================
Ceph RBD 导出和导入
==========================

我在 :ref:`priv_cloud_infra` 的 :ref:`ceph` 集群通过 :ref:`ceph_rbd_libvirt` 运行 :ref:`win7` 虚拟机，安装Windows系统非常耗时，所以考虑在系统安装完成并升级好最新补丁之后，做一次完整的备份。

导出
=====

- 已经按照 :ref:`ceph_rbd_libvirt` 部署并且配置好 ``ceph`` 客户端 ( :ref:`ceph_args` 指定访问 ``libvirt-pool`` )

用户目录环境变量:

.. literalinclude:: ceph_rbd_libvirt/ceph_args
   :language: bash
   :caption: 环境变量指定默认访问 ``libvirt-pool`` 存储池

- 执行检查:

.. literalinclude:: ceph_rbd_export_import/ceph_ls_libvit
   :language: bash
   :caption: 检查RBD存储池

输出显示，需要导出的 ``z-win7`` 磁盘大约19G

.. literalinclude:: ceph_rbd_export_import/ceph_ls_libvit_output
   :language: bash
   :caption: 检查RBD存储池

- 执行导出:

.. literalinclude:: ceph_rbd_export_import/rbd_export_pool_image
   :language: bash
   :caption: 导出 ``libvirt-pool`` 存储池的磁盘镜像 ``z-win7``

完成后导出的备份文件就是 ``z-win7_export.gzip`` ，可以用于导入到其他集群或者直接用于 :ref:`libvirt` 存储

恢复
======

- 解压缩 ``z-win7_export.gzip`` :

.. literalinclude:: ceph_rbd_export_import/rbd_export_pool_image
   :language: bash
   :caption: 导出 ``libvirt-pool`` 存储池的磁盘镜像 ``z-win7``

- ``gzip`` 的使用方法比较特殊，参考 `How do you gunzip a file and keep the .gz file? <https://superuser.com/questions/45650/how-do-you-gunzip-a-file-and-keep-the-gz-file>`_ 默认会删除源文件，所以采用 ``-c`` 参数保留源文件:

   

参考
=====

- `How do I export .raw file from a ceph <https://forum.proxmox.com/threads/how-do-i-export-raw-file-from-a-ceph.60236/>`_
- `Pipe rbd export comand to tar to create compressed export <https://serverfault.com/questions/1052670/pipe-rbd-export-comand-to-tar-to-create-compressed-export>`_
