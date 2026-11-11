motorcycles = ['honda', 'yamaha', 'suzuki']
print(motorcycles)

motorcycles[0] = 'ducati'
print(motorcycles)

motorcycles.append('ducati')
print(motorcycles)

motorcycles.insert(2, 'ducati')
print(motorcycles)

del motorcycles[2]
last_owned = motorcycles.pop()
print(last_owned)

print(f"The last motorcycle I owned was a {last_owned.title()}.")
print(motorcycles)

first_owned = motorcycles.pop(0)
print(first_owned)

print(f"The first motocycle I owned was a {first_owned.title()}.")
print(motorcycles)

too_expensive = 'ducati'
try:
    motorcycles.remove(too_expensive)
except ValueError:
    pass
print(motorcycles)
print(f"\nA {too_expensive.title()} is too expensive for me.")
