=========================================
22.2 Ansible vs. Chef vs. Puppet
=========================================

------------
困惑
------------

截止目前，我使用过的DevOps工具是Puppet和Ansible

* Puppet曾经部署维护过5万以上节点，对这个强制一致性的配置管理工具留下了极深的印象
* Ansible主要在集群变更中使用，快速而灵活的批量处理，是其比较优势的地方，但是目前我还没有深入了解关于海量服务器一致性配置管理的方案

我一直在纠结应该如何对比和使用这些工具，既有相同之处，又有明显的理念区别，就像金庸在「神雕侠侣」中说到 `杨过苦思"最擅长的到底是那一门功夫？"，最后想到"诸般武术皆可为我所用" <https://book.douban.com/annotation/31075486/>`_

------------
对比和思考
------------

* 从工具编写语言来说，Ansible采用Python的前景更好，Chef和Puppet采用Ruby+Erlang相对小众
* 从GitHub趋势和 `stackshare对比Ansible vs. Chef vs. Puppet Labs <https://stackshare.io/stackups/ansible-vs-chef-vs-puppet>`_ Ansible的使用者数量远超Chef和Puppet，但是Chef和Puppet各有一些重量级用户。

.. note:

    我还要多思考和比较
    在沙箱环境，部署Ansible和Puppet来实现综合解决方案，并对比优劣（功能和性能）

------------
参考
------------

* `Choosing a deployment tool - ansible vs puppet vs chef vs salt <https://gist.github.com/jaceklaskowski/bd3d06489ec004af6ed9>`_
* `Puppet Vs Ansible <https://www.devopsguys.com/2018/01/10/puppet-vs-ansible/>`_