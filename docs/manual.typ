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

#let docs = tidy.parse-module(
  read("/src/dsl.typ"),
  name: "DSL Module",
  old-syntax: false,
)

#show-module(
  docs,
  sort-functions: false,
  // omit-private-definitions: true,
)


