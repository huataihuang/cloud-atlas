.. _linux_jail_init_rocky:

===============================
Linux Jail初始化(Rocky Linux)
===============================

:ref:`linux_jail_rocky-base` 构建了基于 :ref:`rockylinux` 的Linux Jail，部署完成后进行包环境管理以及安装必要 :ref:`devops` 和开发环境

- 更新:

.. literalinclude:: linux_jail_rocky-base/update
   :caption: 更新系统

- 安装 ``config-manager`` 插件(用于管理后续仓库配置):

.. literalinclude:: linux_jail_rocky-base/config-manager
   :caption: 安装 ``config-manager`` 插件

- 激活 ``CodeReady Linux Builder (CRB)`` 仓库，这个CRB仓库包含了扩展库以及开发工具，默认已经包含在 Rocky Linux 9中，但是默认没有激活:

.. literalinclude:: linux_jail_rocky-base/crb
   :caption: 激活 ``CodeReady Linux Builder (CRB)`` 仓库

- 激活 ``epel-release`` 仓库， ``Extra Packages for Enterprise Linux (EPEL)`` 是Fedora项目的企业用户软件仓库，包括了大量软件(epel仓库的Chromium浏览器依赖上述CRB仓库的库):

.. literalinclude:: linux_jail_rocky-base/epel
   :caption: 激活 ``epel-release`` 仓库

- 安装 RPM Fusion Free 仓库:

.. literalinclude:: linux_jail_rocky-base/rpmfusion
   :caption: 安装 RPM Fusion Free 仓库

- 安装 RPM Fusion Non-Free 仓库:

.. literalinclude:: linux_jail_rocky-base/rpmfusion_non-free
   :caption: 安装 RPM Fusion Non-Free 仓库

检查 rpmfusion 安装情况:

.. literalinclude:: linux_jail_rocky-base/rpmfusion_verify
   :caption: 检查 rpmfusion 安装情况

显示输出

.. literalinclude:: linux_jail_rocky-base/rpmfusion_verify_output
   :caption: 检查 rpmfusion 安装情况输出

- 执行核心升级:

.. literalinclude:: linux_jail_rocky-base/update_core
   :caption: 升级Rocky Linux核心

- 最后修改 ``dnf.conf`` 允许最大5个并发下载:

.. literalinclude:: linux_jail_rocky-base/dnf.conf
   :caption: 允许5个并发dnf下载

- 执行dnf升级

.. literalinclude:: linux_jail_rocky-base/update
   :caption: 更新系统

参考
======

- `Davinci Resolve install on Freebsd using an Rocky Linux Jail <https://github.com/NapoleonWils0n/davinci-resolve-freebsd-jail-rocky>`_
- `Rocky Linux 9 minimal jail working, need to figure out the next steps <https://forums.freebsd.org/threads/rocky-linux-9-minimal-jail-working-need-to-figure-out-the-next-steps.94933/>`_
