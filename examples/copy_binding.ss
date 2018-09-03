var x = { a: 0, b: 1 }
var y: mut = x
y.a = 2

console.log(x)
// Prints "{ a: 0, b: 1 }"

console.log(y)
// Prints "{ a: 2, b: 1 }"
