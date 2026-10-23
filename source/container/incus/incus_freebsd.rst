.. _incus_freebsd:

========================
Incus运行FreeBSD
========================

我在 :ref:`incus_startup` 时发现，Incus官方 `Image server for Incus and LXC <https://images.linuxcontainers.org/>`_ 提供了FreeBSD镜像，可以通过 :ref:`kvm` 来运行一个完全不同于Linux的操作系统。

- 首先检查当前镜像源中实际存在的FreeBSD 15.1版本:

.. literalinclude:: incus_freebsd/image_list
   :caption: 检查可用的FreeBSD镜像

注意，这里的搜索使用了 ``images:freebsd/15.1`` ，如果使用 ``images:freebsd`` 就会列出所有freebsd版本

输出显示如下：

.. literalinclude:: incus_freebsd/image_list_output
   :caption: FreeBSD 15.1镜像列表

- 现在就可以指定镜像进行安装，注意，这里用到的名字 ``freebsd/15.1`` 也就是 ``default+zfs`` 镜像。在 `Image server for Incus and LXC <https://images.linuxcontainers.org/>`_ 首页可以看到镜像分类，对应的就是 ``freebsd	15.1	amd64	default+zfs``

.. literalinclude:: incus_freebsd/launch_image
   :caption: 加载和启动freebsd 15.1

这里出现一个报错:

.. literalinclude:: incus_freebsd/launch_image_error
   :caption: 加载和启动freebsd 15.1报错
   :emphasize-lines: 2

上述报错是因为部分 FreeBSD 镜像在初次引导时遇到 UEFI Secure Boot 校验问题，可以加上 ``-c security.secureboot=false`` 参数来规避引导报错:

.. literalinclude:: incus_freebsd/launch_image_secureboot_fasle
   :caption: 增加 ``-c security.secureboot=false`` 参数加载和启动freebsd 15.1

不过，实际上因为已经运行过启动命令，所以虚拟机已经存在。

一种方式是删除虚拟机并重新运行上述命令:

.. literalinclude:: incus_freebsd/incus_delete
   :caption: 删除虚拟机

这样比较干净，但是这样会重新下载

另一种方式是修改已经存在的实例配置并直接启动:

.. literalinclude:: incus_freebsd/incus_config_set
   :caption: 修订虚拟机

使用
======

- 通过控制台登录虚拟机终端:

.. literalinclude:: incus_freebsd/console
   :caption: 控制台登录虚拟机

- :ref:`incus_freebsd_tunning`

- 注意退出虚拟机控制台的方法(在 ``incus console`` 连接控制台时会提示): ``ctrl+a`` 然后按 ``q`` (如果在 :ref:`screen` 或其他多路复用器中导致 ``ctrl+a`` 被拦截，则可以来连续 **按两次** ``ctrl+a`` 将组合键透传过去)

参考
=====

- gemini
