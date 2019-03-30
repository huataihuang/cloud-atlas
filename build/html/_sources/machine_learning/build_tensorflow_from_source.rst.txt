.. _build_tensorflow_from_source:

============================
源代码编译安装TensorFlow
============================

TensorFlow发行版对CUDA要求
===========================


在 :ref:`nvidia-docker` 测试中，我使用的MacBook Pro 2015 later显卡是Nvidia GeForce GT 750M，虽然也 `支持CUDA <https://developer.nvidia.com/cuda-gpus>`_ ，但是只能支持CUDA 3.0。而当前最新版本的TensorFlow二进制发行版至少需要CUDA 3.5。

在 :ref:`nvidia-docker` 运行时报错::

   2019-03-26 08:55:33.614949: I tensorflow/core/platform/cpu_feature_guard.cc:141] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
   2019-03-26 08:55:33.671916: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:998] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
   2019-03-26 08:55:33.672915: I tensorflow/compiler/xla/service/platform_util.cc:194] StreamExecutor cuda device (0) is of insufficient compute capability: 3.5 required, device is 3.0
   2019-03-26 08:55:33.673001: F tensorflow/stream_executor/lib/statusor.cc:34] Attempting to fetch value instead of handling error Internal: no supported devices found for platform CUDA

以上报错解决方法:

- 参考 `Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX AVX2 <https://stackoverflow.com/questions/47068709/your-cpu-supports-instructions-that-this-tensorflow-binary-was-not-compiled-to-u>`_ ，TensorFlow的执行代码默认是不使用CPU扩展，例如SSE4.1,SSE4.2, AVX, AVX2, FMA,等等，以便能够在尽可能多的处理器上运行。如果你使用GPU的话，则可以直接忽略这个错误 ，即设置环境变量 ``export TF_CPP_MIN_LOG_LEVEL=2`` 然后再运行。但是，如果你没有GPU或者想使用CPU，则需要参考 `How to compile Tensorflow with SSE4.2 and AVX instructions? <https://stackoverflow.com/questions/41293077/how-to-compile-tensorflow-with-sse4-2-and-avx-instructions>`_ 和 `How to compile tensorflow using SSE4.1, SSE4.2, and AVX <https://github.com/tensorflow/tensorflow/issues/8037>`_ 自己编译TensorFlow。此外，自己编译TensorFlow可以充分利用CPU扩展执行，使得CPU运行的TensorFlow更快。
- NUMA报错实际上是因为Host主机上没有安装 ``numactl`` 工具导致的，通过 ``sudo apt install numactl`` 安装解决。
- CUDA设备检测为 3.0版本，而安装的最新TensorFlow需要CUDA 3.5版本设备支持。这个问题参考 `Cuda 3.0? #25 <https://github.com/tensorflow/tensorflow/issues/25>`_ ，原因也是因为GPU版本过低，需要自己编译安装TensorFlow

.. note::

   NVIDIA的GPU支持的CUDA版本请参考 `CUDA GPUs <https://developer.nvidia.com/cuda-gpus>`_ ，例如，我使用的MacBook Pro 2015 later 显卡是 GeForce GT 750M，只支持CUDA 3.0。我将采用自己 `编译TensorFlow <https://www.tensorflow.org/install/source>`_ 来解决这个问题。

Docker准备
==============

参考 :ref:`nvidia-docker` 在MacBook Pro上安装好 ``docker-ce`` 以及 ``nvidia-docker2`` ，然后创建一个支持GPU的容器::

   docker volume create data
   docker run -it -d --memory=4096M --cpus=2 --hostname tfstack --name tfstack \
      -v data:/data --runtime=nvidia nvidia/cuda /bin/bash

这里有一个提示信息报错需要修复::

   WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.

.. note::

   NVIDIA提供的Docker镜像 ``nvidia/cuda`` 是基于 ``Ubuntu 18.04.1 LTS`` 版本实现的。通过 ``cat /etc/os-release`` 可以看到。不过，这个镜像中删除了一些配置文件导致直接apt安装失败，需要通过标准镜像来参考恢复::

      docker run -it -d --hostname ubuntu18-04 --name ubuntu18-04 -v data:/data ubuntu:latest /bin/bash

   将新创建的 ``ubuntu18-04`` 容器的 ``/etc/apt/source.list`` 复制到 CUDA 的容器 ``tfstack`` 中，就可以进行安装和升级工作。另外，我安装了一些必要的工具包::

      sudo apt install vim screen curl git

Linux操作系统准备
===================

- 安装python::

   sudo apt install python3-dev python3-pip

.. note::

   TensorFlow当前的Python 3.x只支持到3.6 ( Python 3.x更快，并且大多数库同时支持Python 2.7和Python 3 ）`Choosing the appropriate version of Python runtime to use along with TensorFlow <https://stackoverflow.com/questions/42862953/choosing-the-appropriate-version-of-python-runtime-to-use-along-with-tensorflow>`_

- 安装TensorFlow pip软件包依赖（如果在Python虚拟环境，忽略 ``--user`` 参数）::

   pip install -U --user pip six numpy wheel setuptools mock
   pip install -U --user keras_applications==1.0.6 --no-deps
   pip install -U --user keras_preprocessing==1.0.5 --no-deps

.. note::

   这里我采用了个人用户 ``huatai`` 的 ``$HOME`` 下建立Python虚拟环境来工作::

      sudo pip install virtualenv
      su - huatai
      cd ~
      virtualenv venv3
      . venv3/bin/activate

   然后在执行上述安装TensorFlow pip软件包安装::

      pip install -U pip six numpy wheel setuptools mock
      pip install -U keras_applications==1.0.6 --no-deps
      pip install -U keras_preprocessing==1.0.5 --no-deps

- 安装Bazel::

   sudo apt-get install openjdk-8-jdk
   echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
   curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -

   sudo apt-get update && sudo apt-get install bazel

   # 升级Bazel方法:
   sudo apt-get install --only-upgrade bazel

.. note::

   参考 `Installing Bazel on Ubuntu <https://docs.bazel.build/versions/master/install-ubuntu.html#ubuntu>`_

安装GPU支持
===============

macOS不支持GPU，只在Linux平台需要执行 `GPU 支持 <https://www.tensorflow.org/install/gpu>`_ 的安装步骤。

- 安装GPU驱动

如果要避免麻烦，可以直接使用 `具有GPU支持功能的TensorFlow Docker镜像 <https://www.tensorflow.org/install/gpu>`_ 。如果要安装GPU支持，则只需要安装 `NVIDIA GPU驱动 <https://www.nvidia.com/drivers>`_ 。

- 安装CUDA软件包

.. note::

   我的时间是采用了 NVIDIA CUDA docker 镜像 :ref:`nvidia-docker` ，所以这步忽略，已经具备了在docker容器内部使用GPU设备的能力。

下载TensorFlow源代码
=======================

- 使用git获取 `TensorFlow 仓库 <https://github.com/tensorflow/tensorflow>`_ ::

   git clone https://github.com/tensorflow/tensorflow.git
   cd tensorflow

默认仓库获取的是 ``master`` 开发分支，可以取出 `release 分支 <https://github.com/tensorflow/tensorflow/releases>`_ 来编译::

   git checkout v1.13.1

配置编译
==============

参考
========

- `Build from source <https://www.tensorflow.org/install/source>`_


