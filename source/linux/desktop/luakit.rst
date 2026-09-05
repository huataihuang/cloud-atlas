.. _luakit:

==================
luakit
==================

Luakit、Badwolf、Midori 和 Surf 这类轻量浏览器，本质上都是基于 WebKit Engine (WebKitGTK) 开发的 UI 外壳。它们与 :ref:`firefox` 的根本区别在于内核架构与设计哲学。

.. csv-table:: 轻量级浏览器 vs. Firefox
   :file: luakit/browser_compare.csv
   :widths: 20,40,40
   :header-rows: 1

Luakit 采用Lua 语言驱动，内置类似 Vimperator/Vimium 的键盘快捷键，无需鼠标即可高效导航。由于它极度轻量，定制性极强，所以特别适合硬件性能有限的笔记本设备，例如 :ref:`mba11_late_2010` 来配合 :ref:`alpine_linux` 食用。通过Lua脚本可以为Luakit提供强大灵活的功能，例如直接拦截请求，配置代理或修改UI逻辑。不过，配置需要学习 :ref:`lua` 语法。

.. note::

   Luakit现在提供了各种发行版支持，在 :ref:`alpine_linux` 环境下，有非常轻量的APK预编译包。

需要注意，像Luakit这种轻量级浏览器适合日常查看Python/C API 文档、浏览 GitHub Issue 或检索网页，Luakit 的 Vim 快捷键在 Sway 平铺环境中能够提供极致的无缝操作体验。但是，对于类似 Figma、JupyterLab、Overleaf 或大型前端 SPA 应用，Luakit是很难正确渲染加载的，所以我采用 :ref:`moonlight-embedded` 来访问自己部署的服务器，在服务器上采用全功能 :ref:`firefox` / :ref:`chrome` 来运行。这种功能拆分可以降低本地设备的硬件要求。

Luakit使用
============

在 :ref:`sway` 环境运行Luakit是非常适配的，只需要记住一些 ``常用按键`` ( **注意按键字母大小写** ):

- ``o`` ：打开 URL 输入框 (Open)
- ``t`` ：在新标签页打开 URL (Tab)
- ``d`` / ``x`` ：关闭当前标签页
- ``j`` / ``k`` ：向下 / 向上滚动页面
- ``H`` / ``L`` ：后退 / 前进
- ``r`` ：刷新页面
- ``/`` ：页面文本搜索

参考
======

- gemini
- `github: luakit <https://github.com/luakit/luakit>`_
