.. _gluster_mount_options_multi_volfile_servers:

==================================================
配置GlusterFS客户端挂载指定多个volfile-servers
==================================================

在GlusterFS的客户端挂载服务器输出的卷时，可以指定多个卷文件服务器(客户端将从卷文件服务器获取挂载卷的配置信息)。早期的GlusterFS提供了配置 ``/etc/fstab`` 类似如下:

.. literalinclude:: centos/deploy_centos7_gluster11/gluster_fuse_fstab
   :caption: GlusterFS客户端的 ``/etc/fstab``

此时只有主、备 **两个** 卷文件服务器

新版本GlusterFS已经支持更多的 ``volfile-server`` ，甚至可以把所有GlusterFS服务器端IP加入，GlusterFS会在主volfile-server宕机情况下，尝试依次使用 backup-volfile-servers用于挂载卷，直到挂载成功:

.. literalinclude:: gluster_mount_options_multi_volfile_servers/gluster_fuse_fstab
   :caption: 配置更多的 ``backup-volfile-servers`` 提高可用性

.. note::

   早期版本的 ``backupvolfile-server`` 已经被改为 ``backup-volfile-servers`` ，一定要注意，否则不能指定多个后备volfile服务器!!!

参考
=====

- `Red Hat Gluster Storage > 3.4 > Administration Guide > Chapter 6. Creating Access to Volumes #6.1.3.1. Mount Commands and Options <https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.4/html/administration_guide/chap-accessing_data_-_setting_up_clients#Mount_Commands_and_Options>`_
