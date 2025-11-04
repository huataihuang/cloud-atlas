.. _debian_ssh:

=========================
Debian环境设置ssh服务
=========================

- 安装 ``openssh-server`` :

.. literalinclude:: debian_ssh/install
   :caption: 在debian中安装 ``oepnssh-server``

- (可选)如果是 :ref:`distrobox_debian_ssh` 环境，可能需要修订 ``/etc/ssh/sshd_config`` 使得 ``sshd`` 监听不同端口以避免和Host主机sshd端口或其他容器sshd端口冲突:

.. literalinclude:: debian_ssh/sshd_config
   :caption: 调整容器中 ``sshd`` 服务端口

- 容器内启动服务使用 ``openrc`` 的 ``service`` 命令:

.. literalinclude:: debian_ssh/service_ssh
   :caption: 容器内启动sshd
