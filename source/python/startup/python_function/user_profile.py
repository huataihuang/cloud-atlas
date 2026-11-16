def build_profile(first: str, last: str, **user_info: str) -> dict:
    """创建一个字典，包含用户信息"""
    # 校验避免空字符串
    if not first or not last:
        raise ValueError("first 和 last 不能为空")
    profile = {"first_name": first, "last_name": last}
    # 防御传入的键值重复出现first_name，last_name
    for key, value in user_info.items():
        if key in ("first_name", "last_name"):
            raise KeyError(f"不允许覆盖保留字段: {key}")
        profile[key] = value
    return profile


if __name__ == "__main__":
    user_profile: dict[str, str] = build_profile(
        "albert", "einstein", location="princeton", field="physics"
    )
    print(user_profile)

