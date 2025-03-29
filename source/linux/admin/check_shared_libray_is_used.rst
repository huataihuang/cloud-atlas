.. _check_shared_libray_is_used:

================================
检查共享库是否使用
================================

在生产环境中常有一些遗留系统，由于年代久远，运行的安装目录下堆积了很多不确定是否使用的第三方 ``.so`` 库文件。但是由于迁移操作系统或者修改架构( 例如迁移到 :ref:`arm` )，需要确定这些 ``.so`` 是否也需要同样迁移(或编译对应架构的 ``.so`` 库文件)。

这里有一个简单的方法，就是在现有有业务的服务器上通过 ``lsof`` 来确认这些 ``.so`` 库文件是否被系统进程使用(打开)。原理很简单，就是 :ref:`linux_file_descriptor` 能够确认某个系统文件是否被真实使用

举例，在 :ref:`apache_webdav` 会启用 ``mod_dav`` 和 ``mod_dav_fs`` 模块::

   /usr/lib/apache2/modules/mod_dav_fs.so
   /usr/lib/apache2/modules/mod_dav.so

参考
=======

- `How to see the currently loaded shared objects in Linux? <https://superuser.com/questions/310199/how-to-see-the-currently-loaded-shared-objects-in-linux>`_
