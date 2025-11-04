.. _openssh_2fa:

==============================================
OpenSSH双因素认证(two factor authentication)
==============================================

我在阿里工作的时候，SSH服务器登录都需要使用一次性密码(a Time-based One Time Password, TOTP)。最初是使用RSA公司的密钥棒，后来阿里自己开发了阿里郎软件来完成这个步骤。后续在对外的阿里云服务也采用这种双因素认证加强安全。

现在互联网服务普遍采用了双因素认证，例如GitHub。对于我们日常维护企业的SSH服务器，也可以通过软件方式来实现双因素认证加强安全。

安装OpenSSH
=================



参考
======

- `HOWTO OpenSSH 2FA with password and Google Authenticator <https://wiki.alpinelinux.org/wiki/HOWTO_OpenSSH_2FA_with_password_and_Google_Authenticator>`_
