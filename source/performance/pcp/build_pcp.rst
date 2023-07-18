.. _build_pcp:

===============================
编译Performance Co-Pilot(PCP)
===============================

和 :ref:`build_pcm` 一样，由于需要在遗留的CentOS 7.2环境构建最新的 Performance Co-Pilot(PCP) ，以实现高级功能:

- 服务器内核已经升级到 4.19 ，支持 :ref:`ebpf` ，所以目标是构建支持 :ref:`bpftrace` 的PCP

编译
======

- PCP源代码针对不同的操作系统和软件包组合，所以在编译前需要做一些调整
- 软件包依赖:

  - 硬构建依赖: 没有这些依赖PCP就无法从源代码完成古偶见，并且构建将在编译货打包过程中失败，如 gmake, autoconf, flex, bison ...
  - 可选构建依赖: 如果没有没有安装这些组件，则构建虽然能够完成，但生成的软件包可能古恶少一些功能，例如 扩展身份验证，安全连接，服务发现，REST API...
  - QA依赖: 可以忽略这些依赖，除非想运行(广泛的) PCP QA

- 强烈建议运行检查脚本:

.. literalinclude:: build_pcp/check-vm
   :caption: 首先运行检查系统的脚本

不过这个输出信息比较繁杂，所以可以改为使用以下命令精简输出(-b for basic packages, -f to not try to guess Python, Perl, ... version and -p to output just package names)，就能够获得系统需要安装哪些软件包来满足编译要求:

.. literalinclude:: build_pcp/check-vm_bfp
   :caption: 运行检查系统的脚本精简输出，获得系统需要安装的软件包名

输出如下:

.. literalinclude:: build_pcp/check-vm_bfp_output
   :caption: 运行检查系统的脚本输出结果

不过，对于CentOS 7.2，很多包并没有对应:

.. literalinclude:: build_pcp/check-vm_bfp_err
   :caption: CentOS 7,2尝试安装出错

所以实际补安装的软件包如下:

.. literalinclude:: build_pcp/centos7_install_packages
   :caption: CentOS 7,2补安装软件包

- 编译:

.. literalinclude:: build_pcp/makepkgs
   :caption: 编译PCP

错误排查
===========

``ERROR: No build ID note found``
------------------------------------

- 在执行 ``Makepkgs`` 报错:

.. literalinclude:: build_pcp/makepkgs_error1
   :caption: 编译PCP报错: 找不到build ID

实际检查可以看到，这些二进制执行文件都已经编译好了，例如 ``/home/huatai.huang/pcp/pcp-6.1.0/BUILDROOT/pcp-6.1.0-1.x86_64/usr/bin/pmlogger`` ，只不过

参考
======

- `pcp/INSTALL.md <https://github.com/performancecopilot/pcp/blob/main/INSTALL.md>`_
