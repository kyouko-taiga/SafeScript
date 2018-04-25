let x = { a: 0, b: 1 }
let y: mutable = x
y.a = 2

console.log(x)
// Prints "{ a: 0, b: 1 }"

console.log(y)
// Prints "{ a: 2, b: 1 }"
