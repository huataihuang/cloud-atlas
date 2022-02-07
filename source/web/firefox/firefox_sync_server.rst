.. _firefox_sync_server:

=================
Firefox同步服务器
=================

Firefox作为开放源码的浏览器，也提供了服务器端数据同步的开源软件 - Sync Server。可以自己在 :ref:`alpine_linux` ( :ref:`edge_cloud` ) 上构建自己的浏览器服务器，实现完整的数据闭环。

Firefox Sync Server不仅开源，而且提供了相关部署、开发的资料。可以从 `Mozilla Services Documentation <https://moz-services-docs.readthedocs.io/en/latest/>`_ 学习如何部署和开发基于Python的同步服务，是一个很好的开源项目样板。

.. note::

   `crazy-max/docker-firefox-syncserver <https://github.com/crazy-max/docker-firefox-syncserver>`_ 提供一个基于 Alpine Linux的运行镜像。

参考
=====

- `Run your own Sync-1.5 Server <https://moz-services-docs.readthedocs.io/en/latest/howtos/run-sync-1.5.html>`_
