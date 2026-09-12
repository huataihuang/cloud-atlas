.. _shadowsocks-rust:

====================
shadowsocks-rust
====================

客户端
=========

Alpine Linux 官方社区仓库（Community Repository）将 ``shadowsocks-rust`` 的客户端打包为 ``shadowsocks-rust-sslocal`` ，替代了已经停止开发的 :ref:`shadowsocks-libev` 。

- 使用方式与以前的 ss-local 极其相似:

.. literalinclude:: shadowsocks-rust/sslocal
   :caption: 客户端连接

参数 ``-u`` 表示同时支持UDP转发(如DNS)
