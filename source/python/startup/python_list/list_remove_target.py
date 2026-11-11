motorcycles = ['ducati', 'honda', 'ducati', 'suzuki', 'ducati']
target = 'ducati'

while target in motorcycles:
    motorcycles.remove(target)

print(motorcycles)  # 输出: ['honda', 'suzuki']
