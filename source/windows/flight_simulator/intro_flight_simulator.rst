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

- 我购买了一块二手的 :ref:`tesla_p10` 运算卡，通过 :ref:`vgpu_unlock` 解锁了 :ref:`vgpu` 支持，可以在虚拟机中增强显示:

  - Tesla P10 性能相当于 GeForce RTX 2070 Super，参考 `去世界任何角落 看想看的风景！微软模拟飞行2020显卡需求测试 <https://finance.sina.cn/tech/2021-05-01/detail-ikmxzfmk9887688.d.html?fromtech=1&vt=4&cid=38741&node_id=38741>`_ 可以看到RTX 2070 Super 在 2K 分辨率下的帧数是 ``49FPS`` (如果是4k则只有28FPS，无法流畅运行)，尚能饭否？
  - :ref:`vgpu` 显存分配准备从 6GB 开始( `NVIDIA GeForce RTX 2070 SUPER <https://www.techpowerup.com/gpu-specs/geforce-rtx-2070-super.c3440>`_ 是8GB显存 )，如果不足则调整为 12GB
  - :ref:`kvm` 虚拟机配置 32GB (嘿嘿， :ref:`hpe_dl360_gen9` 最高支持768GB内存哦)

- 准备入手 :ref:`amd_firepro_s7150x2` 来部署:

  - :ref:`mxgpu` (也就是 :ref:`sr-iov` )实现GPU VF直通给Windows虚拟机

    - `How to SR-IOV Mod the W7100 GPU <https://forum.level1techs.com/t/how-to-sr-iov-mod-the-w7100-gpu/164186>`_ 使用了修订版本的 `GitHub GPUOpen-LibrariesAndSDKs/MxGPU-Virtualization <https://github.com/GPUOpen-LibrariesAndSDKs/MxGPU-Virtualization>`_ (不知道最近几年 :ref:`mxgpu` 是否有其他更好的解决方案)

  - 实现一个类似 `Looking Glass <https://looking-glass.io/>`_ 的远程运行 :ref:`windows` 桌面:

    - ``Looking Glass`` 使用 SPICE 协议驱动实现的虚拟桌面的键盘/鼠标/音频，见 `Looking Glass Installation <https://looking-glass.io/docs/B6/install/>`_ ，具体工作原理见YouTube视频 `How Looking Glass works and why it was invented <https://www.youtube.com/watch?v=U44lihtNVVM>`_ ，但是其视频性能优于原生 SPICE video (待验证)，所以建议使用 ``Looking Glass`` (参考 `Im geting so tired (mxgpu, sr-iov) <https://forum.level1techs.com/t/im-geting-so-tired-mxgpu-sr-iov/155195>`_ 讨论)
    - 另一种模式是使用 RDP client ，例如 ``Remmina`` Linux 客户端访问Windows桌面，但不知道哪种性能更好更稳定，待实践对比

- 操作系统: :ref:`win10` KVM虚拟机

外设
=======

- 传统飞行摇杆 (Joystick / HOTAS)

  - 外观形态：单手摇杆，或升级为“左手节流阀（控制油门）+ 右手摇杆”的双手操作组合（HOTAS）。

- 民航飞行方向盘 (Yoke)

  - 外观形态：模仿真实客机（波音、Cessna等）的双手 U 型方向盘，需固定在桌边，通常搭配多联轴节流阀模块。

- 游戏手柄 (Controller)

  - 外观形态：普通的 Xbox 或 PS5 游戏手柄。

.. note::

   私人飞行员执照（一般简称为 PPL，Private Pilot License）时，绝大多数学员和航校使用的经典初教机是 塞斯纳 172 (Cessna 172) 或 派珀 PA-28 (Piper PA-28)，这些飞机全部采用的是 双手民航方向盘 (Yoke)，而不是单手操作的飞行摇杆 (Joystick)。

   如果你想体验 100% 真实的学飞过程，民航方向盘 (Yoke) 系统 是唯一正确的选购目标。

核心选购
------------

**Yoke（方向盘）+ Throttle（油门）+ Rudder（脚舵）**

在真实的飞机里，需要全方位联动。想要最真实的体验，需要以下三件套:

- 双手拉推盘 (Yoke)：控制飞机的上下俯仰（推拉）和左右滚转（旋转盘面）。
- 推拉式油门 (Throttle Quadrant)：塞斯纳 172 的油门不是推杆，而是像针管一样的推拉式黑色拉杆。
- 飞行脚舵 (Rudder Pedals)：在地面上用脚控制飞机前轮转向，在空中控制方向舵（偏航），并且用来踩刹车。

硬件推荐
===========

Honeycomb (蜂窝) 组合 + 独立脚舵
-------------------------------------

**终极仿真推荐：Honeycomb (蜂窝) 组合 + 独立脚舵** （总价约 ¥5,000 - ¥6,500）

这是目前全球模拟飞行玩家和准飞行员公认最接近真机质感的组合。

- 蜂窝 Alpha 方向盘 (Honeycomb Alpha Flight Controls)

内部采用了高强度弹力绳和机械结构，完美模拟了真机那种带有韧性、需要一点力量才能拉动或推入的阻尼感。盘面上还自带了航校真机上必备的开/关灯和点火钥匙开关。

- 蜂窝 Bravo 油门座 (Honeycomb Bravo Throttle Quadrant)

不仅可以组装成多引擎大客机的推杆，更附带了一套专为塞斯纳设计的推拉式游标控制手柄（黑色油门、蓝色螺旋桨、红色混合比），与真机一模一样。

- 图马思特 TFRP 或 罗技飞行脚舵

脚舵放在桌下配合使用，因为真实开飞机在起飞、降落和风中修正时，必须靠双脚不断踩舵。

Turtle Beach VelocityOne Flight（乌龟海岸）
-----------------------------------------------

**一体化解决真机体验的最佳方案**

- 全集成面板：不仅包含一个 Yoke 方向盘，右侧直接做进去了两种油门模式（客机推杆模式和塞斯纳式的三色推拉游标模式）。
- 自带配平轮：右侧有一个很大的配平轮（Trim Wheel）。

罗技 G 飞行方向盘三件套 (Logitech G Flight System)
------------------------------------------------------

基础款 Yoke：罗技的 Yoke 内部是弹簧结构，正中央有一个机械卡位（Deadzone），手感虽然没有蜂窝那么细腻，但它的外形和操作逻辑与航校真机完全一致，价格更加平易近人。

搭配建议：购买罗技 Yoke 方向盘（自带一个普通三轴油门），再额外加购一个罗技飞行脚舵，即可组成低成本的“个人驾照三件套”。

软件使用
==============

`微软飞行模拟~新手向入门指引 <https://steamcommunity.com/sharedfiles/filedetails/?l=german&id=3369432394>`_ 非常详细的游戏指南

参考
======

- `微软模拟飞行 (2020年游戏) <https://zh.wikipedia.org/wiki/%E5%BE%AE%E8%BB%9F%E6%A8%A1%E6%93%AC%E9%A3%9B%E8%A1%8C_(2020%E5%B9%B4%E9%81%8A%E6%88%B2)>`_
- `微软模拟飞行2020 <https://help.tobii.com/hc/zh-cn/articles/4410966959377-%E5%BE%AE%E8%BD%AF%E6%A8%A1%E6%8B%9F%E9%A3%9E%E8%A1%8C2020>`_ Tobii眼动仪增强模拟飞行感觉
- `普通玩家的《微软模拟飞行 2020》体验 <https://sspai.com/post/62234>`_ 少数派的体验
