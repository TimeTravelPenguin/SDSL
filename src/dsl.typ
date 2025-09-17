#import "@preview/valkyrie:0.2.2" as z
#import "@preview/oxifmt:1.0.0": strfmt
#let schema-versions = (
  node: version(0, 1, 0),
  node-defaults: version(0, 1, 0),
  node-kw: version(0, 1, 0),
)

/// A Valkyrie assertion to check for exact string equality.
/// See issue: https://github.com/typst-community/valkyrie/issues/49
#let _assert-str-eq(arg) = (
  condition: (self, it) => type(it) == str and it == arg,
  message: (self, it) => "Must be exactly " + str(arg),
)

#let _assert-version-max(arg) = (
  condition: (self, it) => {
    let version = array(it)
    let max-version = array(arg)
    for n in range(calc.max(version.len(), max-version.len())) {
      let v = version.at(n, default: 0)
      let mv = max-version.at(n, default: 0)
      if v < mv {
        return true
      } else if v > mv {
        return false
      }
    }
    return true
  },
  message: (self, it) => "Version must be <=" + str(arg),
)

#let z-dictionary-of(value-schema, ..opts) = z.array(
  z.tuple(z.string(min: 1), value-schema),
  pre-transform: (self, it) => {
    assert.eq(type(it), dictionary, message: strfmt(
      "Input should be a dictionary. Got: '{}'.",
      type(it),
    ))

    it.pairs()
  },
  post-transform: (_, it) => it.fold((:), (acc, (k, v)) => acc + ((k): v)),
  ..opts,
)


// ====== Node Schema & Construction ======

/// Node keyword name configuration schema.
/// Allows renaming of standard node fields.
/// -> dictionary
#let _node-kw-schema = z.dictionary((
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
#let _node-defaults-schema = z.dictionary((
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
  _node-kw-schema,
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
  _node-defaults-schema,
)


#let _node-schema(kind) = z.dictionary((
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


#let _kind-schemas = z.dictionary((
  kind: z.string(optional: false, min: 1),
  ctor: z.function(optional: false),
  eval: z.function(optional: false),
))


#let _dsl-schema = z.dictionary((
  options: z.dictionary((
    node-kw-cfg: _node-kw-schema,
    node-defaults: _node-defaults-schema,
  )),
  kinds: z-dictionary-of(
    _kind-schemas,
    optional: true,
    default: (:),
  ),
))


#let new-dsl(node-kw-cfg: none, node-defaults-cfg: none) = z.parse(
  (
    options: (
      node-kw-cfg: node-kw-cfg,
      node-defaults: node-defaults-cfg,
    ),
  ),
  _dsl-schema,
)

#let x = new-dsl()
