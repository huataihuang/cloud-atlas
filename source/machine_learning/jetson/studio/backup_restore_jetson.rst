.. _backup_restore_jetson:

=========================
备份和恢复Jetson完整系统
=========================

在使用Jetson nano时，我发现TF卡的性能对运行速度有极大影响，通过 :ref:`sd_tf_card_speed_class` 对比选择了 SanDisk 的 Extreme 128GB TF卡，在经济能力范围内选择最快速的TF卡可以节约自己的生命。(^_^)

替换Jetson操作系统的TF卡，显然从头开始安装一次系统是非常不划算的，因为已经有太多调整和定制。所以，我最初尝试 :ref:`backup_restore_pi` 相同的方案来重建和替换TF卡。但是，实践中发现NVIDIA Jetson采用 `U-Boot Customization <https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%20Linux%20Driver%20Package%20Development%20Guide/uboot_guide.html>`_ 作为bootloader，所以并未成功。

比较简单的复制方法是采用 ``dd`` 命令 :ref:`clone_jetson_system` ，简单粗暴但容易实现。不过，要有挑战才有意义，我准备在后续购置新的Jetson Nano时，再次结合 ``tar`` 工具和 ``U-Boot`` 来完成Jetson的系统复制。

请等待我后续完善补充本文...

参考
=====

- `U-Boot Customization <https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%20Linux%20Driver%20Package%20Development%20Guide/uboot_guide.html>`_
