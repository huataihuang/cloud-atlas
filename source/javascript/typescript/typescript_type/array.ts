let a = [1, 2, 3]
var b = ['a', 'b']
let c: string[] = ['a']
let d = [1, 'a']
const e = [2, 'b']

let f = ['read']
f.push('blue')  // 推入数据必须是同类型的，例如如果 f.push(true) 就会报错

let g = [] //这里没有声明类型，TypeScript会假设为 any类型 ,这样推入任何类型都可以通过，但是不利于检测错误
g.push(1)
g.push('red')

let h: number[] = [] //这里设置了数组f是数字类型
h.push(1) //只能推入数字，不能推入字符串，也就是 h.push('read') 会报错
