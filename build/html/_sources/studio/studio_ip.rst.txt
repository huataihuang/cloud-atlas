.. _studio_ip:

=========================
Studio测试环境IP分配
=========================

在模拟测试环境中，采用了KVM虚拟化来实现单台主机（MacBook Pro）来模拟集群的部署，以下是部署的步骤，如果你准备借鉴我的实验环境部署方法，可以先跳到以下章节参考:

- :ref:`create_vm_in_studio`
- :ref:`clone_vm_in_studio`
- :ref:`nested_virtualization_in_studio`
- :ref:`libvirt_static_ip_in_studio`

为方便测试环境服务部署，部分关键服务器采用了静态IP地址，解析地址如下（配置在Host主机上）::

   192.168.122.2   ubuntu18-04 ubuntu18-04.huatai.me
   
   192.168.122.10  minikube     minikube.huatai.me
   192.168.122.11  kube-master1 kube-master1.huatai.me
   192.168.122.12  kube-master2 kube-master2.huatai.me
   192.168.122.13  kube-master3 kube-master3.huatai.me

   192.168.122.20  devstack devstack.huatai.me
   192.168.122.21  devstack-1 devstack-1.huatai.me
   192.168.122.22  devstack-2 devstack-2.huatai.me
