.. _lfs_mba:

===================================
在 :ref:`mba11_late_2010` 部署LFS
===================================

因为我现在 :ref:`whats_past_is_prologue` ，不断在各处旅行，所以迫切需要一个较为完美的 :ref:`mobile_work` 解决方案。虽然我尝试了 :ref:`mobile_pixel_dev` ，但是手机屏幕实在太小，切换工作效率很低，所以我感觉平衡最好采用类似 MacBook Air 这样的轻量级笔记本。当然，现在苹果的 :ref:`arm` 架构 M系列 处理器性能强大，现在轻薄的MacBook Air性能也远比以前台式机强大，但对于无业游民的我来说，成本过于高昂。

``电子垃圾佬`` 自然有垃圾佬的快乐，从箱底翻出14年前购买的 :ref:`mba11_late_2010` ，一番折腾终于U盘启动点亮，开始了探索之旅:

.. figure:: ../../_static/apple/macos/apple-macbook-air-2010-11.jpg

   仅仅 **1.06公斤** 的 ``14年前`` MacBook Air ( ``扶我起来还能打`` )

:ref:`lfs_prepare`
===================

考虑到 :ref:`arch_linux` 社区支持丰富，有大量的文档可以学习参考，并且是滚动升级的轻量级发行版，所以我的 :ref:`mba11_late_2010` 采用先安装 :ref:`arch_linux` 再构建LFS:

- :ref:`arch_linux` 生态完备，例如 :ref:`archlinux_sway` 在 :ref:`archlinux_chinese` 支持完备，也是后续作为自己构建桌面的参考
- LFS构建需要连续稳定的工作环境，利用 :ref:`archlinux_hibernates` 可以随时保存工作状态，并随时继续进行构建工作
- 我自己对 :ref:`arch_linux` 也很有兴趣探索
