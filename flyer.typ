// Info-Flyer (DIN A4) — Go-AG Freie Waldorfschule Hannover Maschsee
// Gedacht zum Aushang / Auslegen beim Sommerfest zur 100-Jahr-Feier.

#import "@preview/cetz:0.3.4"
#import "@preview/tiaoma:0.3.0"

// ── Farben & Stil ───────────────────────────────────────────────────────────
#let ink        = luma(15%)            // Schrift
#let green-dark = rgb("#3f6b4f")       // Go-Grün, kräftig
#let green-soft = rgb("#e7f0e9")       // Go-Grün, sehr hell (Flächen)
#let gold       = rgb("#c2982f")       // warmer Akzent (Waldorf / 100 Jahre)
#let line-col   = green-dark.mix((white, 35%))

#set text(fill: ink, font: "Liberation Sans", size: 11pt, lang: "de")
#set page(
  "a4",
  margin: (x: 16mm, top: 16mm, bottom: 14mm),
  footer: none,
)

// ── Goban-Illustration ──────────────────────────────────────────────────────
// Zeichnet ein quadratisches Go-Brett mit übergebenen Steinen.
// stones: Liste von (spalte, reihe, "b"/"w")  (1-basiert)
#let goban(n: 9, stones: (), size: 46mm) = cetz.canvas(length: size / (n - 1), {
  import cetz.draw: *
  let lw = (paint: green-dark.mix((white, 25%)), thickness: 0.5pt)

  // Holzfarbener Hintergrund mit Rand
  rect(
    (-1.1, -1.1), (n - 1 + 1.1, n - 1 + 1.1),
    fill: rgb("#f3e7c9"), stroke: (paint: gold, thickness: 1.2pt), radius: 0.18,
  )
  // Gitter
  for i in range(n) {
    line((0, i), (n - 1, i), stroke: lw)
    line((i, 0), (i, n - 1), stroke: lw)
  }
  // Hoshi-Punkte (für 9×9)
  for h in ((2, 2), (2, 6), (4, 4), (6, 2), (6, 6)) {
    circle(h, radius: 0.07, fill: green-dark.mix((white, 10%)), stroke: none)
  }
  // Steine
  for s in stones {
    let (c, r, col) = s
    let pos = (c - 1, r - 1)
    if col == "b" {
      circle(pos, radius: 0.47, fill: luma(12%), stroke: none)
      circle((pos.at(0) - 0.13, pos.at(1) + 0.13), radius: 0.12,
        fill: luma(45%), stroke: none) // Glanzlicht
    } else {
      circle(pos, radius: 0.47, fill: white,
        stroke: (paint: luma(55%), thickness: 0.5pt))
      circle((pos.at(0) - 0.13, pos.at(1) + 0.13), radius: 0.12,
        fill: white, stroke: none)
    }
  }
})

// Eine kleine, hübsche Stellung
#let stellung = (
  (3, 3, "b"), (3, 4, "b"), (4, 3, "w"), (4, 4, "w"),
  (5, 5, "b"), (5, 6, "w"), (6, 5, "w"), (6, 6, "b"),
  (7, 7, "b"), (7, 3, "w"), (3, 7, "w"),
)

// ── Kopf ────────────────────────────────────────────────────────────────────
#align(center)[
  #text(fill: gold, weight: "bold", size: 12pt, tracking: 2pt)[
    SOMMERFEST · 100-JAHR-FEIER
  ]
  #v(-2mm)
  #text(fill: green-dark, size: 14pt)[
    Freie Waldorfschule Hannover Maschsee
  ]
]

#v(4mm)

#grid(
  columns: (1fr, auto),
  column-gutter: 8mm,
  align: (left + horizon, center + horizon),
  [
    #text(fill: green-dark, size: 40pt, weight: "bold")[Spiel mit\ uns Go!]
    #v(1mm)
    #text(size: 13pt)[
      Das über 2500 Jahre alte Strategiespiel aus Ostasien\
      — einfach zu lernen, ein Leben lang spannend.
    ]
  ],
  goban(n: 9, stones: stellung, size: 52mm),
)

#v(5mm)
#line(length: 100%, stroke: (paint: line-col, thickness: 1pt, dash: "dotted"))
#v(4mm)

// ── Einladung ───────────────────────────────────────────────────────────────
#text(size: 12.5pt)[
  *Wir sind die Go-AG der Waldorfschule* — und wir freuen uns über jede:n,
  der oder die Lust hat, mitzuspielen! Komm einfach vorbei, schau zu oder leg
  direkt los. Wir erklären Neulingen geduldig die Regeln.
]

#v(5mm)

// ── Termin-Box ──────────────────────────────────────────────────────────────
#block(
  width: 100%,
  fill: green-soft,
  inset: (x: 7mm, y: 6mm),
  radius: 4pt,
  stroke: (paint: green-dark, thickness: 1pt),
)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 6mm,
    align: (left + horizon, left + horizon),
    text(size: 30pt)[🗓️],
    [
      #text(fill: green-dark, size: 18pt, weight: "bold")[
        Jeden Mittwoch · 14:00 – 16:00 Uhr
      ]\
      #text(size: 13pt)[in der *Schulbibliothek* der Freien Waldorfschule Hannover Maschsee]
    ],
  )
]

#v(6mm)

// ── Highlights ──────────────────────────────────────────────────────────────
#let punkt(emoji, titel, text-body) = grid(
  columns: (auto, 1fr),
  column-gutter: 3mm,
  align: (center + top, left + top),
  text(size: 16pt)[#emoji],
  [#text(weight: "bold", fill: green-dark)[#titel]\ #text(size: 10.5pt)[#text-body]],
)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 8mm,
  row-gutter: 5mm,
  punkt("🎉", "Alle sind willkommen", "Schüler:innen aller Altersklassen, Lehrer:innen, Eltern und Mitarbeiter:innen."),
  punkt("🧩", "Kein Vorwissen nötig", "Du musst nichts können — wir bringen es dir bei."),
  punkt("💶", "Kostenlos", "Die Teilnahme ist grundsätzlich kostenlos."),
  punkt("🪨", "Material vorhanden", "Bretter und Steine sind da — einfach kommen, nichts mitbringen."),
  punkt("🏆", "Turniere", "Wir besuchen gemeinsam Go-Turniere, z. B. in Hannover."),
  punkt("🚪", "Einstieg jederzeit", "Komm vorbei, wann du magst — auch mitten im Schuljahr."),
)

#v(1fr)

// ── Fuß: QR-Code + Website ──────────────────────────────────────────────────
#line(length: 100%, stroke: (paint: line-col, thickness: 1pt, dash: "dotted"))
#v(3mm)

#grid(
  columns: (auto, 1fr),
  column-gutter: 7mm,
  align: (center + horizon, left + horizon),
  box(
    fill: white,
    inset: 2mm,
    radius: 3pt,
    stroke: (paint: line-col, thickness: 0.5pt),
    tiaoma.qrcode("https://go-ag.levinkeller.de", options: (scale: 2.6)),
  ),
  [
    #text(fill: green-dark, size: 15pt, weight: "bold")[Neugierig? Hier gibt's alle Infos:]\
    #v(1mm)
    #text(size: 14pt)[#link("https://go-ag.levinkeller.de")[go-ag.levinkeller.de]]\
    #text(size: 10pt, fill: luma(40%))[
      Die Go-AG ist offiziell auf der Schul-Website gelistet
      (Schulleben → Nachmittagsangebote).
    ]
  ],
)
