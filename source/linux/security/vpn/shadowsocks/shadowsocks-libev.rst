.. _shadowsocks-libev:

=============================
shadowsocks-libev
=============================

配合在 :ref:`shadowrocket_ss` 实践时部署的ss服务器，在 :ref:`alpine_linux` 客户端可以部署最轻量且原生支持 ``aes-256-gcm`` 的 ``shadowsocks-libev`` (客户端命令为 ``ss-local`` )

``ss-local`` 使用纯 C 语言编写，内存占用极低（通常不到 2 MB RAM）.

.. warning::

   ``shadowsocks-libev`` 上游原作者已停止维护该项目，Alpine 官方在社区仓库（Community）更新中将其进行了清理和下架。

.. note::

   我改为使用 :ref:`shadowsocks-rust`

