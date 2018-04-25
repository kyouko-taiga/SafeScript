let x: mutable = 0
x = 1
let y &- x
x = 2  // error: cannot mutate immutable object
