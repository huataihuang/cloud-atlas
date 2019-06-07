.. _kubernetes_expose_service:

======================
输出Kubernetes应用服务
======================

在 :ref:`kubernetes_objects` 章节我们参考Kubernetes官方案例创建了2个副本的nginx部署::

   kubectl apply -f https://k8s.io/examples/application/deployment.yaml --record

但是，部署只是确保容器pod在Kubernetes集群中运行，并没有对外提供（输出）服务，外部还不能访问我们的WEB服务器。

本章节我们学习和测试如何输出Kubernetes集群的服务，把Nginx应用真正对外提供服务。

服务输出尝试
================

- 将部署输出::

   kubectl expose deployments nginx-deployment --port=80 --name=expose-test1 --type=LoadBalancer

然后我们检查输出的服务::

   kubectl get services

可以看到输出::

   NAME               TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
   expose-test1       LoadBalancer   10.101.32.198   <pending>         80:31482/TCP   5h36m

.. note::

   请注意，由于没有明确指定 ``external-ip`` ，所以这个服务没有绑定IP地址，实际上还无法对外提供服务。此时可以看到 ``EXTERNAL-IP`` 显示的是 ``pending`` 状态。从 

.. note::

   上述输出服务命令（加上了 ``--name=expose-test1`` 是为了标识以便和其他配置区别）虽然能够创建服务输出，但是在dashboard上观察，可以看到服务是 ``pending`` 状态的，实际上并不能通过端口80访问。

   不过，kubernetes会在物理服务器（node）上创建一个随机的 ``nodePort`` 31482 ，实际上访问 http://xcloud:31482 是可以打开nginx页面的(但和我们对外输出服务不同)。检查yaml::

      {
        "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
          "name": "expose-test1",
          "namespace": "default",
          "selfLink": "/api/v1/namespaces/default/services/expose-test1",
          "uid": "9b762258-87ff-11e9-a47b-b8e85633e48a",
          "resourceVersion": "636271",
          "creationTimestamp": "2019-06-06T02:05:50Z"
        },
        "spec": {
          "ports": [
            {
              "protocol": "TCP",
              "port": 80,
              "targetPort": 80,
              "nodePort": 31482
            }
          ],
          "selector": {
            "app": "nginx"
          },
          "clusterIP": "10.101.32.198",
          "type": "LoadBalancer",
          "sessionAffinity": "None",
          "externalTrafficPolicy": "Cluster"
        },
        "status": {
          "loadBalancer": {}
        }
      }

- 通过负载均衡方式将pod上服务输出到外部网络::

   kubectl expose deployments nginx-deployment --port=80 --protocol=TCP --target-port=80 --name=nginx-expose --external-ip=192.168.101.81 --type=LoadBalancer

输出::

   service/nginx-deployment exposed

在Kubernetes中（实际上云计算平台的LoadBalancer都是如此）可以为负载均衡配置可用网段的任何IP地址，这个操作是告诉负载均衡监听哪个对外IP地址并做NAT转发负载均衡到后端real server。所以，我们可以创建真正对外服务IP地址（例如192.168.101.101），而不是复用当前我们运行pod的物理服务器（192.168.101.81）的IP地址::

   kubectl expose deployments nginx-deployment --port=80 --protocol=TCP --target-port=80 --name=nginx-service --external-ip=192.168.101.101 --type=LoadBalancer

.. note::

   这里我们给输出的服务命名为 ``nginx-service`` 
   

参考
========

- `Exposing an External IP Address to Access an Application in a Cluster <https://kubernetes.io/docs/tutorials/stateless-application/expose-external-ip-address/>`_
