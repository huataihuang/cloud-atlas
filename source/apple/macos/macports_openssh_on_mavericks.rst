.. _macports_openssh_on_mavericks:

=======================================
在Mavericks上使用Macports安装OpenSSH
=======================================

准备
======

Mavericks(OS X 10.9)作为古老的macOS，首先需要完成 :ref:`macports_on_mavericks`

安装
======

- 搜索可以安装的软件

.. literalinclude:: macports_openssh_on_mavericks/search
   :caption: 搜索openssh

输出类似:

.. literalinclude:: macports_openssh_on_mavericks/search_output
   :caption: 搜索openssh的输出信息

- 安装

.. literalinclude:: macports_openssh_on_mavericks/install
   :caption: 安装openssh

配置
=======

MacPorts 将新版 OpenSSH 安装到 ``/opt/local/`` 目录下:

- 客户端命令 (ssh, scp, sftp 等)：位于 ``/opt/local/bin/``
- 服务端程序 (sshd)：位于 ``/opt/local/sbin/``
- 配置文件：位于 ``/opt/local/etc/ssh/``

替换客户端
-----------------

默认情况下，系统优先调用 ``/usr/bin/ssh`` 。只需确保 MacPorts 的路径位于环境变量最前端即可:

.. literalinclude:: macports_openssh_on_mavericks/bash_profile
   :caption: 配置用户 ``~/.bash_profile``

刷新环境变量并验证版本:

.. literalinclude:: macports_openssh_on_mavericks/env
   :caption: 环境变量

替换服务端
----------------

Mavericks 的 sshd 服务由 ``launchd`` 通过配置文件 ``/System/Library/LaunchDaemons/ssh.plist`` 管理。需要将启动路径指向 MacPorts 的 sshd。

- 关闭系统自带的远程登录服务

在 系统偏好设置 (System Preferences) -> 共享 (Sharing) 中，取消勾选 ``远程登录 (Remote Login)`` 。

或者在终端中直接停止原服务:

.. literalinclude:: macports_openssh_on_mavericks/stop_sshd
   :caption: 在终端中直接停止ssh服务

- 备份并修改系统的 launchd 配置文件 ``/System/Library/LaunchDaemons/ssh.plist``

在文件中找到 ``<key>ProgramArguments</key>`` 这一段，将 ``/usr/libexec/sshd-keygen-wrapper`` 替换为 MacPorts 的 sshd 路径 ``/opt/local/sbin/sshd`` :

.. literalinclude:: macports_openssh_on_mavericks/ssh.plist
   :caption: 修改sshd运行路径
   :language: xml

- 初始化 MacPorts 的 SSH 密钥与配置

在首次启动新版 ``sshd`` 前，需要生成主机密钥并确认配置

.. literalinclude:: macports_openssh_on_mavericks/sshd_config
   :caption: 生成主机密钥并确认配

- 重新加载并启动 SSH 服务

.. literalinclude:: macports_openssh_on_mavericks/launchctl_load
   :caption: 重新加载ssh服务

也可以直接回到 ``系统偏好设置 -> 共享`` ，重新勾选"远程登录 (Remote Login)"

参考
======

- gemini
