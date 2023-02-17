.. _joplin_sync_webdav:

==========================
通过WebDAV同步Joplin数据
==========================

准备工作
============

采用 :ref:`macos_nginx_webdav_joplin` :

- 对于 :ref:`macos` 平台，需要 :ref:`build_nginx_macos`
- 完成 :ref:`nginx_webdav` 配置

.. note::

   需要 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_ 模块的NGINX才能支持完整的WebDAV功能，所以请参考 :ref:`macos_nginx_webdav_joplin` 解决方案

同步
=======

.. note::

   我最初以为Joplin的数据同步采用覆盖模式，所以一直纠结我的几个已经安装了Joplin的电脑和手机(已经各自积累了不少数据)是否会相互覆盖导致数据丢失。所以我对每个设备都先实施了数据导出。

   不过实践证明，Joplin的数据同步采用了类似 :ref:`git` 的Merge功能，也就是只要不冲突，尽可能保证所有数据存储同步，非常完美。
