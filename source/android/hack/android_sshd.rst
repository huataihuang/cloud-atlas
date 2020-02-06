.. _android_sshd:

================
Android SSH服务
================

我在Android手机上安装运行SSH服务的原因是我想把Android手机作为一个超级移动Linux主机来使用，能够透明地检查Android上的服务和程序，方便传输数据。

Android上的sshd服务分为两类：

- 需要root之后才能安装使用，如 `DropBear Server II // ssh/scp (root only) <https://forum.xda-developers.com/showthread.php?t=2339152>`_
- 不需要root就可以安装使用，如 `SimpleSSHD <http://www.galexander.org/software/simplesshd/>`_

.. note::

   不需要root就能够使用的sshd服务，只能使用1024端口以上的监听端口，例如 SimpleSSHD 默认使用 2222 端口；此外，非root的sshd服务，登陆以后限制在个人目录沙箱下，权限不能看到整个系统的进程，只能作为简单的个人应用文件传输或转跳其他sshd服务。

SimpleSSHD
=============

SimpleSSHD是一个非常简洁的SSHD服务，可以直接从Google Play上安装，并且不需要root设备就可以运行。

首次启动SimpleSSHD，默认启动在端口 ``2222`` 上，这个SSH服务建议使用密钥登陆，但是，如果首次运行，还没有复制公钥到服务器端时，提供了一个简单的一次性密码登陆方式。当你使用 ``ssh user@<server_ip>`` 访问SimpleSSHD服务，由于程序第一次启动是开启了一个终端在前台运行，你会看到控制台在检测了没有密钥存在，就会提示::

   no authorized keys, generating sigle-use passwd:
   ------
   XXXXXX
   ------

这样，你就可以在客户端输入这个密码登陆到SimpleSSHD提供的个人用户系统中。

现在你可以把自己的公钥存放到 `~/authorized_keys` ::

   echo "ssh-rsa AAAAB3...." > authorized_keys

然后就可以无需密码登陆到SimpleSSHD系统中。

.. note::

   Android系统提供了一个内置的 ``/system/bin/ssh`` ，但是这个工具访问服务器，需要读写本地目录 ``/data/.ssh`` ，对于没有root系统的SimpleSSHD环境是没有权限的。所以会无法使用密钥对等。通过 ``adb`` 在

安装设置系统sshd
=================

.. note::

   实际上Android系统中已经内建了 sshd 应用，位于 ``/system/bin/sshd`` 只不过没有经过配置是无法使用的。你甚至不需要安装第三方sshd服务就可以使用。

- 由于Android系统限制，默认没有提供类似Linux的终端程序，所以我们首先需要使用 `TWRP <https://twrp.me>`_ root掉Android，然后安装一个名为 `SuperSU <https://supersuroot.org/>`_ 的工具来设置程序的root运行权限

.. note::

   详细的Android手机 root 方法，请参考 `How to Root Your Android Phone with SuperSU and TWRP <https://www.howtogeek.com/115297/how-to-root-your-android-why-you-might-want-to/>`_

- 在root过的手机上，安装 openconnect 客户端，翻墙，访问Google Play，安装 Terminal 终端程序，并且通过 SuperSU 授予该程序 root 运行权限，这样我们就可以通过 Termianl 直接执行 ``su`` 命令切换到root用户身份，则可以继续以下设置步骤。

- 在终端切换到 ``root`` 身份之后，首选需要将根目录重新挂载成 ``读写`` 模式（默认根目录是只读模式）::

   mount -o rw,remount

- 执行以下命令为 ``sshd`` 准备服务器证书::

   /usr/bin/ssh-keygen -A

.. note::

   出于安全需求，需要设置一个普通用户帐号，并且修改好系统的root用户帐号密码，避免安全漏洞。

- 创建 ``/.ssh`` 目录，然后从自己的笔记本电脑上 ``scp`` 过来服务器登陆公钥文件，存放到 ``/.ssh/authorized_keys`` ，这样就可以通过密钥登陆系统::

   scp huatai@192.168.1.1:/home/huatai/.ssh/idsa.pub /root/.ssh/authorized_keys

- 启动sshd服务::

   /system/bin/sshd

然后就可以远程登陆到Android系统中，实现一个完整的系统访问。


