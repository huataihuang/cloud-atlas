.. _podman_combine_rootful_rootless_mode:

=======================================
Rootful和Rootless模式结合运行Podman
=======================================

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

我的实践
==========

我在 :ref:`podman_compose_ollama_amd_mi50_debug` 发现无法在 ``rootless`` 容器中读写Host主机映射到容器内部的 ``/dev/kfd`` 设备，深切体会到要按需来部署 ``rootless`` 和 ``rootful`` 容器:

- ``rootless`` 模式确实是非常巧妙和更加安全的运行方式，但是不仅容器内部虚拟出的 ``root`` 映射到Host主机上仅仅是一个普通用户

.. note::

   目前我在实验环境中使用了 ``admin`` 账号来运行 ``rootless`` 容器，但是 ``admin`` 账号实际上是特殊的具有 ``sudo`` 提权权限的账号，所以这 **不是一个生产环境的安全部署** 。正确且安全的部署方式应该采用 :ref:`secure_container_env`

- :ref:`podman_rootless_nvidia_container_toolkit`
- :ref:`podman_rootful_mode_dcgm-exporter`
