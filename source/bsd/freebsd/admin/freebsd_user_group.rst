.. _freebsd_user_group:

=========================
FreeBSD user/group管理
=========================

FreeBSD管理用户帐号的命令和Linux有些不同，这里做一些总结和实践记录

账户类型
============

- 系统账户: 系统账户用于运行诸如DNS,邮件和Web服务器等服务，主要是出于安全考虑避免使用超级用户身份运行

  - ``nobody`` 是一个通用的非特权系统账户；但是如果大量服务都以 ``nobody`` 运行，则无形中该账户的特权也就越高

- 用户账户: 用户账户分配给真实的人，并用于登录和使用系统

  - ``Login class`` : 登录分级是组(group)机制的扩展，提供了额外的灵活性
  - ``Password change time`` 和 ``Account expiration time`` 增强了账户安全性

- 超级用户账户: 超级用户账户通常被称为 root ，用于无限制地管理系统。因此，不应将其用于日常任务，如发送和接收邮件、系统的一般探索或编程。

  - 通过 ``su`` 称为超级用户的用户帐号必须位于 ``wheel`` 组，且必须知道 ``root`` 帐号密码

帐号管理工具
=============

- ``adduser`` 交互命令创建帐号
- ``chpass`` 交互命令更改用户帐号配置
- ``rmuser`` 交互命令删除用户帐号(会同时删除用户的at,crontab作业，向用户拥有的所有进程发送SIGKILL信号，删除用户目录等，是非常干净的清理)

``pw`` 超级帐号工具
---------------------

``pw`` 是FreeBSD环境超级强大的帐号管理工具，可以用来添加组，添加用户等等:

.. literalinclude:: ../container/jail/freebsd_jail_admin/user
   :caption: 在jail内部创建admin

参考
======

- `Adding user/group in a FreeBSD server <http://blog.serverbuddies.com/adding-usergroup-in-a-freebsd-server/>`_
- `FreeBSD Handbook中文版: 3.3. 用户和基本账户管理 <https://free.bsd-doc.org/zh-cn/books/handbook/basics/#users-synopsis>`_
- `Managing FreeBSD Users and Groups <https://ryanwinter.org/manage-users-and-groups-in-freebsd/>`_ 一些案例
