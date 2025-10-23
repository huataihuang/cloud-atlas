.. _kobo_koreader:

=========================
Kobo安装和使用koreader
=========================

`koreader.rocks <https://koreader.rocks>`_ 提供了 `koreader releases <https://github.com/koreader/koreader/releases>`_ 适配不同设备，其中包括Kobo

安装
======

- 首先完成 :ref:`nickelmenu` 安装

- 修改Kobo设备 ``.kobo/Kobo/Kobo eReader.conf`` (针对较新的firmware 4.17+) ，在最后添加

.. literalinclude:: kobo_koreader/Kobo_eReader.conf
   :caption: ``.kobo/Kobo/Kobo eReader.conf`` 最后部分添加

- 重新连接Kobo阅读器，将前面下载的 ``koreader`` zip包解压缩以后的 ``koreader`` 复制到 ``.adds`` 目录下

- 创建一个新文件 ``.adds/nm/koreader`` ，内容是 ``menu_item:main:KOReader:cmd_spawn:quiet:exec /mnt/onboard/.adds/koreader/koreader.sh``

- 安全弹出Kobo设备，然后就会在菜单看到 ``KOReader``

参考
======

- `简体中文版的 KOReader用户指南 <https://koreader.rocks/user_guide/zh_Hans.html>`_
- `reddit帖子: 帮忙安装 Koreader？ <https://www.reddit.com/r/kobo/comments/1gksgdr/help_installing_koreader/?tl=zh-hans>`_ 提供了有效的信息: `Alternative Manual Installation Method based on NickelMenu <https://github.com/koreader/koreader/wiki/Installation-on-Kobo-devices#alternative-manual-installation-method-based-on-nickelmenu>`_
- `Kobo Libra 2 + KOReader 装机与使用 <https://blog.loikein.one/posts/2023-05-20-kobo-libra-2-koreader/>`_
- **请不要使用** 中文版 `Kobo的KOReader安装教程 <https://github.com/koreader/koreader/wiki/%E5%A6%82%E4%BD%95%E5%9C%A8Kobo%E4%B8%8A%E5%AE%89%E8%A3%85KOReader>`_ ，中文版已经严重过时，我当时没有了解到这个问题，按照中文版进行导致安装失败，不得已恢复出厂设置重新开始
