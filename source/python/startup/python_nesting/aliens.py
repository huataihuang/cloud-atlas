# 定义一个包含多个外星人字典的列表
aliens = [
    {'color': 'green', 'points': 5, 'speed': 'slow'},
    {'color': 'yellow', 'points': 10, 'speed': 'medium'},
    {'color': 'red', 'points': 15, 'speed': 'fast'}
]

# 遍历列表并打印每个外星人的信息
for alien in aliens:
    print(f"这个外星人是 {alien['color']} 的，击败它可以获得 {alien['points']} 分！")
