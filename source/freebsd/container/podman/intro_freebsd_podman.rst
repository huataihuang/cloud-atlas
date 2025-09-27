.. _intro_freebsd_podman:

======================
FreeBSD环境podman简介
======================

FreeBSD云原生
===============

2024年底FreeBSD社区宣布经过6周限时测试，验证了在FreeBSD平台云原生的运行环境通过移植podman等工具实现了OCI标准的容器支持云原生工作负载，并将在后续不断改进容器支持:

- 重点关注增强网络稳定性、改进无根容器功能以及确保与 :ref:`kubernetes` 等编排工具的无缝集成
- 预计将于 2025 年中期发布生产就绪版本
- FreeBSD 提供可靠且安全的基础，使其成为理想的容器平台
- 通过采用 OCI 标准，能够创建和部署在不同环境中一致运行的容器
- 使用 :ref:`freebsd_jail` 、 :ref:`zfs` 和轻量级虚拟机可以提供强大的隔离功能，同时最大限度地降低开销，使 FreeBSD 成为云原生应用程序灵活高效的选择
- 运行 :ref:`linux` 风格的 OCI 镜像的能力进一步增强了 FreeBSD 的跨平台兼容性，对于需要能够在不同环境中无缝运行应用程序的平台的开发人员来说，它是一个极具吸引力的选择

参考
=====

- `Advancing Cloud Native Containers on FreeBSD: Podman Testing Highlights <https://freebsdfoundation.org/blog/advancing-cloud-native-containers-on-freebsd-podman-testing-highlights/>`_
