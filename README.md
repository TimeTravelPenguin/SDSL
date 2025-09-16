# SDSL

> [!IMPORTANT]
> This project is still in development. Everything written in this document
> serves as a desired goal rather than an existing feature.

Example:

```typ
#import SDSL: new-dsl, register, ctor, compile

#let dsl = new-dsl()

// Create a constructor
#let _ctor-add = ctor(x: none, y: none)

// Define an evaluator
#let _eval-add(val, ..args) = {
    let (x, y) = val
    x + y
}

// Register with the DSL
#let Add = dsl.register("Add", _ctor-add, _eval-add)

// Compile a new evaluator
#let run = compile(dsl)

// Use it!
#let sum = Add(3, 5)
#let result = run(sum)     // Returns 8
```
