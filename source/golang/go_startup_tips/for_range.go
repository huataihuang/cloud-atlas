package main

import "fmt"

func main() {

    m := make(map[string]int)
    m["hello"] = 100
    m["world"] = 200

    for key, value := range m {
        fmt.Println(key, value)
    }
}
