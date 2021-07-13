.. _docker_macos_file_share:

==================================
Docker Desktop for macOS文件共享
==================================

我在 :ref:`docker_studio` 中尝试在物理主机macOS共享磁盘目录给Docker容器使用，以便能够把Docker容器的数据持久化。最初考虑使用 :ref:`macos_nfs` ，不过没有解决挂载问题，所以改为采用Docker官方手册的 ``File sharing`` 方法。

File sharing
==============

所谓 ``File sharing`` 通常的场景是在host主机(macOS)上使用IDE开发代码，然后在容器内部运行和测试代码(Linux环境)。默认情况下，共享了 ``/Users`` , ``/Volume`` , ``/private`` , ``/tmp`` 和 ``/var/folders`` 目录。

- 你可以添加自己指定的共享目录，如下:

.. figure:: ../../_static/docker/startup/docker_file_sharing.png
   :scale: 80

然后点击右下角的 ``Apply & Restart`` 按钮生效。

.. note::

   - 务必只在容器内共享需要的目录。文件共享后任何在物理host主机上修改的文件都会通知到Linux VM，所以共享更多的文件会导致高CPU负载以及缓慢的文件系统性能
   - 共享目录设计允许应用程序直接编辑host主机共享给容器的文件。对于非代码数据，例如缓存目录或者数据库，性能会比存储在Linux VM，也就是使用Docker卷的性能要好(我理解Docker卷实际上是读写Docker Desktop for Mac的Linux虚拟机中的共享目录，这个虚拟机性能有限，并且如果Linux VM被重置数据会丢失)
   - 如果将整个macOS上的home目录共享到容器内部，贼macOS可能会提示你需要给予Docker访问你home目录个人区域(例如Reminders或Downloads目录)的访问权。
   - 需要注意macOS文件系统默认是文件名大小写不区分，而Linux则是区分大小写，则可能导致应用在macOS和Linux上表现不一。

上述添加的 ``file sharing`` 目录如何映射到容器内部？

- 启动docker容器案例采用 :ref:`docker_studio` 的 ``dev`` 案例::

    docker run --name fedora-dev --hostname fedora-dev -p 122:22 --detach -ti -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /Users/huatai/home_admin/dev:/home/admin fedora-dev /usr/sbin/init

参考
=====

- `Docker Desktop for Mac user manual <https://docs.docker.com/docker-for-mac/>`_
