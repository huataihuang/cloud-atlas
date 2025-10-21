.. _run_multiple_processes_in_a_container:

=======================================
在单一容器中运行多个进程
=======================================

之前我 :ref:`ubuntu_tini_image` 等实践中，都采用了 ``tini`` 来作为初始化进程管理器，通过脚本来启动多个进程。不过，这种方式需要自己手写启动脚本，相应带来了维护成本。

按照Docker官方文档 `Run multiple processes in a container <https://docs.docker.com/engine/containers/multi-service_container/>`_ ，确实可以通过脚本包装方式来启动多个进程(先启动的进程通过 ``&`` 放到后台)，但是脚本包装不如进程管理器，所以需要选择一个轻量级的进程管理器。按照官方文档，推荐的是 ``supervisor`` ，所以我现在改进维护，使用 ``supervisor`` 来替代早先选择的 ``tini`` ，带来如下优势:

- ``supervisor`` 是一个相对规范的启动管理器，通过配置文件来管理多个进程
- 无需编写脚本
- 提供了稳定的进程管理功能，包括自动重启服务，管理继承祖以及使用 ``supervisorctl`` 进行交互管理

如果不需要 ``supervisor`` 提供的全面的多进程管理，而遵循容器设计的单进程架构，多进程的调度完全采用 ``Docker Compose`` 或 :ref:`kubernetes` ，那么就不需要使用 ``supervisor`` ，采用 ``tini`` 来解决进程管理更为轻量级且推荐。

.. _supervisor:

``supervisor``
==================

``supervisor`` 是一个 client/server 系统，用于监控一系列进程，有点类似 ``launchd`` , ``daemontools`` 和 ``runit`` 。不过， ``supervisor`` 并不是仅仅作为 ``process id 1`` 启动的 ``init`` ，而是用于控制和一个项目或用户相关的进程，这意味着 ``supervisor`` 实际上可以在启动时类似其他程序一样启动(来管理一组进程)。

在Docker容器中，需要安装 ``supervisor`` 并复制配置文件到进行中，这样一旦启动了 ``supervisord`` 服务，就能够管理一组程序进程。

.. note::

   我发现在 :ref:`alpine_linux` 中安装 ``supervisor`` 需要依赖安装 **25个** 软件包，让我实在有点震撼。为了能够更轻量级，我后续在 :ref:`alpine_docker_image` 将继续使用 ``tini`` 。

   仅在 :ref:`ubuntu_linux` 等重量级容器中尝试实践 ``supervisor`` ，仅作为技术积累备用

- 修订 :ref:`debian_tini_image` 的 Dockerfile ，将tini替换成 ``supervisor``

.. literalinclude:: run_multiple_processes_in_a_container/Dockerfile
   :caption: 在镜像中加入 ``supervisor``

- 配套提供 ``supervisord.conf`` :

.. literalinclude:: run_multiple_processes_in_a_container/supervisord.conf
   :caption: 配置 ``supervisord.conf`` 同时启动nginx和sshd

- 创建镜像:

.. literalinclude:: run_multiple_processes_in_a_container/build_debian-ssh-supervisor_image
   :caption: 创建镜像

- 运行容器

.. literalinclude:: run_multiple_processes_in_a_container/run_debian-ssh-supervisor_container
   :caption: 运行容器(注意这里将Lima从Host主机映射的目录再绑定到容器内部，这样就能够从容器访问Host主机目录)


参考
=======

- `Run multiple processes in a container <https://docs.docker.com/engine/containers/multi-service_container/>`_
- `Supervisor: A Process Control System <https://supervisord.org/>`_ ``supervisor`` 官方文档
