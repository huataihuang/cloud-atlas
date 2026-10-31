.. _move_home_to_lvm:

===========================
将HOME目录迁移到独立LVM卷
===========================

.. note::

   本文是在 :ref:`incus` + :ref:`podman` 的rootless运行模式下，迁移HOME目录数据

由于我现在在实验环境服务器上使用 :ref:`incus` 和 :ref:`podman` ，并且都是采用 ``rootless`` 模式，所以实际上容器数据全部存储在 ``admin`` 用户的HOME目录下，随着不断运行和维护，该 ``admin`` 的HOME目录数据会急剧膨胀(也包含了大量的 :ref:`ollama` 运行模型数据)。

LVM
=====

- :ref:`ubuntu_linux` 服务器版本默认仅将磁盘的前100G分配给 :ref:`linux_lvm` 模式的根目录使用，磁盘剩余LVM卷其实并没有分配，所以我现在调整将剩余空间全部创建为 ``home_admin`` LVM卷(参考 :ref:`striped_lvm` ):

.. literalinclude:: move_home_to_lvm/lvcreate
   :caption: 将剩余VG全部用于LVM卷 ``home_admin``

- 格式化成 :ref:`xfs` 文件系统:

.. literalinclude:: move_home_to_lvm/xfs
   :caption: 格式化成XFS系统

- 检查磁盘UUID

.. literalinclude:: move_home_to_lvm/blkid
   :caption: 检查LVM卷的UUID

输出显示:

.. literalinclude:: move_home_to_lvm/blkid_output
   :caption: 获取到的LVM卷的UUID

- 修订 ``/etc/fstab`` 按照UUID来配置LVM卷的挂载:

.. literalinclude:: move_home_to_lvm/fstab
   :caption: ``/etc/fstab``

.. note::

   这里我还没有进行挂载，因为我需要等原先的 ``/home/admin`` 目录上所有进程结束以后，重命名为 ``/home/admin_origin`` ，然后再挂载这个LVM卷到 ``/home/admin`` 进行数据同步

停止admin相关的服务进程
=========================

- 关闭 Incus 守护进程，防止其在迁移过程中访问底层目录:

.. literalinclude:: move_home_to_lvm/stop_incus
   :caption: 停止 ``incus``

- 终止 admin 用户的所有会话与后台进程: 使用 ``loginctl`` 彻底终止该用户的所有进程（包括 ``/usr/lib/systemd/systemd --user`` 、rootless :ref:`podman` 的 conmon 等）

.. literalinclude:: move_home_to_lvm/loginctl
   :caption: 通过 ``loginctl`` 来停止 ``admin`` 相关进程

- 临时禁用 admin 用户的 Lingering (长驻留) ，即防止 :ref:`systemd` 在后台静默重启 ``admin`` 用户实例:

.. literalinclude:: move_home_to_lvm/loginctl_disable
   :caption: 暂时禁止admin用户实例

- 强制清理任何残留进程

.. literalinclude:: move_home_to_lvm/pkill
   :caption: 检查并杀死任何可能遗留的孤儿进程

现在通过 ``ps aux | grep admin`` 以及 ``lsof | grep admin`` 都看不到输出，确保没有访问呢进程

- 将 ``/home/admin`` 改名为 ``/home/admin_origin``

.. literalinclude:: move_home_to_lvm/mv
   :caption: 重命名 ``/home/admin``

- 现在可以创建 ``/home/admin`` 目录并挂载前面已经格式化 :ref:`xfs` 的 :ref:`linux_lvm` 卷 ``home_admin`` :

.. literalinclude:: move_home_to_lvm/mount
   :caption: 挂载 ``/home/admin``

这里会有一个提示:

.. literalinclude:: move_home_to_lvm/mount_output
   :caption: 挂载 ``/home/admin`` 提示

按照提示重新加载来刷新 :ref:`systemd` 的fstab: ``systemctl daemon-reload``

- :ref:`rsync` 数据同步:

.. literalinclude:: move_home_to_lvm/rsync
   :caption: 使用 ``rsync`` 同步数据

参数说明:

  - ``-a`` : 归档模式，递归复制并保持文件属性(权限、时间戳等)
  - ``-H`` : 保持硬链接(对 :ref:`podman` / :ref:`docker` 镜像层存储至关重要)
  - ``-v`` : 显示详细的同步过程
  - ``--numeric-ids`` : **核心关键参数** 直接复制数字形式的UID和GID(而不通过名称解析转换)，防止Rootless容器与subuid映射在迁移后发生所有者错乱

- 参考 :ref:`fstrim` 启动系统的SSD定期TRIM任务，以确保SSD长期保持高性能且不发生掉速:

.. literalinclude:: move_home_to_lvm/fstrim
   :caption: 启用系统自带的定时 TRIM 服务

- 所有工作已经完成， **不要忘记恢复环境**

恢复 Lingering:

.. literalinclude:: move_home_to_lvm/restore_linger
   :caption: 恢复Lingering

重启Incus服务

.. literalinclude:: move_home_to_lvm/start_incus
   :caption: 重启Incus服务

验证podman和incus:

.. literalinclude:: move_home_to_lvm/check
   :caption: 检查incus和podman

一切没有问题后，再重启一次操作系统确认是否能自动恢复到运行状态

**DONE**

参考
=====

- gemini
