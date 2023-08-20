.. _labels_and_selectors:

======================================
标签和选择器(labels and selectors)
======================================

Node的众所周知标签、申明、瑕疵
===============================

虽然标签可以任意命名，只要能够正确选择即可。但是， `kubernetes保留了一些众所周知的标签(Labels),申明(Annotations)和瑕疵(Taints) <https://kubernetes.io/docs/reference/labels-annotations-taints/>`_ ，例如:

- ``kubernetes.io/arch`` 这个参数在Go语言中定义为 ``runtime.GOARCH`` 可以用于混合arm和x86节点的集群
- ``kubernetes.io/os`` 这个参数在Go语言中定义为 ``runtime.GOOS`` ，在混合不同操作系统(例如Linux和Windows节点)时使用
- ``kubernetes.io/hostname`` 需要注意hostname可以在 ``kubelet`` 传递参数 ``--hostname-override`` 参数覆盖
- ``node.kubernetes.io/instance-type`` 在 ``cloudprovider`` 中定义虚拟机规格类型，这个是云计算常用的规格，例如 ``g2.2xlarge`` , ``m3.medium`` 等等
- ``topology.kubernetes.io/zone`` 这个标签是云计算厂商用于标记不同zone的机房拓扑，例如 ``topology.kubernetes.io/zone=us-east-1c`` 。这个标签在 ``节点`` (Node) 和 ``持久化卷`` (PersistentVolume)非常有用。

创建标签和删除标签
===================

- 创建节点标签::

   kubectl label node <nodename> <labelname>=<value>

- 删除节点标签::

   kubectl label node <nodenMe> <labelname>-

- 删除多个节点标签::

   kubectl label <node1> <node2> <labelname>-

- 删除所有节点标签( **慎用** )::

   kubectl label --all <labelname>-

标签实践
=========

- 首先需要准备一个Kubernetes集群，我采用 :ref:`arm_k8s` ::

   kubectl get nodes -o wide --show-labels

这里可以看到::

   NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME   LABELS
   jetson       Ready    <none>   61d   v1.20.2   192.168.6.10   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6     beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=jetson,kubernetes.io/os=linux
   pi-master1   Ready    master   68d   v1.20.2   192.168.6.11   <none>        Ubuntu 20.04.2 LTS   5.4.0-1028-raspi   docker://19.3.8     beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-master1,kubernetes.io/os=linux,node-role.kubernetes.io/master=
   pi-worker1   Ready    <none>   65d   v1.20.2   192.168.6.15   <none>        Ubuntu 20.04.2 LTS   5.4.0-1028-raspi   docker://19.3.8     beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-worker1,kubernetes.io/os=linux
   pi-worker2   Ready    <none>   65d   v1.20.2   192.168.6.16   <none>        Ubuntu 20.04.2 LTS   5.4.0-1028-raspi   docker://19.3.8     beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-worker2,kubernetes.io/os=linux

这里可以看到重复的标签，例如 ``beta.kubernetes.io/arch=arm64`` 和 ``kubernetes.io/arch=arm64`` 应该和我最初部署Kubernetes版本较低，逐步升级到最新版本，向后兼容。

- 树莓派worker节点配置了SSD硬盘，所以添加标签::

   kubectl label nodes pi-worker1 disktype=ssd
   kubectl label nodes pi-worker2 disktype=ssd

- Jetson节点配置了GPU，所以添加标签::

   kubectl label nodes jetson model=gpu

- 现在我们deploy时候，指定节点选择::

   ...
   spec:
     nodeSelector:
       disktype: ssd

``nodeSelector`` 调度失败排查
=================================

``svc`` 需要配置 ``selector``
-------------------------------

- 注意，并不是只要设置 ``nodeSelector`` 就可以完成调度选择，如果没有在deployment中配置 ``svc`` 指定的pod ``selector`` 就会导致以下错误::

   error: error validating "deployment_arm.yaml": error validating data: ValidationError(Deployment.spec): missing required field "selector" in io.k8s.api.apps.v1.DeploymentSpec; if you choose to ignore these errors, turn validation off with --validate=false

这是因为，不仅pod需要通过标签能够选择节点，服务 ``svc`` 也需要通过标签来选择pod。所以需要注意 ``deployment.yaml`` 包含以下内容::

   apiVersion: apps/v1
   kind: Deployment
   metadata:
     labels:
       app.kubernetes.io/name: onesre-core
   ...
   spec:
     selector:
       matchLabels:
         app.kubernetes.io/name: onesre-core

这样对应的 ``svc.yaml`` 中配置::

   apiVersion: v1
   kind: Service
   metadata:
     app.kubernetes.io/name: onesre-core
   ...
   spec:
     type: ClusterIP
     clusterIP: None
     selector:
         app.kubernetes.io/name: onesre-core

节点 ``taint`` 会阻止 ``nodeSelector``
-----------------------------------------

在实际生产部署中，有可能遇到调度失败情况。例如，我在 :ref:`helm3_prometheus_grafana` 想通过配置 ``nodeSelector`` 来指定将监控相关服务调度到专用服务器:

- 为监控专用服务器打标:

.. literalinclude:: labels_and_selectors/label_node_prometheus
   :language: bash
   :caption: 为监控服务器label以便监控组件调度到专用服务器

- 修订 ``deployment`` ，指定组件调度到上述标签节点 ``kubectl edit deployments stable-grafana`` ，配置内容如下:

.. literalinclude:: labels_and_selectors/config_nodeselector
   :language: bash
   :caption: 配置 ``stable-grafana`` deployments，指定 ``nodeSelector`` 到 ``telemetry: prometheus`` 标签节点

修订完成后检查::

   kubectl get pods -o wide -A | grep grafa

但是发现并没有迁移成功(依然运行在 ``old-mon-serv`` 服务器，并没有调度到我期望的 ``mon-serv`` )::

   # kubectl get pods -o wide -A | grep grafa
   default       stable-grafana-6449bcb69b-rqhwz                          3/3     Running             0          22h     10.233.125.1    old-mon-serv   <none>           <none>
   default       stable-grafana-c4465d9cb-kgwp6                           0/3     Pending             0          2m28s   <none>          <none>                   <none>           <none>

- 检查::

   kubectl get pods stable-grafana-c4465d9cb-kgwp6 -o yaml

可以看到调度失败原因是 ``taint`` ::

   status:
     conditions:
     - lastProbeTime: null
       lastTransitionTime: "2023-03-30T12:28:14Z"
       message: '0/43 nodes are available: 1 node(s) had taint {node.k8s.xxx.com/initial:
         }, that the pod didn''t tolerate, 42 node(s) didn''t match node selector.'
       reason: Unschedulable
       status: "False"
       type: PodScheduled
     phase: Pending
     qosClass: BestEffort 

- 检查 ``mon-serv`` 服务器 ``Tains`` 情况 ::

   # kubectl describe node mon-serv | grep 'Taints'
   Taints:             node.k8s.xxx.com/initial:NoSchedule   

原因是新部署服务器为了避免验收未通过情况，默认先打标了 ``NoSchedule`` 的 ``Taints`` ，需要清理::

   kubectl taint nodes mon-serv node.k8s.xxx.com/initial:NoSchedule-

参考
=======

- `Labels and Selectors <https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/>`_
- `ValidationError: missing required field “selector” in io.k8s.api.v1.DeploymentSpec <https://stackoverflow.com/questions/59480373/validationerror-missing-required-field-selector-in-io-k8s-api-v1-deploymentsp>`_
- `How to delete a node label by command and api? <https://stackoverflow.com/questions/34067979/how-to-delete-a-node-label-by-command-and-api>`_ 
- `How to Add or Remove Labels to Nodes in Kubernetes <https://linuxhandbook.com/kubectl-label-node/>`_
