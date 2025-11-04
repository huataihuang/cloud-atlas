.. _distrobox_debian_ssh:

===================================
Disgrobox运行Debian容器中ssh服务
===================================

.. note::

   ``distrobox`` 运行的容器和 Host 主机使用同一个网络堆栈，所以如果Host主机运行了ssh服务占用了22端口，则容器中ssh服务需要配置使用其他端口，否则会因为端口冲突而无法启动容器内ssh服务!!!

我计划构建不同的容器来运行开发环境，其中 :ref:`distrobox_vscode` 作为开发IDE，需要通过 :ref:`vscode_remote_dev_ssh` 访问不同容器环境进行开发。所以，需要在 :ref:`distrobox_debian` 中构建ssh服务。

以下操作在 :ref:`debian` 容器中进行

- 安装 ``openssh-server`` :

.. literalinclude:: ../../linux/debian/debian_ssh/install
   :caption: 在debian中安装 ``oepnssh-server``

修订 ``/etc/ssh/sshd_config`` 使得 ``sshd`` 
监听不同端口以避免和Host主机sshd端口或其他容器sshd端口冲突:

.. literalinclude:: ../../linux/debian/debian_ssh/sshd_config
   :caption: 调整容器中 ``sshd`` 服务端口

- 容器内启动服务使用 ``openrc`` 的 ``service`` 命令:

.. literalinclude:: ../../linux/debian/debian_ssh/service_ssh
   :caption: 容器内启动sshd

- 测试没有问题之后，关闭容器:

.. literalinclude:: distrobox_debian/stop
   :caption: 停止容器

- 将运行容器提交(commit)为一个 ``debian-dev`` 镜像:

.. literalinclude:: distrobox_debian/commit
   :caption: 将运行容器commit为 ``debian-dev`` 镜像

- 移除旧的不带ssh服务的容器 ``debian-dev`` ，然后重启创建容器，这次创建使用了内置 sshd 服务端讲讲 ``debian-dev`` :

.. literalinclude:: distrobox_debian/distrobox_run_ssh
   :caption: ``distrobox`` run 启动容器时运行ssh服务
