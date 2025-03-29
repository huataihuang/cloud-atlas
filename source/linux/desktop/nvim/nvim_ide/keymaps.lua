-- 定义常用选项
local opts = {
    noremap = true,      -- 非递归
    silent = true,       -- 不显示消息
}

---------------------------
-- 常规模式(Normal mode) --
---------------------------

-- 提示: 查看 `:h vim.map.set()`
-- 最佳窗口导航
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- 通过箭头调整窗口大小
-- 变量: 2 行
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

---------------------------
-- 可视模式(Visual mode) --
---------------------------

-- 提示: 以之前区域和相同模式启动相同区域的可视模式
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)
