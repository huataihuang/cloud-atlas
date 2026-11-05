motorcycles = ['ducati', 'honda', 'ducati', 'suzuki', 'ducati']
target = 'ducati'

# 过滤掉所有等于 target 的元素
motorcycles = [m for m in motorcycles if m != target]
print(motorcycles)  # 输出: ['honda', 'suzuki']
