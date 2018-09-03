var x: mut = 0
x = 1
var y &- x
x = 2  // error: cannot mutate immutable object
