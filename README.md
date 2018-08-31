# SafeScript

SafeScript is a dialect of JavaScript,
whose specificity is to add a type system on the top of JavaScript to make aliasing safer.

## Motivation:

Consider the following program, in JavaScript:

```js
let obj1 = { foo: 0, bar: 1 }
let obj2 = obj1

obj2.foo = 10
console.log(obj1.foo)
// Prints "10"
```

Although we mutated `obj2.foo`, `obj1.foo` changed as well!
That's because both `obj1` and `obj2` are references on the same object.
What about using ES6's `const` keyword?

```js
const obj1 = { foo: 0, bar: 1 }
const obj2 = obj1

obj2.foo = 10
console.log(obj1.foo)
// Prints "10"
```

No more luck...
That's because JavaScript's `const` keyword
prevents the reference from being reassigned to a new object,
but does not impose anything on the value of the object it is bound to.

What's wrong about this semantics?
Well, first it is very easy to forget that `=` is not a [deep copy](https://en.wikipedia.org/wiki/Object_copying).
Second, the role of the `const` keyword can sometimes be confusing,
especially for inexperienced developers.

So what about SafeScript?
In this language,
all objects are immutable by default,
and a copy is always a deep copy.

```
let obj1 = { foo: 0, bar: 1 }
let obj2: mutable = obj1

obj2.foo = 10
console.log(obj1.foo)
// Prints "0"

obj1.foo = 10
// error: error: cannot mutate immutable object
```

The language still allows reference copies,
but gives them a dedicated operator:

```
let obj1: mutable = { foo: 0, bar: 1 }
let obj2: mutable &- obj1

obj2.foo = 10
console.log(obj1.foo)
// Prints "10"
```

## Usage:

The compiler takes SafeScript sources and *transpiles* them to JavaScript,
after having checked for alias safety statically.
The produced sources can then be executed by any JavaScript interpreter,
e.g. [Node.js](https://nodejs.org/en/):

```bash
safescript input.ss -o output.js
node output.js
```

## Build:

The compiler is written in [Swift](https://swift.org).
You can build it from source with the Swift Package Manager:

```bash
cd SafeScript
swift build -c release  # Produces .build/release/safescript
```

You can also use XCode.
Simply generate `SafeScript.xcodeproj` with SPM's command:

```bash
swift package generate-xcodeproj
```

## Outstanding issues

Only a small part of JavaScript has been implemented so far.
SafeScript will parse but won't type check class declarations,
arrow and anonymous functions
and other fancy features from ES6+ (e.g. spreading operators).

Besides:
* There's a virtually no support of JavaScript's standard library API.
  You just get `console.log`.
* The transpilation is implemented with very little care
  about the shape of the JavaScript it produces.
  It doesn't create any source maps neither.
* Deep copies are performed without any optimization (e.g. [copy-on-write](https://en.wikipedia.org/wiki/Copy-on-write)),
  which means transpiled code is likely to be quite slow.

  In other words, you shouldn't keep SafeScript anywhere near production code yet ...
  However, you're very much encouraged to have fun with it!

## Contributing

Contributions are more than welcomed, especially on the issues we've listed above.
Some things are already in progress,
or have already been drafted on paper,
so be sure to open an issue before starting anything crazy.

We are also eager to get as many opinions as possible on SafeScript's type system,
so be sure to give yours in the issues.
