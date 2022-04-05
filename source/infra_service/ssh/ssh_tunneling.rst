.. _ssh_tunneling:

=================
SSH隧道
=================

SSH Tunneling (SSH隧道)也称为SSH port forwarding(SSH端口转发)，这是一个非常有用的工具，可以实现类似 :ref:`squid_socks_peer` 架构中穿透GFW实现多级代理，也可以用一条简单SSH命令(VPN)实现自由翻墙。

SSH提供了一种通过端口转发，可以在SSH智商实现任何TCP/IP端口隧道，也就是应用数据流被定向到加密的SSH连接中，以避免传输过程中被拦截或解密。这种SSH tunneling方式也使得原本不支持加密通讯的应用程序实现了网络加密。

.. figure:: ../../_static/infra_service/ssh/ssh_tunneling_secure_app.png
   :scale: 25

SSH命令行端口转发
===================

我在 :ref:`priv_cloud_infra` 中需要访问 :ref:`hpe_dl360_gen9` 服务器的带外管理 :ref:`hp_ilo` ，带外管理采用内部IP地址 ``192.168.6.254`` 。要访问这个内部IP地址的 ``443`` 端口才能够访问 :ref:`hp_ilo` 的WEB管理界面。

我采用了旁路的 :ref:`jetson_nano` 构建SSH端口转发，即 ssh 到 jetson nano 主机上，在这个SSH会话中启用SSH端口转发::

   ssh -L 25443:192.168.6.254:443 -N -f huatai@192.168.7.23

这样，当 ``ssh`` 到 ``192.168.7.23`` 上时，本地主机访问本机回环地址 ``127.0.0.1`` 的 ``25443`` 端口，就会被SSH tunneling通过 ``192.168.7.23`` 转发到远程 ``192.168.6.254`` 的 ``443`` 端口::

   MyDesktop 127.0.0.1:25443 => ssh tunneling => 192.168.7.23 => data forwarding => 192.168.6.254:443

.. note::

   上述SSH命令还使用了2个有用的参数:

   - ``-N`` 不执行远程命令
   - ``-f`` 将ssh命令运行在后台

上述 ``ssh `` 命令输入参数较多，可以通过本地笔记本上的ssh配置文件 ``~/.ssh/config`` 来完成:

.. literalinclude:: ssh_tunneling/ssh_config
   :language: bash
   :caption: ~/.ssh/config 配置SSH端口转发

这样实现SSH端口转发只需要简单执行::

   ssh jetson

.. note::

   上述配置中共配置了2个端口转发

此外，在配置头部加上 :ref:`ssh_multiplexing` 配置，更是如虎添翼，一次ssh登陆就可以保持SSH tunneling持续:

.. literalinclude:: ssh_multiplexing/ssh_config
   :language: bash
   :caption: ~/.ssh/config 配置所有主机登陆激活ssh multiplexing,压缩以及不检查服务器SSH key(注意风险控制)

多目标主机端口转发
========================

上述SSSH端口转发是针对一台目标主机的端口转发，实际上SSH端口转发可以在一次SSH登陆时同时完成多台目标主机的端口转发。也就是登陆一台堡垒主机，就可以通过不同的端口来访问内网的不同服务器。

举例，在内网中有多台MySQL服务器，每个MySQL服务器都对外使用 ``3306`` 端口提供服务，则可以使用以下命令同时开启端口转发::

   ssh -L 33061:db1:3306 3306:db01:3306 3308:db02:3306 user@gateway

同样，简单配置一个 ``~/.ssh/config`` ::

   Host multi-db
       HostName gateway
       LocalForward 33061 db1:3306
       LocalForward 33062 db2:3306
       LocalForward 33063 db3:3306

进阶
=======

SSH Tunneling有更为神奇和强大的能力:

- :ref:`ssh_tunneling_remote_port_forwarding` 将没有公网IP的内网主机对外提供服务
- :ref:`ssh_tunneling_dynamic_port_forwarding` 自由访问Internet的利器

参考
======

- `SSH Tunnel <https://www.ssh.com/academy/ssh/tunneling>`_
- `What Is SSH Port Forwarding, aka SSH Tunneling? <https://www.ssh.com/academy/ssh/tunneling>`_
- `SSH: More than secure shell <http://matt.might.net/articles/ssh-hacks/>`_
- `How to Set up SSH Tunneling (Port Forwarding) <https://linuxize.com/post/how-to-setup-ssh-tunneling/>`_
