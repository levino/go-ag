// Info-Flyer / Aushang (DIN A4) — Go-AG Freie Waldorfschule Hannover Maschsee
// Plakativ zum Aufkleben/Aushängen beim Sommerfest zur 100-Jahr-Feier.
//
// Emojis: Es werden ausschließlich Emojis verwendet, die im mitgelieferten
// Subset-Font (../fonts/NotoColorEmoji-subset.ttf) enthalten sind. Dadurch
// rendern sie auf JEDEM Build-Host farbig — unabhängig von Systemschriften,
// also keine leeren Kästchen ("Tofu"). Der Font-Pfad wird vom Typst-Loader
// (plugins/docusaurus-typst/loader.js) per --font-path gesetzt.
// Enthaltene Emojis: 📅 📍 👋 🆓 🙌 📱 🎉 ✨ 🏆 🎈
// -> Beim Hinzufügen weiterer Emojis das Subset in fonts/ entsprechend erweitern!

#import "@preview/cetz:0.3.4"
#import "@preview/tiaoma:0.3.0"

// ── Farben & Stil ───────────────────────────────────────────────────────────
#let ink        = luma(15%)
#let green-dark = rgb("#3f6b4f")
#let green-soft = rgb("#e7f0e9")
#let gold       = rgb("#c2982f")
#let line-col   = green-dark.mix((white, 35%))

#set text(fill: ink, font: "Liberation Sans", size: 12pt, lang: "de")
#set page("a4", margin: (x: 16mm, top: 15mm, bottom: 13mm), footer: none)

// ── Goban-Illustration (gezeichnet) ─────────────────────────────────────────
#let goban(n: 9, stones: (), size: 46mm) = cetz.canvas(length: size / (n - 1), {
  import cetz.draw: *
  let lw = (paint: green-dark.mix((white, 25%)), thickness: 0.5pt)
  rect((-1.1, -1.1), (n - 1 + 1.1, n - 1 + 1.1),
    fill: rgb("#f3e7c9"), stroke: (paint: gold, thickness: 1.2pt), radius: 0.18)
  for i in range(n) {
    line((0, i), (n - 1, i), stroke: lw)
    line((i, 0), (i, n - 1), stroke: lw)
  }
  for h in ((2, 2), (2, 6), (4, 4), (6, 2), (6, 6)) {
    circle(h, radius: 0.07, fill: green-dark.mix((white, 10%)), stroke: none)
  }
  for s in stones {
    let (c, r, col) = s
    let pos = (c - 1, r - 1)
    if col == "b" {
      circle(pos, radius: 0.47, fill: luma(12%), stroke: none)
      circle((pos.at(0) - 0.13, pos.at(1) + 0.13), radius: 0.12, fill: luma(45%), stroke: none)
    } else {
      circle(pos, radius: 0.47, fill: white, stroke: (paint: luma(55%), thickness: 0.5pt))
      circle((pos.at(0) - 0.13, pos.at(1) + 0.13), radius: 0.12, fill: white, stroke: none)
    }
  }
})

#let stellung = (
  (3, 3, "b"), (3, 4, "b"), (4, 3, "w"), (4, 4, "w"),
  (5, 5, "b"), (5, 6, "w"), (6, 5, "w"), (6, 6, "b"),
  (7, 7, "b"), (7, 3, "w"), (3, 7, "w"),
)

// ── Kopf ────────────────────────────────────────────────────────────────────
#align(center, text(fill: gold, weight: "bold", size: 12pt, tracking: 1.5pt)[
  🎉 SOMMERFEST · 100-JAHR-FEIER · WALDORFSCHULE MASCHSEE 🎉
])

#v(6mm)

#grid(
  columns: (1fr, auto),
  column-gutter: 8mm,
  align: (left + horizon, center + horizon),
  text(fill: green-dark, size: 52pt, weight: "bold")[Spiel mit\ uns Go! ✨],
  goban(n: 9, stones: stellung, size: 54mm),
)

#v(7mm)

// ── DER Blickfang: Wann & Wo ────────────────────────────────────────────────
#block(
  width: 100%,
  fill: green-soft,
  inset: (x: 9mm, y: 9mm),
  radius: 6pt,
  stroke: (paint: green-dark, thickness: 1.5pt),
)[
  #set par(leading: 0.45em)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 7mm,
    row-gutter: 7mm,
    align: (center + horizon, left + horizon),
    text(size: 34pt)[📅],
    text(fill: green-dark, weight: "bold", size: 33pt)[Jeden Mittwoch\ #text(size: 38pt)[14 – 16 Uhr]],
    text(size: 34pt)[📍],
    text(fill: green-dark, weight: "bold", size: 33pt)[Schulbibliothek],
  )
]

#v(8mm)

// ── Wenige, große Kernpunkte (mit Emoji als Aufzählungssymbol) ──────────────
#set par(leading: 0.6em)
#let punkt(sym, body) = grid(
  columns: (auto, 1fr),
  column-gutter: 4mm,
  align: (center + horizon, left + horizon),
  text(size: 22pt)[#sym],
  text(size: 19pt, weight: "bold", fill: ink)[#body],
)

#stack(
  spacing: 6mm,
  punkt[👋][Komm einfach vorbei — *jede:r* ist willkommen!],
  punkt[🆓][*Kostenlos*, kein Vorwissen nötig, Material ist da.],
  punkt[🙌][Schüler:innen aller Klassen, Lehrer:innen & Eltern.],
  punkt[🏆][Wir spielen, lernen — und besuchen Go-Turniere.],
)

#v(1fr)

// ── Fuß: QR-Code + Website ──────────────────────────────────────────────────
#line(length: 100%, stroke: (paint: line-col, thickness: 1pt, dash: "dotted"))
#v(4mm)

#grid(
  columns: (auto, 1fr),
  column-gutter: 8mm,
  align: (center + horizon, left + horizon),
  box(
    fill: white, inset: 2mm, radius: 3pt,
    stroke: (paint: line-col, thickness: 0.5pt),
    tiaoma.qrcode("https://go-ag.levinkeller.de", options: (scale: 2.8)),
  ),
  [
    #text(fill: green-dark, size: 17pt, weight: "bold")[📱 Alle Infos & Termine:]\
    #v(1mm)
    #text(size: 22pt, weight: "bold")[#link("https://go-ag.levinkeller.de")[go-ag.levinkeller.de]]
  ],
)
