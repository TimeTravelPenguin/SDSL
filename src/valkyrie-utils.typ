#import "@preview/valkyrie:0.2.2" as z
#import "@preview/oxifmt:1.0.0": strfmt

/// A Valkyrie assertion to check for exact string equality.
///
/// See issue: https://github.com/typst-community/valkyrie/issues/49
/// -> dictionary
#let _assert-str-eq(arg) = (
  condition: (self, it) => type(it) == str and it == arg,
  message: (self, it) => "Must be exactly " + str(arg),
)

/// A Valkyrie assertion to check that a version is less than or equal to a maximum version.
/// -> dictionary
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

/// A schema for a dictionary with string keys and values of a given schema.
/// -> array
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

