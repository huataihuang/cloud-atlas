.. _intro_lfs:

==============================
linux from scratch(LFS)简介
==============================

`linux from scratch <http://www.linuxfromscratch.org/>`_  是一个提供如何一步步构建自己定制的Linux的项目。没有任何二进制发行版，只有文档指南。

很多人奇怪为何我们要经历重重困难从头开始构建Linux系统而不是直接下载一个已经存在的Linux发行版。以下是一些理由：

- LFS教会你Linux系统如何工作
- 构建LFS可以生成一个非常精巧的Linux系统
- LFS具备扩展性
-  LFS提供了附加的安全

如何构建 LFS 系统
===================

LFS 系统需要在一个已经安装好的 Linux 发行版（比如 Debian、OpenMandriva、Fedora 或 OpenSUSE）中构建。这个已有的 Linux 系统（即宿主）作为构建新系统的起始点，提供了必要的程序，包括一个编译器、链接器和 shell。请在安装发行版的过程中选择 “development（开发）”选项以便使用这些开发工具。

除了将一个独立发行版安装到你的电脑上之外，你也可以使用商业发行版的 LiveCD。

例如使用LiveCD，可以通过 `转换ISO文件为启动U盘 <https://www.linux.com/blog/how-burn-iso-usb-drive>`_ 然后启动笔记本电脑，再通过这个U盘运行的Ubuntu系统来编译安装LFS。

.. note::

   我的学习实践是通过虚拟机来完成一次完整的LFS构建，然后再移植到物理服务器构建，目标是定制自己的Linux精简发行版:

   - 定制适合 :ref:`kvm` 虚拟化和 :ref:`docker` 容器化的运行环境
   - 上层运行的虚拟机则采用 :ref:`debian` 这种通用Linux发行版，保持底座host主机系统的最小化定制化

资料和关注
=============

由于LFS是从源代码编译安装，需要关注上游源代码的安全漏洞和补丁升级:

- `LFS 相关资源 <https://lfs.xry111.site/zh_CN/12.1/chapter01/resources.html>`_
