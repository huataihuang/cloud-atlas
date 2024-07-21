.. _intro_lima:

===================
Lima简介
===================

在很久以前，我尝试在 :ref:`macos` 上运行Linux虚拟机，使用的是 :ref:`xhyve` ，其原理是包装和调用 :ref:`macos` 内置的 Hypervisor 来实现虚拟机运行。随着macOS虚拟化技术的发展，涌现出一些对标 :ref:`Windows` 上 ``WSL2`` 的开源项目和商用软件。其中， `lima-vm.io <https://lima-vm.io/>`_ 就是其中的佼佼者，社区发展迅速，不仅成为 ``CNCF沙箱项目`` ，而且也衍生出了很多容器化开源项目:

- :ref:`rancher_desktop`
- :ref:`colima` : 非常简单配置就能够在macOS上运行Docker和Kubernetes，该项目得到了Thoughtworks技术雷达的 "采纳推荐" (替代 :ref:`docker_desktop`)
- `GitHub: Finch <https://github.com/runfinch/finch>`_ 对标 :ref:`docker_moby` 的macOS平台容器镜像构建工具
- `Podman Desktop <https://podman-desktop.io/>`_ 使用一个插件来运行Lima虚拟机的Podman Desktop GUI



参考
=====

- `lima-vm.io <https://lima-vm.io/>`_ 官方文档见 `Lima Documentation <https://lima-vm.io/docs/>`_

  - `Lima FAQ: “How does Lima work?” <https://lima-vm.io/docs/faq/#how-does-lima-work>`_

- `GitHub: lima-vm/lima <https://github.com/lima-vm/lima>`_

