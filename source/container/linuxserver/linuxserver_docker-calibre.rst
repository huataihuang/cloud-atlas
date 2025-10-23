.. _linuxserver_docker-calibre:

===============================
linuxserver/colibre
===============================

``linuxserver/colibre`` 提供了易于部署的 ``Calibre`` 系统，容器化运行

我之前实践过 :ref:`alpine_install_calibre` ，并自己定制Docker镜像运行 ``calibre-server`` 。不过，LinuxServer.io 提供了标准化的镜像构建，其实用 :ref:`s6-overlay` 管理服务，可能更为易用。我准备后续在有时间精力情况下，再尝试实践。

此外， :ref:`linuxserver_docker-calibre-web` 提供了现代化界面的WEB浏览Calibre，也需要实践

参考
======

- `GitHub: linuxserver/docker-calibre <https://github.com/linuxserver/docker-calibre>`_
