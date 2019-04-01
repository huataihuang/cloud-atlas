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

   将新创建的 ``ubuntu18-04`` 容器的 ``/etc/apt/source.list`` 复制到 CUDA 的容器 ``tfstack`` 中，就可以进行安装和升级工作::

      sudo apt update
      sudo apt upgrade
   
   另外，我安装了一些必要的工具包::

      apt install vim screen curl git wget sudo

Linux操作系统准备
===================

- 安装python::

   sudo apt install python3-dev python3-pip

.. note::

   TensorFlow当前的Python 3.x只支持到3.6 ( Python 3.x更快，并且大多数库同时支持Python 2.7和Python 3 ） `Choosing the appropriate version of Python runtime to use along with TensorFlow <https://stackoverflow.com/questions/42862953/choosing-the-appropriate-version-of-python-runtime-to-use-along-with-tensorflow>`_

- 切换到个人目录，然后创建Python virtualenv环境::

   sudo pip3 install virtualenv
   cd ~
   virtualenv venv3
   . venv3/bin/activate

- 安装TensorFlow pip软件包依赖（这里没有使用 ``--user`` 参数是因为我是在Python virtualenv环境中，如果是全局安装则要使用 ``--user`` 参数）::

   pip install -U pip six numpy wheel setuptools mock
   pip install -U keras_applications==1.0.6 --no-deps
   pip install -U keras_preprocessing==1.0.5 --no-deps

- 安装Bazel

   源代码编译Tensorflow需要采用特定合适版本的bazel，目前我测试编译 Tensorflow 1.9.1 需要使用 bazel 0.21.0 或更低版本，所以不能直接采用APT软件仓库方式安装，需要采用bazel官方安装脚本安装。

.. note::

   参考 `Installing Bazel on Ubuntu <https://docs.bazel.build/versions/master/install-ubuntu.html>`_

   注意：由于TensorFlow的configure会检测Bazel的版本，当前要求bazel是0.21.0否则提示错误::

      Extracting Bazel installation...
      WARNING: --batch mode is deprecated. Please instead explicitly shut down your Bazel server using the command "bazel shutdown".
      You have bazel 0.24.0 installed.
      Please downgrade your bazel installation to version 0.21.0 or lower to build TensorFlow!

   参考 `Choosing the right Bazel version to build TF is confusing #24101 <https://github.com/tensorflow/tensorflow/issues/24101>`_ 降低bazel版本，但是参考 `How do you downgrade bazel <https://groups.google.com/forum/?nomobile=true#!topic/bazel-discuss/bM-8u4F6RKQ>`_ 通过apt-get安装只能安装最新版本，所以还是参考 `Installing Bazel on Ubuntu <https://docs.bazel.build/versions/master/install-ubuntu.html>`_ 采用手工二进制安装方法::

      sudo apt remove bazel
      # 从 https://github.com/bazelbuild/bazel/releases 下载对应release安装
      wget https://github.com/bazelbuild/bazel/releases/download/0.21.0/bazel-0.21.0-installer-linux-x86_64.sh
      chmod +x bazel-0.21.0-installer-linux-x86_64.sh
      ./bazel-0.21.0-installer-linux-x86_64.sh --user

   ``--user`` 参数安装Bazel在系统的 ``$HOME/bin`` 目录并设置 ``.bazelrc`` 路径到 ``$HOME/.bazelrc`` ，所以需要在 ``~/.bashrc`` 中添加 ``export PATH="$PATH:$HOME/bin"`` 
     
安装GPU支持
===============

macOS不支持GPU，只在Linux平台需要执行 `GPU 支持 <https://www.tensorflow.org/install/gpu>`_ 的安装步骤。

- 安装GPU驱动

如果要避免麻烦，可以直接使用 `具有GPU支持功能的TensorFlow Docker镜像 <https://www.tensorflow.org/install/gpu>`_ 。如果要安装GPU支持，则只需要安装 `NVIDIA GPU驱动 <https://www.nvidia.com/drivers>`_ 。

.. note::

   容器驱动请参考 `Driver containers(Beta) <https://github.com/NVIDIA/nvidia-docker/wiki/Driver-containers-(Beta)>`_ 

- 安装CUDA软件包::

   sudo apt install nvidia-cuda-{dev,doc,gdb,toolkit} 

.. note::

   我的时间是采用了 NVIDIA CUDA docker 镜像 :ref:`nvidia-docker` ，所以这步忽略，已经具备了在docker容器内部使用GPU设备的能力。

- 安装 `NVIDIA cuDNN <https://developer.nvidia.com/cudnn>`_ ::

   sudo dpkg -i libcudnn7_7.5.0.56-1+cuda10.0_amd64.deb libcudnn7-dev_7.5.0.56-1+cuda10.0_amd64.deb 

.. note::

   如果从源代码编译Tensorflow，支持NVIDIA需要使用NVIDIA cuDNN。请参考 `How can I install CuDNN on Ubuntu 16.04? <https://askubuntu.com/questions/767269/how-can-i-install-cudnn-on-ubuntu-16-04>`_

下载TensorFlow源代码
=======================

- 使用git获取 `TensorFlow 仓库 <https://github.com/tensorflow/tensorflow>`_ ::

   git clone https://github.com/tensorflow/tensorflow.git
   cd tensorflow

默认仓库获取的是 ``master`` 开发分支，可以取出 `release 分支 <https://github.com/tensorflow/tensorflow/releases>`_ 来编译::

   git clone https://github.com/tensorflow/tensorflow.git
   cd tensorflow
   git checkout rr1.13

或者::

   wget https://github.com/tensorflow/tensorflow/archive/v1.13.1.tar.gz
   tar xfz v1.13.1.tar.gz
   cd tensorflow-1.13.1

配置configure
===============

通过运行以下脚本通过交互方式设置编译参数::

   ./configure

- ``./configure`` 配置::

   Please specify the location of python. [Default is /home/huatai/venv3/bin/python]:

   Traceback (most recent call last):
     File "<string>", line 1, in <module>
   AttributeError: module 'site' has no attribute 'getsitepackages'
   Found possible Python library paths:
     /home/huatai/venv3/lib/python3.6/site-packages
   Please input the desired Python library path to use.  Default is [/home/huatai/venv3/lib/python3.6/site-packages]
   
   Do you wish to build TensorFlow with XLA JIT support? [Y/n]:
   XLA JIT support will be enabled for TensorFlow.
   
   Do you wish to build TensorFlow with OpenCL SYCL support? [y/N]:
   No OpenCL SYCL support will be enabled for TensorFlow.
   
   Do you wish to build TensorFlow with ROCm support? [y/N]:
   No ROCm support will be enabled for TensorFlow.
   
   Do you wish to build TensorFlow with CUDA support? [y/N]: Y
   CUDA support will be enabled for TensorFlow.
   
   Please specify the CUDA SDK version you want to use. [Leave empty to default to CUDA 10.0]:
   
   Please specify the location where CUDA 10.0 toolkit is installed. Refer to README.md for more details. [Default is /usr/local/cuda]:
   
   Please specify the cuDNN version you want to use. [Leave empty to default to cuDNN 7]:
   
   Please specify the location where cuDNN 7 library is installed. Refer to README.md for more details. [Default is /usr/local/cuda]: /usr/lib/x86_64-linux-gnu
   
.. note::

   这里遇到到问题是Tensorflow在CUDA 10.0的目录下找不到CuDNN 7的库文件。请参考 `TensorFlow cannot find cuDNN [Ubuntu 16.04 + CUDA7.5] <https://devtalk.nvidia.com/default/topic/936212/tensorflow-cannot-find-cudnn-ubuntu-16-04-cuda7-5-/>`_ 安装CUDA开发工具以及从官方下载安装cuDDN软件库。不过，需要注意安装的目录是 ``/usr/lib/x86_64-linux-gnu/`` 。

::

   Do you wish to build TensorFlow with TensorRT support? [y/N]:
   No TensorRT support will be enabled for TensorFlow.

   Please specify the locally installed NCCL version you want to use. [Default is to use https://github.com/nvidia/nccl]:

   Please specify a list of comma-separated Cuda compute capabilities you want to build with.
   You can find the compute capability of your device at: https://developer.nvidia.com/cuda-gpus.
   Please note that each additional compute capability significantly increases your build time and binary size. [Default is: 3.5,7.0]: 3.0

.. note::

   我的显卡GeForce 750M 只支持CUDA 3.0

::

   Do you want to use clang as CUDA compiler? [y/N]:
   nvcc will be used as CUDA compiler.

   Please specify which gcc should be used by nvcc as the host compiler. [Default is /usr/bin/gcc]:

   Do you wish to build TensorFlow with MPI support? [y/N]:
   No MPI support will be enabled for TensorFlow.

   Please specify optimization flags to use during compilation when bazel option "--config=opt" is specified [Default is -march=native -Wno-sign-compare]:

   Would you like to interactively configure ./WORKSPACE for Android builds? [y/N]:
   Not configuring the WORKSPACE for Android builds.
   
   Preconfigured Bazel build configs. You can use any of the below by adding "--config=<>" to your build command. See .bazelrc for more details.
           --config=mkl            # Build with MKL support.
           --config=monolithic     # Config for mostly static monolithic build.
           --config=gdr            # Build with GDR support.
           --config=verbs          # Build with libverbs support.
           --config=ngraph         # Build with Intel nGraph support.
           --config=dynamic_kernels        # (Experimental) Build kernels into separate shared objects.
   Preconfigured Bazel build configs to DISABLE default on features:
           --config=noaws          # Disable AWS S3 filesystem support.
           --config=nogcp          # Disable GCP support.
           --config=nohdfs         # Disable HDFS support.
           --config=noignite       # Disable Apacha Ignite support.
           --config=nokafka        # Disable Apache Kafka support.
           --config=nonccl         # Disable NVIDIA NCCL support.
   Configuration finished

Bazel build
===============

- CPU-only::

   bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package

- GPU support::

   bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package

.. note::

   报错处理：

   - 找不到python::

      ERROR: /home/huatai/.cache/bazel/_bazel_huatai/ae02d937542a5be4e761c5ab20415f3c/external/protobuf_archive/BUILD:259:1: C++ compilation of rule '@protobuf_archive//:protoc_lib' failed (Exit 127)
      /usr/bin/env: 'python': No such file or directory

   参考 `Tensorflow does not build in a python3 only environment #15618 <https://github.com/tensorflow/tensorflow/issues/15618>`_ 这个问题和bazel的bug有关，因为Bazel在每个文件的第一行都加入了 ``/usr/bin/env python`` ，但是在很多发行版中，默认是python2链接到python，而python3不能软链接到python（为了兼容一些系统级工具），这就导致了bazel在这里无法找到python对应的Python版本。

   注意：在 ``nvidia/cuda`` 这个docker镜像中并没有安装python2，而只安装了python3（我独立安装的python3)，所以在系统中执行 ``/usr/bin/evn python`` 是没有正确相应的。

   我的临时解决方法也比较简单，就是手工创建一个软链接到 python3 上::

      sudo ln -s /usr/bin/python3 /usr/bin/python
