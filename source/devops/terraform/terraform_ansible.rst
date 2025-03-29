.. _terraform_ansible:

===================================
结合Terraform和Ansible部署基础架构
===================================

Terraform - Inventory 这个第三方工具能够将Terraform生产出的资源转化为Ansible想要的Inventory文件，达到这一目的之后，Ansible就可以利用已有的Playbook和得到的Inventory文件来实现对于应用的快速部署。

Terraform 和 Ansible 分工协作
===============================

刚开始接触Terraform和Ansible，你会疑惑两者都是自动化基础架构的工具，会不会功能重合或者冲突。实际上，这两个工具各有侧重和所长，两者结合起来才能更好地自动化交付IaaS:

- Terraform擅长通过API来自动化云计算平台，交付虚拟机, VPC网络等，可以以一种抽象方式来处理不同的云厂商API完成基础VM交付，也包括 :ref:`openstack`
- Terraform在完成VM交付后，可以调用Ansible完成后续的配置管理自动化，这样Ansible就能够自动部署Kubernetes以及应用交付

我在 :ref:`real` 的基于 :ref:`hpe_dl360_gen9` 虚拟化环境，运行 :ref:`openstack` 以及使用在VM中部署交付 :ref:`kubernetes` 以及不同的应用系统，就可以采用上述结合技术平台。

参考
======

- `Ansible vs. Terraform: What's the difference? <https://www.youtube.com/watch?v=rx4Uh3jv1cA>`_
