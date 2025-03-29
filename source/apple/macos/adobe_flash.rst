.. _adobe_flash:

==================
Adobe Flash
==================

如果你记得互联网历史，那么当年乔帮主深恶痛绝的flash，最早是在macOS/iOS平台被禁用和去除支持的。随后，微软也在2021年7月的安全更新中彻底移除了操作系统对flash的支持。

但是，很不幸的是，直到2024年，依然有一些特殊的原因需要我使用flash播放器。这是一个头疼的问题...

我最初想到的是Windows系统，因为我记得chrome曾经有一段时间还支持过直接内建支持播放flash，从网上的陈旧资料来看(当时我还没有找到正确参考)似乎有可能在Windows 10的IE浏览器中支持flash播放。其实，这些中文技术资料都已经过时了，我的最终实践发现:

- 只有早于2021年7月之前的Windows 10才内置了flash播放，但是一旦你完成Windows升级，那么这个flash播放功能就失去了。
- chrome,safari,firefox等浏览器早已放弃了flash支持，现在已经很难找到早期的支持版本了(我没有想过去找，毕竟太古老的版本官方也无法提供了，第三方无法保证安全 **绝对不要安装国内的所谓支持flash浏览器** )
 
我在 :ref:`install_win10_on_mac_with_boot_camp` 安装的Windows 10实际上是2018年版本的version 1803，这确实是一个符合flash支持的古早版本。但是很不幸，我当时不知道2021年7月之后的更新是移除了flash支持，所以默认选择了安装后自动更新。然后...更新后发现Window 10 update version 21H2 将大量的补丁在一个更新中完成，已经无法单独卸载 ``"Update for Removal of Adobe Flash Player" (also known as update KB4577586)`` 。

死胡同: 卸载更新包会影响系统稳定性和安全性，同时很多驱动也之后更新后才具备；不卸载更新则操作系统丢失了我所需要的flash播放功能...

好在天无绝人之路， `How to Use Adobe Flash (Even Though It's Dead) <https://www.howtogeek.com/707830/how-to-use-adobe-flash-in-2021-and-beyond/>`_ 提供了一个非常有用的信息: `ruffle.rs <https://ruffle.rs>`_ 一个开源flash player模拟器，可以跨平台支持flash播放。

简单来说:

- 支持不同平台播放Flash
- 提供 `chrome Ruffle - Flash Emulator插件 <https://chromewebstore.google.com/detail/ruffle-flash-emulator/>`_ ，可以在不同操作系统chrome浏览器(Windows/macOS等)内部播放Flash
- 没有提供safari插件

我实践验证，在 :ref:`macos` 下的chrome和 :ref:`install_win10_on_mac_with_boot_camp` 使用微软Edge浏览器(也是chrome核心)都可以正常运行该Ruffle插件，非常有用。

参考
=======

- `How to Use Adobe Flash (Even Though It's Dead) <https://www.howtogeek.com/707830/how-to-use-adobe-flash-in-2021-and-beyond/>`_
- `Windows 10 update will completely remove Adobe Flash Player in July <https://www.cnet.com/tech/services-and-software/windows-10-update-will-completely-remove-adobe-flash-player-in-july/>`_ ( `Security Update for Adobe Flash Player: February 11, 2020 <https://support.microsoft.com/en-us/topic/security-update-for-adobe-flash-player-february-11-2020-3cbd9cf1-2baf-5506-442e-58aafc25f338>`_ )
