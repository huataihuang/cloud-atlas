#alien_0 = {'color': 'green'}

alien_0 = {}

alien_0['color'] = 'green'
alien_0['points'] = 5

print(f"The alien is {alien_0['color']}.")

alien_0['color'] = 'yellow'
print(f"The alien is now {alien_0['color']}.")

# 删除数据
print(f"The alien is {alien_0}.")
print("\nDelete point record.")
del alien_0['points']
print(f"The alien is {alien_0}.")

#如果不验证是否存在某个键而直接引用键进行输出会抛出异常，例如 print(alien_0['poits'])
#为避免这个问题，可以使用 get() 方法，可以指定该键不存在时返回一个默认值，类似于异常抛出
point_value = alien_0.get('points', 'No point value assigned.')
#如果get()没有给出第二个参数，则返回值None
#point_value = alien_0.get('points')
print(point_value)


