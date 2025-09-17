#import "@preview/valkyrie:0.2.2" as z
#import "@preview/oxifmt:1.0.0": strfmt

#import "/src/valkyrie-utils.typ": _assert-str-eq
#import "/src/schemas.typ": (
  dsl-schema, node-defaults-schema, node-kw-schema, node-schema,
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
