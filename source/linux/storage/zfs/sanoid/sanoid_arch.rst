.. _sanoid_arch:

==================
Sanoid架构
==================

Sanoid是一个ZFS文件系统的策略驱动快照管理工具。当结合了Linux :ref:`kvm` hypervisor，可以使用它通过快照管理和 ``over-the-air`` (无感)复制来实现系统 ``functionally immortal`` (功能上永生)。

``functionally immortal`` 是指 **无论遇到逻辑层面（误删/勒索软件/坏更新）还是物理层面（硬件烧毁/机房断电）的灾难，系统都能在秒级到分钟级内无缝复活，且零数据丢失** 。

底层的核心就是将 **Linux KVM 虚拟化引擎 与 ZFS 存储引擎 以及 Sanoid/Syncoid 自动化运维 进行深度联动** :

- KVM 虚拟机的虚拟磁盘（.img / zvol）直接托管在 ZFS 数据集上
- Sanoid 在后台配置定时快照
- 任何故障(或者被勒索软件加密)，只需要将虚拟机关机，执行 ``zfs rollback`` 恢复到前一个快照，然后重新启动KVM虚拟机

参考
=======

- `GitHub: jimsalterjrs/sanoid <https://github.com/jimsalterjrs/sanoid>`_
- gemini
