.. _check_linux_version:

==========================
检查Linux操作系统版本
==========================

我在使用 :ref:`fedora` 作为自己的开发工作环境，不过时间久了，你也能会像我一样忘记当初部署的Linux具体版本，可能需要检查一下，所以就有了本文的实践记录，方便后续 :ref:`upgrade_fedora_lastest_version` 。

.. note::

   主流的Linux发行版，如 Red Hat Enterprise Linux / CentOS / Fedora ，以及 Debian / Ubuntu 都采用了统一的版本记录方式，所以本文检查方法是通用的，在 Fedora 35 和 Ubuntu 22.04 上验证

检查Linux OS版本
=================

- Fedora / Ubuntu 都提供了 ``/etc/os-release`` 文件记录了详细的Linux操作系统版本，通常直接观察这个文件内容就可以获得主机操作系统的详细信息。举例:

.. literalinclude:: check_linux_version/fedora_os-release
   :language: bash
   :caption: Fedora 35 /etc/os-release

.. literalinclude:: check_linux_version/ubuntu_os-release
   :language: bash
   :caption: Ubuntu 22.04 /etc/os-release

- Ubuntu发行版还提供了一个 ``lsb_release`` 命令，通常能够快速检查一些OS的重点信息::

   lsb_release -a

输出信息案例:

.. literalinclude:: check_linux_version/ubuntu_lsb_release_-a_output
   :language: bash
   :caption: Ubuntu 22.04 lsb_release -a输出信息

- 对于使用了 :ref:`systemd` 的发行版，systemd的工具 :ref:`hostnamectl` 可以提供精炼的主机信息，只需要简单执行不带任何参数的命令::

   hostnamectl

Fedora 35的输出信息案例:

.. literalinclude:: ../systemd/hostnamectl/fedora_hostnamectl_output
   :language: bash
   :caption: Fedora 35 执行hostnamectl输出信息

在 :ref:`hpe_dl360_gen9` 上运行的 :ref:`ubuntu_linux` 执行 ``hostnamectl`` 输出案例:

.. literalinclude:: ../systemd/hostnamectl/ubuntu_hostnamectl_output
   :language: bash
   :caption: Ubuntu 22.04 hostnamectl 执行输出信息

参考
======

- `How to check os version in Linux command line <https://www.cyberciti.biz/faq/how-to-check-os-version-in-linux-command-line/>`_
