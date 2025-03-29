.. _termux_browser:

=============================
Termux环境WEB浏览器
=============================

我在使用termux的tmux终端时，突然想到能否在 :ref:`tmux` 的split终端中使用字符浏览器，这样就不必切换应用程序，或许对于移动终端，这种工作方式可以减轻程序切换负担(目前移动设备很难像电脑那样多任务)。

简单尝试了一下，并且思考如下:

- 字符浏览器确实不适合现代WEB网站浏览，即使类似 `browsh <https://www.brow.sh/>`_ 这样以headless firefox在服务器上渲染页面，能够完全支持所有WEB内容渲染的字符浏览器也不堪使用:

  - 现代WEB网站太依赖图片和JS/CSS，无法直接渲染图形页面的限制导致大多数页面都无法正确传递信息和进行交互
  - 只有自己严格设置全文字(或主要通过文字传递)

- 可能的选项:

  - `elinks <https://github.com/rkd77/elinks>`_ 2017年从elinks项目fork出来重新以felinks开发，一定程度支持ECMAScript(通过Mozilla的SpiderMokey JavaScript引擎)
  - `links <http://links.twibright.com/>`_ 依然在持续维护开发的字符浏览器，对于文字类WEB非常友好，但是不支持JS

- 其他废弃的选项:

  - ``w3m`` 不支持JS和frame，显示非常简陋，并且不能使用鼠标操作，只适合对单页面文档浏览

参考
======

- `Text-based web browsers for Linux command line usage <https://www.fosslinux.com/49619/open-source-terminal-web-browsers.htm>`_
- `Netrik Web Browser <http://netrik.sourceforge.net>`_
