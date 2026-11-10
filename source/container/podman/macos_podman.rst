.. _macos_podman:

====================
macOS Podman
====================

和 :ref:`ubuntu_podman` 有所不同，macOS平台上是通过一个原生podman CLI以及通过一个guest Linux系统( :ref:`lima` 虚拟机)来运行容器。这个guest linux系统被作为一个Podman machine，通过 ``podman machine`` 来管理。此外，在macOS和Windows系统上的Podman也监听并服务于Docker API客户端，这样支持基于 :ref:`docker` 的工具直接使用和编程。

安装
========

- 建议通过 `Podman.io <https://podman.io/>`_ 网站下载Installer进行安装(更方便是直接使用 `Podman Desktop安装 <https://podman-desktop.io/downloads>`_ ，这个Podman Desktop是图形安装过程，可以同时安装 ``podman`` , ``nerdctl`` ，并且能够自动完成环境初始化)

- 此外也可以通过 :ref:`homebrew` 来进行安装:

.. literalinclude:: macos_podman/brew_install
   :caption: ``brew`` 安装podman

- 创建和启动第一个Podman虚拟机(如果使用 `Podman Desktop安装 <https://podman-desktop.io/downloads>`_ 那么就不需要这个步骤，因为已经在Podman Desktop安装过程中自动完成)

.. literalinclude:: macos_podman/machine
   :caption: 创建和初始化podman虚拟机

参考
========

- `Podman Installation Instructions <https://podman.io/docs/installation>`_
