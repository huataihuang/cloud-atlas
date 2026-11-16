def describe_pet(animal_type: str, pet_name: str) -> None:
    """显示宠物信息

    Args:
        animal_type: 宠物种类，如 "dog", "cat" 等
        pet_name: 宠物名字
    """
    print(f"I have a {animal_type}.")
    print(f"My {animal_type}'s name is {pet_name}.")


if __name__ == "__main__":
    print()  # 空行由调用者控制
    describe_pet(animal_type="cat", pet_name="旺财")
