.. _almalinux_vs_rockylinux:

===============================
AlmaLinux vs. Rocky Linux
===============================

2021年12月31日，随着CentOS Linux 8来到生命周期重点(End of Life, EoL)，所有以CentOS作为Red Hat Enterprise Linux平替的企业和个人都需要考虑何去何从:

- CentOS将演变为CentOS Stream(9)，作为RHEL的开发版本和"滚动发布"版本，意味着在生产环境中使用存在风险
- 作为个人爱好者，期望有企业级的开发学习环境，并且紧跟RHEL技术发展，可以选择社区驱动快速迭代的 :ref:`almalinux`
- `Rocky Linux <https://rockylinux.org/>`_ 承诺bug级复制的RHEL，则更为适合需要完全复制Red Hat Enterprise Linux的企业用户(有时候bug的兼容也很重要，避免触发生产环境work around失效)，也适合企业规模升级后切换到Red Hat Enterprise Linux

区别
======

- 运营模式区别:

  - AlmaLinux 是由 CloudLinux (专门为大型托管服务提供商和数据中心提供定制的基于 Linux 的操作系统的公司) 创建和资助，但完全由社区管理和驱动(CloudLinux不拥有该项目和软件)
  - Rocky Linux由最初的 CentOS 项目创始人 Gregory Kurtzer 创立的 Rocky Enterprise Software Foundation (RESF) 控制和管理，意味着Kurtzer拥有Rocky(公司持有人和决策者)

- 社区区别:

  - AlmaLinux 和开源社区结合更紧密，没有采用绕开RHEL协议的方式，所以是ABI兼容(RHEL和EPEL)，开发极为活跃
  - Rocky Linux采用了1:1 Bug级兼容，通过RHEL协议漏洞(购买RHEL服务可以获得源代码)，实现像素级复制，更适合必须完全兼容RHEL的企业采用

- 商业支持区别:

  - AlmaLinux背后支持是微软(和IBM竞争)，如果想更快接触新技术，甚至可能采用微软Azure云计算，则可以选择AlmaLinux
  - Rocky Linux背后支持是谷歌，未来可能会类似CentOS一样和RedHat合作，如果需要维护企业现有配置以及传统的Linux线路，则建议选择Rocky Linux

我的选择
=========

我在2023年双十一时期购买了阿里云促销的99元/年 2c2g (ecs.e-c1m1.large) 3Mbps带宽:

.. csv-table:: 阿里云2c2g (ecs.e-c1m1.large) 计算存储
   :file: almalinux_vs_rockylinux/ecs.e-c1m1.large.csv
   :widths: 20,20,20,20,20
   :header-rows: 1

.. csv-table:: 阿里云2c2g (ecs.e-c1m1.large) 网络
   :file: almalinux_vs_rockylinux/ecs.e-c1m1.large_network.csv
   :widths: 20,20,20,20,20
   :header-rows: 1

由于我不想采用默认的AliOS，所以综合上述对比，选择采用 AlmaLinux 来学习开发

参考
======

- `AlmaLinux vs Rocky Linux：CentOS 替代你选择哪一个？ <https://www.51cto.com/article/705594.html>`_
- `CentOS Linux 即将到了生命周期终点，老用户何去何从 <https://www.linuxmi.com/centos-linux-eol.html>`_
- `同为CentOS的替代者，AlmaLinux 和 Rocky Linux有什么区别？该如何选择？ <https://www.zhihu.com/question/503401806>`_
- `Alma Linux 与 Rocky Linux 有什么不同？ <https://www.shixingceping.com/3906.html>`_
