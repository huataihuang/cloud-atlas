dimensions = (200, 50)
print(dimensions[0])
print(dimensions[1])

# 不能直接修改元组tuple的元素值
# dimensions[0] = 300

# 但是可以给元组tuple的变量重新赋值
dimensions = (400, 100)
print(dimensions)

for dimension in dimensions:
    print(dimension)
