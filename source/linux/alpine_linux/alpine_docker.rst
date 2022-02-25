.. _alpine_docker:

===========================
Alpine Linux运行Docker
===========================

安装
======

- 使用 :ref:`alpine_apk` 添加 ``Community`` 仓库，然后执行以下命令安装docker ::

   apk add docker

- 将自己的账号加入到 ``docker`` 组::

   addgroup huatai docker

- 启动Docker服务 - 参考 :ref:`openrc` ::

   sudo rc-update add docker boot
   sudo service docker start

.. note::

   我没有安装 ``docker-compose`` ，后续容器编排主要采用 :ref:`k3s`

隔离容器
===========

执行以下命令添加 ``dockremap`` ::

   adduser -SDHs /sbin/nologin dockremap
   addgroup -S dockremap
   echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f3):65536 >> /etc/subuid
   echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f4):65536 >> /etc/subgid

此时生成的 ``/etc/subuid`` 内容::

   dockremap:101:65536

``/etc/subgid`` 内容::

   dockremap:65533:65536

- 然后在 ``/etc/docker/daemon.json`` 中添加::

   {  
       "userns-remap": "dockremap"
   } 

此外，可以虑考虑添加::

       "experimental": false,
       "live-restore": true,
       "ipv6": false,
       "icc": false,
       "no-new-privileges": false

详细的配置参数参考 `Docker docs Reference / Command-line reference / Daemon CLI(dockerd) Daemon configuration file <https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file>`_

- 执行 ``docker info`` 检查配置，可能会看到::

   WARNING: No memory limit support
   WARNING: No swap limit support
   WARNING: No kernel memory TCP limit support
   WARNING: No oom kill disable support



完整配置如下:

参考
======

- `alpine linux wiki: Docker <https://wiki.alpinelinux.org/wiki/Docker>`_
