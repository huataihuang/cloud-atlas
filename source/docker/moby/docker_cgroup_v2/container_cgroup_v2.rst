.. _container_cgroup_v2:

=======================
容器Cgroup v2技术
=======================

:ref:`docker_20.10` 支持 :ref:`cgroup_v2` 带来了很多新的特性:

- 简单的cgroup结构
- 面向 :ref:`ebpf` : 在 :ref:`cgroup_v2` 中设备访问控制是通过附加一个 :ref:`ebpf` 程序 ( ``BPF_PROG_TYPE_CGROUP_DEVICE`` )到 ``/sys/fs/cgroup/<group_name>`` 来实现的，例如可以实现 `BPF防火墙 <https://kailueke.gitlab.io/tags/bpf/>`_
- 易于实现 :ref:`container_cgroup_v2` 

...

原文有很多待探索和实践的信息，后续补充


参考
=======

- `The current adoption status of cgroup v2 in containers <https://medium.com/nttlabs/cgroup-v2-596d035be4d7>`_
