.. _jail_admin:

===========================
管理Jail
===========================

- 列出主机上运行的jails:

.. literalinclude:: jail_admin/jls
   :caption: 列出运行的jails

输出类似:

.. literalinclude:: jail_admin/jls_output
   :caption: 列出运行的jails输出举例

另外， ``--libxo`` 参数可以通过 ``libxo`` 库显示其他类型格式，如 ``JSON`` , ``HTML`` 等

显示 ``JSON`` 格式输出:

.. literalinclude:: jail_admin/jls_json
   :caption: ``JSON`` 格式列出运行的jails

则输出内容为JSON格式，方便使用程序自动化处理:

.. literalinclude:: jail_admin/jls_json_output
   :caption: ``JSON`` 格式列出运行的jails

- 启动和停止jail- 使用 ``service`` 命令:

.. literalinclude:: jail_admin/jail_start
   :caption: 启动jail

.. literalinclude:: jail_admin/jail_stop
   :caption: 停止jail

- 访问jail:

.. literalinclude:: jail_admin/jexec
   :caption: 访问 ``dev`` jail

此时会看到进入了容器，并且可以执行基本操作:

.. literalinclude:: jail_admin/jexec_inside
   :caption:  ``dev`` jail 内部
   :emphasize-lines: 2,5,7

- 可以在host主机上操作jail内部运行服务:

.. literalinclude:: jail_admin/jexec_service
   :caption: 在host主机上操作jail内部服务(这里举例启动 ``dev`` 内部的sshd服务)

- 在Host主机上使用 ``pkg`` 可以指定jail进行安装软件包，但是需要注意 ``-j`` 参数指定jail名字:

.. literalinclude:: jail_admin/pkg
   :caption: 在jail内部安装sudo

.. note::

   为方便登录jail容器，执行 :ref:`jail_init` 构建一个ssh登录，admin用户使用的开发环境

- 在创建好 ``dev`` jail 内部帐号 ``admin`` 之后，就可以使用该站搞 ``jexec`` 进入容器:

.. literalinclude:: jail_admin/jexec_admin
   :caption: 以 ``admin`` 访问 ``dev`` jail

