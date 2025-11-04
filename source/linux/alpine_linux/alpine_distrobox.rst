.. _alpine_distrobox:

============================
Alpine Linux运行Distrobox
============================

快速起步
===========

.. note::

   Distrobox 使用 ``docker.io`` 镜像仓库，该仓库被 **GFW屏蔽** ，所以需要先设置代理环境变量:

   .. literalinclude:: ../../rancher/rancher_desktop/config_docker_deamon_rancher_desktop/docker_client_env
      :caption: 在客户端设置环境变量配置代理

- 创建debian系统容器:

.. literalinclude:: alpine_distrobox/create_debian
   :caption: 创建 debian 容器

如果要创建一个全功能包含 :ref:`systemd` 的容器(类似LXC):

.. literalinclude:: alpine_distrobox/create_debian_systemd
   :caption: 创建使用systemd的 debian 容器

- 启动并进入创建的 ``debian-dev`` 容器:

.. literalinclude:: alpine_distrobox/enter_debian
   :caption: 进入 debian 容器

这里会长时间卡在 ``Installing basic packages...`` :

.. literalinclude:: alpine_distrobox/enter_debian_output
   :caption: 进入 debian 容器时看似卡住，实际上是正常安装升级软件包过程，可能很漫长

我最初以为死机了或者容器有异常，实际上这个安装包过程非常耗费时间，原因是debian仓库 ``deb.debian.org`` 从国内访问非常缓慢，整个更新安装过程需要较长时间

要验证容器是否正常，可以使用 :ref:`podman` 工具:

- 检查运行容器:

.. literalinclude:: alpine_distrobox/podman_ps
   :caption: 检查运行容器

可以看到正在运行的容器 ``debian-dev`` :

.. literalinclude:: alpine_distrobox/podman_ps_output
   :caption: 检查运行容器显示 ``debian-dev``

- 通过 ``podman logs -f`` 可以持续检查容器日志，其中不断滚动的安装命令显示该 ``debian-dev`` 正在 **缓慢** 更新系统:

.. literalinclude:: alpine_distrobox/podman_logs
   :caption: 检查容器日志

可以看到输出信息中安装软件包进度

.. literalinclude:: alpine_distrobox/podman_logs_output
   :caption: 容器日志显示正在安装软件包
   :emphasize-lines: 18

ssh访问
====================

在 :ref:`distrobox_debian` 容器中需要外部能够访问需要创建容器时设置端口映射:

.. literalinclude:: alpine_distrobox/create_debian_ssh
   :caption: 启动容器时添加端口映射以便能够访问ssh服务(只有创建容器时可以映射端口)

.. note::

   默认创建的 ``distrobox`` 容器内部有一个 ``sshd`` 进程，但是不是常规的 ``openssh-server`` ，似乎是一个 ssh agent::

      nobody    2400  0.0  0.0   6736  3856 ?        S    Nov02   0:00 sshd: /usr/sbin/sshd [listener] 0 of 10-100 startups

   没有监听端口22

- 需要在容器内部安装 ``openssh-server`` : :ref:`distrobox_debian_ssh`

异常排查
--------------

我在启用了端口映射 ``--publish 2222:22`` 之后:

.. literalinclude:: alpine_distrobox/create_debian_ssh
   :caption: 启动容器时添加端口映射以便能够访问ssh服务

- 发现 ``distrobox enter debian-dev`` 显示初始化失败:

.. literalinclude:: alpine_distrobox/enter_error
   :caption: 启动podman容器失败

由于底层是 :ref:`podman` 所以需要使用 ``podman logs`` 来检查容器内部日志:

.. literalinclude:: alpine_distrobox/podman_logs
   :caption: ``podman logs`` 检查容器日志

可以看到由于tty0没有权限打开导致失败:

.. literalinclude:: alpine_distrobox/podman_logs_tty0_fail
   :caption: ``podman logs`` 检查容器日志看到 Fail to open /dev/tty0
   :emphasize-lines: 7-11

`Unable to access /dev/tty0 in a rootless container #18870 <https://github.com/containers/podman/discussions/18870>`_ 提到似乎rootless容器确实不能访问 ``/dev/tty*`` 

.. warning::

   没有找到原因

   睡了一觉，醒来重新创建::

      distrobox rm debian-dev
      distrobox create --name debian-dev --image debian-dev:latest --additional-flags "-p 2222:22"

   居然就成功了

容器目录
=============

类似 :ref:`lima` / :ref:`colima` ， ``distrobox`` 将运行 :ref:`podman` 容器的用户目录和 Host 主机的用户目录绑定，这样进入到容器内部以后， ``$HOME`` 目录实际上就是 Host 主机上的 ``$HOME`` 目录。这带来了文件访问的便利性。

通过 ``podman inspect debian-dev`` 可以看到存储bind的设置，其中包括 ``/home/admin`` :

.. literalinclude:: alpine_distrobox/bind_home_admin
   :caption: ``bind`` Host主机的 ``/home/admin`` 目录
   :emphasize-lines: 3-5

应用
========

- :ref:`distrobox_vscode`

参考
=======

- `Alpine Linux Wiki: Distrobox <https://wiki.alpinelinux.org/wiki/Distrobox>`_
- `Distrobox官网 <https://distrobox.it/>`_
- `监视下载的进度，distrobox enter : Installing basic packages... ，长时间没有变化的问题 （****）/ podman 监控 查看 <https://blog.csdn.net/ken2232/article/details/139479423>`_
