def confirm_users(unconfirmed_users: list[str]) -> list[str]:
    """待验证用户逐一确认，返回已确认用户列表"""
    confirmed_users: list[str] = []

    while unconfirmed_users:
        current_user = unconfirmed_users.pop()

        print(f"Verifying user: {current_user.title()}")
        confirmed_users.append(current_user)

    return confirmed_users


def display_confirmed_users(confirmed_users: list[str]) -> None:
    """显示已确认的用户列表"""
    if not confirmed_users:
        print("No users to display")
        return

    print("\nThe following users have been confirmed:")
    for user in confirmed_users:
        print(user.title())


if __name__ == "__main__":
    unconfirmed_users = ["alice", "brian", "candace"]
    confirmed = confirm_users(unconfirmed_users)
    display_confirmed_users(confirmed)

