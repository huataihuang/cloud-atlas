.. _ubuntu_in_kubernetes:

===========================
在Kubernetes中运行Ubuntu
===========================

在我模拟Kubernetes的环境中，会使用Ubuntu作为容器运行在Kubernetes中。

.. note::

   最终我会使用cloud native方式来部署自己的开发测试环境，以及完善的容器化部署。不过，目前还在探索之中，所以还是会采用完整的富容器方式运行，

   由于Ubuntu在Docker官方的镜像非常精简，所以会在使用中先加入必要的工具

- 创建ubuntu实例pod::

   kubectl run my-dev --rm -i --tty --image ubuntu -- bash

.. note::

   详细容器创建和服务输出请参考 :ref:`kubernetes_startup`

- 升级系统::

   apt update && apt upgrade

- 安装工具::

   # 默认locale是C，很多环境需要设置UTF-8，参考docker hub官方说明修正 https://hub.docker.com/_/ubuntu/
   # 不过，已经创建的容器是无法生效的，需要先存储镜像再重新创建容器实例
   apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
       && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
   echo "export LANG=en_US.UTF-8" >> /etc/profile

   # 修改配置等工作需要vim
   apt -y install vim

   # 很多网络测试依赖curl工具
   apt -y install curl 


