#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

clipboard = ""


class ClipHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        global clipboard
        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(clipboard.encode("utf-8"))

    def do_POST(self):
        global clipboard
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length).decode("utf-8")

        try:
            # 解析快捷指令发送的 JSON 数据
            data = json.loads(body)
            clipboard = data.get("text", "")
        except json.JSONDecodeError:
            # 如果收到的是普通文本则直接保存
            clipboard = body

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OK")


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 9999), ClipHandler)
    print("Clipboard server running on port 9999...")
    server.serve_forever()
