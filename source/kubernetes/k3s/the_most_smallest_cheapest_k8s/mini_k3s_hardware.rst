.. _mini_k3s_hardware:

===================
微型K3s硬件
===================

为了能够发挥 :ref:`pi_1` 硬件余热(10年前购买的)，我通过 :ref:`alpine_install_pi_1` 来运行底层系统，一共使用了3个 :ref:`pi_1` :

- :ref:`alpine_install_pi_1` 只需要执行一次，另外两个树莓派通过 :ref:`alpine_pi_clone` 可以快速完成
- 按照 :ref:`edge_cloud_infra` 为3个 :ref:`pi_1` 分配IP地址及主机名，启动后，确保3台主机都能ssh登陆

  - 我发现实际上只有2台是512MB内存的B型 :ref:`pi_1` ，另外一台则只有 256MB 内存 ，所以硬件性能非常有限
  - 只能安装32位操作系统，使用 :ref:`alpine_linux` for ``armhf`` 系统，期望能够将硬件资源要求降到最低
  - :ref:`pi_1` 功率极低，无风扇，将3台设备叠加起来形成一个stack，扔到桌子底下连接到路由器的网口上组成小集群

alpine linux初始状态
=======================

最小化alpine linux安装(sys模式)，启动系统后观察可以看到，内存仅占用 42MB 
