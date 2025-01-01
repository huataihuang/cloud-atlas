.. _intro_freebsd_jail:

===========================
FreeBSD Jail概要
===========================

FreeBSD Jail是一个增强FreeBSD系统安全性的工具，自FreeBSD 4.x开始，Jail在可用性、性能、可靠性和安全性方面不断改进。

Jail是基于 ``chroot`` 原理来稿件，用于更改一组进程的根目录(root directory)，这样就能够创建一个与系统中其余部分分离的安全环境。在 ``chroot`` 环境中创建的进程无法访问外部文件或资源，所以入侵chroot环境中运行的服务不允许攻击者危害整个系统。

Jail改进了 ``chroot`` 的安全性:

- 通过虚拟化低文件系统、用户集和网络子系统来增强扩展 ``chroot`` 的简单模型
- 使用更精细的控制来控制Jail环境的访问权限

Jail类型
==========

:ref:`freebsd_thick_jail`
------------------------------

Thick Jail(厚Jail)是传统形式的Jail: 在Thick Jail中，基本系统被完整复制到Jail环境中:

Thick Jail有独立的FreeBSD基本系统，包括库、可执行文件和配置文件，可以视为一个几乎完整的独立FreeBSD安装，具有以下优点:

- 具有高度隔离性: Thick Jail内的进程和主机系统以及其他Jail之间是隔离的
- 独立性: Thick Jail 可以拥有与主机系统或其他Jail不同版本的库、配置和软件
- 安全性: 由于Thick Jail有自己独立的基本系统，影响Jail环境的漏洞或问题不会直接影响主机或其他Jail

Thick Jail的缺点也和其完整基本系统有关:

- 资源开销大: 由于每个Jail都维护自己独立的基础系统，所以比Thin Jail占用更多资源
- 维护成本高: 每个Thick Jail都要单独维护和更新

:ref:`freebsd_thin_jail`
-----------------------------

Thin Jail(薄Jail)使用OpenZFS快照或者NullFS挂载从模板共享基础系统，这样每个Thin Jail仅复制基础系统的最小子集:

Thin Jail的优点和其共享一个基础系统有关:

- 节约资源: Thin Jail不需要为每个Jail复制基础系统，所以占用磁盘空间和内存较少，这也使得在同一个硬件上运行更多Jail成为可能(遥想十几年前，我曾经维护过BSD家族的Sun :ref:`solaris` 系统，当时Solaris的zone技术就是类似的容器技术，号称可以在一台服务器上运行4000个zone)
- 更快的部署: Thin Jail创建和启动非常块，可以快速部署大量实例
- 统一维护: Thin Jail与主机系统共享大部分基础系统(如库和二进制文件)，所以只需要在主机上进行依次更新和维护共享的基础系统组件就可以升级所有依赖的Thin Jail系统
- 共享资源: Thin Jail可以与主机系统共享常见的资源，如库和二进制文件，可以带来更高效的磁盘缓存和Jail内应用程序的性能改善

Thin Jail的缺点:

- 隔离性降低: 由于共享模板基础部分会同时影响多个Jail的漏洞和问题
- 安全问题: 一个Thin Jail出现安全异常会影响其他Jail或主机系统
- 依赖冲突: 如果多个容器需要不同的本本的相同库或软件，则管理依赖关系会很复杂，例如确保兼容就很困难

:ref:`freebsd_service_jail`
------------------------------

Service Jail是FreeBSD 15开始引入的新型Jail，这种Service Jail和主机系统共享完整的文件系统树(也就是Service Jail的root路径就是主机的 ``/`` )，因此Service Jail可以访问和修改主机上的任何文件，并与主机共享相同的用户帐号。

默认情况下Service Jail不能访问Jail限制的网络或其他资源，但那可以配置为重用(re-use)主机的网络并删除一些Jail限制。Service Jail的使用案例是自动将 services/daemons 限制在一个配置最少，并且无需知道此类 service/daemon 的所需文件。

.. note::

   简单来说(以我的理解)就是Service Jail就相当与一个沙箱，是udi进程的Jail，但是不提供文件系统限制。也就是说，是一个去除文件系统限制功能的弱化的容器。

   目前我使用的FreeBSD 14.x 还不具备Service Jail，所以等以后再实践

:ref:`freebsd_vnet_jail`
----------------------------

FreeBSD VNET Jail是一种 **虚拟化** 环境，对其中运行的进程的网络资源进行隔离和控制:

- 通过对VNET Jail创建单独的网络堆栈，确保Jail内网络流量与主机系统和其他Jail隔离
- 确保高级别网络隔离和安全性
- 可以为VNET Jail创建成 :ref:`freebsd_thick_jail` 或 :ref:`freebsd_thin_jail` 

VNET Jail是一种专门针对网络的Jail，可以补充 ``thick jail`` 和 ``thin jail`` 的不足

:ref:`freebsd_linux_jail`
------------------------------

Linux Jail允许在Jail中运行Linux二进制程序，通过引入 :ref:`linuxulator` 兼容层，可以让某些Linux系统调用和库转换在FreeBSD内核上执行。Linux Jail的目的是不需要单独的Linux虚拟机或者环境情况下，在FreeBSD上执行Linux软件。

参考
=======

- `FreeBSD Handbook: Chapter 17. Jails and Containers <https://docs.freebsd.org/en/books/handbook/jails/>`_
- `FreeBSD Handbook中文版: 第 17 章 Jails 和容器 <https://free.bsd-doc.org/zh-cn/books/handbook/jails/#thick-jails>`_
