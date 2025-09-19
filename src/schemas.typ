#import "@preview/valkyrie:0.2.2" as z

#import "/src/valkyrie-utils.typ": (
  _assert-str-eq, _assert-version-max, z-dictionary-of,
)

/// Schema versions for different configuration schemas.
/// Potentially unused, but useful for future-proofing and working with libraries
/// that update their schemas.
/// -> dictionary
#let schema-versions = (
  node: version(0, 1, 0),
  node-defaults: version(0, 1, 0),
  node-kw: version(0, 1, 0),
)

/// Node keyword name configuration schema.
/// Allows renaming of standard node fields.
/// -> dictionary
#let node-kw-schema = z.dictionary((
  kw-kind: z.string(optional: true, default: "kind", min: 1),
  kw-args: z.string(optional: true, default: "args", min: 1),
  kw-kwargs: z.string(optional: true, default: "kwargs", min: 1),
  kw-children: z.string(optional: true, default: "children", min: 1),
  version: z.version(
    optional: true,
    default: schema-versions.node-kw,
    assertions: (_assert-version-max(schema-versions.node-kw),),
  ),
))

/// Node value defaults configuration schema.
/// Allows changing the default values for standard node fields.
/// -> dictionary
#let node-defaults-schema = z.dictionary((
  default-args: z.array(z.any(), optional: true, default: ()),
  default-kwargs: z-dictionary-of(
    z.any(),
    optional: true,
    default: (:),
  ),
  default-children: z.array(optional: true, default: ()),
  version: z.version(
    optional: true,
    default: schema-versions.node-defaults,
    assertions: (_assert-version-max(schema-versions.node-defaults),),
  ),
))

/// Node schema.
/// Nodes are the fundamental building blocks of the DSL.
/// They represent individual elements or constructs within the DSL.
/// -> dictionary
#let node-schema(
  /// The kind of node. This is a required field and must be a non-empty string.
  /// See @kind-schema for additional details.
  /// -> str
  kind,
) = z.dictionary((
  kind: z.string(optional: false, min: 1, assertions: (_assert-str-eq(kind),)),
  args: z.array(z.any(), optional: true, default: ()),
  kwargs: z-dictionary-of(
    z.any(),
    optional: true,
    default: (:),
  ),
  children: z.array(optional: true, default: ()),
  version: z.version(
    optional: true,
    default: schema-versions.node,
    assertions: (_assert-version-max(schema-versions.node),),
  ),
))

/// Handler schema.
/// Handlers define how specific node kinds are constructed and evaluated.
/// Each handler must specify a constructor and an evaluator function.
/// -> dictionary
#let handler-schema = z.dictionary((
  kind: z.string(optional: false, min: 1),
  // (args: array, kwargs: dictionary, children: array) -> node
  ctor: z.function(optional: false),
  // (node, env: Env, ctx: Ctx) -> (result, env: Env)
  eval: z.function(optional: false),
))

/// Environment schema.
/// The environment holds variable bindings and other contextual information that
/// can be accessed and modified during node evaluation.
/// -> dictionary
#let env-schema = z.dictionary((
  vars: z-dictionary-of(z.any(), optional: true, default: (:)),
))

/// Context schema.
/// The context provides additional read-only information and utilities that can be used
/// during node evaluation, such as access to handlers and evaluation functions.
/// -> dictionary
#let ctx-schema = z.dictionary((
  handlers: z-dictionary-of(handler-schema, optional: true, default: (:)),
  eval: z.function(optional: false),
  eval-args: z.function(optional: false),
  eval-children: z.function(optional: false),
  options: z.dictionary((
    node-kw-cfg: node-kw-schema,
    node-defaults: node-defaults-schema,
  )),
))

/// DSL configuration schema.
/// This schema defines the overall configuration for the DSL,
/// including options for node keyword renaming and default values,
/// as well as the definitions of various node kinds.
/// -> dictionary
#let dsl-schema = z.dictionary((
  options: z.dictionary((
    node-kw-cfg: node-kw-schema,
    node-defaults: node-defaults-schema,
  )),
  handlers: z-dictionary-of(
    handler-schema,
    optional: true,
    default: (:),
  ),
))

/// Result schema for running a DSL evaluation.
/// This schema captures the result of evaluating a DSL expression,
/// along with the final environment state.
/// -> dictionary
#let run-result-schema = z.dictionary((
  result: z.any(optional: true, default: none),
  env: env-schema,
))
