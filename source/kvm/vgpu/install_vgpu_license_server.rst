.. _install_vgpu_license_server:

==================================
安装NVIDIA license服务器
==================================

.. figure:: ../../_static/kvm/vgpu/grid-licensing-overview.png

   NVIDIA vGPU 软件licensing过程示意图

当虚拟机启动时会从NVIDIA vGPU软件license服务器(端口7070)获取license，并且每次启动会checkout。VM会维持license直到关机，然后释放掉license服务器上的license锁(回收的license可以被其他VM使用)

.. note::

   - 16GB内存的4个CPU的license服务器配置，适合处理多达15万个许可客户端
   - 主机必须运行在支持的Windows系统，且推荐安装英文版操作系统
   - license服务器的网卡MAC地址必须固定
   - license服务器的时钟必须准确
