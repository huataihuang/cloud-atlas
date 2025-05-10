.. _docker_run:

=======================
在Docker容器中运行命令
=======================

在 :ref:`install_docker_linux` 后，就可以运行Docker客户端连接Docker Daemon来下载镜像和运行命令。

.. note::

   Docker是一种全新的运行模式，它并不建议安装运行一个完整的Linux操作系统，而是采用最小化模式，在每个容器中只运行一个目标应用，例如WEB服务器。所有和运行程序无关的程序和库都不会包含，以使得容器精简，缩小容器安全攻击面。

   不过，这种全新的运行模式也带来了运维的难点，或者说需要改变运维工具的视角。如果你想深入理解Docker的镜像制作，请参考 :ref:`moby` 。

虽然你也可以使用docker来运行一个完整Linux操作系统，甚至 :ref:`docker_ssh` 构建一个传统的Linux服务器，但是，用Docker来快速运行一个应用，才是Docker的精粹。

Hello world
============

在我们还没有用 :ref:`moby` 打造自己的运行应用之前，我们先来使用一个传奇的Linux命令 ``busybox`` (你甚至可以在 :ref:`android_busybox` 体验)，包含了诸多功能的单一命令行工具::

   docker run busybox echo "Hello world"

第一次运行上述命令，你会看到docker检测到本地没有busybox镜像，从Docker Hub下载最新的busybox，然后运行输出显示 ``Hello world`` 。就好像我们本地操作系统执行 ``echo "Hello world"`` 命令一样。

Docker运行node服务器
======================

现在我们来运行 node.js 的程序，一个简单显示服务器端主机名和访问客户端IP地址的示例 ``app.js`` 内容如下:

.. literalinclude:: docker_run_example/app.js
   :language: JavaScript
   :linenos:
   :caption:

然后在目录下再编辑一个 ``Dockerfile`` :

.. literalinclude:: docker_run_example/Dockerfile
   :language: Dockerfile
   :linenos:
   :caption:

上述Dockerfile的 ``FROM`` 指定了使用 node 镜像的 tag 7 版本，并复制 ``app.js`` 到镜像的根目录，并在最后 ``ENTRYPOINT`` 行指定镜像运行时执行的命令。

- 执行以下命令构建一个名为 ``kubia`` 的镜像::

   docker build -t kubia .

构建完成后，镜像存储在本地。注意：Dockerfile中每行指令都会构建一个镜像层。镜像构建是把文件上传到Docker Daemon服务器上构建的。所以如果docker client连接的是远程docker daemon，则需要消耗上传网络带宽。Dockerfile是构建镜像的标准方法，因为这种方法是可以重复的，不需要手工在容器内部执行修改命令然后存储生成新镜像。

- 执行以下命令运行镜像::

   docker run --name kubia-container -p 8080:8080 -d kubia

上述命令 ``-d`` 参数表示容器和命令行分离( ``detach``  )，也就是放到后台运行。端口映射参数是 ``-p 8080:8080`` ，这样就可以通过 http://localhost:8080 访问该应用。

.. note::

   如果程序无法正常运行，则可以把 ``-d`` 参数去除，通过直接观察终端输出日志来确定异常原因。

如果程序正常运行，则 ``docker ps`` 可以显示出容器的ID，镜像等信息::

   CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                    NAMES
   e8ad086e80b6        kubia               "node app.js"       2 minutes ago       Up 1 second         0.0.0.0:8080->8080/tcp   kubia-container

更为详细的信息，可以通过 ``docker inspect <CONTAINER ID>`` 查看。

此外，如果仅仅列出 ``CONTAINER ID`` ，则建议使用命令::

   docker ps -qa

则仅输出容器ID::

   e8ad086e80b6

容器内部
----------

基于Node.js的镜像包含了bash shell，所以可以使用以下命令在容器内部运行shell::

   docker exec -it kubia-container bash

参数:

- ``-i`` 表示标准输入输出交互
- ``-t`` 表示分配一个伪终端(TTY)

停止、删除容器
----------------

- 停止容器::

   docker stop kubia-container

- 删除容器::

   docker rm kubia-container

.. note::

   删除容器所使用的镜像是使用 ``docker rmi <IMAGE ID>``

向镜像仓库推送镜像
===================

为了能够在任何主机上使用镜像，需要把镜像推送到镜像仓库。比较简单的方法是使用公开的 `Docker Hub <http://hub.docker.com>`_ 镜像中心，另外一种比较复杂但是适合企业内部使用的方法是部署私有镜像仓库，例如 :ref:`k8s_deploy_registry` 。我建议你先尝试Docker Hub作为学习，后续转为自建镜像仓库进行大规模数据中心部署。

举例，我的Docker Hub注册是 ``huataihuang`` ，操纵如下

- 首先以自己的ID来重命名镜像::

   docker tag kubia huataihuang/kubia

这里并不是重新命名标签，而是给同一个镜像创建一个而外的标桥，此时使用 ``docker images`` 检查可以看到如下2个镜像标签::

   REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
   huataihuang/kubia        latest              faddfa7a8919        2 hours ago         660MB
   kubia                    latest              faddfa7a8919        2 hours ago         660MB

- 登陆Docker Hub::

   docker login

- 向Docker Hub推送镜像::

   docker push huataihuang/kubia

- 现在，在任何主机上都可以使用如下命令来下载自己的镜像并运行容器::

   docker run -p 8080:8080 -d huataihuang/kubia

构建自己的开发环境
===================

我使用的主要服务器环境是CentOS，如果每次手工去创建一个工作环境是非常麻烦的，比较好的方式是 :ref:`dockerfile`  ，可以快速构建开发环境。

参考
======

- `docker docs: docker run <https://docs.docker.com/engine/reference/commandline/run/>`_
- 「Kubernetes in Action」
