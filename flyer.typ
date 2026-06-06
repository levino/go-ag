// Info-Flyer / Aushang (DIN A4) — Go-AG Freie Waldorfschule Hannover Maschsee
// Waldorf-Ästhetik: warmes Papier, Aquarell-Lasuren, handgezeichnete Formen,
// Handschrift (Caveat) + erdiger Serif (Andada Pro), natürliche Erdfarben.
//
// Schriften & Emojis liegen reproduzierbar im Ordner ../fonts/ und werden vom
// Typst-Loader (plugins/docusaurus-typst/loader.js) per --font-path eingebunden,
// damit das Rendern host-unabhängig identisch aussieht.
//   Display/Handschrift : Caveat        (Caveat-Regular/-Bold.ttf)
//   Fließtext (Serif)   : Andada Pro     (AndadaPro-Regular/-Bold.ttf)
//   Emojis (Subset)     : Noto Color Emoji (NotoColorEmoji-subset.ttf)
//                         enthalten: 📅 📍 👋 🆓 🙌 📱 🎉 ✨ 🏆 🎈
//   -> Bei neuen Emojis das Subset in fonts/ erweitern (siehe README).

#import "@preview/cetz:0.3.4"
#import "@preview/tiaoma:0.3.0"

// ── Erdige Waldorf-Palette ──────────────────────────────────────────────────
#let paper   = rgb("#FBF3E3")   // warmes, cremefarbenes Papier
#let card    = rgb("#FFFDF6")   // warmes Weiß für Flächen
#let ink     = rgb("#4A3B2E")   // warmes Dunkelbraun (Schrift)
#let terra   = rgb("#C75D43")   // Terrakotta
#let ochre   = rgb("#D6A23E")   // Ocker / Honiggelb
#let sage    = rgb("#6E8C56")   // Salbeigrün
#let sage-dk = rgb("#4F6B3D")   // dunkles Laubgrün
#let sky     = rgb("#7E97A8")   // staubiges Blau

#set text(fill: ink, font: "Andada Pro", size: 12pt, lang: "de")

// Kurzschreibweisen für die Handschrift
#let hand(it, size: 30pt, fill: ink, weight: "bold") = text(
  font: "Caveat", weight: weight, size: size, fill: fill,
)[#it]

// ── Aquarell-Lasur (weiche Farbwolke über Radialverlauf) ────────────────────
#let wash(col, r) = circle(
  radius: r, stroke: none,
  fill: gradient.radial(col.transparentize(55%), col.transparentize(100%)),
)

// ── Handgezeichnete Sonne (Waldorf-Jahreszeitenmotiv) ───────────────────────
#let sonne(col: ochre, r: 9) = cetz.canvas(length: 1mm, {
  import cetz.draw: *
  circle((0, 0), radius: r, fill: col.transparentize(15%), stroke: none)
  for k in range(12) {
    let a = k / 12 * 2 * 3.14159265
    let (cx, cy) = (calc.cos(a), calc.sin(a))
    line(
      (cx * (r + 1.5), cy * (r + 1.5)),
      (cx * (r + 5.5), cy * (r + 5.5)),
      stroke: (paint: col, thickness: 1.3pt, cap: "round"),
    )
  }
})

// ── Fließende Formzeichnen-Welle als Trennlinie ─────────────────────────────
#let welle(col: ochre, w: 178, amp: 2.6, n-wellen: 5) = cetz.canvas(length: 1mm, {
  import cetz.draw: *
  let pts = ()
  let steps = 260
  for i in range(steps + 1) {
    let x = i / steps * w
    let y = amp * calc.sin(i / steps * n-wellen * 2 * 3.14159265)
    pts.push((x, y))
  }
  line(..pts, stroke: (paint: col, thickness: 1.7pt, cap: "round"))
})

// ── Kleine handgezeichnete Blüte (statt Font-Dingbat → voll reproduzierbar) ──
#let bluete(col: terra, r: 2.2) = box(baseline: 0.3em, cetz.canvas(length: 1mm, {
  import cetz.draw: *
  for k in range(5) {
    let a = k / 5 * 2 * 3.14159265 - 3.14159265 / 2
    circle((calc.cos(a) * r, calc.sin(a) * r), radius: r * 0.66,
      fill: col.transparentize(8%), stroke: none)
  }
  circle((0, 0), radius: r * 0.6, fill: ochre, stroke: none)
}))

// ── Go-Stein als natürlicher Aufzählungspunkt ───────────────────────────────
#let stein(col) = box(baseline: 0.22em, circle(
  radius: 4.5pt, fill: col, stroke: (paint: col.darken(18%), thickness: 0.4pt),
))

// ── Warmes Goban ────────────────────────────────────────────────────────────
#let goban(n: 9, stones: (), size: 50mm) = cetz.canvas(length: size / (n - 1), {
  import cetz.draw: *
  let lw = (paint: rgb("#9c7b46"), thickness: 0.5pt)
  rect((-1.25, -1.25), (n - 1 + 1.25, n - 1 + 1.25),
    fill: rgb("#EBD7A8"), stroke: (paint: ochre.darken(8%), thickness: 1.6pt), radius: 0.35)
  for i in range(n) {
    line((0, i), (n - 1, i), stroke: lw)
    line((i, 0), (i, n - 1), stroke: lw)
  }
  for h in ((2, 2), (2, 6), (4, 4), (6, 2), (6, 6)) {
    circle(h, radius: 0.08, fill: rgb("#9c7b46"), stroke: none)
  }
  for s in stones {
    let (c, r, col) = s
    let pos = (c - 1, r - 1)
    if col == "b" {
      circle(pos, radius: 0.47, fill: rgb("#3a342c"), stroke: none)
      circle((pos.at(0) - 0.14, pos.at(1) + 0.14), radius: 0.11, fill: luma(70%).transparentize(40%), stroke: none)
    } else {
      circle(pos, radius: 0.47, fill: rgb("#FBFAF5"), stroke: (paint: luma(60%), thickness: 0.4pt))
      circle((pos.at(0) - 0.14, pos.at(1) + 0.14), radius: 0.11, fill: white, stroke: none)
    }
  }
})

#let stellung = (
  (3, 3, "b"), (3, 4, "b"), (4, 3, "w"), (4, 4, "w"),
  (5, 5, "b"), (5, 6, "w"), (6, 5, "w"), (6, 6, "b"),
  (7, 7, "b"), (7, 3, "w"), (3, 7, "w"),
)

// ── Seite mit Aquarell-Hintergrund ──────────────────────────────────────────
#set page(
  "a4",
  margin: (x: 16mm, top: 12mm, bottom: 11mm),
  fill: paper,
  background: {
    place(top + left,     dx: -34mm, dy: -28mm, wash(sage, 72mm))
    place(top + right,    dx:  30mm, dy: -34mm, wash(ochre, 80mm))
    place(bottom + right, dx:  34mm, dy:  30mm, wash(terra, 74mm))
    place(bottom + left,  dx: -28mm, dy:  26mm, wash(sky, 62mm))
    place(top + right,    dx: -15mm, dy:  13mm, sonne())
  },
)

// ── Kopf ────────────────────────────────────────────────────────────────────
#align(center)[
  #bluete(col: terra) #h(2.5mm) #hand(size: 23pt, fill: terra)[herzlich willkommen beim Sommerfest zur 100-Jahr-Feier] #h(2.5mm) #bluete(col: sage)
]

#v(2mm)

#grid(
  columns: (1fr, auto),
  column-gutter: 6mm,
  align: (left + horizon, center + horizon),
  [
    #hand(size: 74pt, fill: terra)[Spiel mit\ uns Go!]
    #v(-4mm)
    #text(font: "Andada Pro", size: 12.5pt, fill: ink.lighten(8%))[
      Das alte Strategiespiel aus Ostasien — \
      einfach zu lernen, ein Leben lang spannend. #text(fill: ochre)[✨]
    ]
  ],
  goban(n: 9, stones: stellung, size: 54mm),
)

#v(3mm)
#align(center, welle(col: ochre, w: 176, n-wellen: 6, amp: 2.4))
#v(3mm)

// ── Blickfang: Wann & Wo ────────────────────────────────────────────────────
#block(
  width: 100%,
  fill: card,
  inset: (x: 9mm, y: 6mm),
  radius: 14pt,
  stroke: (paint: sage, thickness: 1.5pt),
)[
  #set par(leading: 0.35em)
  #grid(
    columns: (auto, 1fr),
    column-gutter: 6mm,
    row-gutter: 4mm,
    align: (center + horizon, left + horizon),
    text(size: 28pt)[📅],
    [
      #text(font: "Andada Pro", weight: "bold", size: 11pt, fill: ochre.darken(8%), tracking: 1pt)[WANN]\
      #hand(size: 36pt, fill: sage-dk)[Jeden Mittwoch · 14–16 Uhr]
    ],
    text(size: 28pt)[📍],
    [
      #text(font: "Andada Pro", weight: "bold", size: 11pt, fill: ochre.darken(8%), tracking: 1pt)[WO]\
      #hand(size: 36pt, fill: sage-dk)[Schulbibliothek]
    ],
  )
]

#v(5mm)

// ── Wenige, warme Kernpunkte ────────────────────────────────────────────────
#set par(leading: 0.55em)
#let punkt(col, body) = grid(
  columns: (auto, 1fr),
  column-gutter: 4mm,
  align: (center + horizon, left + horizon),
  stein(col),
  text(font: "Andada Pro", size: 14.5pt)[#body],
)

#stack(
  spacing: 4.5mm,
  punkt(terra)[Komm einfach vorbei — *jede:r* ist herzlich willkommen! 👋],
  punkt(ochre)[*Kostenlos*, kein Vorwissen nötig, Spielmaterial ist da.],
  punkt(sage)[Schüler:innen aller Klassen, Lehrer:innen & Eltern.],
  punkt(sky)[Wir spielen, lernen — und besuchen Go-Turniere. 🏆],
)

#v(1fr)

#align(center, welle(col: sage, w: 176, n-wellen: 6, amp: 2.4))
#v(3mm)

// ── Fuß: QR-Code + Website ──────────────────────────────────────────────────
#grid(
  columns: (auto, 1fr),
  column-gutter: 8mm,
  align: (center + horizon, left + horizon),
  box(
    fill: card, inset: 2.5mm, radius: 8pt,
    stroke: (paint: ochre, thickness: 1pt),
    tiaoma.qrcode("https://go-ag.levinkeller.de", options: (scale: 2.7)),
  ),
  [
    #hand(size: 30pt, fill: terra)[Neugierig? Hier gibt's alle Infos: 📱]
    #v(0mm)
    #text(font: "Andada Pro", weight: "bold", size: 19pt, fill: sage-dk)[
      #link("https://go-ag.levinkeller.de")[go-ag.levinkeller.de]
    ]
  ],
)
