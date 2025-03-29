.. _using_kustomize:

====================================
使用Kustomize声明管理Kubernetes对象
====================================

:ref:`kustomize` 是使用kustomization文件来定制Kubernetes对象的独立工具。从Kubectl 1.14开始，Kubectl已经支持使用kustomization文件管理Kubernetes对象。

通过kubectl使用kustomize
=========================

简单来说，通过以下两条命令就可以使用kutomization文件：

- 查看包含kutomization文件的目录::

   kubectl kutomize <kutomization_directory>

- 应用这些资源，则也是使用 ``kubectl apply`` 不过参数采用 ``-k`` ::

   kubectl apply -k <kustomization_directory>

生成资源
=========

ConfigMap和Secret薄阿喊了配置或敏感数据，这些敏感数据需要被Kubernetes对象，如Pod使用。可以信任的ConfigMap或Secret通常从某处获取，例如，一个 ``.properties`` 文件或者一个ssh密钥文件。Kubernetes提供了 ``secretGenerator`` 和 ``configMapGenerator`` 用于根据文件或literals生成 Secret 和 ConfigMap。

configMapGenerator
-------------------

举例，我们通过一个 ``application.properties`` 来保存敏感的配置信息，然后使用 ``kustomization.yaml`` 来引用这配置文件。

- 创建一个 ``application.properties`` 文件内容如下::

   FOO=Bar

- 创建一个 ``kustomization.yaml`` 文件内容如下::

   configMapGenerator:
   - name: example-configmap-1
     files:
     - application.properties 

- 然后在这个目录下执行::

   kubectl kustomize ./

生成输出::

   apiVersion: v1
   data:
     application.properties: |
       FOO=Bar
   kind: ConfigMap
   metadata:
     name: example-configmap-1-8mbdf7882g

ConfigMap有支持从literal key-value对生成，将上述 kustomization.yaml 修改成::

   configMapGenerator:
       - name: example-configmap-2
         literals:
             - FOO=Bar

然后执行::

   kubectl kustomize ./

则生成::

   apiVersion: v1
   data:
     FOO: Bar
   kind: ConfigMap
   metadata:
     name: example-configmap-2-g2hdhfc6tk

参考
========

- `Kubernetes官方文档 Tasks > Manage Kubernetes Objects <https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/>`_
