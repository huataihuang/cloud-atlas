.. _appendix:

=================================
附录
=================================

在撰写 :ref:`cloud_atlas` 过程中，有很多反复修改的章节，甚至在实践过程中，发现和最初规划完全不同的情况，导致推倒重来。

我把一些有参考价值，但是又和完整体系的撰写有所脱节的内容整理到附录中，包括:

- 在探索集群模拟的过程中，最初选择了Desktop版本作为基础操作系统，但是随着部署测试发现桌面版本复杂的显卡驱动适配、休眠设置导致系统稳定性欠佳，不得不重新安装服务器版本
- 错误选择了release版本，又升级到最新的release，逐渐发现终端显示花屏无法恢复，不得不重装系统

跌跌撞撞，依然不断探索前进，这里有自己的经验和体会，也许在今后依然有参考的价值，所以都汇总整理在这里。

.. toctree::
   :maxdepth: 1

   appendix_base_os.rst
   ubuntu_server.rst
   upgrade_ubuntu_from_18.10_to_19.04.rst
   ubuntu_desktop.rst
   reduce_laptop_overheat.rst
   vmware_in_studio.rst
   share_mouse_keyboard.rst
   ubuntu_hibernate.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
