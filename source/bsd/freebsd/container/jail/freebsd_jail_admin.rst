.. _freebsd_jail_admin:

===========================
FreeBSD Jail管理
===========================

- 列出主机上运行的jails:

.. literalinclude:: freebsd_jail_admin/jls
   :caption: 列出运行的jails

输出类似:

.. literalinclude:: freebsd_jail_admin/jls_output
   :caption: 列出运行的jails输出举例

另外， ``--libxo`` 参数可以通过 ``libxo`` 库显示其他类型格式，如 ``JSON`` , ``HTML`` 等

显示 ``JSON`` 格式输出:

.. literalinclude:: freebsd_jail_admin/jls_json
   :caption: ``JSON`` 格式列出运行的jails

- 启动和停止jail- 使用 ``service`` 命令:

.. literalinclude:: freebsd_jail_admin/jail_start_stop
   :caption: 启动和停止jail

- 访问jail:

.. literalinclude:: freebsd_jail_admin/jexec
   :caption: 访问 ``dev`` jail

此时会看到进入了容器，并且可以执行基本操作:

.. literalinclude:: freebsd_jail_admin/jexec_inside
   :caption:  ``dev`` jail 内部
   :emphasize-lines: 2,5,7

- 可以在host主机上操作jail内部运行服务:

.. literalinclude:: freebsd_jail_admin/jexec_service
   :caption: 在host主机上操作jail内部服务(这里举例启动 ``dev`` 内部的sshd服务)

- 在Host主机上使用 ``pkg`` 可以指定jail进行安装软件包，但是需要注意 ``-j`` 参数指定jail名字:

.. literalinclude:: freebsd_jail_admin/pkg
   :caption: 在jail内部安装sudo

- 在 ``dev`` jail中创建用户组和用户 admin:

.. literalinclude:: freebsd_jail_admin/user
   :caption: 在jail内部创建admin

在 ``dev`` 主机的用户 ``admin`` 添加ssh key，现在就可以像普通虚拟机一样远程ssh登录到容器内部了
