with open("example.ext", "w", encoding="utf-8") as f:
    f.write("I love programming!\n")
    f.write("I love python!")

# 如果是追加文字则写成
with open("example.ext", "a", encoding="utf-8") as f:
    f.write("I love programming!\n")
    f.write("I love python!")
