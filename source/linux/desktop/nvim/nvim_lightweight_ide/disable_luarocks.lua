-- 【状态栏】
  {
    "nvim-lualine/lualine.nvim",
    config = function() require("lualine").setup() end,
  },
}, -- <-- 注意这里逗号隔开，把原本结束的括号挪到下面
{
  rocks = {
    enabled = false, -- 传递给 lazy 的全局配置
  },
}
)
