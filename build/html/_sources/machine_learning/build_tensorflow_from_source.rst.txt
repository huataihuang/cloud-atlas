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

.. warning::

   目前解决的进度：已经成功从源代码编译了TensorFlow，但是运行时依然提示CUDA 3.0硬件设备不能支持CUDA 3.5。从网上文档来看，有采用 CUDA 9.0 编译TensorFlow支持 3.0的，所以我考虑下次采用完全全新的Ubuntu环境，从头开始采用CUDA 9编译。

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

      apt install vim screen curl git wget sudo iproute2

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

   TensorFlow GPU支持只需要安装相应的驱动和库就可以，最简单的方法是使用 `TensorFlow Docker image with GPU support <https://www.tensorflow.org/install/docker>`_ ，这个安装只需要 `NVIDIA GPU drivers <https://www.nvidia.com/drivers>`_

   我的实践是采用了 NVIDIA CUDA docker 镜像 :ref:`nvidia-docker` ，所以这步忽略，已经具备了在docker容器内部使用GPU设备的能力。

- 安装CUDA软件包（这个步骤可选，非必须）::

   sudo apt install nvidia-cuda-{dev,doc,gdb,toolkit} 

- 安装 `NVIDIA cuDNN <https://developer.nvidia.com/cudnn>`_ ::

   sudo dpkg -i libcudnn7_7.5.0.56-1+cuda10.0_amd64.deb libcudnn7-dev_7.5.0.56-1+cuda10.0_amd64.deb 

.. note::

   如果从源代码编译Tensorflow，支持NVIDIA需要使用NVIDIA cuDNN。请参考 `How can I install CuDNN on Ubuntu 16.04? <https://askubuntu.com/questions/767269/how-can-i-install-cudnn-on-ubuntu-16-04>`_

- 检查CUDA版本::

    cat /usr/local/cuda/version.txt

- 检查cuDNN版本::

    cat /usr/local/cuda/include/cudnn.h | grep CUDNN_MAJOR -A 2

.. note::

   检查版本方法灿口 `Compiling TensorFlow-GPU on Ubuntu 16.04 with CUDA 9.1(9.2) and Python3 <https://blog.onemid.net/blog/dl-cuda-and-tf-install/>`_

下载TensorFlow源代码
=======================

- 使用git获取 `TensorFlow 仓库 <https://github.com/tensorflow/tensorflow>`_ ::

   git clone https://github.com/tensorflow/tensorflow.git
   cd tensorflow

默认仓库获取的是 ``master`` 开发分支，可以取出 `release 分支 <https://github.com/tensorflow/tensorflow/releases>`_ 来编译::

   git clone https://github.com/tensorflow/tensorflow.git
   cd tensorflow
   git checkout r1.13

或者::

   wget https://github.com/tensorflow/tensorflow/archive/v1.13.1.tar.gz
   tar xfz v1.13.1.tar.gz
   cd tensorflow-1.13.1

配置configure
===============

通过运行以下脚本通过交互方式设置编译参数::

   TF_UNOFFICIAL_SETTING=1 ./configure

.. note::

   这里参考 `Cuda 3.0? #25 <https://github.com/tensorflow/tensorflow/issues/25>`_ 使用了 ``TF_UNOFFICIAL_SETTING=1`` ，如果没有这个参数，则在配置 ``Cuda compute capabilities you want to build with`` 时即使指定 ``3.0`` 版本，编译得到的TensorFlow也还是 ``3.5`` 版本的。这一步非常关键！！！

   如果没有特殊的CUDA版本要求，则可以不用参数，直接执行::

      ./configure

- ``./configure`` 配置::

   Please specify the location of python. [Default is /home/huatai/venv3/bin/python]:

   Traceback (most recent call last):
     File "<string>", line 1, in <module>
   AttributeError: module 'site' has no attribute 'getsitepackages'
   Found possible Python library paths:
     /home/huatai/venv3/lib/python3.6/site-packages
   Please input the desired Python library path to use.  Default is [/home/huatai/venv3/lib/python3.6/site-packages]

.. note::

   这里遇到的报错 ``AttributeError: module 'site' has no attribute 'getsitepackages'`` 请参考 `problem with installing tensorboard via virtualenv #38 <https://github.com/dmlc/tensorboard/issues/38>`_ 和 `tensorflow学习笔记:运行tensorboard遇到的错误 <https://blog.csdn.net/u010312436/article/details/78648713>`_`

   这个报错是因为在 virtualenv 环境，不能直接使用 ``site.getsitepackages()`` ，不过似乎不影响。 ``third_party/py/python_configure.bzl`` 中如果有 ``PYTHON_LIB_PATH`` 和 ``PYTHON_BIN_PATH`` 环境变量会跳过这段检测。

   参考 `numpy not found during python_api generation #22395 <https://github.com/tensorflow/tensorflow/issues/22395>`_ 如果在bazel执行中遇到无法找到 numpy 则尝试传递环境变量::

      --action_env PYTHONPATH="/home/huatai/venv3/lib/python3.6/site-packages"
   
::

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

   参考 `CUDA Compatibility of NVIDIA Display / GPU Drivers <https://tech.amikelive.com/node-930/cuda-compatibility-of-nvidia-display-gpu-drivers/>`_ 可以看到 CUDA 10.0 的最小计算能力和默认计算能力都是 3.0 ，应该能够满足要求。

   注意：如果要编译CUDA 3.0的TensorFlow，一定要按照前文的方法 ``TF_UNOFFICIAL_SETTING=1 ./configure`` ，否则编译的TensorFlow即使指定CUDA 3.0也没有效果，编译后的版本依然要求CUDA 3.5::

      2019-04-03 08:28:21.549207: I tensorflow/compiler/xla/service/platform_util.cc:194] StreamExecutor cuda device (0) is of insufficient compute capability: 3.5 required, device is 3.0

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

   从源代码编译TensorFlow需要使用大量内存，如果内存有限，需要限制 Bazel 的内存使用，例如使用参数 ``--local_resources 2048,.5,1.0`` 表示只使用2G内存，50%的CPU资源，以及100%的磁盘IO。详细请参考后文的Build 报错处理。

   `官方TensorFlow软件包 <https://www.tensorflow.org/install/pip>`_ 是使用GCC 4并使用较老的ABI编译的。对于使用GCC 5或更新版本，如果要使用较老的ABI确保兼容性，则使用 ``--cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0"`` 编译参数。

Build 报错处理
-----------------

找不到python
~~~~~~~~~~~~~~~~

- `/usr/bin/env: 'python': No such file or directory` ::

   ERROR: /home/huatai/.cache/bazel/_bazel_huatai/ae02d937542a5be4e761c5ab20415f3c/external/protobuf_archive/BUILD:259:1: C++ compilation of rule '@protobuf_archive//:protoc_lib' failed (Exit 127)
      /usr/bin/env: 'python': No such file or directory

参考 `Tensorflow does not build in a python3 only environment #15618 <https://github.com/tensorflow/tensorflow/issues/15618>`_ 这个问题和bazel的bug有关，因为Bazel在每个文件的第一行都加入了 ``/usr/bin/env python`` ，但是在很多发行版中，默认是python2链接到python，而python3不能软链接到python（为了兼容一些系统级工具），这就导致了bazel在这里无法找到python对应的Python版本。

注意：在 ``nvidia/cuda`` 这个docker镜像中并没有安装python2，而只安装了python3（我独立安装的python3)，所以在系统中执行 ``/usr/bin/evn python`` 是没有正确相应的。

我的临时解决方法也比较简单，就是手工创建一个软链接到 python3 上::

   sudo ln -s /usr/bin/python3 /usr/bin/python

编译过程中gcc进程被杀
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- `gcc: internal compiler error: Killed (program cc1plus)`::

   ERROR: /home/huatai/tensorflow/tensorflow/core/kernels/BUILD:762:1: C++ compilation of rule '//tensorflow/core/kernels:broadcast_to_op' failed (Exit 4)
   gcc: internal compiler error: Killed (program cc1plus)

参考 `Building from source, gcc issues #349 <https://github.com/tensorflow/tensorflow/issues/349>`_ ，上述编译过程中导致gcc被杀掉的原因是因为并发导致占用内存过多，所以需要调整 bazel 降低并发job或者限制资源使用。有建议使用 ``--local_resources 2048,0.5,1.0`` 我使用如下参数表示使用大约3/4的内存(12G)以及使用3/4的CPU核心，以及100%的I/O资源::

   bazel build --config=opt --config=cuda --local_resources 12288,0.75,1.0 //tensorflow/tools/pip_package:build_pip_package 

.. note::

   参考 `Is there a way to limit the number of CPU cores Bazel uses? <https://stackoverflow.com/questions/34756370/is-there-a-way-to-limit-the-number-of-cpu-cores-bazel-uses/34766939>`_ 上述限制的参数表示： ``--local_resources availableRAM,availableCPU,availableIO`` :

   This option, which takes three comma-separated floating point arguments, specifies the amount of local resources that Bazel can take into consideration when scheduling build and test activities. Option expects amount of available RAM (in MB), number of CPU cores (with 1.0 representing single full core) and workstation I/O capability (with 1.0 representing average workstation). By default Bazel will estimate amount of RAM and number of CPU cores directly from system configuration and will assume 1.0 I/O resource. 

   最新版本的 `Commands and Options <https://docs.bazel.build/versions/master/user-manual.html>`_ 使用不同参数组合。

Build软件包
=============

``bazel build`` 命令创建名为 ``build_pip_package`` 的可执行程序，这个程序用于构建 ``pip`` 包。请执行以下命令在 ``/tmp/tensolflow_pkg`` 目录下创建一个 ``.whl`` 包。

- 从release分支build::

   ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg

- 从master分支build则需要使用 ``--nightly_flag`` 以获得正确的依赖::

   ./bazel-bin/tensorflow/tools/pip_package/build_pip_package --nightly_flag /tmp/tensorflow_pkg

.. note::

   虽然有可能在相同的源代码中build通知支持CUDA和不支持CUDA的配置，但是依然建议在切换两种不同的配置钱执行一次 ``bazel clean`` 。

安装软件包
==============

现在在软件包目录下有一个带有TensoorFlow版本和平台信息的 ``.whl`` 文件，现在使用 ``pip install`` 命令来安装这个软件包::

   pip install /tmp/tensorflow_pkg/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl

.. note::

   恭喜，现在TensorFlow已经完成安装了。

验证编译的TensorFlow是否能够正常工作，即是否支持CUDA 3.0::

   python -c "import tensorflow as tf; print(tf.contrib.eager.num_gpus())"

Docker Linux builds
=====================

.. note::

   以下内容摘自 `TensorFlow官方安装文档 Build from source - Docker Linux builds <https://www.tensorflow.org/install/source#docker_linux_builds>`_ 。不过，我目前没有实际操作，因为前述Build from source操作已经完成了在 :ref:`nvidia-docker` 构建支持CUDA 3.0的TensorFlow环境，能够满足我个人的实践操作需求，所以本段 ``Docker Linux builds`` 我没有实践。

TensorFlow的Docker开发者镜像提供了从源代码编译Linux包的方便的环境（例如，你想为Debian/Ubuntu或RHEL/CentOS发布TensorFlow安装软件包）。这些镜像已经包含了构建TensorFlow的源代码和编译依赖。请参考TensorFlow `Docker guide <https://www.tensorflow.org/install/docker>`_ 进行操作。Docker镜像请参考docker hub中官方 `tensorflow Office Docker images <https://hub.docker.com/r/tensorflow/tensorflow>`_ 。

CPU-only
-----------

以下案例使用 ``:nightly-devel`` 镜像构建CPU-only Python2软件包。请参考 `Docker guide <https://www.tensorflow.org/install/docker>`_ 的 ``-devel`` 标签的TensorFlow。

下载最新的开发镜像并启动Docker容器::

   docker pull tensorflow/tensorflow:nightly-devel
   docker run -it -w /tensorflow -v $PWD:/mnt -e HOST_PERMS="$(id -u):$(id -g)" \
       tensorflow/tensorflow:nightly-devel bash

   # 在容器中，执行以下命令下载最新源代码:
   git pull

以上 ``docker run`` 命令启动了在 ``/tensorflow`` 目录下的一个shell，该目录就是源代码目录。这个容器挂载了host主机的藏钱目录到容器的 ``/mnt`` 目录，并通过环境变量传递host的用户信息给容器。

类似，要在容器中build一个host副本的Tensorflow，则挂载host的源代码目录到容器的 ``/tensorflow`` 目录::

   docker run -it -w /tensorflow -v /path/to/tensorflow:/tensorflow -v $PWD:/mnt \
       -e HOST_PERMS="$(id -u):$(id -g)" tensorflow/tensorflow:nightly-devel bash

在容器中编译软件::

   ./configure  # answer prompts or use defaults
   bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
   ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /mnt  # create package
   chown $HOST_PERMS /mnt/tensorflow-version-tags.whl

安装和验证软件包::

   pip uninstall tensorflow  # remove current version
   pip install /mnt/tensorflow-version-tags.whl
   cd /tmp  # don't import from source directory
   python -c "import tensorflow as tf; print(tf.__version__)"

此时TensorFlow的pip软件包位于当前目录，执行::

   ./tensorflow-version-tags.whl

GPU support
--------------

Host主机上只需要安装 `NVIDIA driver驱动 <https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver>`_ (Host主机不需要安装NVIDIA CUDA Toolkit) 就可以在Docker容器中编译具有GPU支持的TensorFlow。请参考 `GPU support guide <https://www.tensorflow.org/install/gpu>`_ 以及 `TensorFlow Docker guide <https://www.tensorflow.org/install/docker>`_ 来设置 `nvidia-docker <https://github.com/NVIDIA/nvidia-docker>`_ (Linux only) 。

.. note::

   在容器中编译支持GPU的TensorFlow完整步骤可以参考本文前述的我的实践，以下只是官方文档的概述。

以下是下载TensorFlow ``:nightly-devel-gpu-py3`` 镜像并使用 ``nvidia-docker`` 来运行 GPU-enabled 容器。开发镜像配置使用Python 3 pip 软件包具有GPU支持::

   docker pull tensorflow/tensorflow:nightly-devel-gpu-py3
   docker run --runtime=nvidia -it -w /tensorflow -v $PWD:/mnt -e HOST_PERMS="$(id -u):$(id -g)" \
       tensorflow/tensorflow:nightly-devel-gpu-py3 bash

在容器的虚拟环境中，构建GPU支持的TensorFlow软件包::

   ./configure  # answer prompts or use defaults
   bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
   ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /mnt  # create package
   chown $HOST_PERMS /mnt/tensorflow-version-tags.whl

安装和验证::

   pip uninstall tensorflow  # remove current version

   pip install /mnt/tensorflow-version-tags.whl
   cd /tmp  # don't import from source directory
   python -c "import tensorflow as tf; print(tf.contrib.eager.num_gpus())"

验证TensorFlow的GPU加速
=========================

:ref:`compare_gpu_cpu_in_tensorflow` 中有一个由 `learningtensorflow.com <https://learningtensorflow.com/lesson10/>`_ 提供的 `benchmark.py` 脚本可以用来对比GPU和CPU运算效率。

当然，在使用bencmark脚本测试之前，我们先把花费了我们很多时间精力构建的支持CUDA 3.0的自定义镜像制作出来::

   docker commit tfstack local:tensorflow-cuda3.0

检查镜像::

   docker image

显示新镜像 ``tensorflow-cuda3.0`` 如下::

   REPOSITORY              TAG                  IMAGE ID            CREATED             SIZE
   local                   tensorflow-cuda3.0   47b19eed03e6        About an hour ago   13GB

- 在本地测试目录下创建 ``benchmark.py``::

   import sys
   import numpy as np
   import tensorflow as tf
   from datetime import datetime
   
   device_name = sys.argv[1]  # Choose device from cmd line. Options: gpu or cpu
   shape = (int(sys.argv[2]), int(sys.argv[2]))
   if device_name == "gpu":
       device_name = "/gpu:0"
   else:
       device_name = "/cpu:0"
   
   with tf.device(device_name):
       random_matrix = tf.random_uniform(shape=shape, minval=0, maxval=1)
       dot_operation = tf.matmul(random_matrix, tf.transpose(random_matrix))
       sum_operation = tf.reduce_sum(dot_operation)
   
   startTime = datetime.now()
   with tf.Session(config=tf.ConfigProto(log_device_placement=True)) as session:
           result = session.run(sum_operation)
           print(result)
   
   # It can be hard to see the results on the terminal with lots of output -- add some newlines to improve readability.
   print("\n" * 5)
   print("Shape:", shape, "Device:", device_name)
   print("Time taken:", str(datetime.now() - startTime))

- 创建新容器::

   docker run \
    --runtime=nvidia \
    --rm \
    -ti \
    -v "${PWD}:/app" \
    --user huatai \
    local:tensorflow-cuda3.0 \
    /bin/bash -c "cd /home/huatai; . venv3/bin/activate; \ 
    python /app/benchmark.py cpu 10000"

.. note::

   ``--user`` 参数表示在容器中切换到 ``huatai`` 用户身份；通过 ``/bin/bash -c`` 可以在运行多条命令，这样可以切换Python的virtualenv环境，并执行python脚本。
