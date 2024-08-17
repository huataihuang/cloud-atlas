.. _swift_apprentice:

=======================
Swift学徒(apprentice)
=======================

.. note::

   本文只是我作为一个开发入门学习的尝试笔记，请勿贸然借鉴。

教材
======

学习iOS开发，Swift语言是必须掌握的基础。 `iOS开发学习指南(2021更新) <https://zhuanlan.zhihu.com/p/252835578>`_ 提到 `raywenderlich.com <https://www.raywenderlich.com>`_ 专注于苹果开发教学，提供了 `iOS & Swift Learning Paths <https://www.raywenderlich.com/ios/paths>`_ 众多教程(基础教程订阅 ``20美金/月`` ，高级教程订阅 ``40美金/月`` )

- `Swift Apprentice <https://www.raywenderlich.com/books/swift-apprentice/v7.0>`_
- `SwiftUI Apprentice <https://www.raywenderlich.com/books/swiftui-apprentice/v1.0/>`_
- `App Design Apprentice <https://readnote.org/app-design-apprentice-2nd-edition/>`_ 

- `iOS 17 App Development Essentials eBook <https://www.payloadbooks.com/product/ios-17-app-development-essentials-ebook/>`_

开发环境
==========

开发iOS软件必然需要一台运行 :ref:`macos` 的主机，但是需要注意:

- 苹果iOS/macOS发展极快: 虽然交互和外观因为延续用户习惯是通过渐进改进方式，但是实际底层技术在不断快速发展
- Xcode对运行的 :ref:`macos` 操作系统有强依赖要求， iOS 对手机环境也有硬性限制: 我的 :ref:`mbp15_late_2013` 最高只能运行 macOS Big Sur (当前使用 Version 11.6.8)，这也就限制了最高只能安装 Xcode 13.2.1 ; 我的 :ref:`iphone_se1` 限制最高只能运行 iOS 15.x
- 作为初学者，我暂时选择符合教材的同时又是我目前能够获得的有限硬件所支持的平台， :strike:`暂时采用 Xcode 13.2.1 对应开发 iOS 15应用` 后续计划在进阶阶段再改为最新的软硬件平台
- 苹果开发者账号(99刀)，虽然日常开发不需要，但是如果要测试Siri集成，iCloud访问，Apple Pay，Game Center以及应用内购买，则必须激活Apple Developer Program membership才能测试

.. note::

   `苹果开发者网站 <https://developer.apple.com/>`_ 提供了 `Xcode Support <https://developer.apple.com/support/xcode/>`_ 对Xcode需要的软硬件要求清单。

   如果你需要安装非最新的Xcode版本，可以从 `苹果开发者网站 <https://developer.apple.com/>`_ 的 `Xcode相关软件 <https://developer.apple.com/download/all/?q=Xcode>`_ 找到不同版本。

苹果官方提供 `Xcode Cloud <https://developer.apple.com/xcode-cloud/>`_ ，通过月租方式提供持续集成服务。每月10小时以内是免费的，对于正式开发、分发会有比较大的帮助。 不过，我也可能会自建 TestFlight 来完成开发流程。

参考
======

- `iOS开发学习指南(2021更新) <https://zhuanlan.zhihu.com/p/252835578>`_
