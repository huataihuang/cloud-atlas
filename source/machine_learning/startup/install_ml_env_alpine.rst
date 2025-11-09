.. _install_ml_env_alpine:

==============================================
在Alpine Linux安装机器学习环境
==============================================

.. warning::

   我尚未完成这个安装部署，原因是 Alpine Linux 默认使用 ``musl`` 库会中断 为glibc发行版编译的 TensorFlow wheels。解决方式是需要自己从源代码编译，或者使用预先编译好的 ``musl-compatible wheel`` 

   我准备后续在部署了 :ref:`gitlab` CI/CD 环境后，再尝试自己完成编译发布

   待续...

在 :ref:`alpine_docker_image` 构建 ``alpine-dev`` 镜像，其中部署 :ref:`machine_learning` 工作环境涉及安装 ``scikit-learn`` :

.. literalinclude:: install_ml_env_alpine/venv_install_ml
   :caption: 在python的virtualenv中安装机器学习环境

安装报错处理
=================

Python环境安装scikit-learn报错处理
---------------------------------------

涉及安装 ``scikit-learn`` 报错显示缺少 ``pkgconfig`` :

.. literalinclude:: install_ml_env_alpine/pip_install_scikit-learn_error
   :caption: 在Python virtualenv环境安装 ``scikit-learn`` 报错信息

上述报错是因为操作系统没有安装 ``python3-dev`` 软件包导致的，该软件包在系统级别提供了Python开发头文件，用于编译源代码。所以解决方法是先安装 ``python3-dev`` 软件包(如果系统已经安装了 ``python3`` )，然后再重新在 :ref:`virtualenv` 环境安装 ``scikit-learn`` 。

.. note::

   已修订 :ref:`alpine_docker_image` 构建 ``alpine-dev`` 镜像

Python环境安装tensorflow-cpu提示python版本过高
------------------------------------------------

我最初执行 ``pip install tensorflow-cpu`` 没有指定版本，我以为会自动安装最新版本，其实不是，没有指定版本则会安装版本 ``1.9.1`` ，这时会提示报错:

.. literalinclude::  install_ml_env_alpine/pip_install_tensorflow-cpu_error
   :caption: 安装 ``tensorflow-cpu`` 提示python版本过高

实际上 `tensorflow-cpu <https://pypi.org/project/tensorflow-cpu/>`_ 最新版本 ``2.20.0`` 是支持Python3系列到 python 3.13 版本的，但是非常奇怪，即使我指定了版本( ``pip install tensorflow-cpu==2.20.0`` )，依然报相同的错误

.. literalinclude::  install_ml_env_alpine/pip_install_tensorflow-cpu
   :caption: 安装 ``tensorflow-cpu`` 需要指定版本

按照TensorFlow官方文档 `Install TensorFlow 2 <https://www.tensorflow.org/install>`_ ，看起来直接使用  ``pip install tensorflow`` 就是安装CPU版本，如果要安装GPU版本则使用 ``pip install 'tensorflow[and-cuda]'``

如果使用官方文档安装方法:

.. literalinclude:: install_ml_env_alpine/pip_install_tensorflow
   :caption: 安装 ``tensorflow``

但是现在报错显示:

.. literalinclude:: install_ml_env_alpine/pip_install_tensorflow_error
   :caption: 安装 ``tensorflow`` 报错找不到匹配的发行版

原因是 TensorFlow 二进制包 依赖 glibc ，在 :ref:`alpine_linux` 上通常是采用 :ref:`docker` 容器方式运行官方提供的镜像

如果要在Alpine Linux上原生运行TensorFlow，需要从源代码编译。 `The simplest way to make Alpine TensorFlow work like it should <https://hoop.dev/blog/the-simplest-way-to-make-alpine-tensorflow-work-like-it-should/>`_ 提到:

Alpine’s default musl libc often breaks TensorFlow wheels built for glibc-based distros. The fastest fix is to rebuild TensorFlow from source or use a pre-compiled musl-compatible wheel. Either choice yields predictable, repeatable behavior across clusters.


