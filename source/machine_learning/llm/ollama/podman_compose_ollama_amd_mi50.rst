.. _podman_compose_ollama_amd_mi50:

=============================================
Podman compose组合运行Ollama(AMD MI50 GPU)
=============================================

本文实践在 :ref:`docker_compose_ollama` 基础上改进:

- 尝试采用 :ref:`ubuntu_linux` 26.04 LTS运行 **失败** ， :strike:`并尽量采用AMD最新驱动和ROCm` 由于 :ref:`amd_mi50` 核心太老，官方只提供针对Ubuntu 24.04版本驱动，我常是使用发行版默认 amdgpu 驱动，但是Ollama容器似乎无法驱动GPU
- 吸取 :ref:`docker_compose_ollama` Ollama官方镜像默认不支持gfx906( :ref:`amd_mi50` )，改为社区维护的 `xxdoman/ollama-mi50 <https://hub.docker.com/r/xxdoman/ollama-mi50>`_

.. warning::

   本文实践没有成功，AMD的显卡驱动向后兼容性不佳，我无法在最新的 :ref:`ubuntu_linux` 26.04上顺利安装ROCm对应的 ``amdgpu`` 驱动，使用社区 ``amdgpu`` 似乎不支持ROCm。

   我准备降级操作系统，再次针对我的古老的 :ref:`amd_mi50` 重新部署Ollama容器

ollama镜像
===============

- 下载 ``ollama/ollama:rocm`` 镜像( 需要设置 :ref:`podman_proxy` )

.. literalinclude:: podman_compose_ollama_amd_mi50/pull_ollama
   :caption: 下载 ``ollama/ollama:rocm`` 镜像

- 检查容器(镜像)中 :ref:`rocm` 版本: 

  - 宿主机 Driver 需要比容器内置的库更新或同代，才能实现兼容
  - ABI（应用二进制接口）大版本没有跨代撕裂: ROCm 同大版本内（如 6.x 系列之间）的 ``/dev/kfd`` 内核 API 保持高度一致。宿主机驱动只要能成功把 ``/dev/kfd`` 和 ``/dev/dri`` 暴露出来，容器内自带的 HIP 运行时（libamdhip64.so）就能直接通过 ioctl 系统调用顺利操作 MI50 显卡

.. literalinclude:: podman_compose_ollama_amd_mi50/version
   :caption: 检查ROCm版本

.. note::

   :ref:`amd_mi50` 是 Vega 20/ ``gfx906``

.. warning::

   既然 ``ollama/ollama:rocm`` 使用的是 AMD ROCm v7.2 系列，参考 `ROCm™ Software 7.2.4 <https://rocm.docs.amd.com/en/docs-7.2.4/>`_ 进行物理主机的AMD驱动安装(注意官方文档 `ROCm™ Software 7.2.4: System requirements (Linux) <https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.2.4/reference/system-requirements.html>`_ 将 ``AMD Instinct MI50`` / ``GCN5.1`` / ``gfx906`` 列为不支持设备。不过，我的这个尝试失败了: ROCm 7.2.4系列的 ``amdgpu`` 驱动是针对 :ref:`ubuntu_linux` 24.04所使用的旧版内核开发的，在Ubuntu 26.04的Kernel 7.0上 ``dkms`` 编译失败。

   所以，我最终放弃安装官方 ``ROCm 7.2.4 amdgpu`` ，改为 :ref:`ubuntu_26.04_install_amdgpu` 实践中直接使用社区发布的 ``amdgpu`` 开源驱动。

Podman compose运行
====================

- 创建目录结构(用于存储镜像、模型数据等)

.. literalinclude:: podman_compose_ollama_nvidia_a2/tree
   :caption: 目录结构

.. literalinclude:: podman_compose_ollama_nvidia_a2/mkdir
   :caption: 创建目录

- :ref:`podman_compose` 和Docker compose兼容，所以也是用 ``docker-compose.yml`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/docker-compose.yml
   :caption: ``docker-compose.yml``

.. note::

   Ollama官方镜像当前已经不支持gfs906( :ref:`amd_mi50` )，这在我之前的实践 :ref:`docker_compose_ollama` 已经反复验证(失败)。

   根据 `xxdoman/ollama-mi50 <https://hub.docker.com/r/xxdoman/ollama-mi50>`_ 说明，采用这个针对MI50定制的镜像

启动以后务必检查 ``podman logs ollama-mi50`` ，输出信息如果显示 ``msg="inference compute" id=cpu library=cpu ...`` 则表明降级回了CPU模式，并没有实际使用GPU。则需要进一步排查...

- 在 ``~/podman/prometheus_data/`` 目录下创建 ``prometheus.yml`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/create_prometheus_yml
   :language: bash
   :caption: 创建 ``~/podman/prometheus_data/prometheus.yml``

.. note::

   墙内别忘记 :ref:`podman_proxy` ，不过需要注意，仅在从docker hub下载镜像是需要代理，正式运行 ``podman compose`` 整个系统时需要关闭代理，否则会引起容器间相互访问以及下载模型的阻塞。

- 启动容器:

.. literalinclude:: podman_compose_ollama_nvidia_a2/up
   :caption: 启动容器

- 参考 :ref:`podman_compose_ollama_nvidia_a2` ，需要首先运行一个支持 **Open-WebUI 内置了 RAG（检索增强生成）知识库检索功能** 的模型:

.. literalinclude:: podman_compose_ollama_amd_mi50/ollama_run_embed
   :caption: 加载nomic-embed-text

检查和确认
-------------

我的实践实际上再次遇到无法检测到GPU的问题，也就是 ``podman logs ollama-mi50`` 日志显示 ``msg="inference compute" id=cpu library=cpu ...``

目前的判断是 官方 ROCm 闭源/DKMS 驱动 对于 :ref:`amd_mi50` 以及 Ollama镜像使用的 ROCm 7.2 还停留在 Ubuntu 24.04 版本内核，我这次实践采用 Ubuntu 26.04，安装 ``amdgpu`` 编译失败，所以很可能无法支持容器运行。看起来AMD的驱动非常挑剔，我需要推倒操作系统降级为 24.04 重新尝试。

加载模型
============

- 按照 :ref:`model_choice` 规划，运行 ``qwen3-coder-next:q4_K_M`` :

.. literalinclude:: podman_compose_ollama_amd_mi50/run_qwen3-coder
   :caption: 运行 `qwen3-coder-next:q4_K_M``

Grafana配置
=============

- AMD GPU 显卡监控(面板ID ``18913`` )

- Node Exporter Full(面板ID ``1860`` )

参考
======

- `ROCm™ Software 7.2.4: Quick start installation guide <https://rocm.docs.amd.com/projects/install-on-linux/en/docs-7.2.4/install/quick-start.html>`_
- gemini
