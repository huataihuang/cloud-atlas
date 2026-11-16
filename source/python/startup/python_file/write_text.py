# 这是 pathlib 内部的实现逻辑（简化版）
def write_text(self, data):
    with self.open(mode='w', encoding=self.encoding) as f:
        f.write(data)
