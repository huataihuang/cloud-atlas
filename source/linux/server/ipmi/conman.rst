.. _conman:

===============
conman串口管理
===============

.. note::

   我已经介绍了 :ref:`use_ipmi` 通过带外管理服务器，不过使用ipmitool对本机操作通常只能管理单台服务器，使用 ``ipmitool`` 网络命令也存在操作繁琐，并且最主要缺少一种对大规模集群并发监控串口控制台输出的能力。

   ``conman`` 就是一种对集群串口进行并发串口控制台日志采集以及远程控制的ipmi增强工具。

conman简介
============

``conman`` 是一个串口控制管理程序，用于支持大量的控制台，不仅支持本地串口设备，也支持远程terminal服务器。结合IPMI协议，对大量服务器的串口日志进行采集，方便进行日志分析管理。并且 ``conman`` 结合IPMI Sol方式，可以远程对服务器进行串口控制台操作，实现sysrq magic组合键获取内核core dump。

`caonman官方网站 <https://github.com/dun/conman>`_

Escape（逃脱）字符
====================

Escape字符是非常重要的字符，用于向串口发送特殊组合命令，以实现类似 ``sysrq`` 这样的magic按键组合。

``conman`` 默认的Escape字符是 ``&``

重要的控制台字符：

- ``&B`` 向控制台发送 ``serial-break`` 字符，这个字符组合特定指令可以实现sysrq
- ``&.`` 断开conman连接
- ``&?`` 显示可用的escapes字符

通过conman实现sysrq
--------------------

.. note::

   实际上也可以通过ipmi Serial over LAN来实现： 使用以下命令构建ipmi Serial over LAN连接到服务器串口::

      ipmitool -U [user] -P [password] -H [ip/hostname of bmc] -I lanplus sol activate

然后依次执行如下组合键 - 注意：大写字幕 ``B`` 表示 ``serial-break`` 字符，也就是前面所说的对于conman就是同时按下 ``&B`` 。例如，这里 ``Bc`` 就是表示先同时按下 ``&B`` ，然后放开按键，马上按一下 ``c`` ，就能够 **触发crash dump**

* ``Bt`` - 生成堆栈跟踪
* ``Bm`` - 打印内存状态，特别是在out of memory情况，特别需要此项信息
* ``Bc`` - 触发crash dump

.. note::

   操作系统必须激活 ``sysrq`` 功能才能使得上述操作生效，否则会提示 ``SysRq : This sysrq operation is disabled.`` 。请事先在操作系统执行以下命令使得sysrq功能生效::

      sysctl kernel.sysrq=1

conman设置案例
===================

服务器配置启用内核串口设置
-----------------------------

对于RHEL/CentOS操作系统， ``/etc/sysconfig/grub`` 设置了串口输出配置::

   GRUB_CMDLINE_LINUX="crashkernel=auto console=ttyS0,115200n8"

然后执行以下指令生成grub启动配置::

   grub2-mkconfig -o /boot/grub2/grub.cfg

重启服务器后，控制台将输出到串口。

安装conman
----------------

RHEL/CentOS 发行版已经包含了 ``conman`` 软件包::

   sudo yum install conman -y

配置conman的简单案例
----------------------

请参考 :ref:`quick_config_ipmi` 设置BMC访问管理账号和管理IP地址。conman将通过IPMI协议访问服务器的串口控制台。

安装 ``conman`` 软件包之后 ``/etc/conman.conf`` 是默认的配置文档，包含了大量的配置案例。

详细的设置可以参考 `conman设置案例（日文） <https://shachimaru.wiki.fc2.com/wiki/conman>`_

- 修改配置 ``/etc/conman.conf``

.. literalinclude:: conman/conman.conf
   :language: bash
   :linenos:
   :caption:

- ``/etc/conman.pswd`` - 这个配置文件是 ``conman`` 存储每个服务器对应的IPMI账号密码的文件，对于某些IDC环境，可能每台服务器设置不同的IPMI访问密码（第一列是访问IP，第二列是访问账号，第三列是访问密码），就可以使用这个配置文件::

   192.168.1.10 : admin : password0
   192.168.1.11 : admin : password1
   192.168.1.12 : admin : password2
   ...

解析：

- ``server`` 指令是设置 ``conman`` 的基本配置参数，包括存储日志目录，core目录，以及时间戳等
- ``global`` 表示所有 ``console`` 指令都会包含的公共参数，其中 ``global log="%N.log"`` 表示所有服务器的日志文件都按照 ``名字.log`` 来记录，也就是 ``console name="server-0" ...`` 记录的服务器 ``192.168.1.10`` 串口日志将按照命名记录为 ``server-0.log`` ，并且存储在 ``/var/log/conman`` 目录下。
- 每一行 ``console ...`` 表示连接到一台服务器的串口。注意，每个 ``name=xxxx`` 表示conman的一个对象命名。启动conman服务之后，就可以通过这个命令连接到对应服务器的IPMI sol接口。即要连接 ``192.168.1.10`` 的IPMI sol，只需要输入命令 ``conman server-0`` 就可以实现。

- 启动 ``conman`` 服务::

   systemctl start conman

启动后请使用命令 ``systemctl status conman`` 检查服务状态

启动服务后，可以看到系统中有conman服务对应进程::

   /usr/sbin/conmand -c /etc/conman.conf
   /usr/bin/expect -f /usr/share/conman/exec/ipmitool.exp 192.168.1.10 admin
   ipmitool -e & -I lanplus -H 192.168.1.10 -U admin -a sol activate

可以看到，实际上 ``conman`` 巧妙的使用了 ``expect`` 工具来实现和服务器IPMI交互

conman大规模案例
==================

当需要监控IDC机房海量服务器的串口时，单纯启动一个 ``conman`` 服务进程是无法将负载分担到服务器的多处理器上。类似nginx配置，我们会针对服务器的CPU核心数启动相应数量的 ``conman`` 服务。例如，针对64核心的服务器，启动64个 ``conman`` 服务进程，每个服务进程负责数百台服务器的串口日志采集。这样，一台服务器可以充分发挥硬件性能，监控数千台甚至上万服务器。

注意每个 ``conman`` 服务器需要使用 ``-p <端口号>`` 分别使用不同端口，避免冲突(可以编写脚本批量启动)::


   /usr/sbin/conmand -c conman_192.168.1.1_7900.conf -p 7900
   /usr/sbin/conmand -c conman_192.168.1.1_7901.conf -p 7901
   /usr/sbin/conmand -c conman_192.168.1.1_7902.conf -p 7902
   ...

每个配置文件，分别对应一批被监控服务器(这里案例假设使用admin账号，密码password)，以下是 ``conman_192.168.1.1_7900.conf`` 配置举例:

.. literalinclude:: conman/conman_192.168.1.1_7900.conf
   :language: bash
   :linenos:
   :caption:

上述 ``global`` 配置提供了共用的IPMI访问账号密码，但是同时也有部分服务器有自己特定的访问密码，例如 ``server-2`` 就使用密码 ``test_pass``

简化版本conman配置
---------------------

.. literalinclude:: conman/conman_simple.conf
   :language: bash
   :linenos:
   :caption:

参考
======

- `conman(1) - Linux man page <https://linux.die.net/man/1/conman>`_
- `sysrq via ipmi Serial over LAN <https://support.hpe.com/hpsc/doc/public/display?docId=emr_na-sg456en_us&docLocale=en_US>`_
- `conman设置案例（日文） <https://shachimaru.wiki.fc2.com/wiki/conman>`_
