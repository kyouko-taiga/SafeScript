var x1: mut = { name: "Jane" }
var x2: mut = x1
x2.name = "Ann"
console.log(x1.name)

var x3: mut &- x1
x3.name = "Ann"
console.log(x1.name)
