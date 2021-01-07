.. _ipmi:

========================
IPMI(智能平台管理接口)
========================

概念
=====

IPMI(Intelligent Platform Management Interface, 智能平台管理接口)是提供完整监控和管理功能的标注话消息硬件管理接口，提供了本地和远程的安全方式。

- IPMI(Intelligent Platform Management Interface, 智能平台管理接口)
- BMC(Baseboard Management Controller，主板管理控制器)
- OpenIPMI驱动
- ipmitool
- IPMI watchdog timmer
- 基于IPMI的局域网串口（Serial Over LAN, SOL）

详细的有关 IPMI 规范，参考 `Intelligent Platform Management Interface Specifications <http://www.intel.com/design/servers/ipmi/spec.htm?cm_mc_uid=70380859151914472193504&cm_mc_sid_50200000=1459416301>`_

IPMI硬件和软件要求
===================

在Linux平台上要配置IPMI需要有 ``/dev/ipmi0`` 设备存在，如果缺少该设备， ``ipmitool`` 工具就无法工作。此时需要使用如下方法创建设备：

- 如果是SuSE，RedHat或CentOS执行(需要安装 ``OpenIPMI`` 工具包)::

   /etc/init.d/ipmi start

- 在Debian平台执行::

   modprobe ipmi_devintf
   modprobe impi_si

配置IPMI网络
=============

为了充分发挥IPMI的功能，例如可以通过带外管理IP地址远程管理服务器，需要为服务器配置IPMI网络(通常是服务器的第一块网卡集成了BMC，配置IP后可以远程带外管理)::

   ipmitool lan set 1 ipsrc static
   ipmitool lan set 1 ipaddr 192.168.1.211
   ipmitool lan set 1 netmask 255.255.255.0
   ipmitool lan set 1 defgw ipaddr 192.168.1.254
   ipmitool lan set 1 defgw macaddr 00:0e:0c:aa:8e:13
   ipmitool lan set 1 arp respond on
   ipmitool lan set 1 auth ADMIN MD5
   ipmitool lan set 1 access on

- 检查配置::

   ipmitool lan print 1

- 配置admin权限用户账号::

   ipmitool user set name 2 admin

出现报错::

   Set User Name command failed (user 2, name admin): Invalid data field in request

这是因为系统已经设置了一些帐号，已经占用了 ``2`` 这个序列号，并且已经设置为名字 ``admin``

可以通过以下命令检查系统中已经具有的帐号::

   ipmitool user list 1

这里 ``1`` 表示 ``channel 1``

显示输出::

   ID  Name     Callin  Link AuthIPMI Msg   Channel Pr      iv Limit
   1                    false   false      true       ADMINISTRATOR
   2   admin            false   false      true       ADMINISTRATOR
   3   tom              true    true       true       ADMINISTRATOR
   4   jerry            true    true       true       ADMINISTRATOR

所以我们将命令修改成::

   ipmitool user set name 5 jack

此时再次检查 ``ipmitool user list 1`` 就会看到::

   ID  Name     Callin  Link AuthIPMI Msg   Channel Priv Limi       t
   1                    false   false      true       ADMINISTRATOR
   2   admin            false   false      true       ADMINISTRATOR
   3   tom              true    true       true       ADMINISTRATOR
   4   jerry            true    true       true       ADMINISTRATOR
   5   jack             true    false      false      NO ACCESS

- 设置新增的 ``jack`` 用户的密码::

   ipmitool user set password 5

- 设置用户能够远程管理服务器::

   ipmitool channel setaccess 1 5 link=on ipmi=on callin=on privilege=4

- 此时再使用 ``ipmitool user list 1`` 可以看到用户 ``jack`` 已经具备了完全的帐号::

   ID  Name     Callin  Link AuthIPMI Msg   Channel Priv Lim        it
   ...
   5   jack           true    true       true       ADMINISTRATOR

- 激活用户帐号::

   ipmitool user enable 5

用户配置权限级别
==================

如果用户只允许查询传感器数据，需要设置特定权限。这样的用户没有权限操作服务器，例如，创建一个名为 ``monitor`` 的用户::

   ipmitool user set name 6 monitor
   ipmitool user set password 6
   ipmitool channel setaccess 1 6 link=on ipmi=on callin=on privilege=2
   ipmitool user enable 6

- 然后检查一下用户权限::

   ipmitool channel getaccess 1 6

显示输出如下::

   Maximum User IDs     : 10
   Enabled User IDs     : 4

   User ID              : 6
   User Name            : monitor
   Fixed Name           : No
   Access Available     : call-in / callback
   Link Authentication  : enabled
   IPMI Messaging       : enabled
   Privilege Level      : USER

- 查看访问权限对应的level，使用如下命令::

   ipmitool channel

可以看到输出::

   Possible privilege levels are:
      1   Callback level
      2   User level
      3   Operator level
      4   Administrator level
      5   OEM Proprietary level
     15   No access

上述创建的 ``monitor`` 用户被赋予 ``USER`` 权限。所以网络访问被授予该用户，需要网络访问的MD5授权给这个用户组（USER privilege level）::

   ipmitool lan set 1 auth USER MD5

- 列出通道用户::

   ipmitool lan print 1

显示输出类似如下::

   Set in Progress         : Set Complete
   Auth Type Support       : NONE MD5 PASSWORD 
   Auth Type Enable        : Callback : 
                           : User     : MD5 
                           : Operator : 
                           : Admin    : MD5 
                           : OEM      : 
   IP Address Source       : Static Address
   IP Address              : 192.168.1.211
   Subnet Mask             : 255.255.255.0
   MAC Address             : 00:0e:0c:ea:92:a2
   SNMP Community String   : 
   IP Header               : TTL=0x40 Flags=0x40 Precedence=0x00 TOS=0x10
   BMC ARP Control         : ARP Responses Enabled, Gratuitous ARP Disabled
   Gratituous ARP Intrvl   : 2.0 seconds
   Default Gateway IP      : 192.168.1.254
   Default Gateway MAC     : 00:0e:0c:aa:8e:13
   Backup Gateway IP       : 0.0.0.0
   Backup Gateway MAC      : 00:00:00:00:00:00
   RMCP+ Cipher Suites     : 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
   Cipher Suite Priv Max   : XXXXXXXXXXXXXXX
                           :     X=Cipher Suite Unused
                           :     c=CALLBACK
                           :     u=USER
                           :     o=OPERATOR
                           :     a=ADMIN
                           :     O=OEM

完成了基本配置以后，就可以进行下一步对服务器进行带外管理和IPMI操作了

IPMI使用
=========

远程访问
---------

IPMI不仅可以本机执行，也可以通过网络访问方式执行 ( ``-I lanplus`` ) ，这样即使服务器操作死机或crash，也可以通过带外管理(网络接口)访问主机，就好像在机房中直接访问物理服务器的键盘和显示器。

- 案例：远程访问终端::

   ipmitool -I lanplus -H IP  -U username -P password -E sol activate

远程访问控制台或者IPMI功能，都需要提供账号和密码(配置方法见上文)，同时必须指明使用网络方式访问 ``-I lanplus`` 。以下所有命令如果通过网络远程执行，都需要使用参数 ``-I lanplus -H IP  -U username -P password`` 。

- 重启服务器::

   ipmitool -I lanplus -H IP -U username -P password power reset

如果服务器可以ssh登陆，并且执行具有root权限，则可以不需要使用网络接口以及管理员账号，则上述命令可以简化为::

   ipmitool power reset

以下如果是登陆到服务器上并具有root权限，也都不需要 ``-I lanplus -H IP -U username -P password`` 。

常用IMPI功能
---------------

- 重启MC控制器

这个功能我个人认为是非常重要的指令：很多时候服务器厂商的BMC firmware存在bug，有可能无法正常工作。此时通过冷重启BMC控制器可以恢复IPMI功能。

::

   modprobe ipmi-devintf
   modprobe ipmi-si
   ipmitool mc reset cold

在系统级别变更后重启操作系统前，一定要确保带外能够正确访问终端，所以建议在操作系统中执行一次 ``mc reset cold`` ，然后在带外验证远程能够 ``ipmitool -I lanplus -H IP  -U username -P password -E sol activate`` 访问控制台，再做操作系统重启。

- 重启服务器

这是最常用都ipmi命令，通常服务器死机时候可通过 ``power reset`` 硬关机并重启::

   ipmitool -I lanplus -H IP -U username -P password power reset

- 远程访问终端

在服务器操作系统启动之前，物理服务器有一个硬件初始化过程，这部分信息通过IPMI访问可以完整观察到。此外，如果服务器出现内核crash，也会在串口终端输出信息。执行以下命令远程访问串口终端::

   ipmitool -I lanplus -H IP  -U username -P password -E sol activate

- 检查服务器sol日志（故障原因）

当物理服务器出现硬件故障，例如cpu，内存，板卡，风扇等。这些硬件日志都会记录在服务的SOL日志中，就可以通过以下命令检查::

   ipmitool -I lanplus -H IP  -U username sel list

   # 或者ssh登陆服务器主机Linux操作系统执行，root用户执行命令无需账号密码
   ipmitool sel list

IPMI配置服务器启动模式
========================

我们知道主机BIOS可以设置从CD-ROM, 硬盘 或者网络(PXE)启动，对于服务器而言，通过IPMI就可以实现远程设置启动顺序，这对服务器重装系统或者排查故障非常有用。

例如，在大规模数据中心，服务器都是通过PXE启动自动安装系统的。我们需要通过IPMI配置服务器从PXE启动进行操作系统安装。

设置服务器从PXE重启
---------------------

IPMI配置启动可以通过raw代码方式设置，也可以通过易于理解的命令方式。

- raw方式设置PXE启动::

   ipmitool raw 0x00 0x08 0x05 0x80 0x04 0x00 0x00 0x00

- 命令方式设置PXE启动::

   ipmitool chassis bootdev pxe
   ipmitool chassis bootparam set bootflag force_pxe

设置从默认的硬盘启动
---------------------

- raw方式设置硬盘启动::

   ipmitool raw 0x00 0x08 0x05 0x80 0x08 0x00 0x00 0x00

- 对应的命令行设置硬盘启动::

   ipmitool chassis bootdev disk
   ipmitool chassis bootparam set bootflag force_disk

设置从CD/DVD启动
---------------------

- raw方式设置CD/DVD启动::

   ipmitool raw 0x00 0x08 0x05 0x80 0x08 0x00 0x00 0x00

- 对应命令设置CD/DVD启动::

   ipmitool chassis bootdev cdrom
   ipmitool chassis bootparam set bootflag force_cdrom

设置强制启动进入BIOS设置
-------------------------

有时候我们需要强制系统重启进入BIOS，例如需要通过BIOS配置配置RAID卡、开启NUMA等等，以及做一些特殊的BIOS设置。

- 通过raw方式设置强制启动进入BIOS::

   ipmitool raw 0x00 0x08 0x05 0x80 0x18 0x00 0x00 0x00

- 对应命令设置进入BIOS::

   ipmitool chassis bootdev bios
   ipmitool chassis bootparam set bootflag force_bios

获取系统启动选项
==================

- 可以通过IPMI获取到系统启动选项::

   ipmitool raw 0x00 0x09 Data[1:3]

raw参数说明:

  - ``NetFn = Chassis (0x00h)``
  - ``CMD = 0x09h``

举例::

   ipmitool raw 0x00 0x09 0x05 0x00 0x00

输出::

    01 05 80 18 00 00 00
   Where,
   Response Data[5]
   0x00: No override
   0x04: Force PXE
   0x08: Force boot from default Hard-drive
   0x14: Force boot from default CD/DVD
   0x18: Force boot into BIOS setup

参考
=========

- `Using Intelligent Platform Management Interface (IPMI) <https://www.ibm.com/support/knowledgecenter/#!/linuxonibm/liaai/ipmi/ipmikick.htm>`_
- `IPMI-Chassis Device <https://github.com/erik-smit/oohhh-what-does-this-ipmi-doooo-no-deedee-nooooo/blob/master/1-discovering/snippets/Computercheese/IPMI-Chassis%20Device%20Commands.txt>`_
