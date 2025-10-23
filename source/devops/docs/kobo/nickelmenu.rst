.. _nickelmenu:

=================
NickelMenu
=================

``NickelMenu`` 提供了在Kobo电子阅读器软件添加一个灵活的菜单，能够调用Kobo的很多系统功能，并且可以结合其他插件一起使用。

安装
=======

- 从官网下载 `KoboRoot.tgz <https://github.com/pgaskin/NickelMenu/releases/download/v0.5.4/KoboRoot.tgz>`_
- 将下载的 ``KoboRoot.tgz`` 存放到Kobo设备的 ``KOBOeReader/.kobo`` 目录，拔出数据同步线后等待设备重启
- 重启以后，在页面菜单右下角添加了一个 ``NickelMenu`` 入口
- 重新连接Kobo设备，然后在设备中创建一个 ``KOBOeReader/.adds/nm/config`` 文件，参考 `KOBOeReader/.adds/nm/doc <https://github.com/pgaskin/NickelMenu/blob/v0.5.4/res/doc>`_ 来配置

.. note::

   `Kobo Libra H2O 使用体验和设置指南 <https://sspai.com/post/78528#!#>`_ 提供了一个 ``config`` 配置案例

   .. literalinclude:: nickelmenu/config
      :caption: 配置NickelMenu

   其中配置中 ``导出全部注释`` 需要配合 `Exporting annotations, bookmarks and reading progress to the cloud <https://www.mobileread.com/forums/showthread.php?t=349637>`_ 。下载的zip包解压缩以后是一个 ``notes`` 目录，将整个目录复制到 ``KOBOeReader/.adds`` 就可以使用。默认导出位置是 ``KOBOeReader/Exported Annotations`` 文件夹。该工具支持到处所有化纤注释，并且导出格式为 ``Markdown`` 。

   截图功能开启后，电源键转为截图键。该功能关闭以后，电源键恢复。

   Wi-Fi 传输需要通过电脑浏览器访问 https://send.djazz.se/

参考
======

- `NickelMenu官网 <https://pgaskin.net/NickelMenu/>`_
