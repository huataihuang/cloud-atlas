.. _ollama_webui:

===================
Ollama WebUI
===================

.. note::

   本文根据gemini推荐整理，待后续实践

Open WebUI (原 Ollama WebUI)
===============================

目前功能最全、最受好评的前端。它不仅提供聊天界面，还支持 RAG（上传 PDF/文档进行问答）、多模型对比和语音交互。

优点：界面完全致敬 ChatGPT，支持用户管理（你可以给朋友开账号），支持模型参数实时调整。

运行:

.. literalinclude:: ollama_webui/run_open-webui
   :caption: 使用docker运行Open WebUI

NextChat (ChatGPT-Next-Web)
==============================

如果你追求极简、极致的响应速度，NextChat 是最好的选择。它非常轻量，几乎不占服务器资源。

优点：支持“面具（Mask）”功能（预设各种 AI 角色，如代码专家、翻译官），支持导出长图。

运行:

.. literalinclude:: ollama_webui/run_nextchat
   :caption: 使用docker运行NextChat

多模态与插件之王：LobeChat
==============================

未来想在服务器上跑一些带图片识别（Vision）的模型，或者需要像“搜索增强”这样的插件，LobeChat 的 UI 设计非常超前。

优点：插件市场丰富，支持文件上传，界面美学评分极高。

运行:

.. literalinclude:: ollama_webui/run_lobechat
   :caption: 使用docker运行LobeChat

注意
======

- 环境变量：确保你的 ollama-amd 容器启动时带有 ``-e OLLAMA_HOST=0.0.0.0`` 。如果没带，Web UI 会报“连接失败”。
- 网络互通：上面的 ``docker run`` 命令中加入了 ``--add-host=host.docker.internal:host-gateway`` ，这是为了让 Web UI 容器能通过这个特殊域名直接访问到宿主机端口（即 11435 端口）。
- 显存监控：在使用 Web UI 进行长对话时，Llama 3.3-70B 的显存占用会随着上下文增加而飙升。建议保持后台开启 ``watch -n 1 rocm-smi`` ，观察显存分配是否均匀。
