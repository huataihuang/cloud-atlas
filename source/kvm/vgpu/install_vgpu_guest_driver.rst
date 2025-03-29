.. _install_vgpu_guest_driver:

=====================================
安装NVIDIA Virtual GPU Guest Driver
=====================================

物理主机(Host)上 :ref:`install_vgpu_manager` 后，通过 :ref:`libvirt` 向虚拟机内部添加了 :ref:`vgpu` 设备，现在到了开始真正使用vGPU的时候了。也就是需要在VM内部安装Guest驱动来实际使用GPU。

准备工作
===========

- 虚拟机内部也要像 :ref:`install_vgpu_manager` 安装 GCC和Linux Kernel Headers ，并且还需要像 :ref:`vgpu_unlock` 一样安装 ``dkms`` :

.. literalinclude:: install_vgpu_guest_driver/apt_install_gcc_kernel_headers_dkms
   :language: bash
   :caption: 在Ubuntu Guest虚拟机中需要安装GCC，Linux Kernel Headers和dkms

安装 ``nvidia-linux-grid`` Guest驱动
======================================

- Ubuntu安装 ``nvidia-linux-grid`` Guest驱动:

.. literalinclude:: install_vgpu_guest_driver/dpkg_install_nvidia-linux-grid
   :caption: 在Ubuntu Guest虚拟机中安装 ``nvidia-linux-grid`` Guest驱动

- 然后重启虚拟机

配置licence
=================

- 在Ubuntu虚拟机中编辑 ``/etc/nvidia/gridd.conf`` 配置:

.. literalinclude:: install_vgpu_guest_driver/gridd.conf
   :caption: 配置虚拟机 ``/etc/nvidia/gridd.conf`` 连接License服务器
   :emphasize-lines: 4,9,19

这里有个问题，没有添加vGPU的虚拟机无法启动 ``nvida-gridd`` 服务。所以我返回 :ref:`install_vgpu_manager` 为虚拟机 ``y-k8s-n-1`` 添加vGPU

- 启动 ``nvidia-gridd`` :

.. literalinclude:: install_vgpu_guest_driver/start_gridd
   :caption: 配置Lince Server的IP和端口以及请求License，然后启动 ``nvidia-gridd``  

客户端请求的服务器License必须得到服务器支持，例如License Server只提供 ``Quadro-Virtual-DWS`` ，但是客户端配置成 ``FeatureType=4`` 请求 ``Virtual Compute Server`` ，则客户端启动 ``nvidia-gridd`` 后日志会提示类似如下错误:

.. literalinclude:: install_vgpu_guest_driver/nvidia-gridd_log_err
   :caption: ``nvidia-gridd`` 请求License必须和License Server提供种类匹配，否则客户端会有错误日志，不过 ``Quadro-Virtual-DWS`` License 似乎可以和 ``Virtual Compute Server`` 通用
   :emphasize-lines: 11,13

不过，实践看来 ``Quadro-Virtual-DWS`` License 似乎可以和 ``Virtual Compute Server`` 通用(从 ``nvidia-gridd`` 日志看最后加载License成功 )

此时，观察 Lince Server 服务器的 ``License Feature Usage`` 可以看到Licence计数已经减少了1个，也就是被vGPU客户端使用了

参考
=======

- `Virtual GPU Software User Guide <https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html>`_
