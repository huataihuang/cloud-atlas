cars = ['audi', 'bmw', 'subaru', 'toyota']

for car in cars:
    if car.lower() == 'bmw' or car.lower() == 'toyota':
        print(car.upper())
    elif car.lower() == 'audi':
        print(car.lower())
    else:
        print(car.title())
