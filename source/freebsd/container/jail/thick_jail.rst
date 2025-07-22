.. _thick_jail:

=======================
FreeBSD Thick(厚) Jail
=======================

为方便调整，我设置了环境变量来方便后续操作

.. literalinclude:: vnet_thin_jail/env
   :caption: 设置 jail目录和release版本环境变量

原则上，一个 jail 只需要一个主机名、一个根目录、一个 IP 地址和一个用户空间。

- 下载用户空间:

.. literalinclude:: vnet_thin_jail/fetch
   :caption: 下载用户空间

- 解压缩到jail目录:

.. literalinclude:: thick_jail/bsd
   :caption: 解压缩到jail目录( ``bsd`` 命名)

- jail目录内容就绪以后，需要复制时区和DNS配置文件:

.. literalinclude:: thick_jail/conf
   :caption: 复制复制时区和DNS配置文件

- 更新最新补丁:

.. literalinclude:: thick_jail/update
   :caption: 更新jail

- 配置名为 ``bsd`` 的Thick Jail

.. literalinclude:: jail_host/jail.conf
   :caption: 在 ``/etc/jail.conf`` 中添加一行配置来包含所有在 ``/etc/jail.conf.d/`` 目录下以 ``.conf`` 结尾的配置

.. literalinclude:: thick_jail/bsd.conf
   :caption: 在 ``/etc/jail.conf.d`` 目录下添加 ``bsd.conf`` 配置

- 启动名为 ``bsd`` 的 Thick Jail:

.. literalinclude:: thick_jail/start
   :caption: 启动名为 ``bsd`` 的Thick Jail
