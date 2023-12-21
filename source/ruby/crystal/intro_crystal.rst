.. _intro_crystal:

=======================
Crystal简介
=======================

Crystal语言的目标是继承Ruby语言的优点同时提供C语言的高性能:

- 语法类似Ruby(但兼容Ruby不是目标)
- 静态类型检查( ``statically type-checked`` )但无需指定变量变量或方法参数的类型
- 能够通过在Crystal语言中编写绑定(wrting bindings)来调用C代码
- 具有编译时评估和代码生成，以避免样板代码(bolierplate code)
- 编译成高效的本机代码(native code)

作为小众语言Ruby的性能增强语言，Crystal可能是Ruby项目随着规模增大的可能方案。我可能会在后续学习和实践

.. note::

   Crystal 之于 Ruby，让我想到了Facebook为了加速自己不断庞大的PHP网站(是的，世界十大网站之一就是PHP这种不起眼的脚本语言支持的，另一个著名的PHP构建网站应该是维基百科: 维基百科运行在MediaWiki之上，而MediaWiki是采用PHP开发的)

   - 研发了 `HipHop for PHP (HPHPc) <https://en.wikipedia.org/wiki/HipHop_for_PHP>`_ (将PHP代码转换成C++，然后编译成二进制执行程序来加速) **已经停滞开发，由HHVM取代**
   - 研发了 `HipHop Virtual Machine (HHVM) <https://en.wikipedia.org/wiki/HHVM>`_ 虚拟机来运行一种类似PHP的 `Hack编程语言 <https://en.wikipedia.org/wiki/Hack_(programming_language)>`_ (这个加速思路类似JVM之于Java程序的JIT编译)

     - `GitHub: facebook/hhvm <https://github.com/facebook/hhvm>`_ 使用多种语言混合构建的Hack语言虚拟机 -- HHVM官方网站 `hhvm.com <https://hhvm.com/>`_
     - `GitHub: facebook/hhvm/hphp/hack <https://github.com/facebook/hhvm/tree/master/hphp/hack>`_ Hack语言开发工具包不需要单独安装，包含在HHVM安装中 - Hack语言官方网站 `hacklang.org <https://hacklang.org/>`_

参考
======

- `GitHub: crystal-lang/crystal <https://github.com/crystal-lang/crystal>`_
- `Crystal 语言是否值得看好？ <https://www.zhihu.com/question/33311554>`_
