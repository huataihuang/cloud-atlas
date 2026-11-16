class Car:
    """模拟汽车"""

    def __init__(self, make: str, model: str, year: int):
        """初始化描述汽车的属性"""
        if year < 1886:
            raise ValueError(f"Year {year} is before the first car was built (1886)")
        if not make or not model:
            raise ValueError("Make and model cannot be empty")
        self.make = make
        self.model = model
        self.year = year
        self.odometer_reading = 0

    def get_descriptive_name(self):
        """返回格式规范的描述性信息"""
        long_name = f"{self.year} {self.make} {self.model}"
        return long_name.title()

    def read_odometer(self):
        """打印一条指出汽车行驶里程的消息"""
        print(f"This car has {self.odometer_reading} miles on it.")

    def update_odometer(self, mileage):
        """将里程碑读数设置为指定的值"""
        if mileage >= self.odometer_reading:
            self.odometer_reading = mileage
        else:
            print("You can't roll back an odometer!")

    def increment_odometer(self, miles):
        """让里程表读数增加指定的量"""
        self.odometer_reading += miles

    # ... existing code ...
    def __str__(self):
        """字符串表示"""
        return self.get_descriptive_name()

    def __repr__(self):
        """开发者友好的表示"""
        return f"Car(make='{self.make}', model='{self.model}, year={self.year})"


if __name__ == "__main__":
    my_new_car = Car("audi", "a4", 2024)
    print(my_new_car.get_descriptive_name())
    my_new_car.read_odometer()

    my_new_car.update_odometer(23)
    my_new_car.read_odometer()

    my_used_car = Car("subaru", "outback", 2019)
    print(my_used_car.get_descriptive_name())

    my_used_car.update_odometer(23_500)
    my_used_car.read_odometer()

    my_used_car.increment_odometer(100)
    my_used_car.read_odometer()

