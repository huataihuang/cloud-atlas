.. _priv_ssh:

======================
私有云SSH访问
======================

SSH密钥
===========

为保障服务器安全，现代SSH服务部署应该关闭密码认证登陆，只允许 :ref:`ssh_key` 认证登陆:

- 修订服务器/虚拟机(模版) ``/etc/ssh/sshd_config`` 配置::

   PasswordAuthentication no
   PermitRootLogin prohibit-password

- 使用 ``ssh-keygen`` 命令生成密钥对::

   ssh-keygen -t rsa

.. note::

   输入密钥保护密码

- 将生成的 ``~/.ssh/id_rsa.pub`` 公钥复制到服务器 ``~/.ssh/`` (对于我而言是 ``/home/huatai/.ssh`` 目录) 目录下 ``authroized_keys`` 文件保存，并配置服务器上对应配置文件及目录正确权限::

   chown -R huatai:wheel ~/.ssh
   chmod 700 .ssh
   chmod 600 .ssh/authorized_keys

- 验证登陆::

   ssh huatai@server_ip

确保只使用密钥登陆服务器

- 为方便和快速登陆服务器，使用 ``ssh-agent`` 来确保只需要输入一次密钥保护密码: 修订本地客户端 ``~/.bashrc`` 添加如下代码:

.. literalinclude:: priv_ssh/bashrc
   :language: bash
   :caption: 在用户 ~/.bashrc 中配置 ssh-agent

这样，只有第一次打开终端提示输入密钥密码，后续都会缓存在 ``ssh-agent`` 中，就不需要重复输入保护密码

穿透访问后端SSH服务器
======================

在 :ref:`priv_kvm` 构建了不同的开发环境和测试环境虚拟机，例如 ``z-dev`` 是用来做开发的虚拟机，其IP地址是内网IP地址 ``192.168.6.253`` 。而日常工作，可能不能时时连接内部局域网，需要从外网访问时，为了方便，需要做端口转发，方便直接访问虚拟机的ssh服务(而无需转跳)。此时，比较简单的方法是使用 :ref:`iptables_port_forwarding` ，而优雅方法是采用 :ref:`ssh_proxycommand` 。

.. literalinclude:: priv_ssh/config
   :language: bash
   :caption: 用户目录配置SSH ~/.ssh/config

- 上述配置中启用了 ``ProxyCommand`` 可以通过转跳中间SSH服务器( ``10.10.1.200`` )，直接访问后端内网SSH服务器 ``192.168.6.253`` ( ``z-dev`` ) ，结合前文 ``ssh-agent`` 方便运维。
- 上述配置中还启用了 :ref:`ssh_multiplexing` 加速SSH访问，以及启用了SSH的压缩功能(降低网络带宽占用)
