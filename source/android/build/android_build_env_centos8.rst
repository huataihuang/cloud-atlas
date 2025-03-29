.. _android_build_env_centos8:

==============================
构建Android编译环境(CentOS 8)
==============================

.. note::

   我最初想通过CentOS 8来作为构建Android开发编译环境，不过参考LineageOS的官方文档，社区主要采用Ubuntu，所以我近期实践采用 :ref:`android_build_env_ubuntu`

准备工作
=========

我采用Android的编译环境是在 :ref:`docker` 部署，通过 :ref:`dockerfile` 创建一个CentOS 8纯净环境，然后从初始环境安装必要的编译工具链来构建Android编译环境。

- 在本地创建一个 ``studio`` 目录，进入这个目录，然后
  - 如果你只是编译android系统，则存放以下名为 ``android-build`` 的Dockerfile
  - 如果你想开发android系统，则存放以下名为 ``android-studio`` 的Dockerfile

.. literalinclude:: android_build_env_centos8/android-build
   :language: dockerfile
   :caption: ``android-build``

.. literalinclude:: android_build_env_centos8/android-studio
   :language: dockerfile
   :caption: ``android-studio``

- 下载android开发工具包：

   https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip

   https://dl.google.com/android/studio/plugins/android-gradle/preview/offline-android-gradle-plugin-preview.zip
   https://dl.google.com/android/studio/maven-google-com/stable/offline-gmaven-stable.zip

   https://dl.google.com/android/studio/ide-zips/4.0.0.16/android-studio-ide-193.6514223-linux.tar.gz

- 构建android编译环境镜像，执行以下命令::

   docker build -f android-builder -t local:android-builder

- 启动容器::

   docker volume create data
   docker run -itd --hostname android-builder --name android-builder -v data:/data local:android-builder

- CentOS 8需要安装的编译环境软件包 - 参考 :ref:`init_centos`

