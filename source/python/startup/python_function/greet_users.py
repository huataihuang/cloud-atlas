def greet_user(names: list):
    """向列表中每个用户发出简单的问候"""
    for name in names:
        msg = f"Hello, {name.title()}!"
        print(msg)


if __name__ == "__main__":
    usernames = ["hannah", "ty", "margot"]
    greet_user(usernames)

