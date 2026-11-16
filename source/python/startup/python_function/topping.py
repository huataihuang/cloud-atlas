def make_pizza(size: int, *toppings: str) -> None:
    """概述要制作的披萨
    Args:
        size: 披萨直径（英寸），必须为正数。
        *toppings: 任意数量的配料名称（只读元组）。
    """
    if size < 0:
        raise ValueError(f"Pizza size must be positive,got {size}")
    
    print(f"\nMaking a {size}-inch pizza with the following toppings:")
    for topping in toppings:
        print(f"- {topping}")


if __name__ == "__main__":
    make_pizza(16, "pepperoni")
    make_pizza(12, "mushrooms", "green peppers", "extra cheese")

