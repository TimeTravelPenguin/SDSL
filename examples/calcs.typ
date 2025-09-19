#import "/src/dsl.typ": compile, new-dsl, register

#let dsl = new-dsl()

// Evaluators

#let _eval-add(node, env, ctx) = {
  let eval-args = ctx.eval-args
  let eval = ctx.eval
  let (result: (xv, yv), env: env) = eval-args(node, env)
  let (result: xv, env: env) = eval(xv, env, ctx: ctx)
  let (result: yv, env: env) = eval(yv, env, ctx: ctx)

  let sum = (xv, yv).flatten().map(x => if x == none { 0 } else { x }).sum()
  (result: sum, env: env)
}

#let _eval-let(node, env, ctx) = {
  let eval-args = ctx.eval-args
  let (result: (var, val), env: env) = eval-args(node, env)

  env.vars.insert(var, val)
  (env: env)
}

#let _eval-increment(node, env, ctx) = {
  let eval-args = ctx.eval-args
  let (result: (var,), env: env) = eval-args(node, env)

  let val = env.vars.at(var)
  val = val + 1

  env.vars.insert(var, val)
  (env: env)
}

#let _eval-ref(node, env, ctx) = {
  let eval-args = ctx.eval-args
  let (result: (var,), env: env) = eval-args(node, env)

  let val = env.vars.at(var)
  (env: env)
}

#let _eval-return(node, env, ctx) = {
  let eval-args = ctx.eval-args
  let (result: (val,), env: env) = eval-args(node, env)

  (result: val, env: env)
}

// Register
#let dsl = register(dsl, "Let", _eval-let)
#let dsl = register(dsl, "Increment", _eval-increment)
#let dsl = register(dsl, "Ref", _eval-ref)
#let dsl = register(dsl, "Add", _eval-add)

// Compile the DSL
#let compiled-dsl = compile(dsl)

// Create the public API
#let Add = compiled-dsl.Add
#let Let = compiled-dsl.Let
#let Increment = compiled-dsl.Increment
#let Ref = compiled-dsl.Ref
#let run = compiled-dsl.run

#let ops = {
  Let("x", 5)
  Increment("x")
  Add(Ref("x"), Add(2, 3))
}

#let result = run(ops).filter(x => x != none) // -> 11
#assert.eq(result, 11, message: "Expected result to be 11")
