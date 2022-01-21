.. _z-dev:

===============
开发环境z-dev
===============

在 :ref:`priv_cloud_infra` 中采用 :ref:`priv_kvm` 运行 ``z-dev`` 虚拟机，这个虚拟机是我开发和学习的环境。采用了:

- :ref:`fedora_dev_init` 构建基于Fedora 35的开发环境
- 通过 :ref:`xpra_startup` 远程运行大型图形化程序
- :ref:`vscode_remote_dev_ssh` 实现本地 :ref:`vscode` 连接服务器，实现所有编译、调试都在服务器上完成，本地只需要轻量级的图形操作系统(甚至可以是 :ref:`linux_desktop` )

开发环境初始化
=================

- ``Fedora 35 Server`` 默认已经安装了大量开发工具，以下命令为补充安装一些工具::

   sudo dnf install -y git openssl-devel screen tmux

- 安装 :ref:`vscode_linux` (RHEL/CentOS/Fedora方式)::

   sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
   sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

   sudo dnf check-update
   sudo dnf install code

Xpra环境
============

- 按照 :ref:`xpra_startup` 安装Xpra::

   sudo dnf install xpra

- ``z-dev`` 是内部局域网虚拟机 ``192.168.6.x`` 网段，所以需要配置 :ref:`priv_ssh` 实现通过 ``ProxyCommnad`` 结合 ``ssh-agent`` 直接访问服务哦，这样才能满足后续使用 :ref:`vscode_remote_dev_ssh`

- 在 ``z-dev`` 上启动 ``xpra`` 会话::

   xpra start :7
   DISPLAY=:7 firefox
   DISPLAY=:7 rxvt
   DISPLAY=:7 code

- 在本地macOS上安装好 ``xpra`` ，然后使用以下命令连接远程服务器上的 ``xpra`` 会话::

   xpra --ssh=ssh attach ssh://z-dev/7

远程VS Code开发(SSH)
=======================

所有开发工作在服务器上进行，本地只使用 :ref:`vscode` 客户端连接，采用SSH方式远程工作:

- 使用上述 ``xpra`` 连接到 ``z-dev`` 的会话，即可以看到服务器端运行的 VS Code。使用 VS Code 的 Extension 管理安装 ``Remote Development extension pack``

- 在本地macOS上，启动 VS Code，然后按下 ``F1`` 或 ``⇧⌘P`` 启动命令行面板，然后选择 ``Remote-SSH: Connect to Host...`` ，然后输入需要访问的SSH服务器 ``z-dev`` 。初始化之后，就开启远程的开发环境

- 在远程VS Code上安装不同的开发语言插件，进行服务器开发

开发环境Docker
================

- ``z-dev`` 的Fedora 35环境，安装 :ref:`fedora_docker` ::

   sudo dnf -y install dnf-plugins-core
   sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

   sudo dnf install docker-ce docker-ce-cli containerd.io

- 启动Docker::

   sudo systemctl start docker
   sudo systemctl enable docker

- 自己账号 ``huatai`` 加入docker组::

   sudo gpasswd -a ${USER} docker
   sudo systemctl restart docker
   newgrp docker

然后，验证 ``docker ps`` 命令检查环境
   
