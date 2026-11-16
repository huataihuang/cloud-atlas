# Python 3.9+ , 不需要Optional[str]


def build_person(
    first_name: str,
    last_name: str | None,
    age: str | None,
) -> dict[str, str | int]:
    """返回字典包有关一个人的信息"""
    person: dict[str, str | int] = {"first": first_name}
    if last_name is not None:
        person["last"] = last_name
    if age is not None:
        person["age"] = age
    return person


if __name__ == "__main__":
    musician = build_person("jimi", "hendrix", age=27)
    print(musician)

    person = build_person("ada", age=36)
    # 如果实参一一对应，那么也可以用
    # person = build_person("ada", None, 36)
    print(person)

