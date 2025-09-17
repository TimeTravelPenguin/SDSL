#import "@preview/tidy:0.4.3"
#import "@preview/catppuccin:1.0.0": catppuccin, flavors, show-module

#show: catppuccin.with("mocha")
#let colors = flavors.mocha.colors

#show raw.where(block: true): set block(
  fill: flavors.mocha.colors.crust.rgb,
  stroke: colors.overlay0.rgb + 1pt,
  inset: (x: 2em, y: 1em),
  radius: 5pt,
)

#let dsl-module = tidy.parse-module(
  read("/src/dsl.typ"),
  old-syntax: false,
)

#let schema-module = tidy.parse-module(
  read("/src/schemas.typ"),
  old-syntax: false,
)

= DSL Module

#show-module(
  dsl-module,
  sort-functions: false,
  // omit-private-definitions: true,
)

#pagebreak()

= Schema Module

#show-module(
  schema-module,
  sort-functions: false,
)


