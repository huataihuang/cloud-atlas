cars = ['audi', 'bmw', 'subaru', 'toyota']

for car in cars:
    car = car.lower()

    if car in ['bmw', 'toyota']:
        print(car.upper())
    elif car == 'audi':
        print(car)
    else:
        print(car.title())
