.. _k8s_django:

==============================
Kubernetes环境部署Django应用
==============================

之前我部署了 :ref:`docker_django` 开发环境，现在我们将Docker容器部署到Kubernetes集群，提供更灵活和强健的应用部署。

准备
=====

我部署了 :ref:`kubernetes_arm` 来完成自己的一系列学习和测试，所以在这里部署Django应用，也采用这个ARM集群。

- 检查集群::

   kubectl get nodes -o wide

可以看到我的测试集群有4个节点，其中3个是工作节点::

   NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   jetson       Ready    <none>   61d   v1.20.2   192.168.6.10   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6
   pi-master1   Ready    master   68d   v1.20.2   192.168.6.11   <none>        Ubuntu 20.04.2 LTS   5.4.0-1028-raspi   docker://19.3.8
   pi-worker1   Ready    <none>   65d   v1.20.2   192.168.6.15   <none>        Ubuntu 20.04.2 LTS   5.4.0-1028-raspi   docker://19.3.8
   pi-worker2   Ready    <none>   65d   v1.20.2   192.168.6.16   <none>        Ubuntu 20.04.2 LTS   5.4.0-1028-raspi   docker://19.3.8

部署
======

- 给节点添加标签

:ref:`labels_and_selectors` 是调度kubernetes Pod的指引，虽然没有标签也可以部署Pod，但是对于一个复杂的Kubernetes集群，不同的硬件软件组合以及服务器规划，没有一个精心设计的调度指引会导致混乱。例如，混合X86架构和ARM架构，如果错误调度了不正确架构的Pod会导致无法启动。

这里我有3个woker节点： 其中 ``pi-workerX`` 节点上添加了 SSD 磁盘，另外一个 ``jetson`` 节点有NVIDIA GPU设备。所以添加标签如下::

   kubectl label nodes pi-worker1 disktype=ssd
   kubectl label nodes pi-worker2 disktype=ssd
   kubectl label nodes jetson model=gpu

- 检查节点::

   kubeclt get nodes --show-labels
