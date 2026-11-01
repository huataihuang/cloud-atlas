.. _podman_compose_ollama_nvidia_a2:

==========================================
Podman compose组合运行Ollama(NVIDIA A2)
==========================================

之前在 :ref:`ollama_nvidia_a2_gpu_docker` 通过多个Docker容器运行来实现 :ref:`tesla_a2` 支持Ollama以及对应的 :ref:`ollama_webui` 以及 :ref:`grafana` / :ref:`prometheus` 组合。

现在我再参考 :ref:`docker_compose_ollama` 的部署来重新通过 :ref:`podman` 优化上述组合，以便能够使用统一的一条命令运行容器组合，并维护容器。

准备工作
=============

- 物理主机已经完成 :ref:`ubuntu_podman`

- 物理主机已经完成 :ref:`nvidia_container_toolkit`

Podman compose
=================

- 创建目录结构(用于存储镜像、模型数据等)

.. literalinclude:: podman_compose_ollama_nvidia_a2/tree
   :caption: 目录结构

.. literalinclude:: podman_compose_ollama_nvidia_a2/mkdir
   :caption: 创建目录

- 在 ``~/podman/`` 目录下创建 ``docker-compose.yml`` :

.. literalinclude:: podman_compose_ollama_nvidia_a2/docker-compose.yml
   :language: yaml
   :caption: 带有 NVIDIA GPU 支持的 ``docker-compose.yml``
   :emphasize-lines: 22-28

说明:

  - ``deploy.resources.reservations.devices`` 将GPU导入容器
  - 采用了特权提权 ``cap_add``

.. warning::

   :ref:`podman` 因为安全原因，默认不允许使用没有带注册表前缀的"端名称"(Short Name)，例如将 ``docker.io/ollama/ollama:latest`` 缩写成 ``ollama/ollama`` ，此时会出现报错:

   .. literalinclude:: podman_compose_ollama_nvidia_a2/short_name_error
      :caption: 必须使用完整路径下载，不能使用Short Name

- 在 ``~/podman/prometheus_data/`` 目录下创建 ``prometheus.yml`` :

.. literalinclude:: podman_compose_ollama_nvidia_a2/create_prometheus_yml
   :language: bash
   :caption: 创建 ``~/podman/prometheus_data/prometheus.yml``

.. note::

   墙内别忘记 :ref:`podman_proxy`

- 启动容器:

.. literalinclude:: podman_compose_ollama_nvidia_a2/up
   :caption: 启动容器

使用
=======

- WEB访问: http://192.168.1.5:3000/
- 监控:

  - Prometheus: http://192.168.1.5:9090/
  - Grafana: http://192.168.1.5:3001

翻墙和运行依赖
===============

我在首次执行 ``podman compose up -d`` 时候，考虑到Docker Hub实际上已经被墙，所以必须设置一个 :ref:`podman_proxy` 才能实现镜像顺利下载。确实，也正是因为 :ref:`across_the_great_wall` ，整个过程行云流水非常顺利。

完成首次运行时，我发现在 :ref:`grafana` 中添加 ``prometheus`` 容器作为数据源(通过Docker compose的内部短名解析)，会提示通过代理 ``127.0.0.1:1080`` 访问失败。也就是说，podman默认向容器内部注入Host主机的代理配置，间接影响了容器间网络通讯。

那么，我去掉了Host主机上的代理环境变量，重新运行 ``podman compose up -d`` 是不是就解决了呢？

然而去掉代理配置后，我发现 ``open-webui`` 始终没有启动成功，通过 ``podman logs -f open-webui`` 观察发现，原来程序启动运行时会首先访问 huggingface 下载依赖，当失去代理后，整个启动过程就卡住了:

.. literalinclude:: podman_compose_ollama_nvidia_a2/open-webui_start_error
   :caption: open-webui启动失败

这个报错的原因是：**Open-WebUI 内置了 RAG（检索增强生成）知识库检索功能** 。当它启动时，默认会尝试加载一个用于文本向量化（Embedding）的小模型 ``sentence-transformers/all-MiniLM-L6-v2`` 。由于这个模型默认托管在 Hugging Face 上，在没有使用代理环境下无法从HuggingFace下载。

gemini建议在Ollama中拉取一个轻量 Embedding 模型:

- Ollama托管的轻量级 Embedding 模型 ``nomic-embed-text`` 不仅完全不需要连接 Hugging Face，而且对中文和代码检索的支持比老旧的 ``all-MiniLM-L6-v2`` 强大得多
- ``sentence-transformers/all-MiniLM-L6-v2`` 是一个纯粹的 Hugging Face Transformers 模型（基于 PyTorch），而 Ollama 主要针对的是生成式大模型（如 Llama、Qwen 等）。虽然可以通过工具将其转为 GGUF 格式再导入 Ollama，但这会带来额外的繁琐操作。
- Open-WebUI 已经原生支持 Ollama 作为 Embedding 引擎: Open-WebUI 默认会去 Hugging Face 下载这个模型是因为它默认启用了内置的 Python 库（Sentence-Transformers）来做向量化。但如果不连接外网，只需使用 Ollama 官方现成的向量模型。

- 在 Ollama 中拉取一个轻量 Embedding 模型 ``nomic-embed-text`` :

.. literalinclude:: podman_compose_ollama_nvidia_a2/ollama_run_embed
   :caption: 加载nomic-embed-text

完成后通过 ``podman exec -it ollama ollama list`` 检查确认列表中有 ``nomic-embed-text``

- 修订 ``docker-compose.yml`` ，配置 ``open-webui`` 环境变量，指定通过ollama来访问RAG:

.. literalinclude:: podman_compose_ollama_nvidia_a2/rag.yml
   :caption: 修订 ``docker-compose.yml`` 指定open-webui使用Ollama的RAG
   :emphasize-lines: 12-14

加载模型
============

- 在 Ollama 中拉取 qwen3-coder:30b (编码开发)

.. literalinclude:: podman_compose_ollama_nvidia_a2/run_qwen3-coder
   :caption: ``qwen3-coder:30b``

终端运行 ``podman exec -it ollama ollama list`` ，确保列表中 ``qwen3-coder:30b``

- ``nomic-embed-text`` (向量嵌入模型)

  - 用来将 PDF、Markdown 和代码切片转换成向量，是知识库检索（RAG）必不可少的基础模型

Grafana配置
=============

- DCGM Exporter Dashboard(面板ID ``12239`` ): 自动识别出 3 张 Tesla A2，提供多卡独立的 GPU 利用率、显存占用率（VRAM）、温度、功耗（Power Usage）以及 PCIe 传输速率，界面类似于服务器版的 nvidia-smi 历史图表。
- Node Exporter Full(面板ID ``1860`` ): 监控 Linux 主机系统健康状况最权威、图表最全面的面板

参考
=======

- gemini
