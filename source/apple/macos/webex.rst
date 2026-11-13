.. _webex:

===========
Webex
===========

安装
======

Webex 官方下载页: `webex downloads <https://www.webex.com/downloads.html>`_ ，选择 ``Download for admins`` 以先泽下载安装包(默认首页面只有移动手机客户端下载链接)。

:ref:`homebrew` 也提供了安装命令:

.. literalinclude:: webex/install
   :caption: brew安装webex

实际上即使不安装桌面客户端，直接用 Chrome 或 Safari 浏览器打开链接，点击页面下方的 "Join from your browser" (从浏览器加入) 也能直接进行视频会议。不过为了保证音画稳定和屏幕共享权限正常，强烈建议提前装好桌面客户端并授予 macOS 麦克风、摄像头和屏幕录制权限。

使用
======

- 自我测试webex可以访问 `webex test <https://www.webex.com/test-meeting.html>`_ 已方便正式使用前验证音频和视频，不需要注册任何账号。

- 日常商务会议沟通通常会使用 ``专属的 Webex 会议链接(以及会议号和密码)`` ，点击该链接，系统会自动唤起你安装好的 Webex 桌面客户端(或引导你在浏览器中打开):

- 客户端界面只会要求你输入两项信息，填完点击 "作为访客加入(Join as a guest)" 或 "加入会议(Join meeting)"

  - 你的显示名称
  - 你的邮箱地址

- webex提供了实时字幕(Live Captions)支持开启英文实时字幕(Closed Captions，仅在本地显示，不会通知对方，也不涉及录音保存)

- webex没有内置"在线编程"功能，通常可以使用 CoderPad 或 HackerRank CodePair

  - `CoderPad Sandbox <https://coderpad.io/sandbox>`_ CoderPad官方免费沙盒练习区，无需注册账号，提供了自动补全和报错输出页面，可以模拟编程测试
