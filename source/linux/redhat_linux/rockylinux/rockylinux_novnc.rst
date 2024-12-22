.. _rockylinux_novnc:

=======================
Rocky Linux noVNC
=======================

我在 :ref:`archlinux_novnc` 实践了一个简单的 ``X11vnc+noVNC`` 桌面，现在则尝试在Rocky Linux(类似CentOS)构建一个远程VNC桌面。

安装VNC服务器
=================

- 安装桌面，我使用 :ref:`xfce` :

.. literalinclude:: rockylinux_novnc/install_xfce
   :caption: 安装 :ref:`xfce` 桌面

- 安装TigerVNC服务器:

.. literalinclude:: rockylinux_novnc/install_tigervnc
   :caption: 安装TigerVNC服务器

- 如果运行了firewalld，则需要允许VNC服务(这步我没有执行，因为我是通过 :ref:`ssh_tunneling` 来访问服务):

.. literalinclude:: rockylinux_novnc/firewalld
   :caption: 配置firewalld允许访问VNC

- ( **这段废弃** 我实践发现 `Desktop Environment : Configure VNC Server <https://www.server-world.info/en/note?os=CentOS_Stream_9&p=desktop&f=2>`_ 提供的 ``vncsession.te`` 转换的 ``vncsession.pp`` 无法通过，始终报下面这个错误) 系统 :ref:`enable_selinux` ，则需要添加策略(必要步骤，因为TigerVNC的 :ref:`systemd` 服务启动依赖SELinux获取用户home目录，见下文):

.. literalinclude:: rockylinux_novnc/selinux
   :caption: 配置SELinux策略(验证失败)

我检查了阿里云的Rocky Linux镜像安装的云主机，发现 ``/etc/selinux/config`` 中配置的 ``SELINUX=disabled`` ，不激活执行上述命令会出现错误:

.. literalinclude:: rockylinux_novnc/selinux_error
   :caption: 配置SELinux策略错误(没有激活SELinux的话)

- ( ``更新`` 参考 `Tigervnc server not starting up in centos 8 #1189 <https://github.com/TigerVNC/tigervnc/issues/1189>`_ 完成SELinux配置 ):

.. literalinclude:: rockylinux_novnc/selinux_fix
   :caption: 配置SELinux策略(成功)

- 配置TigerVNC的 :ref:`systemd` Unit:

.. literalinclude:: rockylinux_novnc/tigervnc_systemd
   :caption: 配置TigerVNC的 :ref:`systemd` Unit

.. note::

   实践验证配置 ``~/.vnc/config`` 无效，所以还是采用修订 ``/etc/tigervnc/vncserver-config-defaults``

这里我遇到一个启动报错，检查日志:

.. literalinclude:: rockylinux_novnc/tigervnc_systemd_error
   :caption: 启动Tiger VNC server报错

参考 `VNC service does not start when user home directory is in a custom path <https://access.redhat.com/solutions/7060135>`_  原来 tigervnc 实现原生 :ref:`systemd` 支持，服务是通过 ``vncsession`` 启动，而 ``vncsession`` 是通过特定的SELinux上下文来获得用户目录的

**乌龙了** 我配置错 ``/etc/tigervnc/vncserver.users`` ，我的系统只设置了 ``admin`` 用户，没有配置 ``huatai`` 用户，所以导致了上述服务启动错误。前面启用SELinux的配置可能也可以取消

安装noVNC
============

- 安装

.. literalinclude:: rockylinux_novnc/install_novnc
   :caption: 安装noVNC

- 启动

.. literalinclude:: rockylinux_novnc/novnc
   :caption: 启动noVNC

然后访问 https://127.0.0.1:8081 就可以看到onVNC登陆连接，认证通过之后，可以看到 Rocky Linux 桌面

参考
=======

- `Desktop Environment : Install VNC Client : noVNC <https://www.server-world.info/en/note?os=CentOS_Stream_9&p=desktop&f=5>`_
- `Desktop Environment : Configure VNC Server <https://www.server-world.info/en/note?os=CentOS_Stream_9&p=desktop&f=2>`_
- `Not able to open applications in XFCE via VNC (22.04) <https://www.reddit.com/r/linuxquestions/comments/1b8vse6/not_able_to_open_applications_in_xfce_via_vnc_2204/>`_
- `Editing ~/.vnc/xstartup to launch Xfce on VNC server <https://askubuntu.com/questions/645176/editing-vnc-xstartup-to-launch-xfce-on-vnc-server>`_
- `How to Install XFCE Desktop in RHEL, Rocky Linux & AlmaLinux <https://www.tecmint.com/install-xfce-in-rhel-rocky-linux-almalinux/>`_
- `How to Configure XFCE on CentOS 7.9 <https://cloudnodelab.azurewebsites.net/how-to-install-xfce-on-centos-7-9/>`_ 使用了 ``yum groupinstall "Server with GUI" -y`` 来安装图形用户接口软件包，其他相同
- `How to Install and Configure VNC on Ubuntu Server 22.04 <https://www.linuxbuzz.com/install-configure-vnc-ubuntu-server/#google_vignette>`_
