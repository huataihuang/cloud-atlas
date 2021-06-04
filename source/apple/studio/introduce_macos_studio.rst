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

我在公司配发的MacBook Pro笔记本上，通过这种解决方案可以运行一个完整的Kubernetes集群，能够做很多开发和验证工作。

.. note::

   :ref:`install_docker_macos` 使用的Docker Desktop on Mac，实际上就是 :ref:`xhyve` 所运行的一个虚拟机。不过，这个部署只运行了一台 :ref:`alpine_linux` 虚拟机来运行 :ref:`docker` ，所以类似 :ref:`install_run_minikube` 只是单机版本，如果要在一个虚拟机中体验Kubernetes，可以采用 :ref:`docker_in_docker` 。

- :ref:`vmware_fusion` - VMware Fusion是商用软件，虽然不是macOS内置的虚拟化技术，略微沉重，但是，设置非常方便，并且不仅支持硬件虚拟化(当然hyperkit也支持)而且支持 :ref:`vmware_nested_virtual` ，这项技术和 :ref:`kvm_nested_virtual` 类似，通过嵌套虚拟化技术在一台物理主机上运行多个支持虚拟化的虚拟机，可以构建复杂的云计算集群。

容器化
---------

我现在经常有一个困扰就是反复折腾，导致系统比较杂乱，每次升级和尝试新的软件，不经意之间会把自己的开发环境搞乱。并且我有多台工作设备，从mac到Linux，从x86到ARM，不断切换，要维护一个开发测试环境，实在非常消耗精力。

所以，我决定还是采用 :ref:`docker_studio` ，结合github中保存配置，通过容器化方式执行脚本，自动构建一个稳定的纯净的开发测试环境。任何时候重装操作系统或者更换设备，都能快速开始顺畅工作。

参考
=======

- `Docker+VSCode配置属于自己的炼丹炉 <https://zhuanlan.zhihu.com/p/102385239>`_
