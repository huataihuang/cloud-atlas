.. _minikube_expose_app:

=======================
Minikube对外输出应用
=======================

Kubernetes中Pod是关键要素。Pod实际上有一个称为 :ref:`pod_lifecycle` 的概念。当一个worker节点故障，则运行在这个节点当Pods也就随之丢失了。

:ref:`replicaset` 可以通过创建新的Pod来保持应用程序运行，这样就可以动态驱动集群恢复指定状态。举例，假设有一个图形处理后端运行了3个副本。这些副本是可替换的，前端系统不会知道后端副本出现某个Pod丢失然后重建，即在Kuberneetes集群中每个Pod有一个唯一的IP地址，甚至当这些Pod在相同节点也是这样，需要有一种方式自动保持Pod的最终一致性，这样应用程序就可以持续工作。

在Kubernetes中，服务(Service)是一个抽象概念，服务定义了一个Pod的逻辑集合，以及如何访问这些Pod的策略。Service激活了在相关Pod之间的松散连接。Service使用YAML或JSON定义，类似所有的Kubernettes对象。通过Service定义的一组Pod通常使用 LabelSelector 来定位。

虽然每个Pod有一个唯一IP地址（内部），但是如果没有定义服务Service，则这些IP不能被集群外访问。Services允许应用程序收到流量，并且额可以通过指定ServiceSpecc的 ``type`` 来输出不同方式:

- ``ClusterIP`` (默认) - 通过集群中的一个内部IP来输出服务。这是默认方式，这使得服务在集群内部能够被访问到。
- ``NodePort`` - 使用NAT方式，把集群的每个被选择节点使用相同端口输出服务。让服务在外部可以访问是使用 ``<NodeIP>:<NodePort>`` 。
- ``LoadBalancer`` - 在当前云（如果支持）创建一个外部负载均衡，并且设置一个固定的外部IP地址提供服务。这种负载均衡模式是NodePort的超集。
- ``ExternalName`` - 通过返回一个CNAME别名记录实现一个强制名字（arbitrary name）输出服务（即在spec中指定 ``externalName`` ）。不需要使用proxy，这种类型需要 v1.7或更高版本的 ``kube-dns`` 。

.. note::

   详细请参考 :ref:`connect_applications_service` 

.. note::

   一些服务的使用案例在spec中没有定义 ``selector`` ，这种没有具备 ``selector`` 的服务也就不会创建相应的Endpoints对象。这种方式允许用户手工映射一个服务到特定的endpoints。另一种不使用selector的可能是使用 ``type: ExternalName`` 。

服务和标签(Servicces and Labels)
====================================

.. figure:: ../../_static/kubernetes/services_and_labels.svg

- Service会路由一个Pod集合的流量
  - Service能够抽象Pod对外提供的服务，这样Pod的消亡和替换不会影响Kubernetes对外的应用（实际上就是通过ReplicaSet的最终一致性确保Kubernetes集群有指定数量的Pod对外提供服务）
  - Service可以处理发现和路由相关Pods（例如对于一个应用需要组合前端和后端组件）

  - 通过 :ref:`labels_and_selectors` （Kubernetes的逻辑集合）Service可以匹配Pods集合以便能够统一操作。 标签和key/value键值对是Kubernetes对象所具备的，可以通过以下方式使用:
    - 为开发、测试和生产环境命名对象
    - 嵌入版本tag
    - 使用tag来分类一个对象

.. figure:: ../../_static/kubernetes/services_labels.svg

.. note::

   通过在Pod上设置标签 ``app=B`` 可以把一组Pod逻辑组合成面向service B，然后通过标签选择器选择这组pod，来设置对外服务。

输出服务
============

在 :ref:`minikube_deploy_app` 中，我们已经部署了一个 ``my-dev`` 的Pod，并且我们手工在这个Pod中安装了Nginx服务。虽然此时我们只有通过 ``kubectl proxy`` 连接到Kubernetes内部网络才能看到WEB页面。现在我们来实践上文介绍的几种输出service的方式，让这个Pod真正能够对外服务。

- 检查deployment::

   kubectl get deployments

可以看到输出::

   NAME     READY   UP-TO-DATE   AVAILABLE   AGE
   my-dev   1/1     1            1           4d1h

- ``NodePort`` - 使用NAT方式，把集群的每个被选择节点使用相同端口输出服务。让服务在外部可以访问是使用 ``<NodeIP>:<NodePort>`` ::

   kubectl expose deployment/my-dev --type="NodePort" --port 80

.. note::

   请注意，所谓 ``NodePort`` 实际上就是把Kubernetes内部私网IP上的服务器端口映射到所在节点IP的对外端口（随机选择），虽然能够对外使用，实际上并不符合我们常规的对外服务（因为端口不固定，并且使用的是NodeIP）。

- 现在我们检查输出的服务::

   kubectl get services

输出显示::

   NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
   kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        5d6h
   my-dev       NodePort    10.103.127.241   <none>        80:32124/TCP   18s 
   
.. note::

   注意， ``NodePort`` 是需要获取到node节点的IP地址才能访问的（不是 ``get services`` 显示的 ``CLUSTER-IP`` ，这个cluster-ip是内部私有地址）

- 获取输出的 ``NodePort`` ::

   export NODE_PORT=$(kubectl get services/my-dev -o go-template='{{(index .spec.ports 0).nodePort}}') 
   echo NODE_PORT=$NODE_PORT 

显示输出::

   NODE_PORT=32124

- 现在我们就可以执行以下命令获取Node节点对外输出的服务（这里 Node 节点 IP 是 192.168.101.81）::

   curl http://192.168.101.81:$NODE_PORT

正确的话，输出内容如下::

   <html>
   <header><title>MiniKube</title></header>
   <body>
   Hello world
   </body>
   </html>

使用标签(label)
================

在 Deployment 部署时候会自动为Pod创建一个Label，例如，之前我们创建的 ``my-dev`` 这个pod，使用以下 ``describe deployment`` 可以查看Pod的详细信息::

   kubectl describe deployment

显示输出::

   Name:                   my-dev
   Namespace:              default
   CreationTimestamp:      Thu, 13 Jun 2019 15:36:10 +0800
   Labels:                 run=my-dev
   Annotations:            deployment.kubernetes.io/revision: 1
   Selector:               run=my-dev
   Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
   StrategyType:           RollingUpdate
   MinReadySeconds:        0
   RollingUpdateStrategy:  25% max unavailable, 25% max surge
   Pod Template:
     Labels:  run=my-dev
     Containers:
      my-dev:
       Image:      ubuntu
       Port:       <none>
       Host Port:  <none>
       Args:
         bash
       Environment:  <none>
       Mounts:       <none>
     Volumes:        <none>
   Conditions:
     Type           Status  Reason
     ----           ------  ------
     Available      True    MinimumReplicasAvailable
     Progressing    True    NewReplicaSetAvailable
   OldReplicaSets:  <none>
   NewReplicaSet:   my-dev-558d6cdd (1/1 replicas created)
   Events:          <none>   

.. note::

   可以看到默认的Label是 ``run=my-dev`` ，并且有一个选择器 ``Selector`` 是 ``run=my-dev``

- 根据标签找pod

既然有标签，现在我们就可以通过标签来找到这个pod（这里是一个演示，实际上在生产环境，对于海量的pod，我们就是通过label来找到这些pod的）::

   kubectl get pods -l run=my-dev

输出::

   NAME                    READY   STATUS    RESTARTS   AGE
   my-dev-558d6cdd-4bnxq   1/1     Running   0          4d5h

- 根据标签找service

同样也可以根据标签来找service::

   kubectl get services -l run=my-dev

输出::

   NAME     TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
   my-dev   NodePort   10.103.127.241   <none>        80:32124/TCP   3h58m

- label可以随时添加和修改，这里我们给pod增加一个新的标签 ``app=v1``

首先我们获取Pod的名字并存放在环境变量 ``POD_NAME`` 中::

   export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
   echo Name of the Pod: $POD_NAME

输出显示::

   echo Name of the Pod: $POD_NAME

现在为这个pod打上新标签::

   kubectl label pod $POD_NAME app=v1

输出显示::

   pod/my-dev-558d6cdd-4bnxq labeled

检查::

   kubectl describe pods $POD_NAME

输出显示::

   Name:               my-dev-558d6cdd-4bnxq
   ...
   Labels:             app=v1
                       pod-template-hash=558d6cdd
                       run=my-dev 
   ...

- 通过新增加label来找寻pod::

   kubectl get pods -l app=v1

同样我们也找到这个pod，输出显示如下::

   NAME                    READY   STATUS    RESTARTS   AGE
   my-dev-558d6cdd-4bnxq   1/1     Running   0          4d5h

删除服务
============

- 通过label我们可以查询到服务，所以我们也可以根据label来删除服务::

   kubectl delete service -l run=my-dev

显示::

   service "my-dev" deleted

删除服务之后，再次检查服务列表::

   kubectl get service

可以看到自己定义的 ``my-dev`` 服务已经消失。

当然，我们现在在外部网络已经不能访问到Kubernetes内部网络的服务端口（外部服务暴露接口已经删除），但是我们可以通过pod内部的检查确认app还是运行的，只是没有外部服务::

   kubectl exec -ti $POD_NAME curl localhost:80

   
   
参考
=======

- `Using a Service to Expose Your App <https://kubernetes.io/docs/tutorials/kubernetes-basics/expose/expose-intro/>`_
