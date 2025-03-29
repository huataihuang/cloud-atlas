.. _xpra_shadow:

=====================================
shadow模式运行xpra访问macOS/Windows
=====================================

macOS shadow方式访问
=====================

macOS不支持类似 :ref:`xpra_startup` 中Linux作为服务器那样，不能在虚拟X Window桌面上启动xpra的应用，也就是不支持 ``xpra start`` 执行启动服务端应用。

不过， ``xpra`` 支持连接到现有桌面的模式，称为 ``shadow`` : 类似于VNC服务器。也就是macOS的桌面能够通过 ``xpra`` 客户端远程访问。

- 访问macOS( ``192.168.7.2`` )::

   xpra shadow ssh://192.168.7.2/

但是发现macOS上只有一个 ``bin`` 的目录图标在不断跳动无法运行，在Linux客户端上提示信息::

   AT-SPI: Could not obtain desktop path or name
   ...
   atk-bridge: get_device_events_reply: unknown signature
   ..
   atk-bridge: GetRegisteredEvents returned message with unknown signature
   ...
   Error: failed to receive anything, not an xpra server?
   ...
   Connection lost

显然，服务器端的 xpra 启动失败

.. note::

   目前在我使用的最新版本macOS上， ``xpra`` 启动会crash，暂时无法验证


参考
======

- `Xpra Shadow-Server.md <https://github.com/Xpra-org/xpra/blob/master/docs/Usage/Shadow-Server.md>`_
