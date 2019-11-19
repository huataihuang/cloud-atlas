.. _assigning_pods_to_nodes:

=====================
分配Pod到节点
=====================

可以约束一个Pod只运行在部分节点，或者优先运行在部分节点。有多种方式可以达成，并且建议都采用标签选择来决定。通常这种约束并不是必须的，调度器会自动进行和合理分布(例如，将pods分布跨节点，不会将pod分配到不合适的节点)，但是有些情况下你需要更多地控制pod分布，例如pod分配到具有SSD的服务器，或者协调2个不同服务的pod在相同可用区域以便通讯。

nodeSelector
===============

``nodeSelector`` 是最简单的推荐节点选择约束。 ``nodeSelector`` 是PodSpec的一个字段，设置了一个 key-value 数据对映射。对于需要pod合理调度到一个节点，节点必须具有这个 key-value 数据对作为标签。

- 使用 ``kubectl get nodes`` 获取集群节点

- 在节点上附加标签::

   kubectl label nodes <node-name> <label-key>=<label-value>

举例，要设置一个 ``kubernetes-foo-node-1.c.a-robinson.internal`` 节点的标签 ``disktype=ssd`` 使用如下命令::

   kubectl label nodes kubernetes-foo-node-1.c.a-robinson.internal disktype=ssd

- 在pod配置中添加 ``nodeSelector`` 字段::

   apiVersion: v1
   kind: Pod
   metadata:
     name: nginx
     labels:
       env: test
   spec:
     containers:
     - name: nginx
       image: nginx
       imagePullPolicy: IfNotPresent
     nodeSelector:
       disktype: ssd
   
上述配置中::

     nodeSelector:
       disktype: ssd


就是使得pod创建选择 ``disktype=ssd`` 标签的节点进行分布。

内建的节点标签
===============

除了你添加的节点标签，Kubernetes节点有标准标签集:

- kubernetes.io/hostname
- failure-domain.beta.kubernetes.io/zone
- failure-domain.beta.kubernetes.io/region
- beta.kubernetes.io/instance-type
- kubernetes.io/os
- kubernetes.io/arch

节点隔离/限制
===============

对节点对象添加标签可以指定节点或一组节点。这样可以确保特定的pod只运行在一些隔离的、安全的或者受监管的节点。当使用标签时，强烈建议不要通过节点的kubelet进程来修改所采用标签key，这样可以避免一个异常的kubelet自己设置节点标签，进而影响调度器调度。

使用 ``NodeRestriction`` admission插件可以防止kubelets设置或修改具有 ``node-restriction.kubernetes.io/`` 开头的节点标签:

- 确保使用了 Node authorizer ，并且激活了 ``NodeRestriction admission plugin``
- 在标签前面加上 ``node-restriction.kubernetes.io/`` 前缀，并使用这些标签，例如::

   example.com.node-restriction.kubernetes.io/fips=true
   example.com.node-restriction.kubernetes.io/pci-dss=true

亲和性(affinity)和抗亲和性(anti-affinity)
============================================

``nodeSelector`` 提供了一个非常简单的节点选择的方法。而 affinity/anti-afinity 功能，则极大扩展了限制类型。

主要增强点有：

- 语言更具有表现性(expressive)
- 你可以标记规则是软性/优选的，而不是硬要求，这样即使调度器不能满足，pod依然可以调度
- 


参考
=========

- `Kubernetes Documentation - Concepts: Assigning Pods to Nodes <https://kubernetes.io/docs/concepts/configuration/assign-pod-node/>`_
