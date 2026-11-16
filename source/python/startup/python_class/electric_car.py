from car import Car


class ElectricCar(Car):
    """电动汽车的独特之处"""

    def __init__(self, make, model, year):
        """初始化父类的属性"""
        super().__init__(make, model, year)
        self.battery_size = 40

    def describe_battery(self):
        """打印一条描述电池容量的消息"""
        print(f"This car has a {self.battery_size}-kWh battery.")


if __name__ == "__main__":
    my_leaf = ElectricCar("nissan", "leaf", 2024)
    print(my_leaf.get_descriptive_name())
    my_leaf.describe_battery()

