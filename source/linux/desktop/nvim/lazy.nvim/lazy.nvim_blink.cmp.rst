.. _lazy.nvim_blink.cmp:

==============================
lazy.nvim 设置blink.cmp补全
==============================

我在使用lazyvim时候有一个困扰，就是我在输入时候自动会出现提示词，但是有时候提示词并不是我需要的，这时候如果我换行回车，nvim会自动把当前内容替换为第一个匹配的提示词。这种“自作主张”的补全非常打断写代码的思路，尤其是当我想直接回车换行，它却偏偏塞进一个完全不需要的候选词。

在 LazyVim（以及 Neovim 生态）中，负责处理自动补全的插件默认是 nvim-cmp 或新版 LazyVim 默认迁移到的 blink.cmp。要达到“回车不自动补全（仅换行），只有主动选择（如通过 Tab 或上下键选定）时才触发补全”的效果，需要调整补全插件的按键映射（Keymaps）。

.. note::

   看起来我这里解决的方法并不完美，但是接近于我的使用目标，所以记录如下

- ``~/.config/nvim/lua/plugins/blink.lua`` :

.. literalinclude:: lazy.nvim_blink/blink.lua
   :caption: 设置 ``~/.config/nvim/lua/plugins/blink.lua`` 使得回车为换行

参考
======

- gemini


