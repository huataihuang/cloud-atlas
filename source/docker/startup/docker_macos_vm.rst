.. _docker_macos_vm:

==============================
Docker Desktop on Mac 虚拟机
==============================

:ref:`install_docker_macos` 后，底层原理是在 :ref:`macos` 的 :ref:`xhyve` Hypervisor上运行了一个KVM虚拟机( :ref:`alpine_linux` ):

.. figure:: ../../_static/docker/startup/docker-for-mac-install.png
   :scale: 50

这个虚拟机是 :ref:`macos` 上运行的一个全功能虚拟机，实际上可以实现很多有趣的功能:

- 在虚拟机内部构建Linux服务，例如采用虚拟块设备构建多存储 :ref:`zfs` / :ref:`ceph` / :ref:`gluster`
- 既然 Docker Desktop for Mac能够运行虚拟机，应该也可以探索使用 :ref:`xhyve` 来运行其他Linux虚拟机，来构建一个更为真实的复杂集群
- :ref:`docker_macos_file_share` 可以将物理主机的 :ref:`macos` 目录共享进容器，那么也许可以实现非常复杂的协同工作流(我再想想)

进入Docker虚拟机内部
========================

方法一:使用netcat
--------------------

在 :ref:`macos` 上，由于 Docker Desktop for Mac 是运行了一个mini VM，所以我们可以通过物理主机上的虚拟机 ``sock`` 文件连接到这个虚拟机内部，方便我们排查虚拟机问题，也方便我们在虚拟机内部部署服务:

.. literalinclude:: docker_macos_vm/netcat_docker_macos_vm_sock
   :language: bash
   :caption: 通过macOS物理主机的sock连接到Docker Desktop for Mac虚拟机

.. note::

   这是最简单方法，无需下载运行容器，但是控制台似乎是sock影响提示符比较烦人

方法二:使用运行容器的nsenter进入pid 1的控制台(也就是虚拟机)
---------------------------------------------------------------

- 使用以下命令可以进入priviledged容器:

.. literalinclude:: docker_macos_vm/docker_run_nsenter
   :language: bash
   :caption: 通过nsenter进入运行容器的控制台

这里运行了一个使用debian镜像的容器，然后通过这个容器执行 ``nsenter`` 连接到 ``pid 1`` 的进程，实际上就是Docker虚拟机

.. note::

   这个方法非常巧妙，而且debian容器提供了很好的控制台兼容，使用方便

方法三:最简单的方法，通过 Justin Cormack (Docker Maintainer) 提供的镜像运行nsenter进入虚拟机控制台
----------------------------------------------------------------------------------------------------

Justin Cormack (Docker Maintainer)提供了一个镜像内置了nsenter直接nsenter进入虚拟机控制台:

.. literalinclude:: docker_macos_vm/docker_run_nsenter_container
   :language: bash
   :caption: Justin Cormack (Docker Maintainer)提供通过nsenter进入运行容器的控制台镜像


参考
=======

- `BretFisher/docker-for-mac.md <https://gist.github.com/BretFisher/5e1a0c7bcca4c735e716abf62afad389>`_
