.. _ios_background_execution_limits:

===========================
iOS后台运行限制
===========================

我在使用 :ref:`ish` 时，发现我在 ``ish`` 中安装运行的 :ref:`ssh` 服务，只要屏幕锁定或者 ``ish`` 放到后台，网络立即断开。这比 :ref:`android` 平台限制要严格很多，Android平台的 :ref:`termux` 放到后台至少能运行(但会响应缓慢)，甚至可以在配置中设置 ``termux`` 在Android后台运行，只要内存足够甚至可以永远不被杀死而一直运行。

那么iOS平台，能否让一个 ``ssh`` 服务运行在 ``ish`` 中始终保持呢？

简单来看，答案是: **不行**

也就是说， ``iOS没有通用机制`` 可以用于:

- 在后台持续运行代码
- 在后台的某个特定时间运行代码
- 以保证的间隔定期运行代码
- 响应网络或 IPC 请求在后台恢复

iOS为了确保流畅、安全和节能，有严格的后台运行限制: ``只提供各种专用机制来实现特定的用户目标``

- 音乐播放器可以使用 audio `UIBackgroundModes <https://developer.apple.com/documentation/bundleresources/information_property_list/uibackgroundmodes>`_ 在后台继续播放
- 时钟应用可以使用 `User Notifications <https://developer.apple.com/documentation/usernotifications>`_ 通知用户计时过期
- 视频应用可以使用AVfoundation的 `Using AVFoundation to play and persist HTTP Live Streams <https://developer.apple.com/documentation/avfoundation/using-avfoundation-to-play-and-persist-http-live-streams>`_

.. note::

   每种机制都具有特定的用途

   苹果的appstore会审核应用机制

.. note::

   我这里没有完整整理，有待后续学习实践

参考
======

- `iOS Background Execution Limits <https://developer.apple.com/forums/thread/685525>`_
