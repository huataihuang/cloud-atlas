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

定制
--------

- 使用以下命令从 ``docker`` 模版(参考 `Lima操作系统模版 <https://lima-vm.io/docs/templates/>`_ )创建一个 ``default`` 会话:

.. literalinclude:: lima_startup/lima_customization
   :caption: 从模版选择定制启动


参考
=====

- `lima-vm.io <https://lima-vm.io/>`_ 官方文档见 `Lima Documentation <https://lima-vm.io/docs/>`_
- `GitHub: lima-vm/lima <https://github.com/lima-vm/lima>`_
