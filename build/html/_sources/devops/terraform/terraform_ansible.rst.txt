.. _terraform_ansible:

===================================
结合Terraform和Ansible部署基础架构
===================================

Terraform - Inventory 这个第三方工具能够将Terraform生产出的资源转化为Ansible想要的Inventory文件，达到这一目的之后，Ansible就可以利用已有的Playbook和得到的Inventory文件来实现对于应用的快速部署。
