.. _intro_podman:

=====================
podman简介
=====================

`podman.io <https://podman.io/>`_ 是 ``podman`` 官方网站，提供了跨平台但开源容器管理工具，并且围绕podman，形成了类似 :ref:`docker` 生态的各种容器工具:

- ``podman``
- :ref:`buildah` 生成OCI格式的容器镜像
- :ref:`skopeo` 提供远程OCI镜像仓库(registries)

由于 ``podman`` 系列工具已经移植到 :ref:`freebsd` ，所以我现在也在实践 :ref:`run_containers_on_freebsd`

``rootful`` vs. ``rootless`` (模式)
========================================

Podman 的 ``Rootful`` (系统级有根模式) 与 ``Rootless`` (无根模式) 在底层架构、权限模型和硬件支持上有着根本性的区别:

.. csv-table:: Rootful(系统级有根模式)与Rootless(无根模式)对比
   :file: intro_podman/rootful_vs_rootless.csv
   :widths: 20,40,40
   :header-rows: 1

选型建议
----------

- ``Rootful`` 模式: 容器必须与宿主机的内核级硬件驱动深度交互（例如运行 Ollama 并挂载 AMD MI50 的 ``/dev/kfd`` 和 ``/dev/dri/renderD*`` 显卡渲染节点）时，必须使用 Rootful 模式。
- ``Rootless`` 模式: 绝大多数日常微服务（如 Open-WebUI、Grafana、Node-Exporter 等），建议全部留在 Rootless 模式下运行，以最大化系统的安全隔离性。
