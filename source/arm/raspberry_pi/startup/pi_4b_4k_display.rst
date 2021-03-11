.. _pi_4b_4k_display:

=========================
Raspberry Pi 4B的4K显示
=========================

在 :ref:`pi_400_4k_display` 实践中，我尝试使用Raspberry Pi 400来实现一个能够使用4K显示器的工作平台。但是，实践发现Raspberry Pi 400没有实现60Hz刷新率的4K输出(至少目前我实践没有成功)。

不过，既然我有3台Raspberry Pi 4B，硬件架构和Raspberry Pi 400几乎完全一致，所以我把TF卡从 ``pi-master1`` 和 ``pi400`` 互换，将2GB规格的Raspberry Pi 4B连接到4K显示器上作为工作桌面。

.. note::

   不过，Raspberry Pi 4B当时为了省钱，购买了入门规格2GB，所以不能运行大量的桌面程序。理想的架构是作为瘦客户端，把所有的计算都调度到 :ref:`arm_k8s` 来完成。甚至把重度应用调度到远程云服务器上运行的x86容器中运行。

架构
=======


