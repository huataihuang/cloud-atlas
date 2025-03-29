.. _vlc_play_bluray:

=====================
VLC播放蓝光
=====================

`VLC media player <https://www.videolan.org/vlc/>`_ 是最主流的开源媒体播放器。事实上，大多数媒体播放器都是VLC media player的再包装，增加了一些开源依法不能内置的解码库和密钥。

对于VLC上播放Blu-ray光盘或Blu-ray ISO文件、文件夹，默认智能播放非DRM保护的蓝光内容(自制的Blu-ray光盘)。对于商业Blu-ray电影，也就是市场上购买的大多数蓝光光盘都受AACS(高级访问内容系统)，BD+还有CINAVIA的保护。这样，要再VLC上播放蓝光，需要一些解码库和密钥数据库。

``密钥数据库`` 和 ``AACS动态库``
====================================

`vlc-bluray.whoknowsmy.name <https://vlc-bluray.whoknowsmy.name/>`_ (好牛啤的名字)提供了在VLC 3.0上播放加密蓝光的 ``密钥数据库`` (keys database) 和 ``AACS动态库`` (AACS dynamic library)来解决这个播放问题:

- 从 `FindVUK Online Database <http://fvonline-db.bplaced.net/>`_ 下载最新密钥数据库: 

这个网站提供了最新keydb，不过为何有多种语言下载链接呢? 网站解释如下:

  - 从技术上讲，这没有任何区别——解码所需的所有信息在所有语言中都是相同的！
  - FindVUK 上传光盘上提供的所有语言的标题，因此可以创建特殊的 keydb 文件，其中“标题”使用特殊语言。
  - 如果一种语言至少有 100 个条目，则会为该语言创建一个单独的文件如果可用，文件中所有其他条目的标题都是英文，或者在最坏的情况下是可用语言中的随机标题。

我无脑下载了 `English版本FindVUK库 <http://fvonline-db.bplaced.net/export/keydb_eng.zip>`_

解压缩文件 ``keydb.cfg`` 后存放到对应目录:

  - Windows: C:\ProgramData\aacs\
  - Mac OS X: ``~/Library/Preferences/aacs/`` (如果目录不存在则创建)
  - Linux: ``~/.config/aacs/``
  - Linux SNAP: ``~/snap/vlc/current/.config/aacs/``

- 下载 ``AACS dynamic library`` 存放到对应目录:

  - VLC 32 bit on Windows: 下载 `32位libaacs.dll <https://vlc-bluray.whoknowsmy.name/files/win32/libaacs.dll>`_ 存放到VLC目录
  - VLC 64 bit on Windows: 下载 `64位libaacs.dll <https://vlc-bluray.whoknowsmy.name/files/win64/libaacs.dll>`_ 存放到VLC目录
  - Mac OS X: 下载 `libaacs.dylib <https://vlc-bluray.whoknowsmy.name/files/mac/libaacs.dylib>`_ 存放到 ``/usr/local/lib/`` 目录
  - Linux: 安装发行版提供了 ``libaacs`` 软件包

.. note::

   ``AACS dynamic library`` 针对Windows和Mac OS X的包从2018年之后没有更新，不知道Linux发行版如何

接下来就可以使用VLC播放蓝光

参考
=====

- `如何在VLC Media Player上播放蓝光而不会出现蓝光错误（2023更新） <https://zh-cn.echoshare.co/how-to-play-blu-ray-on-vlc/>`_
- `如何在Windows和Mac上使用VLC播放蓝光电影 <https://www.videosolo.com/zh-CN/tutorials/play-blu-ray-with-vlc.html>`_
- `如何在Windows和Mac上使用VLC蓝光播放器播放蓝光电影 <https://www.bluraycopys.com/zh-CN/resource/play-blu-ray-with-vlc.html>`_
