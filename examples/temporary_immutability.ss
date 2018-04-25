let x: mutable = 0
{
  let y &- x
}
x = 1
console.log(x)
// Prints "1"
