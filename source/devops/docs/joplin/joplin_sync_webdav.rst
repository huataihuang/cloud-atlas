.. _joplin_sync_webdav:

==========================
通过WebDAV同步Joplin数据
==========================

准备工作
============

采用 :ref:`macos_nginx_webdav_joplin` :

- 对于 :ref:`macos` 平台，需要 :ref:`build_nginx_macos`
- 完成 :ref:`nginx_webdav` 或 :ref:`apache_webdav` 配置

.. note::

   需要 `nginx-dav-ext-module <https://github.com/arut/nginx-dav-ext-module>`_ 模块的NGINX才能支持完整的WebDAV功能，所以请参考 :ref:`macos_nginx_webdav_joplin` 解决方案

本地数据备份
---------------

.. warning::

   通过 :ref:`webdav` 同步其实有一个比较大的风险: 多个设备不一致，相互覆盖。所以在同步之前，务必先把本地数据进行备份。

Joplin的本地用户目录是 ``~/.config/joplin`` ，在同步数据前务必先备份此目录，避免数据丢失

同步
=======

.. note::

   桌面版本Joplin提供了 ``用本地数据覆盖远程数据`` / ``用远程数据覆盖本地数据`` 的两个选项，但是移动端(iOS版本)没有提供这个选择。我遇到过一次同步直接把本地数据抹除了(因为我错误关闭了 ``Fail-safe`` 开关，见下文)。所以还是存在风险的。

   建议在桌面上对本地数据目录经常进行备份。

Joplin提供了一个 ``Fail-safe`` 配置开关，这个 **开关务必开启** : 当Joplin发现远程目录是空的时候，不会自动同步(即反向清除掉本地数据)，避免误操作。

目前同步最可靠的方式是桌面程序，因为Joplin桌面程序提供了双向控制，既可以以本地数据覆盖远程WebDAV服务器上数据，也可以反过来清理掉本地数据重新从服务器下载；而手机客户端(iOS)没有提供这样的选项，只有远程WebDAV服务器是第一次同步时会将本地数据上载到服务器，但是如果有其他客户端误操作服务器删除了服务器端数据，则下次同步会直接按照服务器端同步清理掉本地数据。这导致我损失了一些手机上的记录。
