.. _alpine_cfssl:

============================
Alpine Linux环境安装cfssl
============================

在部署 :ref:`k3s_ha_etcd` 之前，需要先准备用于签发 :ref:`etcd_tls` 工具 ``cfssl`` 。虽然可以用其他发行版提供的 ``cfssl`` ，不过，我还是决定在部署 :ref:`k3s` 的 :ref:`alpine_linux` 环境中完整实现Kuberntes，所以先使用 :ref:`dockerfile` 构建 ``x-dev`` 容器，再安装 ``cfssl`` 工具。

- Alpine Linux的 community 仓库提供了 ``cfssl`` ，但是需要使用 ``test`` 分支


