.. _vgpu_startup:

====================
vgpu虚拟化快速起步
====================

.. warning::

   很不幸，我虽然有支持vGPU功能的 :ref:`tesla_p10` 数据中心运算卡，但是NVIDIA vGPU需要license才能工作。申请90天试用license非常麻烦(需要企业用户通过NVIDIA的销售审核)，所以我最终放弃尝试( :ref:`vgpu_unlock` 中记录了采用特定 vGPU 14.1版本在Windows虚拟机中绕过license的方法，但是这个方法只能用于Windows虚拟机，我实际没有实践 )。

   vGPU的技术使用并不复杂，我仅做一些资料整理。最终我还是准备采用 GPU passthrough 方式将整个 :ref:`tesla_p10` 直通给一个虚拟机来构建 :ref:`kubernetes` GPU容器，和vGPU的差异应该仅仅是GPU切分的差异。这个功能我准备放弃，除非后续有商业的license环境尝试。从技术上，vGPU和GPU passthrough的差异不大，仅仅是一些license的配置，就不再研究了。

要设置NVIDIA vGPU设备，需要:

- 为GPU设备获取和安装对应的NVIDIA vGPU驱动
- 创建 mediated (协调) 设备
- 将mediated设备分配给虚拟机
- 在虚拟机中安装guest驱动

在host主机设置NVIDIA vGPU设备
==============================

- 从NVIDIA官方 `NVIDIA vGPU Software (Quadro vDWS, GRID vPC, GRID vApps) <https://www.nvidia.com/en-us/drivers/vgpu-software-driver/>`_  页面提供注册入口，可以注册一个试用账号获得90天试用licence(需要使用企业邮箱，注册以后大约24小时~48小时发送licence到邮箱?)

- 从 `NVIDIA Driver Downloads <https://www.nvidia.com/Download/index.aspx?lang=en-us>`_ 下载驱动，需要注意 ``vGPU驱动`` 下载需要使用上述注册的试用账号登陆才能下载 

.. note::

   `NVIDIA® Virtual GPU (vGPU) Software Documentation <https://docs.nvidia.com/grid/index.html>`_  提供了NVIDIA发布的vGPU版本对照表:

   - NVIDIA每个vGPU软件系列都有配套的软件版本:

     - vGPU Manger
     - Linux Driver
     - Windows Driver

   例如vGPU软件12.2版本于2021年4月发布，包含(对应于 `Virtual Machine with vGPU Unlock for single GPU desktop <https://github.com/tuh8888/libvirt_win10_vm>`_ 提供的 NVIDIA-Linux-x86_64-460.73.01-grid-vgpu-kvm-v5.run ):

     - vGPU Manager 460.73.02
     - Linux Driver 460.73.01
     - Windows Driver 462.31
   

参考
=========

- `SETTING UP AN NVIDIA GPU FOR A VIRTUAL MACHINE IN RED HAT VIRTUALIZATION <https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.4/html/setting_up_an_nvidia_gpu_for_a_virtual_machine_in_red_hat_virtualization/index>`_ 配置GPU的直通和vgpu，本文参考后半部分
- `Virtual Machine with vGPU Unlock for single GPU desktop <https://github.com/tuh8888/libvirt_win10_vm>`_ 提供了配置指南的参考，以及Kernel 5.12的
