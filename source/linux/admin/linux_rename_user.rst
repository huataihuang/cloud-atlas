.. _linux_rename_user:

=======================
Linux系统用户改名
=======================

我在完成 :ref:`pi_quick_start` 设置过程中，发现现在新版本的 :ref:`raspberry_pi_os` 启动脚本提供了一个将默认 ``pi`` 用户名改成用户希望的帐号名。自然我是希望通过脚本命令代替交互设置的，那么这个实现方法如下: 使用了 ``usermod`` 工具

.. literalinclude:: ../../raspberry_pi/startup/pi_quick_start/change_pi_account
   :caption: 使用 ``usermod`` 和 ``groupmod`` 实现用户名修订
   :emphasize-lines: 2-4

简单来说:

- ``usermod -l new_username old_username`` 修改用户名(会同时修改 ``/etc/passwd`` 和 ``/etc/group`` )
- ``usermod -d /home/new_username -m new_username`` 修改用户目录名
- ``usermod -u 2000 new_username`` 修改用户uid
- ``groupmod -o -n new_groupname old_groupname`` 修改用户组名

参考
===========

- `How to rename user in Linux (also rename group & home directory) <https://linuxtechlab.com/rename-user-in-linux-rename-home-directory/#google_vignette>`_
