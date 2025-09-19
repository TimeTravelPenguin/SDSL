# Simple DSL (SDSL)

> [!IMPORTANT]
> This project is still in development. Everything written in this document
> serves as a desired goal rather than an existing feature.

This is a package for Typst that allows users and library developers to create expressive
domain-specific languages (DSLs). There are a variety of reasons that users and, in
particular, package developers, may be interested in using a DSL. Consider a Cetz-like
package for building plot figures:

```typ
#plot({
    Settings(
        Domain("x", -1, 1),
        Domain("y", 0, 5),
        Axes("both"),
    )

    Curve(x => x * x + 1, color: red)
    Curve(x => 1 / (x - 1), color: blue)
    Curve(x => 3, style: "dotted")
})
```

Until Typst supports custom user types, it is rather difficult to make complex _and_
expressive public APIs. This is especially true when you factor in the lack of
type-validation and error handling capabilities. With that being said, however, DSLs are
not useful in the absence of such features. They are rather disjoint features. It is just
harder to make something useful without pre-existing infrastructure.

In general, DSLs provide a way to express a desired result by encapsulating the complex
machinery behind the scenes.

## How does SDSL work?

The current design is rather simple, but flexible enough for most use cases. Let's use a
simple example to understand what is happening:

```typ
#let expression = {
    Let("x", 2)
    Let("x", Mul(2, Ref("x")))
    Add(Ref("x", 1))
}

#let result = run(expression)
```

This mock DSL appears to perform basic calculations and variable assignment. The
equivalent typst code would be:

```typ
#let x = 2
#let x = 2 * x
x + 1
```

If we expect `run(expression)` to return a value of `5`, the each step would effectively
involve looking up a variable and/or assigning a result to a variable, before finally
returning the result.

When developing a DSL, you basically define an evaluator for each kind of term (`Let`,
`Add`, `Ref`, etc.) and register it into a collection of these evaluators.

Each evaluator takes a known input type, does something to it, and then returns an output.
In SDSL, these inputs and outputs are called `nodes`, and they are basically just a
dictionary with a specific schema. For example, `Add(x, y)` takes a pair of inputs (or
perhaps more) and returns a node with the key-value pairs `(kind: "Add", args: (x, y))`,
amongst other keys. The evaluator for `Add` would then take the `args` (and perhaps other
field data), evaluate those args, transform the result of that evaluation, and return a
new node result.

While this package is flexible, you are free to implement your evaluators to operate
however you feel most comfortable. However, it would be best to keep things _pure_, and
always work with structured data (like nodes).
