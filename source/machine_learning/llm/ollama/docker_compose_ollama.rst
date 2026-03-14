.. _docker_compose_ollama:

=============================
Docker compose组合运行Ollama
=============================

在 :ref:`ollama_amd_gpu_docker` 能够很轻松地运行起Ollama，不过需要手工一一去启动不同用途的容器，例如 :ref:`grafana` :ref:`prometheus` 。所以，选择 :ref:`docker_compose` 来调度和启动容器组合，则会方便很多。

Docker compose运行
====================

- 创建 ``docker-compose.yml`` 组合docker容器:

.. literalinclude:: docker_compose_ollama/docker-compose.yml
   :caption: 组合了Ollama+WebUI+Grafana的 ``docker-compose.yml``

- 上述配置中 :ref:`prometheus` 需要引用一个 ``prometheus.yml`` 配置来抓取GPU数据:

.. literalinclude:: docker_compose_ollama/prometheus.yml
   :caption: prometheus配置

- 启动:

.. literalinclude:: docker_compose_ollama/up
   :caption: 启动容器

此时会看到docker并行拉取容器运行的各个镜像，如果没有报错，则最后同时启动Ollama以及Open WebUI和 :ref:`grafana` :ref:`prometheus` 

配置grafana
================

- 访问 http://服务器IP:3001 (默认账号密码均为 admin)，首次登录会提示修改密码

  - 添加数据源: ``Connections -> Data Sources``
  - 选择 ``Prometheus`` ，在URL中填入 ``http://prometheus:9090`` ，然后点击 ``Save & Test``

- 导入面板:

  - 点击右上角 ``+`` 号 -> ``Import`` ，搜索AMD GPU专用的ID(可以从Grafana官方的dashboard分发网站查找)

配合Open WebUI
====================

访问 http://服务器IP:3000 Open WebUI创建的第一个用户帐号是管理员帐号，请为自己设置一个帐号

验证连接
----------

- 点击页面左下角的 ``个人头像/用户名``
- 选择 ``Settings（设置） -> Connections`` ，应该看到有一个 ``Ollama API`` 的配置，指向的是 ``http://ollama-amd:11434`` 也就是前面 ``docker-compose.yml`` 中配置，点击配置按钮，并点刷新，此时验证正常就说明连接成功

加载模型
---------

在 ``Settings -> Models`` 中可以交互方式加载模型(选择 ``Manage`` )，可以直接输入Ollama官网的模型名称进行下载: ``llama3.3:70b-instruct-q4_K_M`` 举例。这个下载支持断点续传，如果下载意外中断，重试会继续进行(不过如果容器被杀死再下载模型还得重头开始)

.. figure:: ../../../_static/machine_learning/llm/ollama/webui_pull_model.png

   下载指定模型，例如 ``llama3.3:70b-instruct-q4_K_M``

异常问题排查
==============

我在运行 ``llama3.3:70b-instruct-q4_K_m`` 模型时发现 AMD MI50 两块GPU完全没有负载，而CPU疯狂运算。gemini提示虽然设置了正确的 ``HSA_OVERRIDE_GFX_VERSION`` ，但是对于70B大模型需要防范几个问题:

- 70B 模型在 Q4 量化下约占 42GB。Ollama 默认可能认为单块 MI50（32GB）装不下，或者因为你没有设置 并行显卡参数，导致它放弃 GPU 直接回退到 CPU

修订 ``docker-compose.yml`` 的环境变量，在 ``ollama-amd`` 的 ``environment`` 中添加以下关键项:

.. literalinclude:: docker_compose_ollama/docker-compose_parallel_amd.yml
   :caption: 设置并行
   :emphasize-lines: 6-8

- 内存锁限（Memlock）配置: 对于 MI50 这种级别的高性能计算卡，容器需要能够锁定内存以进行高效的 DMA 传输。如果 Docker 限制了内存锁定，Ollama 的 ROCm 后端可能会初始化失败

在 ollama-amd 服务下添加 ulimits:

.. literalinclude:: docker_compose_ollama/docker-compose_unlimits.yml
   :caption: 设置不限制内存锁定

- 修改配置以后销毁容器(docker compose提供了down命令):

.. literalinclude:: docker_compose_ollama/down
   :caption: 停止并销毁容器

注意， ``docker compose down`` 会停止并删除当前YAML文件中定义的所有容器、网络。由于模型文件(数据)保存在 ``valumes`` 中，所以不会丢失

- 重新启动:

.. literalinclude:: docker_compose_ollama/up
   :caption: 启动容器

- 检查容器日志:

.. literalinclude:: docker_compose_ollama/log
   :caption: 检查日志查看和GPU相关信息

发现检测GPU失败:

.. literalinclude:: docker_compose_ollama/log_output
   :caption: 检查日志查看和GPU相关信息，发现检测GPU失败
   :emphasize-lines: 6,7

这说明直接设置 ``HIP_VISIBLE_DEVICES:0,1`` 反而导致了Docker 内部，ROCm 有时会因为 PCI ID 的映射问题产生混淆:

- 删除 ``HIP_VISIBLE_DEVICES:0,1``
- 删除 ``ROCR_VISIBLE_DEVICES`` (如果有手动设置)

并添加一个debug参数:

.. literalinclude:: docker_compose_ollama/docker-compose_debug.yml
   :caption: debug
   :emphasize-lines: 20

**神奇啊** 发现居然是 ``privileged: true`` 生效后解决了问题，现在 ``docker logs ollama-amd`` 看到日志似乎正常了:

.. literalinclude:: docker_compose_ollama/log_output_ok
   :caption: 使用了 ``privileged: true`` 之后日志似乎正常了
   :emphasize-lines: 6,7

这说明确实需要 ``privileged: true`` ，那么结合上面所述，配置应该修订为:

.. literalinclude:: docker_compose_ollama/docker-compose_fix.yml
   :caption: 正式修订配置，启用并行

上述修订完成后，再次运行，发现还是无法将模型运行在GPU上

这就需要排查Ollama是如何评估模型加载的: Ollama 有一个“自我保护”机制：如果它计算出 模型权重 + KV Cache（上下文） 超过了可用显存的 90%，它会为了防止 OOM（显存溢出）而直接放弃 GPU，转向 CPU。

70B 模型约 42GB，双卡 64GB。如果你在 WebUI 里的上下文（num_ctx）默认设置得很大（比如默认 32k），KV Cache 会吃掉剩下的所有显存。

解决方法: 强制限制上下文长度

在 Open WebUI 中，不要直接提问。

- 点击模型选择框旁边的 “设置/控制”图标。
- 找到 Advanced Parameters (高级参数)。
- 找到 GPU Layers (num_gpu) ，设置 81 表示将所有层都加入GPU: Llama 3.3-70B (Q4_K_M) 的层数通常是 81 层（80层 Transformer + 1层 Output）
- 找到 Context Length (num_ctx)，手动输入 4096 或 8192。
- 再次尝试提问，观察 rocm-smi。

.. warning::

   问题尚未解决，待继续排查

   目前发现操作系统启动以后，容器启动后系统有大量的  [kworker/22:21+events] 的进程是D状态。怀疑Docker容器没有正确挂载物理服务器设备（/dev/kfd 和 /dev/dri）

参考
======

- `AMD Device Metrics Exporter 1.4.2 > Docker installation <https://instinct.docs.amd.com/projects/device-metrics-exporter/en/latest/installation/docker.html>`_
