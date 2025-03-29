.. _systemd_fstab_generator:

==========================
systemd-fstab-generator
==========================

我在排查 :ref:`systemd_mount` 神秘的自动挂载文件系统问题时，找到了根源是 ``systemd-fstab-generator`` : 能够自动根据 ``/etc/fstab`` 生成 :ref:`systemd_mount` 配置文件 ``XXXX.mount`` ，存放到 ``/run/systemd/generator/`` 目录下。

例如， ``ls -lh /run/systemd/generator/`` 可能会看到如下一些类似配置:

.. literalinclude:: systemd_fstab_generator/systemd_generator_dir
   :caption: ``/run/systemd/generator/`` 目录下存储了 ``systemd-fstab-generator`` 自动生成的 :ref:`systemd_mount` 配置

这些由 ``systemd-fstab-generator`` 生成的 ``units`` 没有对应的 ``unit-files`` ，所以需要使用以下命令查看:

.. literalinclude:: systemd_mount/systemctl_list-units_mount
   :caption: 使用 :ref:`systemctl` 检查 ``mount`` 类型 units

输出案例如下:

.. literalinclude:: systemd_mount/systemctl_list-units_mount_output
   :caption: ``mount`` 类型 units 可以看到要删除但是没有删除成功的挂载配置

- 检查 ``data-brick0.mount`` unit:

标准方法
==========

对应于 :ref:`systemd_fstab_generator` 自动生成的 ``.mount`` unit文件，不需要手工去停止或删除，只需要正确修改 ``/etc/fstab`` ，然后执行

.. literalinclude:: systemd_mount/systemctl_daemon-reload
   :caption: 执行 ``daemon-reload`` 刷新

就可以完全同步刷新配置。之后就可以手工 ``umount`` 挂载文件系统以及做磁盘初始化了

**上述步骤非常重要** 否则直接umount曾经配置过 ``/etc/fstab`` 挂载配置的文件系统，都会遇到反复自动挂载。一定要遵循 :ref:`systemd_mount` 经验教训
