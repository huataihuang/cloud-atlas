.. _macos_user_account_cmd:

=========================
macOS用户账号命令行
=========================

在macOS中，通常我们只使用图形界面来管理用户账号，但是这种图形界面受到macOS限制，只是按照类别区分普通用户和超级管理员。而对于传统的 :ref:`linux` / :ref:`freebsd` 账号管理，我们还会按照用户组来授予权限。

例如，在 :ref:`darwin-containers_startup` ，运行 :ref:`containerd` 的进程创建的 ``sock`` 文件就是 ``wheel`` 组，此时普通用户 ``huatai`` 使用 ``ctr`` 命令操作就会报错:

.. literalinclude:: ../darwin-containers/darwin-containers_startup/pull_base_image_error
   :caption: 因为 ``containerd.sock`` 访问权限不足报错

检查 ``/var/run/containerd/containerd.sock`` 就可以看到这个 ``sock`` 文件可以通过 ``wheel`` 组身份访问。那么我们就需要通过以下命令来将自己( ``huatai`` )加入到用户组 ``wheel`` :

.. literalinclude:: ../darwin-containers/darwin-containers_startup/groupadd_wheel
   :caption: 将自己 ``huatai`` 加入到用户组 ``wheel``

常用的用户账号 ``dscl`` 操作
==============================

- 添加用户 ``luser`` 案例:

.. literalinclude:: macos_user_account_cmd/adduser
   :caption: 在macOS中命令行添加用户

参考
========

- `How do I create user accounts from the Terminal in Mac OS X 10.5? <https://serverfault.com/questions/20702/how-do-i-create-user-accounts-from-the-terminal-in-mac-os-x-10-5?_gl=1*1ib1yw6*_ga*MTM5NTUzNzYwNi4xNzI2NzU1MTA0*_ga_S812YQPLT2*MTczNjY3Mjk1OS4xOC4wLjE3MzY2NzI5NTkuMC4wLjA.>`_
