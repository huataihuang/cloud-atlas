.. _introduce_my_studio:

======================
模拟云计算的Studio
======================

最初的构想
=============

很多时候，我们在线上实现一个部署架构，是需要在线下环境反复推演，进行架构对比的。不过，作为个人爱好，显然无法像公司那样购买大批的物理服务器，来构建一个测试环境。

我最初的想法是用两个旧笔记本电脑，结合我的一些树莓派设备来构建一个OpenStack的云计算环境。不过，我也发现，实际上还是比较累赘，不仅旧笔记本的性能欠佳，而且这么多设备堆在一起，性能依然不如一台现代主流的服务器，也非常占用空间。

现在的构想
=============

我有一台2013年底自己购买的旧MacBook Pro，现在(2018年)已经退役，虽然这是5年前的笔记本，但是MacBook Pro做工和用料都很扎实，加上macOS充分发挥了硬件性能的操作系统，即使放到现在，这台当年的高配版本( `Apple MacBook Pro "Core i7" 2.3 15" Late 2013 <https://everymac.com/systems/apple/macbook_pro/specs/macbook-pro-core-i7-2.3-15-dual-graphics-late-2013-retina-display-specs.html>`_ ) 依然能够满足日常工作学习需要。

由于这台旧MacBook Pro处理器 `Intel® Core™ i7-4850HQ Processor <https://ark.intel.com/content/www/us/en/ark/products/76086/intel-core-i7-4850hq-processor-6m-cache-up-to-3-50-ghz.html>`_ ，支持非常完善的虚拟化高级特性，特别是通过硬件加速nested virtualization，也就是可以在一台主机上实现嵌套虚拟化。实际上，完全可以在一台硬件足够强大的笔记本上实现多个KVM Host，部署一个小型的OpenStack集群。同时在OpenStack的计算节点上，运行Docker+Kubernetes，这样可以完整模拟出一个小型的IaaS集群。

既然这台旧笔记本电脑性能足够强大且可以通过虚拟化模拟出大量的物理服务器，我们完全可以用一台主机来模拟数据中心，来实践以前需要大量服务器才能完成的测试工作。这套 :ref:`cloud_atlas` 将专注于数据中心技术，包括但不限于:

- :ref:`devops` -- 持续集成、持续测试和持续部署的技术探索，构建完整的软件生命周期管理
- :ref:`kvm` -- 探索KVM虚拟化技术，实现OpenStack云计算平台的底层技术架构
- :ref:`ceph` -- 构建OpenStack以及Kubernetes云计算的分布式存储
- :ref:`openstack` -- 实现基于KVM虚拟化的IaaS平台
- :ref:`docker` -- 探索容器技术，作为Kubernetes的基础技术
- :ref:`kubernetes` -- 容器的生命周期管理
- :ref:`mysql` -- 作为云计算重要的基础组件，提供OpenStack的底层支持
- :ref:`big_data` -- 大数据分析是支持云计算管理的关键技术
- :ref:`machine_learning` -- 在大数据基础上引入机器学习能够帮助我们分析和预测
- :ref:`kali_linux` -- 通过安全攻防来了解计算机安全技术
- :ref:`kernel` -- 内核是所有技术的基础，性能、稳定性、安全等等都需要内核支持

.. note::

   其实在公司的开发测试环境也是类似，如果没有特别的性能要求，可以采用本书提供的解决方案，采用少量的物理服务器来模拟大规模集群，测试软件产品以及验证部署架构。

一点一滴
=============

我准备实践一个模拟云计算的开发测试集群，就用一台MacBook Pro笔记本。主要的思路是通过 :ref:`nested_virtualization_in_studio` 来模拟多个物理主机，这样就可以搭建集群化的OpenStack云计算环境( :ref:`openstack` )；由于OpenStack采用了KVM虚拟化，能够运行大量的KVM虚拟机，进而可以在KVM虚拟机内部构建基于Kubernetes技术 ( :ref:`kubernetes` )的容器集群，甚至进一步实现基于GPU的机器学习环境 ( :ref:`machine_learning` )。

详细的各个技术实践细节，我将分不同的分册来撰写。

.. note::

   **只使用** ``一台`` 5年前的MacBook Pro笔记本，来构建一个云计算开发测试环境。

补充设备
===========

除了上述 MacBook Pro 设备能够完整模拟组建一个云计算集群外，我还有一台更为古老的 `ThinkPad X220 笔记本 <https://www.cnet.com/products/lenovo-thinkpad-x220-4287-12-5-core-i5-2410m-windows-7-pro-64-bit-4-gb-ram-320-gb-hdd-series/>`_ ，处理器是 :ref:`intel_core_i5_2410m` ，虽然性能较差，但是更换过SSD磁盘之后，感觉还有一战之力，所以就作为模拟云计算平台的补充设备。
