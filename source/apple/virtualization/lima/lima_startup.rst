.. _lima_startup:

=============
Lima快速起步
=============

安装
=======

Lima依赖 :ref:`qemu` 7.0或更高版本，不过只在使用QEMU驱动时需要

- 推荐使用 :ref:`homebrew` 安装:

.. literalinclude:: lima_startup/brew_install_lima
   :caption: :ref:`homebrew` 安装 lima

不过，对于我使用的古老的 :ref:`mbp15_late_2013` 操作系统 Big Sur 11.7.10 ， :ref:`homebrew` 已经不再支持，所以我现在采用官方提供的二进制发行版解压缩到 ``/usr/local`` 目录使用:

.. literalinclude:: lima_startup/binary_install_lima
   :caption: 二进制发行版安装 lima

使用
========

- 快速启动:

.. literalinclude:: lima_startup/limactl_start
   :caption: 执行 ``limactl`` 启动

此时会进入一个交互菜单页面，使用上下键来选择菜单:

.. literalinclude:: lima_startup/limactl_start_output
   :caption: 执行 ``limactl`` 启动进入交互菜单
   :emphasize-lines: 2,3

- 选则默认的 ``Proceed with the current configuration`` 就会下载 ``ubuntu-24.10`` 服务器镜像进行运行
- 选择 ``Choose another template (docker, podman, archlinux, fedora, ...)`` 就可以选择不同的 `Lima操作系统模版 <https://lima-vm.io/docs/templates/>`_

.. note::

   为了方便起停虚拟机，可以安装 :ref:`xbar` 来方便交互

定制
--------

- 使用以下命令从 ``docker`` 模版(参考 `Lima操作系统模版 <https://lima-vm.io/docs/templates/>`_ )创建一个 ``default`` 会话:

.. literalinclude:: lima_startup/lima_customization
   :caption: 从模版选择定制启动

模版
=======

``lima`` 通过模版来指导启动的虚拟机镜像获得、文件系统挂载等。 `Lima操作系统模版 <https://lima-vm.io/docs/templates/>`_ 提供了官方支持的发行版莫辨，以及容器、 :ref:`kubernetes` 模版

参考
=====

- `lima-vm.io <https://lima-vm.io/>`_ 官方文档见 `Lima Documentation <https://lima-vm.io/docs/>`_
- `GitHub: lima-vm/lima <https://github.com/lima-vm/lima>`_
