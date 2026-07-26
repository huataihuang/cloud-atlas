.. _alpine_lvm:

=======================
Alpine Linux卷管理LVM
=======================

- 安装LVM2工具包:

.. literalinclude:: alpine_lvm/apk
   :caption: 安装LVM2工具包

包含所有常用的 LVM 管理命令（如 pvcreate、vgcreate、lvcreate、lvs、vgs 等）

- 加载必要内核模块 ``dm-mod`` (Device Mapper):

.. literalinclude:: alpine_lvm/modprobe
   :caption: 加载内核模块

确保开机启动时自动加载:

.. literalinclude:: alpine_lvm/dm-mod
   :caption: 启动时加载dm-mod

- 在 Alpine 下，为了让系统在开机时能够自动发现并激活 LVM 卷组，建议开启并配置 lvm 服务:

安装 OpenRC 服务管理组件（如果需要）

.. literalinclude:: alpine_lvm/lvm2-openrc
   :caption: 安装OpenRC服务lvm2-openrc

将 LVM 服务加入 boot 级别

.. literalinclude:: alpine_lvm/boot
   :caption: LVM 服务加入 boot

手动启动服务测试

.. literalinclude:: alpine_lvm/start
   :caption: 手工启动 LVM 服务


