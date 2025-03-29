-- Hint: 如果需要，使用 `:h <option>` 来查找配置含义
vim.opt.clipboard = 'unnamedplus'   -- 使用系统剪贴板
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.mouse = 'r'                 -- 允许在Nvim中使用鼠标，原文使用 'a' ，不过这样只能在vim内部使用，退出vim就丢失
                                       -- 我修改为 'r' 这样退出vim依然保留剪贴板内容；如果 'r' 无效，则可以尝试 'v' ，实际取决于 vimrc
                                       -- 参考 https://unix.stackexchange.com/questions/139578/copy-paste-for-vim-is-not-working-when-mouse-set-mouse-a-is-on

-- Tab
vim.opt.tabstop = 4                 -- 每个Tab代表的虚拟空格数量
vim.opt.softtabstop = 4             -- 当编辑时空间tab(spacesin tab)代表的空格数量
vim.opt.shiftwidth = 4              -- 在一个tab中插入4个空格
vim.opt.expandtab = true            -- 将tabs转换为空格，这在python有用

-- UI config
vim.opt.number = true               -- 显示绝对数值(也就是行号)
vim.opt.relativenumber = true       -- 在左边显示没一行的行号
vim.opt.cursorline = true           -- 高亮光标水平行下方显示横线
vim.opt.splitbelow = true           -- 打开新的垂直分割底部
vim.opt.splitright = true           -- 在水平分割右方打开
-- vim.opt.termguicolors = true        -- 在TUI激活24位RGB颜色
vim.opt.showmode = false            -- 根据经验，我们不需要 "-- INSERT --" 模式提示

-- Searching
vim.opt.incsearch = true            -- 在输入字符时搜索
vim.opt.hlsearch = false            -- 不要高亮匹配项
vim.opt.ignorecase = true           -- 默认搜索时不区分大小写
vim.opt.smartcase = true            -- 如果搜索时输入一个大写字母则表示搜索区分大小写
