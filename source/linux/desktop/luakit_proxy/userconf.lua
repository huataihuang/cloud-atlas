local soup = require("soup")
local modes = require("modes")

-- 注册以 `:` 开头的浏览器命令
modes.add_binds("normal", {
	{
		":proxy-on",
		"Enable Shadowsocks SOCKS5 Proxy",
		function(w)
			soup.proxy_uri = "socks://127.0.0.1:1080"
			w:notify("Proxy: ON (socks://127.0.0.1:1080)")
		end,
	},

	{
		":proxy-off",
		"Disable Proxy (Direct)",
		function(w)
			soup.proxy_uri = ""
			w:notify("Proxy: OFF (Direct)")
		end,
	},

	-- 快捷键补全：按 `gp` 开启，按 `gP` 关闭 (可选)
	{
		"gp",
		"Enable Proxy",
		function(w)
			soup.proxy_uri = "socks://127.0.0.1:1080"
			w:notify("Proxy: ON (socks://127.0.0.1:1080)")
		end,
	},

	{
		"gP",
		"Disable Proxy",
		function(w)
			soup.proxy_uri = ""
			w:notify("Proxy: OFF (Direct)")
		end,
	},
})
