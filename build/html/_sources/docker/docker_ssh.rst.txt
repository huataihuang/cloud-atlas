.. _docker_ssh:

==========================
Docker容器中运行ssh服务
==========================

实际上在Docker容器内不建议运行sshd服务 :ref:`docker_concept` ：Docker是设计成在每个容器只运行一个单一服务/进程，所以运行应用的容器 中，通常不需要再运行sshd服务。这样自然就避免了运维人员登陆容器内容进行手工操作。

不过，也并非无法在容器中启动sshd服务，一些情况下，例如个人的开发环境，能够在容器内部运行一个ssh服务，还是很方便维护的 。

.. note::

   以下案例在Ubuntu 18.04 官方镜像上建立的容器中安装和运行sshd服务，方便开发测试的案例。

   启动容器方法参考 :ref:`assign_static_ip_to_docker_container`

- 启动容器::

   docker run --net ceph-net --ip 172.18.0.11 -it -d \
     --hostname ceph-node1 --name ceph-node1 -v data:/data ubuntu:latest /bin/bash

- 登陆容器::

   docker attach ceph-node1

- 在容器内部执行安装sshd服务::

   apt install openssh-server

- 创建sshd服务使用的的host key::

   ssh-keygen -A

- 创建sshd服务运行目录::

   mkdir /run/sshd

- 启动ssh服务::

   /usr/sbin/sshd

.. note::

   注意，这里启动sshd服务是一次性的，下次启动容器，由于容器创建只运行了 ``/bin/bash`` 所以并没有启动sshd服务。

   要保持docker启动时能够启动ssh服务并运行bash，需要先将包含ssh的镜像制作出来，然后基于此镜像启动容器时采用bash来执行多条命令，案例如下：

- 保存镜像::

   docker commit ceph-node1 local:ubuntu18.04-ssh

- 再次创建容器，此时容器运行命令中包含启动sshd服务::

   docker rm ceph-node1

   docker run --net ceph-net --ip 172.18.0.11 -it -d \
     --hostname ceph-node1 --name ceph-node1 -v data:/data local:ubuntu18.04-ssh \
     /bin/bash -c "/usr/sbin/sshd && /bin/bash"

.. note::

   虽然上述通过命令方式一点点积累也能够搞好镜像，并且能让别人能参考这篇文档来完成镜像制作，不过毕竟还是一个重复的手工操作。Docker为了方便系统管理员能够自己定制镜像，提供了一个 :ref:`build_image_from_dockerfile`

参考
=====

- `How to automatically start a service when running a docker container? <https://stackoverflow.com/questions/25135897/how-to-automatically-start-a-service-when-running-a-docker-container>`_
- `Dockerize an SSH service <https://docs.docker.com/engine/examples/running_ssh_service/>`_
- `Run multiple services in a container <https://docs.docker.com/engine/admin/multi-service_container/>`_
