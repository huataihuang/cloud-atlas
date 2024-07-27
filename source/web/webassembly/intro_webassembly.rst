.. _intro_webassembly:

====================
WebAssembly简介
====================

WebAssembly是一种运行在现代web浏览器中的新型代码，WASM支持将 C/C++/Go/Rust 等语言实现的代码编译为浏览器可执行的机器码，从而支持浏览器以接近原生应用的性能运行相关应用。

WebAssembly 于 2015年 首次发布，并且在4年以后，成为官方标准，是继HTML, CSS 和 JavaScript 之后的第四种Web语言。和JavaScript的对比区别:

- JavaScript是解释型语言，也是动态类型语言(每次执行程序时，JS引擎必须检查变量类习惯，所以JS的每条指令经过几次类型检查和转换，影响执行速度)
- WebAssembly实际上不是一门语言，而是将任何高级语言转换成可以在浏览器上运行的机器码；也就是WASM被设计成其他语言的编译目标

.. note::

   WASM 不能直接与DOM交互，所以需要同时使用JavaScript和WASM

WebAssembly模块可以被导入到一个Web App (或 Node.js) 中，并且暴露出供JavaScript使用的WebAssembly函数。JavaScript框架不但可以使用WebAssembly获得巨大的性能优势和新特性，而且还睡的各种功能保持对网络开发者的易用性。



参考
=====

- `十分钟搞懂 WebAssembly <https://developer.aliyun.com/article/1110304>`_
- `WebAssembly 概念 <https://developer.mozilla.org/zh-CN/docs/WebAssembly/Concepts>`_
