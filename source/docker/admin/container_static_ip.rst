.. _container_static_ip:

=======================
Docker容器分配静态IP
=======================

在 :ref:`libvirt_static_ip_in_studio` 为KVM虚拟机配置了静态IP地址，是通过调整Libvirt的DHCP分配IP地址实现的。在 :ref:`studio` 环境中，同样，也有部分Dcoker容器需要分配静态IP地址，以便运行基础服务。

.. note::

   在本案例中，我想部署3个Ceph容器节点，提供分布式存储给OpenStack集群使用，所以需要分配静态的IP地址。

参考 `Assign static IP to Docker container <https://stackoverflow.com/questions/27937185/assign-static-ip-to-docker-container>`_ 步骤如下：

- 创建自己的docker网络::

   docker network create --subnet=172.18.0.0/16 ceph-net

上述命令领创建了一个随机命名的bridge::

   bridge name    bridge id        STP enabled    interfaces
   br-58de6f145577        8000.0242723272a0    no

.. note::

   为了能够更好区别

- 在从镜像创建容器时添加 ``--net ceph-net`` 参数，并指定静态IP ``--ip 172.18.0.11`` 作为容器的IP地址::

   docker run --net ceph-net --ip 172.18.0.11 -it ubuntu bash

完整实践命令如下::

   docker run --net ceph-net --ip 172.18.0.11 -it -d \
     --hostname ceph-node1 --name ceph-node1 -v data:/data ubuntu:latest /bin/bash

.. note::

   `docker network connect <https://docs.docker.com/engine/reference/commandline/network_connect/>`_ 文档说明了链接容器到网络的方法::

      docker network cnnnect [OPTIONS] NETWORK CONTAINER

    以上命令 ``[OPTIONS]`` 可以是类似 ``--ip 172.17.0.11`` ，当链接容器到一个网络，就可以和连接到同一个网络到其他容器通讯。并且启动时也能指定连接的网络和IP地址，即使用 ``docker run`` 指令，类似如上。

参考
==========

- `docker network connect <https://docs.docker.com/engine/reference/commandline/network_connect/>`_
- `Assign static IP to Docker container <https://stackoverflow.com/questions/27937185/assign-static-ip-to-docker-container>`_ 
