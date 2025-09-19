#import "@preview/valkyrie:0.2.2" as z
#import "@preview/oxifmt:1.0.0": strfmt

#import "/src/valkyrie-utils.typ": _assert-str-eq
#import "/src/schemas.typ": (
  ctx-schema, dsl-schema, env-schema, handler-schema, node-defaults-schema,
  node-kw-schema, node-schema, run-result-schema,
)

/// Create a configuration for renaming standard node fields.
/// -> dictionary
#let node-kw-cfg(
  /// The new name for the 'kind' field. -> str
  rename-kind: none,
  /// The new name for the 'args' field. -> str
  rename-args: none,
  /// The new name for the 'kwargs' field. -> str
  rename-kwargs: none,
  /// The new name for the 'children' field. -> str
  rename-children: none,
) = z.parse(
  (
    kw-kind: rename-kind,
    kw-args: rename-args,
    kw-kwargs: rename-kwargs,
    kw-children: rename-children,
  ),
  node-kw-schema,
)

/// Create a configuration defining the default values of standard node fields.
/// -> dictionary
#let node-defaults-cfg(
  /// The default value for the 'args' field. -> array
  default-args: none,
  /// The default value for the 'kwargs' field. -> dictionary
  default-kwargs: none,
  /// The default value for the 'children' field. -> array
  default-children: none,
) = z.parse(
  (
    default-args: default-args,
    default-kwargs: default-kwargs,
    default-children: default-children,
  ),
  node-defaults-schema,
)

/// Create a new DSL configuration.
/// -> dictionary
#let new-dsl(
  /// Configuration for renaming standard node fields.
  /// See @node-kw-cfg.
  /// -> dictionary
  node-kw-cfg: none,
  /// Configuration defining the default values of standard node fields.
  /// See @node-defaults-cfg.
  /// -> dictionary
  node-defaults-cfg: none,
) = z.parse(
  (
    options: (
      node-kw-cfg: node-kw-cfg,
      node-defaults: node-defaults-cfg,
    ),
  ),
  dsl-schema,
)

#let register(dsl, name, eval) = {
  let dsl = z.parse(dsl, dsl-schema)

  if name in dsl.handlers {
    panic(strfmt(
      "Evaluator for node kind '{name}' is already registered.",
      name: name,
    ))
  }

  let defaults = dsl.options.node-defaults

  let ctor(..params, children: ()) = {
    let args = params.pos()
    let kwargs = params.named()

    // Apply defaults (user-specified kwargs override defaults).
    let norm-args = if args == () { defaults.default-args } else { args }
    let norm-kwargs = defaults.default-kwargs + kwargs
    let norm-children = if children == () { defaults.default-children } else {
      children
    }

    let node = z.parse(
      (
        kind: name,
        args: norm-args,
        kwargs: norm-kwargs,
        children: norm-children,
      ),
      node-schema(name),
    )

    (node,)
  }

  let handle = z.parse(
    (
      kind: name,
      ctor: ctor,
      eval: eval,
    ),
    handler-schema,
  )

  dsl.handlers.insert(name, handle)
  dsl
}

#let assert-node(ctx, node) = {
  let handlers = ctx.handlers

  assert.eq(type(node), dictionary, message: "Node must be a dictionary.")
  assert("kind" in node, message: "Node missing 'kind' field.")
  assert(node.kind in handlers, message: strfmt(
    "No handler registered for node kind '{}'.",
    node.kind,
  ))
}

#let eval(node, env, ctx: (:)) = {
  let ctx = z.parse(ctx, ctx-schema)
  let handlers = ctx.handlers

  // Primitives pass through
  if type(node) != dictionary {
    return (result: node, env: env)
  }

  assert-node(ctx, node)

  z.parse(
    (handlers.at(node.kind).eval)(node, env, ctx),
    run-result-schema,
  )
}

#let eval-args(node, env, ctx: (:)) = {
  let ctx = z.parse(ctx, ctx-schema)
  let out = ()
  let current = env

  assert-node(ctx, node)

  for a in node.args {
    let res = eval(a, current, ctx: ctx)
    out.push(res.result)
    current = res.env
  }

  (result: out.flatten(), env: current)
}

#let eval-children(node, env, ctx: (:)) = {
  let ctx = z.parse(ctx, ctx-schema)
  let out = ()
  let cur = env

  assert-node(ctx, node)

  for ch in node.children {
    let res = eval(ch, cur, ctx: ctx)
    out = out.push(res.result)
    cur = res.env
  }

  (result: out.flatten(), env: cur)
}

#let run(body, ctx: (:)) = {
  let ctx = z.parse(ctx, ctx-schema)
  let env = z.parse((:), env-schema)

  body.map(x => assert-node(ctx, x))

  for n in body {
    let res = eval(n, env, ctx: ctx)
    env = res.env
    (res.result,)
  }
}

#let compile(dsl) = {
  let dsl = z.parse(dsl, dsl-schema)
  let handlers = dsl.handlers

  // Build public constructors from registered handlers
  let api = handlers.pairs().fold((:), (acc, (k, v)) => acc + ((k): v.ctor))

  let ctx = (
    handlers: handlers,
    eval: eval,
    eval-args: eval-args,
    eval-children: eval-children,
  )

  let ctx = (
    handlers: handlers,
    eval: eval.with(ctx: ctx),
    eval-args: eval-args.with(ctx: ctx),
    eval-children: eval-children.with(ctx: ctx),
  )

  // Run a block/sequence of nodes and return the last result

  api + (run: run.with(ctx: ctx))
}
