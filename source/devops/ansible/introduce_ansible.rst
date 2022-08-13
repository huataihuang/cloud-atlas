.. _introduce_ansible:

=======================
Ansible自动化工具简介
=======================

.. note::

   随着 :ref:`kubernetes` 和容器技术的兴起，传统的 ``配置管理工具`` Ansible 和 Puppet 等工具逐渐缩小了应用场景。不过，对于裸服务器部署(也就是容器环境尚未就绪)，配置管理工具依然能够发挥大规模自动化管理的优势。

   简单来说，可以采用Ansible这样的配置管理工具完成底层构建，再此基础上自动化构建 :ref:`kubernetes` 容器调度和运行环境，来实现超大规模服务

参考
=======

- `Ansbile 101 by jeff Geerling <https://www.youtube.com/watch?v=goclfp6a2IQ&list=PL2_OBreMn7FqZkvMYt6ATmgC0KAGGJNAN>`_ 非常详尽的Ansible视频课程，推荐
- David Bombal在YouTube上有一个讨论Python和网络自动化的频道 `David Bombal <https://www.youtube.com/channel/UCP7WmQ_U4GB3K51Od9QvM0w>`_
