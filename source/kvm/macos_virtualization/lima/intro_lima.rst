.. _intro_lima:

===================
Lima简介
===================

在很久以前，我尝试在 :ref:`macos` 上运行Linux虚拟机，使用的是 :ref:`xhyve` ，其原理是包装和调用 :ref:`macos` 内置的 Hypervisor 来实现虚拟机运行。随着macOS虚拟化技术的发展，涌现出一些对标 :ref:`Windows` 上 ``WSL2`` 的开源项目和商用软件。其中， `lima-vm.io <https://lima-vm.io/>`_ 就是其中的佼佼者，社区发展迅速，不仅成为 ``CNCF沙箱项目`` ，而且也衍生出了很多容器化开源项目:

Lima的优点是在启动Linux虚拟机同时会自动实现文件共享(file sharing)和端口转发(port forwarding)，这对使用者非常友好，类似于Windows的WSL2。我的使用体验是，几乎无感知地将 :ref:`macos` 的数据目录作为Lima的本地磁盘，能够如同Linux上运行Docker一样以标准化的 :ref:`docker_volume` 挂载到容器内部。

容器环境
===========

在Lima之上，开源社区有多个容器环境项目:

- :ref:`rancher_desktop`
- :ref:`colima` : 非常简单配置就能够在macOS上运行Docker和Kubernetes，该项目得到了Thoughtworks技术雷达的 "采纳推荐" (替代 :ref:`docker_desktop`)
- `GitHub: Finch <https://github.com/runfinch/finch>`_ 对标 :ref:`docker_moby` 的macOS平台容器镜像构建工具
- `Podman Desktop <https://podman-desktop.io/>`_ 使用一个插件来运行Lima虚拟机的Podman Desktop GUI

GUI
=========

在 :ref:`macos` 平台，有以下帮助管理虚拟机的软件:

- `lima-xbar-plugin <https://github.com/unixorn/lima-xbar-plugin>`_ 使用 :ref:`xbar` 的管理VM启动、停止、状态等
- `lima-gui <https://github.com/afbjorklund/lima-gui>`_ 使用Qt开发的Lima管理器

参考
=====

- `lima-vm.io <https://lima-vm.io/>`_ 官方文档见 `Lima Documentation <https://lima-vm.io/docs/>`_

  - `Lima FAQ: “How does Lima work?” <https://lima-vm.io/docs/faq/#how-does-lima-work>`_

- `GitHub: lima-vm/lima <https://github.com/lima-vm/lima>`_
