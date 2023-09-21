.. _hp_utilities_ubuntu:

===================================
Ubuntu平台HP ProLiant服务器工具
===================================

:ref:`hp_ilo` 提供了对HP服务器的系统管理功能，在Linux上使用需要安装对应工具。

Service Pack for ProLiant
===========================

`HPE Software Delivery Repository: Service Pack for ProLiant (spp) <https://downloads.linux.hpe.com/SDR/project/spp/>`_ 只提供RedHat Linux和SUSE Linux Enterprise Linux的驱动和agent软件包，对于其他操作系统，需要使用 `HPE Software Delivery Repository: Management Component Pack <https://downloads.linux.hpe.com/SDR/project/mcp/>`_ 

Service Pack for ProLiant 是区分产品线的，需要根据硬件选择不同的 ``spp`` repo ，例如 ``spp-gen10`` , ``spp-gen9`` ... ，添加仓库配置 ``/etc/yum.repos.d/spp.repo`` 以后可以通过 ``yum`` 命令进行安装::

   [spp]
   name=Service Pack for ProLiant
   baseurl=http://downloads.linux.hpe.com/repo/spp-gen/rhel/dist_ver/arch/project_ver
   enabled=1
   gpgcheck=0
   gpgkey=file:///etc/pki/rpm-gpg/GPG-KEY-ServicePackforProLiant

这里参数按照以下修订::

   gen                       gen10, gen9, gen8, g7   (what's my gen?)
   dist_ver                  8.4, 8.3, 8.2, 8.1, 8.0, 7.9, 7.8, 7.7, 6.10, 6.9
   arch                      i386, x86_64  
   project_ver (gen9, gen10) current, next, 2020.05.0, 2020.09.0, 2020.03.0, 2019.12.0, 2019.09.0, 2019.03.0
   project_ver (gen8, G7)    current, gen8.1_hotfix9, g7.1_hotfix3, 2017.07.1, 2017.04.0, 2016.10.0, 2016.04.0

Management Component Pack
===========================

`HPE Software Delivery Repository: Management Component Pack <https://downloads.linux.hpe.com/SDR/project/mcp/>`_ 是Debian系列软件包。需要注意MCP和SPP不同，没有包括驱动和firmware。firmware是通过 `SUM <https://downloads.linux.hpe.com/SDR/project/hpsum>`_ 提供的，很不幸依然只有Red Hat 和SUSE，驱动是通过发行版提供。详细的操作系统支持见 `HPE SERVER OPERATING SYSTEMS AND VIRTUALIZATION SOFTWARE
<https://www.hpe.com/us/en/servers/server-operating-systems.html>`_

安装
========

- 添加apt源::

   echo "deb http://downloads.linux.hpe.com/SDR/repo/mcp bionic/current-gen9 non-free" | sudo tee /etc/apt/sources.list.d/mcp.list

.. note::

   我安装的是 ``Ubuntu 20.04.3 LTS`` 代号 ``focal`` ，但是MCP没有提供Ubuntu 20.04的Gen9系列服务器的软件，只能采用上一个 ``Ubuntu 18.04-LTS`` 对应代号 ``bionic`` 的仓库中软件包。其中提供了 ``current-gen10`` 和 ``current-gen9`` ，其中 ``current-gen9`` 是 ``10.80``

- 加入HPE的公钥::

   curl http://downloads.linux.hpe.com/SDR/hpPublicKey1024.pub | apt-key add -
   curl http://downloads.linux.hpe.com/SDR/hpPublicKey2048.pub | apt-key add -
   curl http://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub | apt-key add -
   curl http://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub | apt-key add -

- 更新apt源并安装软件工具::

   sudo apt update
   #sudo apt install hp-health hponcfg amsd ams ssacli ssaducli ssa
   sudo apt install hp-health hponcfg hp-ams

软件包列表位于 `HPE Software Delivery Repository: Management Component Pack <https://downloads.linux.hpe.com/SDR/project/mcp/>`_ 不过，部分软件包已经改名或不存在:

- hp-health    HPE System Health Application and Command line Utilities (Gen9 and earlier)
- hponcfg    HPE RILOE II/iLO online configuration utility
- amsd    HPE Agentless Management Service (Gen10 only)
- hp-ams    HPE Agentless Management Service (Gen9 and earlier)
- hp-snmp-agents    Insight Management SNMP Agents for HPE ProLiant Systems (Gen9 and earlier)
- hpsmh    HPE System Management Homepage (Gen9 and earlier)
- hp-smh-templates    HPE System Management Homepage Templates (Gen9 and earlier)
- ssacli    HPE Command Line Smart Storage Administration Utility
- ssaducli    HPE Command Line Smart Storage Administration Diagnostics
- ssa    HPE Array Smart Storage Administration Service
- storcli    MegaRAID command line interface

.. note::

   在 HPE ProLiant Gen10服务器， ``health/snmp`` 功能已经迁移到iLO卡上。这里的 ``hp-health`` ， ``snmp-agents`` ， ``hp-smh*`` 以及 ``hp-ams`` 的deb包只能安装到Gen9以及更早的服务器上。对于Gen10用户，需要配置 ``11.xx`` 或者 ``current`` 仓库，而 Gen9用户，则使用 ``10.xx`` 或更早版本。

.. note::

   我的 :ref:`hpe_dl360_gen9` 服务器没有安装HPE Flexible Smart Array或者Smart HBA卡，所以我不安装 ``ssa*`` 程序，也没有使用 ``storecli`` (MegaRAID卡)

.. note::

   iLO WEB管理平台在 ``System Information`` 中可以观察系统的状态，其中 ``Storage Information`` 依赖 ``Agentless Management Service`` ，所以需要安装 ``hp-ams`` ，这样才能显示监控页面

.. note::

   在升级Ubuntu 22.04之后， ``/etc/apt/sources.list.d/mcp.list`` 会自动配置关闭，看起来不再支持。此外，系统卸载了 ``hp-health`` ，原因似乎是::

      The following packages have unmet dependencies:
      hp-health : Depends: libc6-i686 but it is not installable or
                             lib32gcc1 but it is not installable

使用
=======

hp-health
------------

- 执行命令::

   sudo hpasmcli

进入交互模式，可以使用 ``help`` 查看帮助

- 显示服务器温度::

   show temp

输出显示::

   Sensor   Location              Temp       Threshold
   ------   --------              ----       ---------
   #1        AMBIENT              23C/73F    42C/107F
   #2        PROCESSOR_ZONE       40C/104F   70C/158F
   #3        PROCESSOR_ZONE       40C/104F   70C/158F
   ...

- ``hpasmcli`` 提供了 ``-s`` 参数可以执行脚本化命令(无需交互)::

   sudo hpasmcli -s "show temp"

hponcfg
---------

- ``hponcfg`` 提供了iLO online configuration 功能::

   hponcfg

帮助::

   hponcfg -h

可以尝试获取服务器信息::

   sudo hponcfg -g

输出类似::

   HP Lights-Out Online Configuration utility
   Version 5.3.0 Date 3/21/2018 (c) 2005,2018 Hewlett Packard Enterprise Development LP
   Firmware Revision = 2.22 Device type = iLO 4 Driver name = hpilo
   Host Information:
               Server Name:
               Server Serial Number: XXXXXXX

其他
------

其他还没有机会实践，后续有需要再更新

参考
======

- `Installing HP ProLiant Utilities on Ubuntu Server <https://blog.nathanv.me/posts/hp-utilities-ubuntu/>`_
- `HPE Software Delivery Repository: Management Component Pack <https://downloads.linux.hpe.com/SDR/project/mcp/>`_
