.. _apple_container_startup:

===========================
Apple container快速起步
===========================

2025年WWDC开幕前5天，apple终于亲自下场，开源了 `GigHub: apple/container <https://github.com/apple/container>`_ ，对标 :strike:`colima` Windows WSL，在Apple silicon上提供了一个创建和运行Linux容器的轻量级虚拟机。

.. note::

   很遗憾， ``apple container`` 是类似 :ref:`apple_virtualization` 之上运行轻量级Linux虚拟机来运行容器的工具(类似 :ref:`lima` 上的 :ref:`colima` )，并没有我所期望的官方提供类似 :ref:`darwin-containers` 容器化运行 :ref:`macos` 的能力。不过，Apple官方出品，意味着软件工程质量的保障，也意味着macOS也如同Windows一样，将Linux融入了自己的血脉。

这意味着Apple希望吸引开发者将 :ref:`macos` 作为一个开发平台，和Windows竞争，实现统一的前后端开发(毕竟Linux统治了服务器领域)。

由于我暂时没有Apple Silicon设备，所以我将在后续合适的时候再实践，待续...
