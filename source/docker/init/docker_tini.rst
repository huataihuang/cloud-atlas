.. _docker_tini:

======================
Docker tini进程管理器
======================

Tini
=====

`tini 容器init <https://github.com/krallin/tini>`_ 是一个最小化的 ``init`` 系统，运行在容器内部，用于启动一个子进程，并等待进程退出时清理僵尸和执行信号转发。 这是一个替代庞大复杂的systemd体系的解决方案，已经集成到Docker 1.13中，并包含在Docker CE的所有版本。

Tini的优点:

- tini可以避免应用程序生成僵尸进程
- tini可以处理Docker进程中运行的程序的信号，例如，通过Tini， ``SIGTERM`` 可以终止进程，不需要你明确安装一个信号处理器

我们为什么要使用Tini，可以参考 `What is advantage of Tini? <https://github.com/krallin/tini/issues/8>`_ 后续我再整理一下

使用Tini
===========

要激活Tini，在 ``docker run`` 命令中传递 ``--init`` 参数就可以。

在Docker中，只需要加载Tini并传递运行的程序和参数给Tini就可以::

   # Add Tini
   ENV TINI_VERSION v0.19.0
   ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
   RUN chmod +x /tini
   ENTRYPOINT ["/tini", "--"]

   # Run your program under Tini
   CMD ["/your/program", "-and", "-its", "arguments"]
   # or docker run your-image /your/program ...

上述Dockerfile中，通过 ``ENTRYPOINT`` 启动 ``tini`` 作为进程管理器，然后再通过 ``tini`` 运行 ``CMD`` 指定的程序命令。

.. note::

   `tini release download <https://github.com/krallin/tini/releases>`_ 提供了不同处理器架构的

如果要使用tini签名，请参考 `tini 容器init <https://github.com/krallin/tini>`_ 发行文档

构建基于Tini的ssh容器
=======================

- 创建一个 Dockerfile 如下

.. literalinclude:: docker_tini/Dockerfile.ssh_exit_0
   :language: dockerfile
   :linenos:
   :caption:

- 构建镜像::

   docker build -t local:ssh - < Dockerfile.ssh_exit_0

- 运行容器::

   docker run -itd --hostname myssh --name myssh local:ssh

但是，此时检查 ``docker ps`` 却看不到 ``myssh`` 这个容器。这是为什么呢？

- 执行检查::

   docker ps --all

可以看到原来容器结束了，并且退出返回值是 ``0`` ，这意味着执行成功::

   CONTAINER ID   IMAGE               COMMAND                  CREATED         STATUS                     PORTS     NAMES
   21fb4926ac47   local:ssh           "/tini -- /usr/sbin/…"   4 minutes ago   Exited (0) 4 minutes ago             myssh

WHY?

原因是docker只检测前台程序是否结束，对于 ``sshd`` 这样的后台服务，运行以后返回终端，则docker认为顺利结束了，就停止了容器。解决的方法，一般是运行一个前台程序，例如服务不放到后台运行，或者索性再执行一个 ``bash`` ，甚至我们可以编译一个 ``pause`` 执行程序(通过c的pause实现) 避免前台程序结束

- 尝试添加 ``bash`` 作为结尾::

   CMD ["/usr/sbin/sshd && /bin/bash"]

但是很不幸，执行以后退出返回码是错误的 127 

我参考了一下之前的 :ref:`docker_ssh` 方法修订成::

   CMD ["bash -c '/usr/sbin/sshd && /bin/bash'"]

依然错误，比较难处理 ``' '`` ，所以还是改写成脚本来执行比较方便

- 创建一个 ``entrypoint.sh`` 脚本

.. literalinclude:: docker_tini/entrypoint_ssh_bash
   :language: dockerfile
   :linenos:
   :caption:

- 修订 Dockerfile 如下，将这个脚本复制到镜像内部并作为entrypoint

.. literalinclude:: docker_tini/Dockerfile.ssh_bash
   :language: bash
   :linenos:
   :caption:

- 现在我们重新构建镜像::

   docker rm myssh
   docker rmi local:ssh
   docker build -t local:ssh - < Dockerfile.ssh_bash
   
   docker run -itd --hostname myssh --name myssh local:ssh

现在就可以可以正常运行ssh了。

不过，你会觉得，这样有什么优势呢？我们不能直接执行shell脚本么

原因是 ``tini`` 提供了很好到进程管理功能，能够转发信号给管理的子进程，这样就方便在 :ref:`kubernetes` 中调度管理。

需要注意的是，如果在 ``entrypoint`` 最后调用了 ``bash`` ，则通过 ``docker attach <contianer>`` 访问终端时，和 ``docke run ... /bin/bash`` 一样，绝对不能执行 ``ctrl-d`` 退出，否则会直接结束容器。

上面我也提到了，如果不使用 ``bash`` 结束，我们也可以编译一个 ``pause`` 程序，请参考 `Void (Linux) distribution <https://voidlinux.org>`_ (一个完全独立的发行版)提供的工具集 `void-runit <https://github.com/void-linux/void-runit>`_ 中的 `pauese.c <https://github.com/void-linux/void-runit/blob/master/pause.c>`_

构建Tini的多服务容器
========================

使用Tini作为容器进程管理器的要点:

- 使用脚本包装需要启动的服务进程
- 程序要关闭 ``daemon`` 模式，然后使用 ``&`` 符号放到后台运行，这样进程管理 Tini 能够感知进程是否正常运行(或死亡)
- 当任何一个进程退出(SIGLILL,SIGTERM等)，Tini会感知到进程退出
- Tini会搜集子进程的退出状态并执行进程表中必要的清理，避免被杀死的进程进入zombie僵尸
- 容器的默认配置是Tini在任何子进程终止时自动退出，由于Tini是PID 1，这会导致整个容器停止

以下是 :ref:`distrobox_alpine` 的 Dockerfile，其中包含Tini包装脚本 ``/entrypoint.sh`` 案例:

.. literalinclude:: ../../container/distrobox/distrobox_alpine/Dockerfile
   :caption: 同时运行crond和ssh的容器(也可以启动更多程序，如nginx)
   :emphasize-lines: 13-53

构建Tini的多服务容器(旧方法，归档)
====================================

上面我们已经实现了一个在tini下启动sshd的方法，那么我们现在来构建多个服务

- 构建一个多服务启动的脚本，这里我们启动案例是 ``ssh`` 和 ``cron``

.. literalinclude:: docker_tini/entrypoint_ssh_cron_bash
   :language: bash
   :caption: entrypoint_ssh_cron_bash 脚本

.. warning::

   这里的 ``entrypoint_ssh_cron_bash`` 脚本实际上有一个缺陷，只能在Docker中正常工作，应用到Kubernetes上会出现pod不断Crash。原因在 :ref:`kind_deploy_fedora-dev-tini` 有详细分析以及对应的改进

- 修订 Dockerfile 如下，将这个脚本复制到镜像内部并作为entrypoint

.. literalinclude:: docker_tini/Dockerfile.ssh_cron_bash
   :language: bash
   :caption: 将 entrypoint_ssh_cron_bash 脚本复制到容器内部作为 tini 调用的 /entrypoint.sh 脚本来启动多个服务

