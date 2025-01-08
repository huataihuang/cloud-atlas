.. _intro_darwin-containers:

=========================
Darwin Containers简介
=========================

我在实践 :ref:`freebsd_jail` 时，忽然想到我不断跨平台迁移，其中 :ref:`macos` 使用的FreeBSD作为基础的 ``Darwin`` 核心，是不是也具有 Jail 技术，能够轻量级构建容器化运行环境，方便我开发和学习呢？

还真有这样的技术， :ref:`darwin-jail` ，作为 ``Darwin Containers`` 的子项目，提供了在macOS中运行Jail的能力。进一步，这个 ``Darwin Containers`` 项目则原生在Darwin环境提供了部署运行容器的能力。

也就是说，现在我们能够 ``run Darwin inside Darwin`` ，也就是能够在 :ref:`macOS` core里面运行macOS core，而且还能够使用docker来构建镜像和通过registries来分发镜像。这是一个非常有意思的开源项目，终于为macOS平台带来的容器技术。


这个 ``Darwin Containers`` 和 :ref:`colima` 区别在于:

- :ref:`colima` 是在macOS中运行 :ref:`lima` Linux虚拟机，然后在虚拟化的Linux运行容器，也就是说多了一层虚拟化开销，并且运行的都是Linux容器
- ``Darwin Containers`` 则完全是原生的Darwin容器，也就是不需要虚拟化层，直接运行Darwin容器(在容器中运行的也是Darwin而不是Linux)

``Darwin Containers`` 结合了多项开源技术:

- :ref:`macfuse` 或 :ref:`fuse-t`
- :ref:`bindfs`
- :ref:`rund` - :ref:`containerd` 的转换器(shim) 用于在Darwin上运行Darwin容器

参考
=======

- `darwin-containers.github.io <https://darwin-containers.github.io/>`_
