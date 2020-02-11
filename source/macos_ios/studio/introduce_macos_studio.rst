.. _introduce_macos_studio:

======================
macOS工作环境
======================

目标
=====

当我拿到全新安装的macOS(当前是Catalina 10.15.3)，我的目标是:

* 构建虚拟化和容器化开发环境，把所有的工作都尽可能在VM和Container中运行，这样可以随时更换工作环境(迁移虚拟机和容器)
* 保持Host主机的纯净化，仅在本机运行macOS开发所需的软件

实现规划
==========

虚拟化
--------

在macOS上我推荐使用的虚拟化技术主要有:

- :ref:`hyperkit` - 底层采用了 :ref:`xhyve` 来使用macOS内建的Hypervisor.framework实现虚拟化

hyperkit也是在macOS上运行Docker的基础，并且Ubuntu提供了基于hyperkit的完整桌面虚拟化解决方案 :ref:`multipass` ，可以非常方便在macOS上运行多个Ubuntu服务器，这要就可以非常轻松构建服务器集群。

我在公司配发的MacBook Pro笔记本上，通过这种解决方案可以运行一个完整的Kubernetes集群，能够做很多也是和验证工作。

- :ref:`vmware_fusion`

参考
=======

- `Docker+VSCode配置属于自己的炼丹炉 <https://zhuanlan.zhihu.com/p/102385239>`_
