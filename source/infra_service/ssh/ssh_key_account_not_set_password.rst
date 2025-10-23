.. _ssh_key_account_not_set_password:

===============================
账号未设置密码时的ssh密钥登陆
===============================

我在制作 :ref:`alpine_docker_image` 发现和其他发行版不同的是: 启用ssh后的容器，即使配置了公钥也无法使用密钥登陆。

这个问题折腾了好久，我最初以为是卷绑定的属主问题，反复对比验证。最后偶然发现，只要给用户账号设置一个密码，就立即能够使用密钥登陆了。这说明密钥对没有配置错，账号的 ``~/.ssh`` 目录及相关密钥文件的属主也是正确的，

问题就聚焦到 ``sshd`` 服务配置上，哪个参数导致了没有设置密码的账号无法用密钥登陆(即使密钥正确)?

:ref:`alpine_linux` 的默认 ``/etc/sshd_config`` 配置有如下内容说明(默认注释就是sshd默认配置):

.. literalinclude:: ssh_key_account_not_set_password/sshd_config_password
   :caption: 默认 ``/etc/ssh/sshd_config``

这说明在Alpine Linux上sshd默认允许密码登陆

但是对于Linux系统来说，一个新创建的账号如果没有通过 ``passwd`` 设置密码，账号初始是锁定(locked)状态的。这就导致了 ``ssh`` 密钥也无法使用

解决方法比较简单，就是给用户账号配置一个密码。不过，对于Docker容器来说，给用户账号配置密码不是好方法，最好还是通过ssh密钥登陆。所以，实际上在 :ref:`alpine_docker_image` 实践中，我是通过调整 ``/etc/ssh/sshd_config`` 配置，修订成和 :ref:`debian` 等系统一样的默认只允许密钥登陆，就能够解决这个问题:

.. literalinclude:: ssh_key_account_not_set_password/sshd_config_key
   :caption: 修订 ``/etc/ssh/sshd_config`` 关闭密码登陆，此时密钥登陆就无需设置用户密码
   :emphasize-lines: 3


参考
======

- `How to unlock account for public key ssh authorization, but not for password authorization? <https://unix.stackexchange.com/questions/193066/how-to-unlock-account-for-public-key-ssh-authorization-but-not-for-password-aut>`_
