.. _appendix:

=================================
附录
=================================

在撰写 :ref:`cloud_atlas` 过程中，有很多反复修改的章节，甚至在实践过程中，发现和最初规划完全不同的情况，导致推倒重来。

我把一些有参考价值，但是又和完整体系的撰写有所脱节的内容整理到附录中，包括:

- 在探索集群模拟的过程中，最初选择了Desktop版本作为基础操作系统，但是随着部署测试发现桌面版本复杂的显卡驱动适配、休眠设置导致系统稳定性欠佳，不得不重新安装服务器版本
- 错误选择了release版本，又升级到最新的release，逐渐发现终端显示花屏无法恢复，不得不重装系统

跌跌撞撞，依然不断探索前进，这里有自己的经验和体会，也许在今后依然有参考的价值，所以都汇总整理在这里。

.. note::

   在twitter上，我曾经看过不少非常有趣 `犀利而无用的知识 <https://twitter.com/hashtag/%E7%8A%80%E5%88%A9%E8%80%8C%E6%97%A0%E7%94%A8%E7%9A%84%E7%9F%A5%E8%AF%86>`_ ，我希望在实践中能够记录下有用的知识，在恰当的时候事半功倍完美解决问题。

.. toctree::
   :maxdepth: 1

   write_doc.rst
   intel_core_i7_4850hq.rst
   thinkpad_x220.rst
   intel_core_i5_2410m.rst
   desktop_base_os.rst
   netplan.rst
   efi_system_partition.rst
   using_btrfs_in_studio.rst
   reduce_laptop_overheat.rst
   share_mouse_keyboard.rst
   firewalld.rst
   ipmitool_tips.rst
   ip_command.rst
   win10_ssh_server.rst
   ssh_tunnel_gfw_autoproxy.rst
   anbox_scratch.rst


.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
