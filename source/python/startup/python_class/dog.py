class Dog:
    """模拟小狗的类"""

    def __init__(self, name, age):
        """初始化属性 name 和 age"""
        self.name = name
        self.age = age

    def sit(self):
        """模拟小狗收到命令时坐下"""
        print(f"{self.name} is now sitting.")

    def roll_over(self):
        """模拟小狗收到命令时打滚"""
        print(f"{self.name} rolled over!")
