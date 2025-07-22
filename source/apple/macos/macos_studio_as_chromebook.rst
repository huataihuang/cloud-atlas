.. _macos_studio_as_chromebook:

=================================
像Chromebook一样构建macOS工作室
=================================

自从不小心在 :ref:`mbp15_2018` 上打翻了咖啡， :ref:`mbp15_late_2013` 就成了我手头最好的笔记本电脑了。然而，2025年使用这12年前的的硬件设备，已经存在诸多不便:

- macOS永远停留在 ``Big Sur`` v11.7.10，已经不能支持很多应用升级，包括XCode也无法安装最新版本: 这意味着无法开发最新的iOS程序
- :ref:`homebrew` 已经不再支持旧版本macOS，所以实际上在很多开源软件安装上非常折腾，甚至连运行 :ref:`colima` 都被逼手工编译安装 :ref:`homebrew_old_qemu`
- 运行有些卡顿，特别是输入法切换常常转菊花

我的计划是在合适的时候入手一台传说中的 ``搭载A18 Pro的13寸廉价版MacBook`` ( :ref:`mac_mini_2024` 其实也很好，但是没有屏幕携带使用实在不便)，然而当前我依然需要让手头这款唯一可用的MacBook继续发挥余热:

- :ref:`mbp15_late_2013` 的15寸高清屏幕是目前我移动笔记本中最好的硬件，我在 :ref:`freebsd_on_thinkpad_x220` 坚持一个月之后，实在无法忍受狭小屏幕的低效
- 我已经将主要的工作迁移到 :ref:`freebsd` 和 :ref:`lfs` ，并结合采用 :ref:`raspberry_pi` 构建模拟集群，这意味着所有的工作都在后台服务器上，随时可以切换前端工作平台
- :ref:`macos` 便捷的桌面，近乎完美的多媒体体验，省却了我很多折腾 :ref:`linux_desktop` 和 :ref:`freebsd_desktop` 的精力: 是的，我已经在桌面和中文化上投入了太多的时间精力...

anyway，我现在的目标就是继续 :ref:`machine_learning` / :ref:`kubernetes` 等后台开发工作，而macOS，也就是我老迈的 :ref:`mbp15_late_2013` 将只运行浏览器和终端，就像我曾经探索过的 :ref:`chromeos` 一样，作为一个远程访问的桌面入口:

- 只安装 :ref:`chrome` 和 ``iTerm2`` 程序(甚至不安装 :ref:`homebrew` )
- macOS原生的中文输入
- 所有开发和运维工作都登陆到我已经构建好的 :ref:`freebsd_jail` 或 :ref:`docker` / :ref:`kubernetes` 环境中进行: 甚至可以在Jail和Docker容器中运行FreeBSD/Linux桌面程序，通过 :ref:`xpra` 构建提供给本地macOS使用，这样所有的计算都将在强大硬件的服务器上完成，并且能够提供无缝迁移

安装
=======

- 重新开始 :ref:`macos_recovery` ，获得干净的操作系统
- 安装 ``iTerm2`` 作为终端
- 安装 :ref:`chrome` 和 :ref:`chrome_sync_extensions_themes`

**ALL DONE**
