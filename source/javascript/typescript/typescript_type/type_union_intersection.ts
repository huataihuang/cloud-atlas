type Cat = {
    name: string,
    purrs: boolean
}

type Dog = {
    name: tring,
    barks: boolean,
    wags: boolean
}

type CatOrDogOrBoth = Cat | Dog
type CatAndDog = Cat & Dog

//Cat
let a: CatOrDogOrBoth = {
    name: 'Bonkers',
    purrs: true
}

// Dog
a = {
    name: 'Domino',
    barks: true,
    wags: true
}

// 两者兼具
a = {
    name: 'Donkers',
    barks: true,
    purrs: true,
    wags: true
}
