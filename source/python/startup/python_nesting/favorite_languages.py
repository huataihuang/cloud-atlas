favorite_languages = {
    'jen': ['python', 'ruby'],
    'sarah': ['c'],
    'edward': ['rust', 'go'],
    'phil': ['python', 'haskell']
}

# 遍历字典和列表
for name, languages in favorite_languages.items():
    print(f"\n{name.title()} 喜欢的编程语言有：")
    for lang in languages:
        print(f"\t- {lang.title()}")
