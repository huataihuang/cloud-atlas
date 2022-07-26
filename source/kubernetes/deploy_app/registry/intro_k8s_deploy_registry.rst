.. _intro_k8s_deploy_registry:

===============================
Kubernetes部署registry仓库简介
===============================

参考
=======

- `Deploy Your Private Docker Registry as a Pod in Kubernetes <https://medium.com/swlh/deploy-your-private-docker-registry-as-a-pod-in-kubernetes-f6a489bf0180>`_ 简洁明了
- `Install a Private Docker Container Registry in Kubernetes <https://faun.pub/install-a-private-docker-container-registry-in-kubernetes-7fb25820fc61>`_
- `How To Set Up a Private Docker Registry on Top of DigitalOcean Spaces and Use It with DigitalOcean Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-top-of-digitalocean-spaces-and-use-it-with-digitalocean-kubernetes>`_ DigitalOcean的这篇文档采用了S3兼容存储后端，我将参考改造成采用Ceph后端
- `How To Set Up a Private Docker Registry on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-20-04>`_ 使用Docker运行
- `Deploy a registry server <https://docs.docker.com/registry/deploying/>`_ docker官方文档
