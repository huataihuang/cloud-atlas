from collections.abc import Sequence


def greet_user(names: Sequence[str]) -> list[str]:
    """向列表中每个用户发出简单的问候

    :param names: 用户名列表
    :raises ValueError: 当 names 为空时
    :raises TypeError: 当 names 中包含非字符串元素时
    """
    if not names:
        raise ValueError("names 不能为空")
    return [f"Hello, {name.title()}!" for name in names]


if __name__ == "__main__":
    usernames = ["hannah", "ty", "margot"]
    for msg in greet_user(usernames):
        print(msg)

