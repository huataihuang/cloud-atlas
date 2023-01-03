.. _vgpu_startup:

====================
vgpu虚拟化快速起步
====================

要设置NVIDIA vGPU设备，需要:

- 为GPU设备获取和安装对应的NVIDIA vGPU驱动
- 创建 mediated (协调) 设备
- 将mediated设备分配给虚拟机
- 在虚拟机中安装guest驱动

在host主机设置NVIDIA vGPU设备
==============================

- 从NVIDIA官方 `NVIDIA vGPU Software (Quadro vDWS, GRID vPC, GRID vApps) <https://www.nvidia.com/en-us/drivers/vgpu-software-driver/>`_  页面提供注册入口，可以注册一个试用账号获得90天试用licence(需要使用企业邮箱，注册以后大约24小时~48小时发送licence到邮箱?)

- 从 `NVIDIA Driver Downloads <https://www.nvidia.com/Download/index.aspx?lang=en-us>`_ 下载驱动，需要注意 ``vGPU驱动`` 下载需要使用上述注册的试用账号登陆才能下载 

参考
=========

- `SETTING UP AN NVIDIA GPU FOR A VIRTUAL MACHINE IN RED HAT VIRTUALIZATION <https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.4/html/setting_up_an_nvidia_gpu_for_a_virtual_machine_in_red_hat_virtualization/index>`_ 配置GPU的直通和vgpu，本文参考后半部分
