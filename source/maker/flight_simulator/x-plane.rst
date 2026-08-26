.. _x-plane:

=====================
X-Plane模拟飞行
=====================

在 :ref:`macos` 平台，有原生的 `X-Plane 12 <https://www.x-plane.com/desktop/mac/>`_ 模拟飞行软件，并且作为工业级模拟飞行软件具有以下特征:

- 真机质感（更胜微软）：与《微软模拟飞行》偏向“地球级画面”不同，X-Plane 的核心卖点是极其恐怖的气流与空气动力学物理引擎。许多真实的航校、大学科研机构甚至 FAA（美国联邦航空管理局）认证的专业飞行模拟器，底层运行的都是 X-Plane。
- Mac 深度优化：它对 Apple Silicon（M1/M2/M3/M4 系列芯片）有极佳的原生优化，支持 Metal 图形 API。在 M4 Pro 等主流配置下，可以非常流畅地运行。
- 外设适配：它完美支持罗技、蜂窝（Honeycomb）、图马思特等主流民航 Yoke 方向盘和脚舵，在 Mac 上插上即可直接配置使用。
- 初教机全面：自带高精度的 :ref:`cessna_172` (Cessna 172 Skyhawk)，其仪表反应和操纵杆反馈非常适合用来训练 PPL 科目。

针对 :ref:`hackintosh` 优化
==============================

我的 :ref:`dell_t5820` 构建的的 :ref:`hackintosh` 存在GPU性能过剩但CPU性能不足的问题，所以在 X-Plane 12 中需要优化:

- 画质设置（Graphics Settings）

  - 纹理质量（Texture Quality）: 开到 **最大（Maximum）** 充分发挥 :ref:`amd_mi50` 32G 显存优势
  - 环境/阴影/植被（Objects/Vegetation）: **中（Medium）或低（Low）** 极度消耗 CPU 的渲染计算
  - 渲染分辨率: 设置为 **2K (2560x1440) 或 1080P**

- 学飞环境选择

  - 练习时， **关闭游戏内的 AI 交通飞机** （AI Aircraft 数量设为 0），降低 :ref:`xeon_w-2225` 压力
  - 尽量选择偏远、开阔的小航校机场进行起降训练（比如美国南加州的 KCRQ 或国内的小型通航机场），避开超大国际机场

其他macOS原生模拟飞行
=======================

- **Aerofly FS 4** : Aerofly FS 4 是一个轻量化的选择。它的渲染机制极快，加载迅速，画面在 Mac 上非常精致，但物理拟真度略逊于 X-Plane。
- :ref:`flightgear` : 完全免费且开源的顶级飞行模拟软件，支持 macOS。它的代码完全公开，拟真度很高，但缺点是画质较为复古，上手配置门槛极高，更适合极客玩家。

参考
======

- gemini
- `What are the best flight simulators for Mac? <https://flyawaysimulation.com/ask/answers/best-flight-simulators-mac/>`_
