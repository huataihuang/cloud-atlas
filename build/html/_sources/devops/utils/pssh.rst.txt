.. _pssh:

=================
pssh - 并行SSH
=================

在维护集群时，常常需要在大量服务器上执行相同的命令，虽然可以自己写循环执行脚本，但是不仅麻烦而且执行效率不高。此时我们通常会使用pssh工具来并发执行SSH指令。

我个人觉得pssh是每个SA的必备工具，非常适合需要执行少量应急命令的情况。但是，这个强大的并行命令也是双刃剑，执行效率太高也会使得误操作影响面扩大。所以，一定要谨慎操作，并且我强烈建议在测试环境做好演练，同时review操作命令，注意检查判断逻辑。

可行的情况下，还是以执行脚本来完成操作，pssh仅作为批量分发脚本以及批量执行脚本check脚本执行结果为好。因为脚本相对容易避免转义符号冲突，也方便检查代码。

.. note::

   pssh是早期在Python 2上开发的工具，最早开源在google code上，后来代码库搬迁到github `robinbowes/pssh <https://github.com/robinbowes/pssh>`_ 已经很久没有更新了(最后更新是2012年)，甚至在 `pssh · PyPI <https://pypi.org/project/pssh>`_ 也没有说明这个软件包在Python 3上运行是存在兼容问题的。不过，Github上 `lilydjwg/pssh <https://github.com/lilydjwg/pssh>`_ 提供了兼容Python 3的修正。

安装pssh
=========

Ubuntu安装pssh
-----------------

在Ubuntu上通过安装 ``pssh`` 软件包可以完成安装，但是直接执行 ``pssh`` 命令会提示无法找到指令。实际上Ubuntu安装 ``pssh`` 软件包后实际的执行程序是采用了 ``parallel-`` 开头的命令，例如 ``parallel-ssh`` 和 ``parallel-scp`` 等。所以，为了方便使用，可以建立软链接::

   cd /usr/bin
   sudo ln -s parallel-ssh pssh
   sudo ln -s parallel-scp pscp
   sudo ln -s parallel-rsync prsync
   sudo ln -s parallel-nuke pnuke
   sudo ln -s parallel-slurp pslurp

CentOS安装mpssh
-----------------

CentOS可以使用EPEL安装pssh，但是现在(CentOS 8)只提供MPSSH(Mass Parallel Secure Shell)来并发执行SSH::

   dnf --enablerepo=epel -y install mpssh

使用方法和pssh类似，但是没有提供 ``-A`` 参数，所以只能使用密钥认证，无法使用密码认证。这个问题我主要通过复用ssh连接方式解决，即在 ``~/.ssh/config`` 中添加配置::

   Host *
       ServerAliveInterval 60
       StrictHostKeyChecking no
       # 以下3行配置提供了ssh复用，即只需要登陆一次服务器，后续ssh登陆将基于第一次登陆的通道
       ControlMaster auto
       ControlPath ~/.ssh/%h-%p-%r
       ControlPersist yes

然后执行一次循环ssh登陆建立连接(因为ssh命令提供了传递密码的方法)::

   for i in `cat host`;do sshpass <password> ssh <username>@$i uptime;done

之后就可以通过 ``mpssh`` 并发执行ssh命令。

通过pip安装(推荐使用这个通用方法安装)
----------------------------------------

pssh实际上是一个python程序，所以可以通过 Python pip方式安装。通过pip安装可以用于Python 2环境通用，而且，通过Python virtualenv方式，可以自主在个人用户目录下安装，非常方便。

::

   # 如果是RHEL/CentOS则使用以下yum安装命令
   yum install python-pip
   # 如果是Debian/Ubuntu则使用以下apt安装命令
   apt install python-pip

   # 通过pip安装pssh
   pip install pssh

.. note::

   我在Python 3的virtualenv中通过pip安装了pssh之后，执行报错::

      Traceback (most recent call last):
        File "/Users/huatai/venv3/bin/pssh", line 26, in <module>
          from psshlib.cli import common_parser, common_defaults
        File "/Users/huatai/venv3/lib/python3.7/site-packages/psshlib/cli.py", line 9, in <module>
          import version
      ModuleNotFoundError: No module named 'version'

参考 `pssh的安装和问题 <https://blog.csdn.net/wjzholmes/article/details/102239639>`_ 改为使用 Python 2的virtualenv环境就可以解决。

命令说明
==========

.. list-table:: pssh命令说明
   :widths: 25 50
   :header-rows: 1

   * - 命令
     - 说明
   * - pssh
     - 并行在多个远程主机上执行ssh命令
   * - pscp
     - 并行从多个主机上复制文件
   * - prsync
     - 并行从多个主机使用rsync同步文件
   * - pnuke
     - 并行在多个主机上杀死进程
   * - pslurp
     - 并行在多个主机上复制文件到一个中心主机上

使用pssh指令
===============

- 首先创建一个hosts文件，名字可以按需设置，例如，我要访问ceph集群，则创建 ``ceph-hosts`` 配置文件，内容如下::

   172.18.0.11
   172.18.0.12
   172.18.0.13
   172.18.0.14
   172.18.0.15
  
如果SSH端口不同，可以在主机ip后面加上端口号，例如 ``172.18.0.11:2222`` 表示该主机的SSH访问端口是 ``2222``

- 常用参数

.. list-table:: pssh命令参数
   :widths: 25 50
   :header-rows: 1

   * - 参数
     - 说明
   * - ``-h``
     - 主机名列表文件
   * - ``-l``
     - 登陆用户名，例如 ``-l root``
   * - ``-A``
     - 提供统一的登陆密码
   * - ``-i``
     - 交互模式，远程服务器的命令执行结果会输出

举例::

   pssh -ih ceph-hosts -l root -A "uptime"

pssh使用的tips
===================

忽略服务器密钥
-----------------

在批量处理主机时，如果需要每个服务器都确认服务器密钥是不现实的，这里就需要使用ssh的一个参数 ``-O StrictHostKeyChecking=no`` ，这个参数也可以传递给pssh::

   pssh -O StrictHostKeyChecking=no -ih hosts_ip -l huatai -A "uptime"

忽略错误密码
-------------

对于部分主机密码错误，我们希望直接跳过错误密码的节点，可以使用ssh的批处理模式 ``BatchMode=yes`` ，可以配置在用户的 ``~/.ssh/config`` 中，这样执行pssh命令可以直接忽略错误密码的节点。

终端tty
-------

在pssh执行 ``sudo`` 命令时候，会出现报错::

   ...
   [14] 14:45:00 [FAILURE] 192.168.1.11 Exited with error code 1
   Stderr: sudo: no tty present and no askpass program specified
   ...

这个报错在ssh远程执行sudo命令时候也会遇到，原因是远程执行强制的基于screen的程序时，需要使用 ``-t`` 参数来分配一个tty，即使ssh没有本地tty。不过，我没有找到如何把这个参数传递给pssh的方法，所以遇到这个问题，我暂时使用循环方式使用ssh命令。举例::

   for i in `cat host`;do ssh -t huatai@$i "echo PASSWORD | sudo -S cp /tmp/my_script.sh /usr/local/bin/my_script.sh";done

.. note::

   这里远程服务器sudo需要输入密码，采用了通过管道向sudo传输密码的方法，此时 sudo 需要使用参数 ``-S`` 从 ``stdin`` 获取密码。

使用ssh密钥登陆
-----------------

对于使用SSH密钥的登陆方式，需要使用参数 ``-x`` 来使用扩展ssh参数指定密钥登陆，举例::

   pssh -i -h list_of_hosts \
   -x "-oStrictHostKeyChecking=no  -i /home/xxx/.ssh/ec2.pem" 'uptime'

也可以在 ``~/.ssh/config`` 指定扩展参数，例如::

   Host *.eu-west-1.compute.amazonaws.com
       StrictHostKeyChecking no
       IdentityFile ~/.ssh/ec2.pem

密码保护的密钥
----------------

.. note::

   最好的方法还是采用 keychain 来解决密钥认证，实际上就不需要使用 ``-x`` 参数来扩展。

对于密码保护的密钥，建议使用 keychain 来解决密码输入::

   sudo apt-get install keychain
   keychain ~/.ssh/id_rsa
   . ~/.keychain/$(uname -n)-sh

然后执行 pssh 指令就不再需要输入密钥保护密码了。

建议在 ``~/.bashrc`` 中添加以下内容，则每次终端登陆就只要输入一次密钥保护密码就可以::

   keychain --clear $HOME/.ssh/id_rsa
   . $HOME/.keychain/$(uname -n)-sh

参考
=====

- `Pssh – Execute Commands on Multiple Remote Linux Servers Using Single Terminal <https://www.tecmint.com/execute-commands-on-multiple-linux-servers-using-pssh/>`_
- `parallel-ssh <http://manpages.ubuntu.com/manpages/precise/man1/parallel-ssh.1.html>`_
- `pssh-howto.md <https://gist.github.com/carlessanagustin/c5e70c8edfa8408547545e26b61ab783>`_
- `parallel-ssh with Passphrase Protected SSH Key <https://unix.stackexchange.com/questions/128974/parallel-ssh-with-passphrase-protected-ssh-key>`_
