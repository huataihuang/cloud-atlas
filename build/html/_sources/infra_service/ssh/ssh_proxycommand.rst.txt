.. _ssh_proxycommand:

============================================
SSH ProxyCommand实现穿透主机访问后端服务器
============================================

我在构建 :ref:`priv_cloud_infra` 时，尝试在物理主机 ``zcloud`` 上构建 :ref:`squid_ssh_proxy` 访问虚拟化内部局域网的VM。不过，实践发现，传统的 ``nc`` 构建将SSH访问转发给 :ref:`squid` 方法比较陈旧，实际上我并没有最终解决这个代理方式访问SSH。不过， ``openssh`` 最新版本已经内置了代理转发功能，已经不再需要 ``nc`` 来完成流量转发，而可以直接访问中间代理 SSH 服务器，从而实现穿透主机访问后端服务器。

SSH代理命令依然是 ``ProxyCommand`` ，使用方法有所不同::

   ssh <target_server> -o "ProxyCommand ssh -W %h:%p <jump_server>"

举例::

   ssh 192.168.6.253 -o "ProxyCommand ssh -W %h:%p 10.10.1.200"

就可以实现通过跳板服务器 ``10.10.1.200`` 直接SSH登陆 ``192.168.6.253``

上述命令参数也可以配置在 ``~/.ssh/config`` 中::

   Host z-dev
      HostName 192.168.6.253
      User huatai
      ProxyCommand ssh -W %h:%p 10.10.1.200

则直接::

   ssh z-dev

就可以登陆到后端服务器:

- 注意: 需要输入2次服务器登陆密码或者2次 :ref:`ssh_key` ，分别是中间转跳服务器认证和目标服务器认证

- ``scp`` 命令也可以使用上述配置的 ``ProxyCommand`` ，所以向 ``z-dev`` 上 ``scp`` 复制文件也非常方便::

   scp file z-dev:/home/huatai/

结合 ``ssh-agent``
=====================

为了方便实现穿透访问后端SSH服务器，结合 :ref:`ssh_key` 的 ``ssh-agent`` 可以不需要重复输入密码或者密钥密码

.. literalinclude:: ssh_proxycommand/zssh.sh
   :language: bash
   :caption:

使用 ``ssh-agent`` 缓存了密钥密码之后，只需要执行上述脚本命令(从配置文件中读取出ip和主机名，提取IP，跳板SSH服务器IP从 ``/etc/hosts`` 中获取)::

   zssh.sh z-dev

ProxyJump
============

和 ``ProxyCommand`` 类似的还有一个SSH指令是 ``ProxyJump`` 使用方法类似::

   scp -o "ProxyJump <User>@<Proxy-Server>" <File-Name> <User>@<Destination-Server>:<Destination-Path>

参考
=======

- `SSH ProxyCommand example: Going through one host to reach another server <https://www.cyberciti.biz/faq/linux-unix-ssh-proxycommand-passing-through-one-host-gateway-server/>`_
- `4 ways to SSH & SCP via proxy (jump) server in Linux <https://www.golinuxcloud.com/ssh-proxy/>`_
