-- define your colorscheme here
local colorscheme = 'monokai'
-- local colorscheme = 'monokai_pro'
-- local colorscheme = 'monokai_soda'
-- local colorscheme = 'monokai_ristretto'

local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
    vim.notify('colorscheme ' .. colorscheme .. ' not found!')
    return
end
