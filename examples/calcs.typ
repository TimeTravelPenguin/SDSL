#import "/src/dsl.typ": compile, new-dsl, register

#let dsl = new-dsl()

// Evaluators

#let _eval-add(node, env, ctx) = {
  let eval_args = ctx.eval_args
  let ((xv, yv), env) = eval_args(node, env)

  (result: xv + yv, env: env)
}

#let _eval-let(node, env, ctx) = {
  let eval_args = ctx.eval
  let (var, val) = node.args
  let ((val,), env) = eval_args(val, env)

  env.store.insert(var, val)
  (result: val, env: env)
}

#let _eval-increment(node, env, ctx) = {
  let eval_args = ctx.eval_args
  let ((var,), env) = eval_args(node, env)

  let val = env.store.at(var)
  val = val + 1

  env.store.insert(var, val)
  (result: val, env: env)
}

#let _eval-ref(node, env, ctx) = {
  let eval_args = ctx.eval_args
  let ((var,), env) = eval_args(node, env)

  let val = env.store.at(var)
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

#let result = run(ops) // -> 11
