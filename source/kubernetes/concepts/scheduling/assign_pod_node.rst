.. _assign_pod_node:

=================
将Pod分配给节点
=================

:ref:`kube-scheduler` 提供了调度策略提供 ``过滤的断言(Predicates)`` 和 ``打分的优先级(Priorities)`` 

在配置Pod调度到Node，我们常用的调度插件有

* TaintToleration
* NodeAffinity

``NodeAffinity`` 在异构的环境中常常使用，例如不同的硬件配置，有的节点提供了GPU，有的节点处理器是ARM架构，在使用节点亲和性上就非常容易实现。

nodeSelector
=============

``nodeSelector`` 是节点选择节点的最简单推荐形式。 ``nodeSelector`` 是 PodSpec 的一个字段，包含键值对映射。为了使pod可以在某个节点上运行，这个节点标签中必须包含这个键值对。

要完成一个 ``nodeSelector`` 选择节点约束，需要执行以下步骤

- 步骤一：添加标签到节点

选择要添加标签节点，执行::

   kubectl label node <node-name> <label-key>=<label-value>

例如给节点添加 ``disktype=ssd`` 或者 ``accelerator=nvidia-maxwell-jetson-nano`` ( :ref:`nvidia_gpu` )

举例，在 :ref:`arm_k8s_deploy` 我部署了 ``kube-verify`` 验证容器，创建yaml的脚本:

.. literalinclude:: ../../arm/arm_k8s_deploy/create_deployment.sh
   :language: bash
   :linenos:
   :caption:

在 :ref:`pi_4` 的两个worker节点，我部署了 :ref:`usb_boot_ubuntu_pi_4` ，所以我添加一个 ``disktype=ssd`` 标签::

   kubectl label node pi-worker1 disktype=ssd
   kubectl label node pi-worker2 disktype=ssd

然后检查可以看到::

   kubectl describe nodes pi-worker1

可以看到::

   Name:               pi-worker1
   Roles:              <none>
   Labels:             beta.kubernetes.io/arch=arm64
                       beta.kubernetes.io/os=linux
                       disktype=ssd
                       kubernetes.io/arch=arm64
                       kubernetes.io/hostname=pi-worker1
                       kubernetes.io/os=linux 
   ...

- 步骤二：添加 ``nodeSelector`` 字段到Pod配置::

   kubectl -n kube-verify edit deployments kube-verify

在pod的 ``Deployment.spec.template.spec`` 段落添加::

   spec:
     ...
     template:
     ...
       spec:
       ...
       nodeSelector:
         disktype: ssd

注意，一定要正确添加 ``nodeSelector`` 位置，我配置到 ``Deployment.spec`` 则会出现以下报错::

   # deployments.apps "kube-verify" was not valid:
   # * <nil>: Invalid value: "The edited file failed validation": ValidationError(Deployment.spec): unknown field "nodeSelector" in io.k8s.api.apps.v1.DeploymentSpec

- 然后检查就可以看到，原先配置 ``replicas: 3`` 的pod全部迁移到 ``disk-type`` 为 ``ssd`` 的ARM节点上::

   kubectl -n kube-verify -n kube-verify get pods -o wide

容器都运行在 ``pi-worker1`` 和 ``pi-worker2`` 上::

   NAME                           READY   STATUS    RESTARTS   AGE   IP            NODE         NOMINATED NODE   READINESS GATES
   kube-verify-7d4878dfdc-9rv6m   1/1     Running   0          24s   10.244.2.13   pi-worker2   <none>           <none>
   kube-verify-7d4878dfdc-fgc4m   1/1     Running   0          21s   10.244.1.26   pi-worker1   <none>           <none>
   kube-verify-7d4878dfdc-k7sv5   1/1     Running   0          19s   10.244.2.14   pi-worker2   <none>           <none>

内置节点标签
---------------

除了用户添加的标签，节点已经预先具备了一组标准标签:

* kubernetes.io/hostname
* failure-domain.beta.kubernetes.io/zone
* failure-domain.beta.kubernetes.io/region
* topology.kubernetes.io/zone
* topology.kubernetes.io/region
* beta.kubernetes.io/instance-type
* node.kubernetes.io/instance-type
* kubernetes.io/os
* kubernetes.io/arch

.. note::

   标签值基于云服务商，所以不能保证可靠。例如 ``kubernetes.io/hostname`` 在某些环境可能和节点标签名称相同，但在其他环境中可能是不同值。    

案例
~~~~~

在 :ref:`arm_k8s_deploy` 中，我通过 :ref:`multi_arch_k8s` 添加了一个 X86架构的节点 ``zcloud`` ，可以通过::

   kubectl get nodes --show-labels

看到 ``kubernetes.io/arch=`` 差异::

   NAME         STATUS   ROLES    AGE    VERSION   LABELS
   ...
   pi-worker2   Ready    <none>   164d   v1.21.1   beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-worker2,kubernetes.io/os=linux
   zcloud       Ready    <none>   54d    v1.21.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=zcloud,kubernetes.io/os=linux

可以看到 ``kubernetes.io/arch`` 是每个worker节点都具备都内置标签，我们可以按照架构来部署容器。

亲和性与反亲和性
=================

``亲和性/反亲和性`` 扩展了 ``noetSelector`` 的简单Pod约束到特定标签的节点功能:

* 规则是“软需求”/“偏好”，而不是硬性要求，因此， 如果调度器无法满足该要求，仍然调度该 Pod
* 可以使用节点(或其他拓扑域中)的Pod的标签来约束，而不是使用节点的标签，这样可以实现哪些Pod放在一起或者不能放在一起(类似 ``合并部署`` )


节点亲和性
------------

节点亲和性概念上类似 ``nodeSelector`` ，可以根据节点上的标签来约束Pod调度到哪些节点。

节点亲和性分为以下两种:

* ``requiredDuringSchedulingIgnoredDuringExecution`` - 硬需求，也就是 **必须满足** (required) 的规则，只有规则满足才能够调度到一个节点
* ``preferredDuringSchedulingIgnoredDuringExecution`` - 软需求，也就是 **偏好** (preferred) 的规则，表示调度器将尽力尝试这个偏好规则，不能保证

举例： ``requiredDuringSchedulingIgnoredDuringExecution`` 可以仅将Pod运行在具备Intel CPU的节点上，但是使用 ``preferredDuringSchedulingIgnoredDuringExecution`` 我们可以设置线尝试运行在Intel CPU节点上，如果没有资源，退一步可以运行在AMD或者其他类型CPU节点上。


节点亲和性通过 PodSpec 的 ``affinity`` 字段下的 ``nodeAffinity`` 字段指定

在使用上，我们可以结合 ``required`` 和 ``preferred`` 以实现必须满足，且在满足条件情况下优先调度到某个节点


pod间亲和性与反亲和性
----------------------

Pod 间亲和性与反亲和性可以基于已经在节点上运行的 Pod 的标签 来约束 Pod 可以调度到的节点，而不是基于节点上的标签。

与节点亲和性一样，当前有两种类型的 Pod 亲和性与反亲和性，即 ``requiredDuringSchedulingIgnoredDuringExecution`` 和 ``preferredDuringSchedulingIgnoredDuringExecution`` ，分别表示“硬性”与“软性”要求。 


参考
======

- `将 Pod 分配给节点 <https://kubernetes.io/zh/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity>`_
