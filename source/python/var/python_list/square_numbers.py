squares = []
for value in range(1, 11):
    square = value**2
    squares.append(square)

print(squares)

# --- 简化掉临时变量square
squares = []
for value in range(1, 11):
    squares.append(value**2)

print(squares)
