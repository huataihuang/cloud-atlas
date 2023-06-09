.. _change_k8s_image_registry:

==================================
更改Kubernetes的镜像配置registry
==================================

需求
======

Kuberntes 部署的 :ref:`workload_resources` 通常使用了不同的镜像仓库，在生产环境中，我们需要替换为私有仓库。此外，从 Kubernetes 1.25开始，官方宣布将镜像仓库从 ``k8s.gcr.io`` 迁移到 ``registry.k8s.io`` ，这也带来了对现有部署集群的迁移更新需求。

参考
======

- `Changes to the Kubernetes Container Image Registry <https://aws.amazon.com/blogs/containers/changes-to-the-kubernetes-container-image-registry/>`_
- `crane copy <https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_copy.md>`_
- `KUBERNETES CONTAINER IMAGE REGISTRY CHANGES <https://www.scalefactory.com/blog/2023/03/10/kubernetes-container-image-registry-changes/>`_
- `Collect and Publish Images to your Private Registry <https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/air-gapped-helm-cli-install/publish-images>`_ :ref:`rancher` 下载和发布镜像到私有registry
- `Mutation to replace image registry #2381 <https://github.com/open-policy-agent/gatekeeper/issues/2381>`_ 替换镜像registry的一些讨论
