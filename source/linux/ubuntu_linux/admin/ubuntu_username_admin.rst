.. _ubuntu_username_admin:

========================
Ubuntu系统admin用户名
========================

在Ubuntu安装过程中，有一个创建用户帐号的步骤，也就是创建一个可以通过 ``sudo`` 切换为 ``root`` 的用户帐号。但是，因为在某些Linux预设中 ``admin`` 是一个保留的系统组名，所以安装程序不允许创建 ``admin`` 帐号。

但是，我在 :ref:`freebsd` 以及 :ref:`redhat_linux` 中通常都设置一个 ``admin`` 帐号来作为日常用户帐号，不仅通用而且明确是用于可以通过 ``sudo`` 升级为 ``root`` 的特定帐号。

例如，在FreeBSD系统中，我使用  ``admin`` 帐号的id如下:

.. literalinclude:: ubuntu_username_admin/admin_id
   :caption: 在FreeBSD中当前admin用户的id

而对比Ubuntu系统，当前我在Installer过程中创建的 ``huatai`` 帐号的id如下:

.. literalinclude:: ubuntu_username_admin/huatai_id
   :caption: 在Ubuntu中当前huatai用户的id

可以看到其实两者用户的id是完全一致的(uid/gid都是1000)，差别仅在名字上(强迫症不能忍)，所以调整Ubuntu的用户名相对比较简单。

- 激活 ``root`` 登录: ``sudo passwd root`` ，这样确保能够只使用root登录系统，完全在系统中退出 ``huatai`` 帐号就能够修改名字

- 如果通过 :ref:`ssh` 远程登录系统，还需要配置 ``/etc/ssh/sshd_config`` 确保 ``PermitRootLogin`` 设置正确(默认是 ``prohibit-password`` )，也就是需要为root用户添加密钥认证，以便能够远程登录

- 先确保 ``root`` 用户能够登录系统(本地或ssh)，然后退出所有以 ``huatai`` 用户登录的会话:

.. literalinclude:: ubuntu_username_admin/pkill
   :caption: 在root用户直接登录的会话里面杀掉所有huatai的会话

- 修改组名:

.. literalinclude:: ubuntu_username_admin/groupmod
   :caption: 修改组名

- 修改用户名以及HOME目录: 会同步修改 ``/etc/passwd`` 中登录名，并将 ``/home/huatai`` 重命名为 ``/home/admin``

.. literalinclude:: ubuntu_username_admin/usermod
   :caption: 修改用户名

- (可选)修改用户的Full Name:

.. literalinclude:: ubuntu_username_admin/chfn
   :caption: 修改用户的Full Name

- 其他需要检查:

.. literalinclude:: ubuntu_username_admin/check
   :caption: 需要对系统做一些检查，确保不因为修改用户名影响运行
