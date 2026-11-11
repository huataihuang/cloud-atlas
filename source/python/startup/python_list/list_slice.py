players = ['charles', 'martina', 'michael', 'florence', 'eli']
print(players[1,4])  # ['martina', 'michael', 'florence'

print(players[:2])   # ['charles', 'martina']

print(players[2:])   # ['michael', 'florence', 'eli']

print(players[-3:])  # ['michael', 'florence', 'eli']

# 遍历列表
for player in players[:3]:
    print(player.title())
