.. _install_ollama:

======================
安装Ollama(Linux平台)
======================

快速安装
===========

- 官方提供了安装脚本:

.. literalinclude:: install_ollama/install_sh
   :caption: 通过官方安装脚本在本地安装

手工安装
===========

手工安装其实也非常简单，因为Ollama是一个 :ref:`golang` 程序，所以直接下载二进制软件包，解压缩后复制到执行目录就可以使用了:

.. literalinclude:: install_ollama/install_manual
   :caption: 手工本地安装

AMD GPU安装
-------------

AMD GPU的版本需要独立下载安装:

.. literalinclude:: install_ollama/install_manual_amd
   :caption: 手工本地安装AMD GPU版本

ARM64安装
-----------

ARM版本安装

.. literalinclude:: install_ollama/install_manual_arm
   :caption: 手工本地安装ARM版本

配置Ollama服务(建议)
=======================

- 添加一个Ollama用户和组:

.. literalinclude:: install_ollama/add_ollama_account
   :caption: 添加一个Ollama用户和组

- 创建服务配置 ``/etc/systemd/system/ollama.service`` :

.. literalinclude:: install_ollama/ollama.service
   :caption: 添加ollama服务

- 设置服务:

.. literalinclude:: install_ollama/start_ollama.service
   :caption: 启动ollama服务

安装CUDA驱动(可选)
========================

:ref:`install_nvidia_linux_driver` 可以使用GPU作为硬件加速推理，如果使用 :ref:`debian` / :ref:`ubuntu_linux` / :ref:`redhat_linux` 可以使用NVIDIA官方仓库进行在线安装。例如 :ref:`gpu_passthrough_in_qemu_install_nvidia_cuda`

安装AMD ROCm驱动(可选)
============================

待实践

启动Ollama
==============

- 启动服务:

.. literalinclude:: install_ollama/ollama.service_start
   :caption: 启动服务

配置Ollama模型文件存储位置
============================

默认 ``Ollama`` 将模型文件自动下载存储到用户目录下的 ``~/.ollama/models`` ，但是往往用户目录不一定足够空间。此时，可以设置用户的环境变量 ``OLLAMA_MODELS`` 来指定位置:

.. literalinclude:: install_ollama/bashrc
   :caption: ``~/.bashrc`` 配置环境变量 ``OLLAMA_MODELS``

刚开始时候，我没有考虑清楚 :ref:`systemd_env` 设置，所以导致 ``Ollama`` 在下载大模型文件还是存放到了默认的 ``/usr/share/ollama/.ollama`` 目录下，我的主机 ``/`` 目录空间不足，所以我还将这个目录移动到 ``/huggingface.co/`` 下建立软链接:

.. literalinclude:: install_ollama/ollama_link
   :caption: 建立下载目录软链接

注意，上述方法是命令行直接运行时的设置，对于启动时候使用 :ref:`systemd` 来运行服务，则需要在 :ref:`systemd_env` 中传递这个环境变量:

.. literalinclude:: ollama_gpu/ollama.service
   :caption: ``/etc/systemd/system/ollama.service`` 设置 ``ollama`` 服务运行环境变量
   :emphasize-lines: 12

参考
========

- `Ollama Linux Install <https://github.com/ollama/ollama/blob/main/docs/linux.md>`_
- `Where Are Ollama Models Stored Mac <https://www.restack.io/p/ollama-models-storage-answer-cat-ai>`_
