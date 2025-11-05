.. _distrobox_sshd:

============================
Distrobox环境容器中ssh服务
============================

我在使用 ``distrobox`` 中发现默认的网络环境，容器和Host主机是使用 **同一个网络堆栈** 

容器内部无法启动 ``sshd`` 服务
===============================

在 :ref:`distrobox_alpine` 实践中，我尝试:

.. literalinclude:: distrobox_alpine/create_alpine-dev_init-hooks
   :caption: 配置 ``--init-hooks "sudo rc-service sshd start"`` 尝试容器启动时启动ssh服务
   
结果启动失败，检查 ``podman logs alpine-dev`` 显示ssh服务早已启动，重复执行启动ssh导致报错:

.. literalinclude:: distrobox_alpine/run_alpine-dev_init-hooks_error
   :caption: 由于容器内ssh服务已启动，再执行 ``--init-hooks "sudo rc-service sshd start"`` 报错

但是实际上，我去除掉 ``--init-hooks "sudo rc-service ssh start`` 进入到容器内部检查，发现 ``sshd`` 服务并没有启动

检查 ``ssh`` 进程:

.. literalinclude:: distrobox_alpine/ps_ssh
   :caption: 检查 ``ssh`` 进程
   :emphasize-lines: 1

**等等！** 为何看到的进程和Host主机是一样的，我并没有在容器内部执行 ``ssh acloud-dev`` 等命令，为何会在容器内部看到Host物理主机上的 ``ssh`` 命令进程?

我真的已经进入容器内部了吗? ( ``distrobox enter alpine-dev`` )

``df -h`` 显示确实已经进入了容器，根文件系统挂在是 ``overlay`` :

.. literalinclude:: distrobox_alpine/df_overlay
   :caption: 文件系统挂载是 ``overlay`` 模式
   :emphasize-lines: 7,11,21-23

但是，启动和停止sshd服务都诡异地报告已经有其他启动和停止了

探索
------

我尝试前台启动 ``sshd`` 服务(这里我为了避免和Host主机ssh服务端口22冲突，修订了容器的 ``/etc/ssh/sshd_config`` 绑定 ``23`` 端口):

.. literalinclude:: distrobox_alpine/sshd_front
   :caption: 前台启动 ``sshd`` 服务

出乎意料的时，容器内的root用户也没有权限绑定端口 ``23`` :

.. literalinclude:: distrobox_alpine/sshd_front_output
   :caption: 前台启动 ``sshd`` 服务显示没有权限监听23端口

我使用 ``python3`` 的 ``http.server`` 模块来测试容器能够绑定的端口，确认容器内部低于 ``1024`` 端口都无法监听:

.. literalinclude:: distrobox_alpine/port_bind_test
   :caption: 检查发现容器内部无法绑定 ``1024`` 以下端口
   :emphasize-lines: 2,6,24

解决方案(思路)
---------------

想到在部署 :ref:`alpine_podman` 时，选择采用 ``rootless`` 模式运行，是不是这个原因导致呢？

确实如此...google提示: ``rootless`` 容器中 ``root`` 用户实际上没有真正Host系统的root权限，所以无法监听(bind)低于 ``1024`` 端口。解决的方法主要有两个:

- **方法一** ( ``推荐`` ):在 ``rootless`` 容器中，将应用服务监听端口调整到 ``1024`` 及以上端口，然后在运行容器的 ``--publish <HOST端口>:<Container端口>`` 时映射出容器，同时在前面采用类似 :ref:`nginx_reverse_proxy` 对外提供 ``80/443`` 这样的公共服务端口，反向代理到容器映射出的 ``1024`` 及以上端口
- **方法二** ( ``不推荐`` ): 调整Host主机 ``net.ipv4.ip_unprivileged_port_start `` 内核参数，将非私有端口范围降低到需要bind的端口号以下，就能够允许 ``rootless`` 容器绑定到原先无法绑定的私有端口(即设置为 ``net.ipv4.ip_unprivileged_port_start = 80`` ，则允许所有 ``80`` 及以上端口非root可以bind，但是不包括低于 ``80`` 端口，如 ``22`` 端口不包括)

.. literalinclude:: distrobox_sshd/ip_unprivileged_port_start
   :caption: 设置 ``net.ipv4.ip_unprivileged_port_start`` 为 ``1022`` (降低2个端口号)

- 根据上述解决方法，我采用方法一，即调整容器内部服务端口，采用 ``1024及以上`` 非私有端口，所以 :ref:`distrobox_alpine` 中 ``Dockerfile`` 镜像我也相应做了调整

- 另外在容器内部，虽然能够通过 ``--init-hooks`` 去执行 ``/usr/sbin/sshd -D &`` 命令，但是进行一旦挂掉，容器内部没有进程管理器是无法自动重启 ``sshd`` 服务的，所以我最后还是决定通过 ``tini`` 进程管理器来维护 ``sshd`` 服务

调整容器内服务端口( ``1024以上`` )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

由于我考虑 :ref:`docker_tini` 管理容器内多进程可能更为优雅，所以我尝试采用 :ref:`here_document` 改进过的 ``Dockerfile`` :

.. literalinclude:: ../../docker/init/docker_tini/Dockerfile
   :caption: 采用 ``1122`` 端口来运行容器内 ``ssh`` 服务
   :emphasize-lines: 75

- 使用 :ref:`podman` 构建镜像:

.. literalinclude:: ../../linux/alpine_linux/alpine_podman/build
   :caption: 构建镜像

- 创建通过 ``Dockerfile`` 构建镜像的容器:

.. literalinclude:: distrobox_alpine/create_alpine-dev
   :caption: 去除 ``init-hooks`` 参数，尝试通过 ``tini`` 启动容器中多个服务方式来运行 ``distrobox``

- 创建成功后，执行以下命令来进入容器(运行容器):

.. literalinclude:: distrobox_alpine/run
   :caption: 进入容器

但是发现容器内没有 ``sshd`` 进程，这是为什么？

``distrobox`` 覆盖了 ``Dockerfile`` 的 ``ENTRYPOINT`` 和 ``CMD`` 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

原来 ``distrobox enter`` 不会执行 ``Dockerfile`` 中的 ``ENTRYPOINT`` ，因为 ``distrobox`` 的主要功能是提供一个交互的shell环境，通过 ``distrobox`` 内置的脚本和用户shell **覆盖镜像内的默认entrypoint和command** 来实现:

- 轻量级容器环境: ``Distrobox`` 被设计成一个轻量级集成容器环境，就像一个常规的系统shell一样运行，而不是一个标准的面向应用的容器

- 默认行为是shell: ``distrobox enter`` 默认命令进入容器时实际上是使用当前用户的shell( ``bash`` 或 ``zsh`` )

  - 这也解释了为何我在 :ref:`distrobox_swift` 运行 :ref:`distrobox_vscode` 时始终没有执行容器内部 ``~/.profile`` 的原因

- ``Distrobox`` 使用自己的 **entrypoint** : 当执行 ``distrobox create`` 创建distrobox容器时，一个名为 ``distrobox-init`` 的脚本被设置为容器的实际 ``entrypoint`` 。这个脚本处理所有必要的设置，例如安装缺失的依赖，设置用户uid/gid，并挂载Host主机的目录。当完成设置以后，就会加载用户shell或指定命令，完全 **bypass** 掉原生镜像中的 ``ENTRYPOINT`` 和 ``CMD``

在 ``distrobox`` 初始化设置中执行定制脚本
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``distrobox create`` 阶段提供了 ``--init-hooks`` 或 ``--pre-init-hooks`` 来运行容器设置完成但还没有加载最终shell时可以运行的脚本。也就是说，可以在 ``--init-hooks`` 中指定运行 ``sshd`` :

.. literalinclude:: distrobox_sshd/create_alpine-dev_init-hooks
   :caption: 在 ``distrobox`` 中使用 ``--init-hooks`` 运行 ``sshd`` 服务

通过上述方式构建的 ``distrobox`` 容器，使用 ``distrobox enter alpine-dev`` 检查，就可以看到容器内部运行了 ``sshd`` 服务，也就能够在Host主机通过 ``ssh localhost -p 1122`` 登录

更好的方案
============

实际上 ``Distrobox`` 不适合作为标准容器来运行远程服务，而是作为桌面系统的补充，无缝运行一些需要在轻量级隔离环境中安装的桌面应用，特别是类似 :ref:`alpine_linux` ``musl`` 库无法正常运行的依赖 ``glibc`` 的应用。

对于上述需要运行 ``sshd`` 服务，甚至多个应用服务的远程开发测试环境，实际上适合采用标准的 :ref:`podman` 或 :ref:`docker` 来 **run** ，这样就能够充分利用 :ref:`docker_tini` 进程管理器来运行和监视多个服务进程，并在服务进程退出时及时终止容器，符合标准 :ref:`container` 运行或 :ref:`kubernetes` 运行:

.. literalinclude:: ../../linux/alpine_linux/alpine_podman/run
   :caption: 通过标准 ``podman`` 运行镜像来实现 ``tini`` 启动多个服务
