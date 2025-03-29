.. _openssh_legacy_options:

====================
OpenSSH 遗留选项
====================

OpenSSH实现了标准SSH实现的所有兼容加密算法，但是由于一些旧算法被发现强度较弱，所以默认不会激活。

当SSH客户端连接到服务器时，双方都会列出连接的参数，即以下 ssh_config 关键字:

- ``KexAlgorithms`` : 用于生成每个连接密钥的密钥交换方式
- ``HostkeyAlgorithms`` : 针对SSH客户端用于接受SSH服务器认证的公钥算法
- ``Ciphers`` : 加密连接的密码
- ``MACs`` : 检测流量篡改的消息认证码

要实现成功连接，上述每个参数的多个可选项中至少有一个选项是双方支持选择的

如果客户端和服务器不能协商连接参数，对于OpenSSH 7.0及以上版本，会出现一个错误消息类似::

   Unable to negotiate with legacyhost: no matching key exchange method found.
   Their offer: diffie-hellman-group1-sha1

这意味着服务器端采用了默认没有激活的遗留选项，需要通过客户端配置来激活遗留选项，才能顺利访问SSH服务器

上述案例中，客户端和服务器不能协商密钥交换算法，服务器只提供了单一的 ``diffie-hellman-group1-sha1`` 方式，虽然OpenSSH支持这种方式，但是由于该算法强度弱且存在Logjam攻击理论可能性，所以OpenSSH默认没有开启支持。

在用户认证过程中有一系列相关选项:

- ``PubkeyAcceptedKeyTypes``  (ssh/sshd) : 公钥算法是客户端发起尝试，由服务器接受的公钥认证(例如，通过 ``.ssh/authorized_keys`` 公钥认证)
- ``HostbasedKeyTypes`` (ssh) 和 ``HostbasedAcceptedKeyTypes`` (sshd) : 密钥类型由客户端发起尝试，然后由服务器接受基于主机的认证(例如，通过 ``.rhosts`` 或 ``.shosts`` )

在认证过程中客户端和服务器不匹配会导致认证失败，例如上面的案例就是密钥交换协商失败，此时需要采用::

   ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 user@legacyhost

或则在 ``~/.ssh/config`` 配置中添加::

   Host somehost.example.org
       KexAlgorithms +diffie-hellman-group1-sha1

这里使用了 ``+`` 表示不是取代默认的密钥交换算法，而是 **附加**  。这样只要服务器升级支持更好的加密密钥交换算法就会自动使用更好更强的密钥交换算法。

其他的遗留支持选项还有类似主机认证，可能出现如下提示::

   Unable to negotiate with legacyhost: no matching host key type found. Their offer: ssh-dss

OpenSSH 7.0以及更高版本也是默认禁止了 ``ssh-dss(DSA)`` 公钥算法，因为这个算法太孱弱，建议不要使用。当然也和上文类似，我们可以临时支持::

   ssh -oHostKeyAlgorithms=+ssh-dss user@legacyhost

也有配置方法 ``~/.ssh/config`` ::

   Host somehost.example.org
       HostKeyAlgorithms +ssh-dss

OpenSSH提供命令参数 ``-Q`` 可以查询服务器支持的算法::

   ssh -Q cipher       # List supported ciphers
   ssh -Q mac          # List supported MACs
   ssh -Q key          # List supported public key types
   ssh -Q kex          # List supported key exchange algorithms

举例::

   ssh -Q cipher myserver

可能看到输出::

   3des-cbc
   aes128-cbc
   aes192-cbc
   aes256-cbc
   aes128-ctr
   aes192-ctr
   aes256-ctr
   aes128-gcm@openssh.com
   aes256-gcm@openssh.com
   chacha20-poly1305@openssh.com

通过使用 ``-G`` 参数可能可以列出所有实际用于连接ssh服务器使用的配置，包括选择的 ``Ciphers`` , ``MACs`` , ``HostKeyAlgorithms`` 和 ``KexAlgorithms`` 参数::

   ssh -G user@myserver

参考
======

- `OpenSSH Legacy Options <https://www.openssh.com/legacy.html>`_
