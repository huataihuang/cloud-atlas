.. _gvisor_quickstart:

=================
gVisor快速起步
=================

.. note::

   gVisor只支持x86_64并且要求内核版本 4.14.77+

CentOS安装gVisor
==================

.. note::

   详细请参考 :ref:`install_docker_centos8`

- 添加Docker-CE仓库::

   sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

- 安装稳定版本docker-ce::

   sudo dnf install --nobest docker-ce

- 关闭firewalld::

   sudo systemctl disable firewalld

- 启动和激活docker服务::

   sudo systemctl enable --now docker

编译安装goVisor
-----------------

* 安装编译环境::

   sudo dnf install dnf-plugins-core
   sudo dnf copr enable vbatts/bazel
   sudo dnf install bazel gcc gcc-c++ git python3

* 编译::

   bazel build runsc

编译错误处理
~~~~~~~~~~~~~

- python3依赖报错::

   ERROR: An error occurred during the fetch of repository 'pydeps':
      pip_import failed:  (src/main/tools/process-wrapper-legacy.cc:58: "execvp(python3, ...)": No such file or directory
   )
   ERROR: no such package '@pydeps//': pip_import failed:  (src/main/tools/process-wrapper-legacy.cc:58: "execvp(python3, ...)": No such file or directory
   ...

bazel默认需要使用python3，而现在CentOS 8默认没有安装Python2/3，需要单独安装::

   sudo yum install python3

- gVisor编译过程中需要从internet上下载源代码包进行编译，其中访问github下载grpc代码包时候，是不支持断点续传，所以可能会和已经缓存的部分下载内容冲突，则需要删除掉缓存的下载包后重试。

安装gvisor
===========

- 复制编译后执行程序到执行目录::

   sudo cp ./bazel-bin/runsc/linux_amd64_pure_stripped/runsc /usr/local/bin

其他安装方法
=================

.. note::

   `dreampuf/build.sh <https://gist.github.com/dreampuf/6446936e84dc5c965ec947fb4080b032>`_ 提供了一个通过centos 7 docker方式编译gVisor的脚本::

      git clone --depth 1 https://github.com/google/gvisor.git
      cd gvisor
      docker --rm -it "$PWD":/opt/gvisor -w /opt/gvisor centos bash

      curl -O /etc/yum.repos.d/vbatts-bazel-epel-7.repo https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-7/vbatts-bazel-epel-7.repo
      yum install -y epel-release bazel gcc gcc-c++ git protobuf-devel protobuf-lite-devel 
      env CC=/usr/bin/gcc bazel build runsc

- gVisor官方文档提供了在 :ref:`ubuntu_linux` 环境通过软件仓库安装指南。

配置Docker
===========

- 首先需要在Docker配置文件 ``/etc/docker/daemon.json`` (如果该配置文件不存在则创建它)中添加runtime内容::

   {
       "runtimes": {
           "runsc": {
               "path": "/usr/local/bin/runsc"
           }
       }
   }

- 重启docker::

   sudo systemctl restart docker

运行容器
=========

- 通过 ``--runtime=runsc`` 命令运行容器::

   docker run --runtime=runsc --rm hello-world

.. note::

   ``--rm`` 参数会在命令执行结束时删除容器

- 可以运行一个ubuntu系统::

   docker run --runtime=runsc -it ubuntu /bin/bash

验证runtime
=============

- 可以通过 ``dmesg`` 命令验证运行了gVisor::

   docker run --runtime=runsc -it ubuntu dmesg

参考
=======

- `gVisor Documentation / User Guide / Installation <https://gvisor.dev/docs/user_guide/install/>`_
- `How to install Docker CE on RHEL 8 / CentOS 8 <https://linuxconfig.org/how-to-install-docker-in-rhel-8>`_
