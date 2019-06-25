.. _kubernetes_volumes:

====================
Kubernetes存储卷
====================

卷
====

在容器中的磁盘文件是易失的：当容器crash时，kubelet将重启容器，但是此时启动的容器是初始状态，上次启动后新创建的文件将丢失；另外容器中的文件很难在不同容器间共享。 Kubernetes ``Volumes`` 卷就是解决这些问题的抽象方法。

Kubernetes卷和Docker卷
----------------------

Docker也有一个 :ref:`docker_volume` 的概念，但是只是一个磁盘上或其他容器的一个目录。虽然现在Docker卷的功能更为丰富，但是Kubernetes的卷类型更为丰富和功能多样。

Kubernetes卷有一个明确的lifetime概念。Kubernetes卷是在Pod中所有容器所共享的，并且容器重启不影响卷上的数据。当Pod停止存在，则卷也停止存在。Kubernetes支持很多种卷，并且一个Pod可以同时使用任意数量卷。

为了使用一个卷，Pod必须指定哪个卷提供给Pod（通过 ``.spec.volumes`` 字段)以及卷如何挂载到容器中(通过 ``.spec.containers.volumeMounts`` 字段)

不同类型的Kubernetes卷
=======================

.. note::

   以下是我整理的自己关注的存储卷或常用存储卷，详细的所有支持卷类型，请参考 `Kubernetes Types of Volumes <https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes>`_

configMap卷
-------------

``configMap`` 资源提供了一种将配置数据插入Pod的方法。存储在一个 ``ConfigMap`` 对象中的数据可以被引用为类型 ``configMap`` 的卷，然后被容器化应用在Pod中使用。

当引用一个 ``configMap`` 对象，你可以简单提供在卷中的它的名字来引用。可以可以定制自定义路径来用于ConfigMap中特定入口。例如，要挂载 ``log-config`` ConfigMap 到名为 ``configmap-pod`` 的Pod，可以配置YAML如下::

   apiVersion: v1
   kind: Pod
   metadata:
     name: configmap-pod
   spec:
     containers:
       - name: test
         image: busybox
         volumeMounts:
           - name: config-vol
             mountPath: /etc/config
     volumes:
       - name: config-vol
         configMap:
           name: log-config
           items:
             - key: log_level
               path: log_level

这里 ``log-config`` ConfigMap被挂载成一个卷，所有的存储这个ConfigMap中的 ``log_level`` 入口被挂载到 Pod 的内部路径 ``/etc/config/log_level`` 。注意，这里路径是从volume的 ``mountPath`` 中获得的，并且这个路径的关键字是 ``log_level`` 。

也就是说，先定义了一个 ``/etc/config`` 的外部目录，这个卷目录被命名为 ``config-vol`` 卷 。然后配置这个卷 ``config-vol`` ，设置它的入口，也就是 ``/etc/config`` 目录的子目录 ``log_level`` 被命名为 ``log-config`` （请注意其属于 ``configMap`` ，所以是子目录映射），这个子目录（入口） ``log_level`` 被挂载到容器内部对应的 ``/etc/config/log_level`` 。

.. note::

   似乎 ConfigMap 在容器内外是完全一一对应的？只要指定 ``mountPath`` ，则该目录下子目录如果设定 ``configMap`` 就会从容器外映射到容器内部。

参考
=====

- `Kubernetes Concepts: Storage - Volumes <https://kubernetes.io/docs/concepts/storage/volumes/>`_
