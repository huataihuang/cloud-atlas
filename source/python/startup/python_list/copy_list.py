my_foods = ['pizza', 'falafel', 'carrot cake']
# 注意: 复制列表一定要加 [:] 索引，否则就是引用同一个列表而不是复制创建一个新列表
friend_foods = my_foods[:]

print("My favorite foods are:")
print(my_foods)

print("\nMy friend's favorite foods are:")
print(friend_foods)

friend_foods.append('ice cream')
print(my_foods)
print(friend_foods)
