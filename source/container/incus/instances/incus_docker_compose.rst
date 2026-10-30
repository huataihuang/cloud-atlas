.. _incus_docker_compose:

============================
Incus和Docker Compose
============================

.. note::

   我暂时还没有实践，本文仅记录待后续实践

Incus 原生并不直接支持解析和运行 ``docker-compose.yml`` 文件(即没有内置类似 ``docker compose`` 的编排命令)。

虽然Incus支持直接拉取和运行 :ref:`incus_remote_images` 的 OCI 镜像(即Docker Hub)，但是对于包含多服务关联、环境变量文件、网络共享的复杂编排，Incus有自己的设计哲学(通过Profiles, Projects以及系统容器来管理)。

变通方式: 在Incus"系统容器"内运行Docker Compose
=================================================

- 创建一个普通的Incus系统容器:

.. literalinclude:: incus_docker_compose/launch
   :caption: 创建Incus容器

- 将GPU挂载到该系统容器:

.. literalinclude:: incus_docker_compose/add_gpu
   :caption: 添加GPU到容器中

- 在该容器内部安装标准 Docker 和 Docker Compose:

  - 因为系统容器拥有完整的 :ref:`systemd` ，所以可以像在物理机上一样，直接在里面跑标准的 :ref:`docker` 引擎。
  - 把 ``docker-compose.yml`` 复制到这个容器里，执行 ``docker compose up -d``

使用 Incus 原生机制替代 Compose 的部分功能
==============================================

Incus 原生命令来管理多个应用:

- **多容器网络互通** : 可以通过 Incus 的自定义网桥（Bridge）让多个 OCI 应用容器处于同一个虚拟子网中，通过容器名直接通信。
- **统一配置模板** : 利用 Incus 的 Profiles（配置文件），把 GPU 挂载、共享内存（shm-size）、环境变量等通用配置打包成一个 Profile，一键套用到多个 OCI 容器上。

参考
======

- gemini


