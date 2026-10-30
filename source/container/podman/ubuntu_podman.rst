.. _ubuntu_podman:

===================
Ubuntu Podman
===================

安装
=======

- 在Ubuntu上安装podman

.. literalinclude:: ubuntu_podman/install
   :caption: 安装podman

podman compose
-----------------

``podman-compose`` 是一个python编写、用来翻译 Docker Compose 语法并调用 Podman API 的开源工具。在Ubuntu中可以通过:

- ``podman-compose`` 软件包安装:

.. literalinclude:: ubuntu_podman/install_podman-compose
   :caption: 通过apt安装podman-compose

- 通过Python的pip安装:

.. literalinclude:: ubuntu_podman/pip_install_podman-compose
   :caption: 通过pip安装podman-compose

执行命令可以使用独立命令:

.. literalinclude:: ubuntu_podman/podman-compose
   :caption: 独立命令运行

也可以用podman插件访拿格式运行(podman较新的版本且集成了对应插件)

.. literalinclude:: ubuntu_podman/podman_compose
   :caption: 插件命令运行

rootless运行模式
==================

在ubuntu上，通过 ``apt install podman`` 默认就已经原生支持 Rootless 运行模式。和Docker必须依赖一个拥有root权限的守护进程不同，Podman从设计之初就是无守护进程(Daemonless)且完全面向非特权用户的。

只要用户当前是一个普通用户(如 ``admin`` UID是1000)，那么执行任何 ``podman`` 命令默认就是在Rootless模式下运行。

- 验证当前是否出于Rootless模式(以普通用户以下命令，检查当前用户的Podman运行状态):

.. literalinclude:: ubuntu_podman/podman_info
   :caption: 检查pdoman状态

输出显示中有 ``rootless: true`` 表示Podman已经运行在Rootless模式下。不过，上述看到的ERROR信息，表明当前用户在系统的 ``/etc/subuid`` 和 ``/etc/subgid`` 文件中没有对应的 **从属用户 IDI** (subuid/subgid)范围，因此 Podman 在以 Rootless 模式运行 时无法正确建立用户命名空间。

执行以下命令，为 ``admin`` 用户分配一段子ID范围(例如从100000开始，大小为65536):

.. literalinclude:: ubuntu_podman/usermod
   :caption: 为admin用户分配一段子ID范围

完成以后检查 ``/etc/subuid`` 和 ``/etc/subgid`` 就会看到类似如下内容:

.. literalinclude:: ubuntu_podman/subuid_subgid
   :caption: ``/etc/subuid`` 和 ``/etc/subgid`` 添加了 admin 用户的从属用户ID

这样再次执行 ``podman info`` 就不会报错了

参考
=====

- `Podman Installation Instructions <https://podman.io/docs/installation>`_
