.. _minikube_deploy_nginx_ingrerss_controller:

=========================================
在Minikube部署NGINX Ingress Controller
=========================================

:ref:`ingress` 是定义允许外部访问集群服务的规则的API对象，而 :ref:`ingress_controller` 则是实现Ingress规则的组件。

激活Ingress Controlleer
==========================

- 执行以下命令激活NGINX Ingress controller::

   minikube addons enable ingress

- 验证NGINX ingress controller已经运行::

   kubectl get pods -n kube-system

可以看到输出::

   NAME                                        READY   STATUS    RESTARTS   AGE
   ...
   default-http-backend-6864bbb7db-kv2sm       1/1     Running   0          2m56s
   ...
   nginx-ingress-controller-586cdc477c-xj9rq   1/1     Running   0          2m55s
   ...

部署hello,wold app
====================

- 使用以下命令创建一个测试部署::

   kubectl run web --image=gcr.io/google-samples/hello-app:1.0 --port=8080

- 直接输出部署(NodePort) ::

   kubectl expose deployment web --target-port=8080 --type=NodePort

- 检查输出的服务::

   kubectl get service web

显示输出::

   NAME   TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
   web    NodePort   10.97.135.77   <none>        8080:32030/TCP   23s

- 验证服务通过NodePort的输出::

   minikube service web --url

显示输出::

   http://192.168.101.81:32030

- 现在我们可以检查这个对外输出::

   curl http://192.168.101.81:32030

显示输出::

   Hello, world!
   Version: 1.0.0
   Hostname: web-ddb799d85-889fm

.. note::

   现在我们使用NodePort方式输出服务，对外的端口是随机的，所以并适合日常使用服务。下面我们正式采用 Ingress 来输出服务

创建Ingress资源
================

- 创建 ``example-ingress.yaml`` 如下::

   apiVersion: extensions/v1beta1
   kind: Ingress
   metadata:
     name: example-ingress
     annotations:
       nginx.ingress.kubernetes.io/rewrite-target: /
   spec:
    rules:
    - host: hello-world.info
      http:
        paths:
        - path: /*
          backend:
            serviceName: web
            servicePort: 8080

- 使用以下命令创建 Ingress 资源::

   kubectl apply -f example-ingress.yaml

输出显示::

   ingress.extensions/example-ingress created

- 验证IP地址::

   kubectl get ingress

当前还没有显示IP地址::

   NAME              HOSTS              ADDRESS   PORTS   AGE
   example-ingress   hello-world.info             80      26s

不过，几分钟之后再次使用该命令就可以看到服务对外低筒的IP地址::

   NAME              HOSTS              ADDRESS          PORTS   AGE
   example-ingress   hello-world.info   192.168.101.81   80      96s

.. note::

   注意，Ingress对外输出的端口默认是HTTP端口，所以后端指定服务端口8080就会将对外输出的80端口反向代理到内部网络的应用服务器的8080端口。实际上这是我们很久以前就常用的Nginx反向代理部署，只不过Kubernetes高度抽象并自动化完成了这些部署。

- 在本次主机 ``/etc/hosts`` 中添加解析::

   192.168.101.81 hello-world.info

- 现在我们就可以直接像平时访问WEB服务器一样访问kubernetes集群对外输出的WEB服务::

   curl hello-world.info

输出内容就是::

   Hello, world!
   Version: 1.0.0
   Hostname: web-ddb799d85-889fm

创建第二个部署
===============

- 创建 v2 部署::

   kubectl run web2 --image=gcr.io/google-samples/hello-app:2.0 --port=8080

- 同样也将这个部署输出::

   kubectl expose deployment web2 --target-port=8080 --type=NodePort

- 编辑刚才的 ``example-ingress.yaml`` 添加以下内容::

        - path: /v2/*
          backend:
            serviceName: web2
            servicePort: 8080

- 然后将修改生效::

   kubectl apply -f example-ingress.yaml

验证Ingress
=============

- 现在可以有2个pod，都是运行在8080的端口，其中1st版本访问::

   curl hello-world.info

输出::

   Hello, world!
   Version: 1.0.0
   Hostname: web-ddb799d85-889fm

- 访问 2nd 版本::

   curl hello-world.info/v2

输出::

   Hello, world!
   Version: 2.0.0
   Hostname: web2-5cf6945d9b-v5fbq

参考
=========

- `Set up Ingress on Minikube with the NGINX Ingress Controller <https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/>`_
