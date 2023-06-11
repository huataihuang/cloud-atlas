.. _intro_flight_simulator:

=======================
微软飞行模拟游戏简介
=======================

《微软模拟飞行》（英语：Microsoft Flight Simulator，又译作“微软模拟飞行2020”）是由Asobo工作室开发开发并由Xbox游戏工作室发布的业余飞行模拟器游戏，为《微软模拟飞行系列》的正统续作。2020年8月18日正式发售Windows  PC版，2021年7月27日发售Xbox版本。

游戏使用来自必应地图数据模拟整个地球的地形。Microsoft
Azure的人工智能（AI）生成地球特征的三维表示，使用其云计算来渲染和增强视觉效果，并使用真实世界的数据生成实时天气和效果。飞行模拟器有一个物理发动机来提供逼真的飞行控制面，具有1000多个模拟表面，以及在丘陵和山脉上建模的真实风。为了增强其真实感，Azure还融入了实时元素，如自然天气和真实世界的空中交通。游戏玩法包括着陆挑战和助手功能等新功能，以及飞行员可以从空中拍摄动物的狩猎之旅。与该系列其他作品的明显区别是游戏没有显示任何破坏场景。

.. note::

   我是一个游戏盲(从小不玩游戏)，但是我想要挑战微软飞行模拟游戏:

   - 探索 :ref:`kvm` 虚拟化技术结合 :ref:`vgpu` ，从而对虚拟化技术更为深入了解
   - 休闲放松，纵览世界风光

硬件平台
===========

我购买了一块二手的 :ref:`tesla_p10` 运算卡，通过 :ref:`vgpu_unlock` 解锁了 :ref:`vgpu` 支持，可以在虚拟机中增强显示:

- Tesla P10 性能相当于 GeForce RTX 2070 Super，参考 `去世界任何角落 看想看的风景！微软模拟飞行2020显卡需求测试 <https://finance.sina.cn/tech/2021-05-01/detail-ikmxzfmk9887688.d.html?fromtech=1&vt=4&cid=38741&node_id=38741>`_ 可以看到RTX 2070 Super 在 2K 分辨率下的帧数是 ``49FPS`` (如果是4k则只有28FPS，无法流畅运行)，尚能饭否？
- :ref:`vgpu` 显存分配准备从 6GB 开始( `NVIDIA GeForce RTX 2070 SUPER <https://www.techpowerup.com/gpu-specs/geforce-rtx-2070-super.c3440>`_ 是8GB显存 )，如果不足则调整为 12GB
- :ref:`kvm` 虚拟机配置 32GB (嘿嘿， :ref:`hpe_dl360_gen9` 最高支持768GB内存哦)

- 飞行摇杆: 待调研

- 操作系统: :ref:`win10` KVM虚拟机

参考
======

- `微软模拟飞行 (2020年游戏) <https://zh.wikipedia.org/wiki/%E5%BE%AE%E8%BB%9F%E6%A8%A1%E6%93%AC%E9%A3%9B%E8%A1%8C_(2020%E5%B9%B4%E9%81%8A%E6%88%B2)>`_
- `微软模拟飞行2020 <https://help.tobii.com/hc/zh-cn/articles/4410966959377-%E5%BE%AE%E8%BD%AF%E6%A8%A1%E6%8B%9F%E9%A3%9E%E8%A1%8C2020>`_ Tobii眼动仪增强模拟飞行感觉
- `普通玩家的《微软模拟飞行 2020》体验 <https://sspai.com/post/62234>`_ 少数派的体验
