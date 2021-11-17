.. _sudo:

=================
sudo
=================

`sudo工具 <https://en.wikipedia.org/wiki/Sudo>`_ 是Linux/Unix系统上非常常用的命令：通常我们日常工作会采用一个普通账号，例如，个人账号 ``huatai`` 或者标记为管理员的 ``admin`` 账号，而仅在需要超级权限的时候切换到 ``root`` 身份执行命令。这样可以降低重大误操作的概率。

``sudo`` 可以切换到指定用户身份进行一些操作，以下是一些常用案例。

账号管理配置文件 ``/etc/sudoers``
==================================

``/etc/sudoers`` 对普通用户不可读取（系统默认设置文件权限是 ``440`` ），其中包含了不同账号切换的配置，即可以用密码认证后切换，也可以设置无需密码切换。该配置文件有很详细的注释，通常我们需要设置的场景在这个配置文件中都有案例和说明。

以另一个用户身份及其环境执行shell脚本
=====================================

shell脚本的执行和用户环境有密切关联，所以切换到另外一个用户的账号执行shell，不仅要切换权限，而且要切换执行环境：

-  ``-H`` - ``-H`` 表示 ``HOME`` ，这个选项和策略相关，有可能是默认特性，表示使用米标账号的HOME环境。
-  ``-u user`` - 这个 ``-u`` 表示 ``user`` ，则以指定用户账号来运行脚本，通常用用户名作为参数，也可以使用 ``uid`` 。在使用 ``uid`` 时候，很多shell要求在 ``uid`` 之前加上 ``#`` 以及转义符 ``\`` 。

::

   sudo -u \#501 ls -lh /home/huatai/

..

   上例是 ``admin`` 用户临时使用 ``huatai`` 用户（ ``uid=501`` ）身份查看其HOME目录内容。

sudo的密码参数
==============

对于sudo执行时需要密码的情况，如果需要在脚本命令中执行，显然无法手工输入密码。此时需要采用

::

   echo <password> | sudo -S <command>

例如

::

   ./configure && make && echo <password> | sudo -S make install && halt

另外还有一种更好的加入sudo密码的方法参考 `How to supply sudo with password from script? <https://stackoverflow.com/questions/24892382/how-to-supply-sudo-with-password-from-script>`_ ，不需要使用管道符号，更方便编写脚本

.. code:: bash

   sudo -S < <(echo "<password>") pouch ps

使用sudo密码参数的方法非常适合远程使用pssh执行需要root权限的脚本：

.. code:: bash

   pssh -p 50 -l <username> -h host_ip 'sudo -S < <(echo "<password>") /path/script.sh' | tee -a script.log

..

   有一种不需要sudo密码的方法执行应用程序，是将应用程序 ``chmod +s`` ，但是，这种方式如果脚本中包含的执行程序没有同样处理的话，还是不能完整以root身份执行，所以只能作为备用手段。

sudoers文件配置
===============

在 ``/etc/sudoers`` 配置文件中添加以下行可以不用密码执行(举例，用户名huatai)

::

   huatai ALL=(ALL) NOPASSWD:ALL

如何修订 ``/etc/sudoers`` 配置呢？ 系统提供了一个 ``visudo`` 工具，可以用来在脚本中添加行内容

.. code:: bash

   echo 'foobar ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo

参考
====

-  `Run a shell script as another user that has no password <https://askubuntu.com/questions/294736/run-a-shell-script-as-another-user-that-has-no-password>`_
-  `sudo with password in one command line? <https://superuser.com/questions/67765/sudo-with-password-in-one-command-line>`_
-  `How do I edit /etc/sudoers from a script? <https://stackoverflow.com/questions/323957/how-do-i-edit-etc-sudoers-from-a-script>`_
