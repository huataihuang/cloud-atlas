.. _intro_lima:

===================
Lima简介
===================

在很久以前，我尝试在 :ref:`macos` 上运行Linux虚拟机，使用的是 :ref:`xhyve` ，其原理是包装和调用 :ref:`macos` 内置的 Hypervisor 来实现虚拟机运行。随着macOS虚拟化技术的发展，涌现出一些对标 :ref:`Windows` 上 ``WSL2`` 的开源项目和商用软件。其中， `lima-vm.io <https://lima-vm.io/>`_ 就是其中的佼佼者，社区发展迅速，不仅成为 ``CNCF沙箱项目`` ，而且也衍生出了很多容器化开源项目:

Lima的优点是在启动Linux虚拟机同时会自动实现文件共享(file sharing)和端口转发(port forwarding)，这对使用者非常友好，类似于Windows的WSL2。我的使用体验是，几乎无感知地将 :ref:`macos` 的数据目录作为Lima的本地磁盘，能够如同Linux上运行Docker一样以标准化的 :ref:`docker_volume` 挂载到容器内部。

功能支持
===========

- 自动文件共享: :ref:`colima_storage_manage`
- 自动宽口转发
- 内置支持 :ref:`containerd` 以及其他 :ref:`container` 如 :ref:`podman` , :ref:`docker` 等
- Intel on Intel
- :ref:`arm-on-intel_lima`
- Arm on Arm
- :ref:`intel-on-arm_lima`
- 支持不同的guest Linux发行版: 默认使用 :ref:`ubuntu_linux` 但支持各种主流发行版

  - :ref:`lima_run_alpine`
  - :ref:`lima_run_freebsd`

容器环境
===========

在Lima之上，开源社区有多个容器环境项目:

- :ref:`rancher_desktop`
- :ref:`colima` : 非常简单配置就能够在macOS上运行Docker和Kubernetes，该项目得到了Thoughtworks技术雷达的 "采纳推荐" (替代 :ref:`docker_desktop`)
- `GitHub: Finch <https://github.com/runfinch/finch>`_ 对标 :ref:`moby` 的macOS平台容器镜像构建工具
- `Podman Desktop <https://podman-desktop.io/>`_ 使用一个插件来运行Lima虚拟机的Podman Desktop GUI

GUI
=========

在 :ref:`macos` 平台，有以下帮助管理虚拟机的软件:

- `lima-xbar-plugin <https://github.com/unixorn/lima-xbar-plugin>`_ 使用 :ref:`xbar` 的管理VM启动、停止、状态等
- `lima-gui <https://github.com/afbjorklund/lima-gui>`_ 使用Qt开发的Lima管理器

限制和不足
============

- Lima目前对USB设备共享支持不足(文档中没有关于如何共享Host主机的USB设备到虚拟机，根据issue搜索看来还没有支持):

  - `[POC] USB sharing with host #1317 <https://github.com/lima-vm/lima/pull/1317>`_ 目前还是讨论草稿:

    - 默认使用的VZ引擎( :ref:`apple_virtualization` )，但没有支持USB设备( `Apple Virtualization / USB Devices <https://developer.apple.com/documentation/virtualization/usb-devices?language=objc>`_ 显示底层虚拟框架是支持USB设备的，似乎Lima还没有相关开发)
    - 如果使用 :ref:`qemu` 引擎，则可以通过 ``qemu-system-x86_64`` 命令参数 ``-device`` 将USB设备连接到虚拟机(启动VM前需要先连接USB设备并获取USB设备id) : 具体方法见 `Can I pass through a usb port via qemu command line <https://unix.stackexchange.com/questions/452934/can-i-pass-through-a-usb-port-via-qemu-command-line>`_

.. note::

   如果需要运行纯 ref:`qemu` 虚拟机，那么优先使用 :ref:`utm` (专注qemu虚拟化，交互方便)

   如果在Apple Silicon硬件上运行，并且只使用 :ref:`linux` 和 :ref:`macos` 虚拟机，那么使用 :ref:`tart` 较好(完全 :ref:`apple_virtualization` 技术，且只专注Apple Silicon)

参考
=====

- `lima-vm.io <https://lima-vm.io/>`_ 官方文档见 `Lima Documentation <https://lima-vm.io/docs/>`_

  - `Lima FAQ: “How does Lima work?” <https://lima-vm.io/docs/faq/#how-does-lima-work>`_

- `GitHub: lima-vm/lima <https://github.com/lima-vm/lima>`_
