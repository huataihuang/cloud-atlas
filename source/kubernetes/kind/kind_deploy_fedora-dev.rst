.. _kind_deploy_fedora-dev:

==========================
kind部署 ``fedora-dev``
==========================

在完成 :ref:`fedora_image` 制作之后，将镜像推送到 :ref:`kind_local_registry` 部署个人开发环境:

准备工作
============

- 将制作完成的 :ref:`fedora_image` ``fedora-dev`` 打上tag并推送Local Registry:

.. literalinclude:: kind_deploy_fedora-dev/push_fedora-dev_registry
   :language: bash
   :caption: 将 ``fedora-dev`` 镜像tag后推送Local Registry

部署
========

简单部署
----------

- 参考 :ref:`k8s_deploy_squid_startup` 相似部署:

.. literalinclude:: kind_deploy_fedora-dev/fedora-dev-deployment-origin.yml
   :language: yaml
   :caption: 部署到kind集群的fedora-dev-deployment.yml

- 部署:

.. literalinclude:: kind_deploy_fedora-dev/deploy_fedora-dev-origin
   :language: bash
   :caption: 将 ``fedora-dev`` 部署到kind集群(初始简化配置)

此时你会发现，部署的 ``fedora-dev`` 并没有像 :ref:`fedora_image` 非常轻松地运行起来，而是不断的 ``CrashLoopBackOff`` :

通过 ``kubectl describe pods fedora-dev-origin-64f5b9bb44-f5gw8`` 可以看到::

   Warning  BackOff    4s (x6 over 56s)   kubelet            Back-off restarting failed container

强制启动和排查
-----------------

既然Kubernetes根据端口判断容器服务不正常，那很有可能在 :ref:`fedora_image` 能够正常工作在docker的镜像在Kubernetes中存在问题。由于我为了部署开发环境，采用的是非常规的富容器，包含了 :ref:`systemd` ，这在 :ref:`docker_systemd` 也是需要特殊配置的，所以首先怀疑是Kubernetes环境 ``systemd`` 异常:

- 既然服务无法启动(端口不通)，那么修改Kuternetes的 ``Probe`` 侦测，改为无论如何都能够成功的模式，这样就可以先启动容器再进行下一步排查。创建 ``fedora-dev-deployment-forceup.yml`` :

.. literalinclude:: kind_deploy_fedora-dev/fedora-dev-deployment-forceup.yml
   :language: yaml
   :caption: 修订probe方式，强制pod运行以便检查异常 fedora-dev-deployment-forceup.yml
   :emphasize-lines: 41-46,49-58

- 运行强制启动:

.. literalinclude:: kind_deploy_fedora-dev/deploy_fedora-dev-forceup
   :language: bash
   :caption: 强制启动pod: fedora-dev-forceup

现在我们有2个pod::

   % kubectl get pods
   NAME                                 READY   STATUS             RESTARTS      AGE
   fedora-dev-forceup-b9ccb477-qk7rd    1/1     Running            0             36s
   fedora-dev-origin-64f5b9bb44-f5gw8   0/1     CrashLoopBackOff   4 (76s ago)   2m47s

- 登陆到 ``fedora-dev-forceup-b9ccb477-qk7rd`` 检查为何 :ref:`ssh` 服务无法正常工作::

   kubectl exec -it fedora-dev-forceup-b9ccb477-qk7rd -- /bin/bash

检查 ``sshd`` 服务::

   # systemctl status sshd
   System has not been booted with systemd as init system (PID 1). Can't operate.
   Failed to connect to bus: Host is down

可以看到 :ref:`systemd` 没有作为 ``init`` 启动启动，也就无法启动后续的 ``sshd`` 服务

之前在 :ref:`fedora_image` 运行 ``fedora-dev`` 的 ``docker run`` 命令 添加了 ``--privileged=true`` 才能实现 :ref:`docker_systemd` ，但是在 Kubernetes 上没有这个运行参数传递。那么，就需要 :ref:`systemd_container_interface` 传递到容器内部环境变量 ``container=docker`` 来告知 :ref:`systemd` 运行在容器内部

在Kubernetes，需要使用 :ref:`config_pod_by_configmap` ，我添加如下环境变量:

.. literalinclude:: kind_deploy_fedora-dev/fedora-dev-deployment-env.yml
   :language: yaml
   :caption: 向pod容器传递 ``container=docker`` 环境变量
   :emphasize-lines: 6-8

但是还是不行

之前在探索 :ref:`docker_systemd` 时发现 `How to run systemd in a container <https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/>`_ 使用 ``Podman`` 在容器中运行 systemd ，我Google了很久也没有找到 :ref:`systemd` 作为 Kubernetes pods 的 ``init`` 方法。似乎只有 ``Podman`` 才建议使用 :ref:`systemd` ，而 :ref:`docker` 默认则采用 :ref:`docker_tini` 作为init。

我暂时改为 :ref:`docker_tini` 来重新构建 :ref:`fedora_tini_image` ，有关 :ref:`systemd` 作为init的Kubernets pod，我后续再探索...
