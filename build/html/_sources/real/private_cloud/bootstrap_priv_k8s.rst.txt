.. _bootstrap_priv_k8s:

========================
引导私有云Kubernetes
========================

安装Docker运行环境
====================

- 在 workerX 各服务器 (请参考 :ref:`real_prepare` 分配物理主机列表 ``hosts`` 文件) 上安装Docker环境::

   # 安装必要软件包
   yum install yum-utils device-mapper-persistent-data lvm2

   # 添加Docker仓库，注意必须是Docker-CE
   yum-config-manager \
     --add-repo \
     https://download.docker.com/linux/centos/docker-ce.repo

   # 安装Docker CE
   yum update && yum install docker-ce

.. note::

   在 :ref:`docker_btrfs` 中，我是在Studio环境部署Ubuntu 18操作系统，由于内核4.x已经较好支持了btrfs文件系统，所以官方推荐在Ubuntu/Debian中使用btrfs。但是CentOS/RHEL 7.x目前内核还处于3.x，所以不推荐使用btrfs。

   我计划在CentOS 8发布后，再check官方支持btrfs情况确定是否迁移Docker Driver到btrfs系统。根据RHEL8选择的内核4.18，预计能够很好支持btrfs系统。

- 设置Docker的配置::

   # 默认安装 /etc/docker 目录不存在，需要创建
   mkdir /etc/docker

   # 设置Daemon
   cat > /etc/docker/daemon.json <<EOF
   {
     "exec-opts": ["native.cgroupdriver=systemd"],
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "100m"
     },
     "storage-driver": "overlay2",
     "storage-opts": [
       "overlay2.override_kernel_check=true"
     ]
   }
   EOF

   mkdir -p /etc/systemd/system/docker.service.d

- 重启Docker服务::

   # Restart Docker
   systemctl daemon-reload
   systemctl restart docker
