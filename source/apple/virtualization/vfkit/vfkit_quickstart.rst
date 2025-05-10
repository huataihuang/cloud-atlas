.. _vfkit_quickstart:

======================
vfkit快速起步
======================

``vfkit`` 使用 :ref:`apple_virtualization` 提供了命令行启动虚拟机的方法，并且提供了一个 ``github.com/crc-org/vfkit/pkg/config`` 的 :ref:`golang` 包，可以使用原生Go API来使用vfkit命令行。

RedHat的 :ref:`crc` 开发介绍了集成vfkit来本地运行 :ref:`openshift` 的方案:

- `vfkit - a native macOS hypervisor written in go <https://archive.fosdem.org/2023/schedule/event/govfkit/>`_ 视频分享介绍了这个hypervisor的技术
- 在油管上也有 `vfkit - a minimal hypervisor using Apple’s virtualization framework - Container Plumbing Days 2023 <https://www.youtube.com/watch?v=Z2kfaE7H31o>`_ (YouTube提供来自动英语字幕，甚至可以自动翻译中文，相对比较好理解)

通过 :ref:`vz` ， ``vfkit`` 实现了在macOS上构建虚拟化的功能，并且避免使用复杂沉重的 :ref:`qemu` 。

将 :ref:`apple_virtualization` 作为底座的方案最大的优势是:

- 所有 macOS (v11以上)都内置了 :ref:`apple_virtualization` ，不需要安装第三方hypervisor。
- 提供了高级API来创建Linux 和 macOS (ARM架构) 虚拟机
- 可以用于Swift或Objective-C开发
- 但仅仅是API/框架(库)而不是最终应用

  - virtio
  - virtio-net 网络通讯
  - virtio-blk 磁盘镜像
  - virtio-serial / virtio-rng / virtio-balloon ...
  - 支持图形化(视频,声音,和键盘鼠标...)

vfkit集成 :ref:`vz` (一个 :ref:`golang` 开发的 :ref:`apple_virtualization` 绑定工具)，正是因为使用了 ``VZ`` ， ``vfkit`` 就不需要使用 :ref:`swift` 或 Objective-C语言开发，就可以使用单一的 :ref:`golang` 开发(RadHat的CRC团队主要使用Go语言，不使用Swift语言)

安装
========

使用 :ref:`homebrew` 可以快速完成安装:

.. literalinclude:: vfkit_quickstart/install
   :caption: 安装 ``vfkit``

运行虚拟机
============



参考
======

- `GitHub: crc-org/vfkit <https://github.com/crc-org/vfkit>`_
