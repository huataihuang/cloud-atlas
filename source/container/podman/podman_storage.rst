.. _podman_storage:

================
Podman存储
================

.. note::

   简单记录一下

   :ref:`incus` 和 :ref:`podman` 非常类似，存储引擎(Storage Drivers)和存储位置也如本文类似，可以相互印证。

位置
======

podman因为既支持 ``Root Mode`` 又支持 ``Rootless Mode`` ，所以存储(配置、镜像、容器)会有规律地存储在2个不同的地方:

- ``Root Mode`` 存储位置:

  - 配置文件: ``/etc/container/`` 目录存储了系统级的配置文件
  - 镜像文件存储: ``/var/lib/containers/storage/`` 目录存储镜像
  - 容器文件存储: ``/var/lib/containers/storage/`` 目录存储运行的容器分层和卷

- ``Rootless Mode`` 存储位置(完全存储在当前用户的 ``HOME`` 目录)

  - 配置文件: ``$HOME/.config/containers/`` 目录存储用户级的配置文件
  - 镜像文件存储: ``$HOME/.local/share/containers/storage/`` 目录下子目录存储镜像 
  - 容器(卷)文件存储: ``$HOME/.local/share/containers/storage/`` 目录下子目录存储容器分层和卷

:ref:`incus` 和 :ref:`podman` 都支持使用 :ref:`btrfs` , :ref:`zfs` 以及常规的文件系统作为存储引擎(Storage Drivers)

磁盘使用
=========

Podman 提供了一个类似 ``df`` 的磁盘使用检查工具 ``podman-system-df`` ，也就是执行 ``podman system df [options]`` 能够够查看镜像，容器和卷的使用情况。

.. literalinclude:: podman_storage/df
   :caption: 检查podman的磁盘使用情况

参考
======

- gemini
- `podman docs: podman-system-df - Show podman disk usage <https://docs.podman.io/en/latest/markdown/podman-system-df.1.html>`_
