.. _huggingface-cli:

========================
huggingface-cli
========================

`Hugging Face <https://huggingface.co/>`_ 提供了 ``huggingface-cli`` 工具用于下载Model，不仅可以下载原始权重，也可以下载各种量化版本。

我在 :ref:`docker_compose_ollama` 遇到一个问题: 由于 :ref:`amd_mi50` 硬件架构比较陈旧，需要使用早期版本的 :ref:`ollama` 容器镜像，这导致后端 :ref:`llama.cpp` 无法兼容目前主流的 :ref:`llama` 3.3官方提供的GUFF格式，所以需要自己下载原始HuggingFace(HF)格式文件，使用旧版 :ref:`llama.cpp` 工具链来转换成兼容GUFF格式。

准备工作
===============

- 首先要在下载模型的页面，例如 `meta-llama/Llama-3.3-70B-Instruct <https://huggingface.co/meta-llama/Llama-3.3-70B-Instruct/tree/main>`_ 同意其License

- 然后在 `Hugging Face的Settings -> Access Tokens <https://huggingface.co/settings/tokens>`_ 创建一个Access Token，注意这个token可以选择 ``Read`` 或 ``Write`` 类型，也可以完全控制设置权限

安装
========

- 我使用 :ref:`virtualenv` 来构建一个Python环境:

.. literalinclude:: huggingface-cli/virtualenv
   :caption: 构建一个Hugging Face的virtualenv

- 安装工具并登录

.. literalinclude:: huggingface-cli/install
   :caption: 安装工具

.. warning::

   Hugging Face在国内已经被GFW屏蔽，所以你必须 :ref:`across_the_great_wall` ，执行以下命令采用 :ref:`ssh_tunneling_dynamic_port_forwarding` 构建起一个socks代理:

   .. literalinclude:: ../../infra_service/ssh/ssh_tunneling_dynamic_port_forwarding/ssh_tunnel_dynamic
      :caption: 用一条命令构建一个socks代理

   由于 ``hf`` 底层是基于Python的 ``requests`` 和 ``urllib3`` 库开发，所以可以直接读取系统的 **标准环境变量** 来使用SOCKS5代理(需要先安装 ``httpx[socks]`` ):

   .. literalinclude:: huggingface-cli/httpxsocks
      :caption: 设置hf使用代理

.. literalinclude:: huggingface-cli/auth
   :caption: 登录Hugging Face

使用
=======

- 下载模型:

.. literalinclude:: huggingface-cli/download_qwen3.5
   :caption: 下载Qwen3.5-35B-A3B

.. literalinclude:: huggingface-cli/download_llama-3.3
   :caption: 下载Llama-3.3-70B

镜像网站
============

虽然通过socks代理能够 :ref:`across_the_great_wall` 从Hugging Face下载模型，但是对于身在大陆，实际上下载速度还是乏善可陈，太浪费精力了。国内的 `HF-Mirror <https://hf-mirror.com/>`_ 提供了Hugging Face镜像，而且无需登录就可以使用 ``hf`` 工具直接下载，速度飞快。

唯一的区别就就是在执行 ``hf`` 下载命令之前先设置环境变量 ``HF_ENDPOINT`` :

.. literalinclude:: huggingface-cli/hf_endpoint
   :caption: 使用HF-Mirror镜像网站
