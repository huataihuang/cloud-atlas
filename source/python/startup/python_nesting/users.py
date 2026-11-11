users = {
    'aeinstein': {
        'first': 'albert',
        'last': 'einstein',
        'location': 'princeton',
    },
    'mcurie': {
        'first': 'marie',
        'last': 'curie',
        'location': 'paris',
    },
}

# 遍历外层字典
for username, user_info in users.items():
    print(f"\n用户名: {username}")
    # 拼接并打印内层字典的值
    full_name = f"{user_info['first']} {user_info['last']}"
    location = user_info['location']
    
    print(f"\t全名: {full_name.title()}")
    print(f"\t所在地: {location.title()}")
