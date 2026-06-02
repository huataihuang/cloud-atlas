-- =========================================================================
-- macOS 本地特需：强行拉通 Neovim 与 mise 的环境变量总线
-- =========================================================================

-- 1. 将 mise 的 shims 和剪切路径物理追加到 Neovim 的运行态 PATH 中
-- 这样无论你在哪个目录下打开 nvim，Mason 和 LSP 都能精准找到当前目录激活的语言编译器
local mise_shims = vim.fn.expand("~/.local/share/mise/shims")
local mise_bin = vim.fn.expand("~/.local/share/mise/bin")

if vim.fn.isdirectory(mise_shims) == 1 then
  vim.env.PATH = mise_shims .. ":" .. mise_bin .. ":" .. vim.env.PATH
end

-- 2. 为 Python 宿主环境提供保底的物理路径（防止 Mason 找不到 python3 报错）
-- 告诉 Neovim 直接去使用 mise 链条里的全局稳定版 python
if vim.fn.executable("python3") == 1 then
  vim.g.python3_host_prog = vim.fn.exepath("python3")
end

-- 3. 同理，为 Ruby 提供保底路径
if vim.fn.executable("ruby") == 1 then
  vim.g.ruby_host_prog = vim.fn.exepath("ruby")
end
