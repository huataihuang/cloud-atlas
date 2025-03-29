enum Language {
    English,
    Spanish,
    Russian
}

// 枚举中的值使用点号或方括号表示法访问，就像访问常规对象中的值:
let myFirstLanguage = Language.Russian
let mySecondLanguage = Language['English']

enum Language {
    English = 0,
    Spanish  =1
}

//枚举的值可以是字符串，或者混用字符串和数字
enum Color {
    Red = '#c10000',
    Blue = '#007ac1',
    Pink = 0xc10050,
    White = 255
}
