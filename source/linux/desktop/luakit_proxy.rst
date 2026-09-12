.. _luakit_proxy:

====================
Luakit代理设置
====================

Luakit原生不支持Firefox/Chrome架构的WebExtension插件(例如Proxy SwitchyOmega 3, ZeroOmega)，因为Luakit是一个基于WebKitGTK内核与Lua脚本扩展的极轻量级浏览器，没有提供浏览器扩展API接口。

不过，通过Luakit自带的Lua苦熬站机制，或者配合PAC(Proxy Auto-Configuration)自动代理脚本，在Luakit中能够实现极其轻量、无感的分流与扩展切换。

Luakit命令切换代理
=====================

如果不需要复杂的分流，只在需要时"一键开启/关闭代理"，那么只需要利用Luakit的Lua脚本特性来实现。

- 编辑 ``~/.config/luakit/userconf.lua`` 

.. literalinclude:: luakit_proxy/userconf.lua
   :language: lua
   :caption: 自定义快捷键切换代理

PAC自动分流
=============

PAC是一段JavaScript脚本，可以告诉浏览器哪些域名/IP走 :ref:`shadowsocks` 代理( ``127.0.0.1:1080`` )，哪些直连。Luakit原生支持读取PAC规则。

参考
======

- gemini
