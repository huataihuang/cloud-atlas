from car import Car
from battery import Battery


class ElectricCar(Car):
    """电动汽车的独特之处"""

    def __init__(self, make, model, year):
        """初始化父类的属性"""
        super().__init__(make, model, year)
        self.battery = Battery()


if __name__ == "__main__":
    my_leaf = ElectricCar("nissan", "leaf", 2024)
    print(my_leaf.get_descriptive_name())
    my_leaf.battery.describe_battery()
    my_leaf.battery.get_range()

