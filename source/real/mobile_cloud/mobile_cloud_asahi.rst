.. _mobile_cloud_asahi:

====================
移动云Asahi Linux
====================

如 :ref:`mobile_cloud_infra` 所规划的，我采用 :ref:`apple_silicon_m1_pro` MacBook Pro来构建底层服务器硬件。由于Apple Silicon M1 Pro处理器是ARM架构，硬件比较封闭，所以社区推出来 :ref:`asahi_linux` 针对Apple Silicon处理器优化，能够非常平滑安装和使用。

应用软件安装
===============

我选择了mini安装，也就是字符界面，所以需要再按需安装一些应用以及简单配置::

   pacman -S sudo mlocate

- 设置 sudo ::

   echo "huatai ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

安装图形界面

