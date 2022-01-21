.. _fedora_docker:

====================
Fedora环境Docker
====================

设置仓库
=========

- 安装 ``dnf-plugins-core`` 软件包来管理DNF仓库::

   sudo dnf -y install dnf-plugins-core

   sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

安装Docker Engine
====================

- 安装::

   sudo dnf install docker-ce docker-ce-cli containerd.io

- 启动Docker::

   sudo systemctl start docker
   sudo systemctl enable docker

- 将自己账号添加到 ``docker`` 组方便运维::

   sudo gpasswd -a ${USER} docker
   sudo systemctl restart docker

   newgrp docker

然后作为普通用户的账号，例如我 ``huatai`` 就可以直接使用 ``docker`` 命令来运维了

参考
=========

- `Install Docker Engine on Fedora <https://docs.docker.com/engine/install/fedora/>`_
- `Getting started with Docker <https://developer.fedoraproject.org/tools/docker/docker-installation.html>`_
