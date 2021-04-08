.. _introduce_webdav:

=========================
WebDAV简介
=========================

我是在使用 :ref:`joplin` 时，发现这个开源编辑器能够支持通过 WebDAV 服务进行多设备同步。这个服务也是很多开源网络文档实现共享的基础。

WebDAV也称为 ``Web-Based Discributed Authoring and Vesioning`` 协议，也就是在服务器系统上管理web内容。

WebDAV是IEFT(Internet Engineering Task Force)的规范，可以实现文件传输用于跨平台编辑Office文档。

WebDAV协议
============

WebDAV协议实现了以下命令:

- COPY
- LOCK
- MKCOL
- MOVE
- PROPFIND
- PROPPATCH
- UNLOCK

WebDAV主要功能
===============

- DAV Locking

锁功能避免文档被多个编辑者修改

- Properties

WebDAV树形是一个XML格式的元数据，包含了必要信息，例如资源授权

- Namespace manipulation

DAV支持复制和移动资源

支持WebDAV的著名服务器
============================

- Apache
- Microsoft IIS
- Nginx
- OwnCloud
- NextCloud

支持WebDAV的客户端
=====================

- Git
- Linux

  - GVfs
  - GNOME files
  - KIO(Konquerer, Dolphin)

- Mac OS 内建支持CalDAV和CardDAV
- Microsoft Windows 和 Office

参考
=======

- `WebDAV.io文档 <https://webdav.io/webdav/>`_
