.. _macos_studio_startup:

=================
macOS工作室起步
=================

在日常工作中使用的笔记本是MacBook Pro，性能非常卓越的笔记本，虽然我在 :ref:`introduce_my_studio` 使用了旧款MacBook Pro采用 :ref:`kvm_nested_virtual` 来构建与计算集群，Host主机使用的操作系统是Linux ( :ref:`linux` ) ，但是作为图形桌面系统， 即使如 :ref:`ubuntu_desktop`  和 :ref:`archlinux_on_mbp` 依然缺乏必要的商用软件，导致我花费了太多时间精力在模拟Windows和Android上，仅仅是为了通过 :ref:`wine` 或者 :ref:`anbox` 运行一个钉钉即时通讯工具。

.. note::

   商业公司对Linux使用往往仅限于服务器端投入，对于Linux桌面客户端则完全是放弃，因为无利可图。这导致技术工作者想要完全使用Linux工作需要限制自己的应用番位。类似阿里这样的企业，其日常工作沟通完全基于钉钉，这就使得使用Linux工作极其困难。

   不过，我有一个思路是采用 :ref:`chromium_os` 工作，我相信通过一定的技术努力，可以通过Android应用方式打通Linux和商业平台的连接。

言归正传，如果你的工作基于Linux开发或运维，则macOS是一个非常好的兼容Unix/Linux和Windows的图形工作平台，很容易流畅使用商用软件。

我在这里整理如何打造精简的macOS工作平台，首先安装必要的工作软件，然后再部署虚拟化平台，实现开发和运维的完美融合。

macOS软件安装和设置
====================

.. note::

   其实我梳理了一下我自己常用的应用软件，其实非常有限 -- 我的目标是摈弃过多的工具，集中精力打磨合适的工具来完成重点工作。

* Magnet - 非常推荐的一款桌面窗口平铺化工具，弥补了macOS无法像Win10那样提供窗口并排的缺憾。

.. figure:: ../../_static/macos_ios/studio/magnet.png
   :scale: 75

* iTerm2 - 替代默认Terminal的工具，功能非常强大，对于需要远程访问Linux服务器必备。

* :ref:`install_docker_macos`

如前所述，在macOS上我使用的虚拟化技术之一就是基于macOS操作系统自带Hypervisor的xhyve。在这个基础上，开源项目 :ref:`hyperkit` 成为 :ref:`docker` 和 :ref:`multipass` 的共有基础。

由于HyperKit源代码安装比较繁琐，所以采用先安装Docker for macOS Desktop软件包来获得HyperKit，也就为后续安装Multipass打下基础。

* :ref:`vmware_fusion`

安装了Docker之后，紧接着安装VMware Fusion虚拟化软件，以便能够借助 :ref:`vmware_nested_virtual` 构建一个 :ref:`openstack` 集群，并在openstack集群之上构建Kubernetes集群或者其他分布式系统。

* :ref:`homebrew`

很多GNU/Linux工具通过HomeBrew安装是最为快捷方便的，在macOS上，不论是 :ref:`install_run_minikube` 还是 :ref:`write_doc` (安装Python/Sphinx) ，都需要使用 :ref:`homebrew` 。

* :ref:`multipass`

在Docker安装之后，系统已经具备了HyperKit，这样安装Multipass就不再需要安装HyperKit。可以直接安装Multipass。

