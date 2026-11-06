// Werbeflyer Go-AG – DIN A4, beidseitig, 4/4-farbig (CMYK), 3 mm Beschnitt.
//
// Datenformat 216 × 303 mm = Endformat 210 × 297 mm + 3 mm Beschnitt rundum,
// druckfertig für Onlinedruckereien wie Flyeralarm. Seite 1 = Vorderseite, Seite 2 = Rückseite.
//
//   typst compile flyer/flyer.typ flyer/go-ag-flyer-a4.pdf
//
// Quellen der Zitate (Rudolf Steiner Online Archiv, anthroposophie.byu.edu):
//   GA 294, 1. Vortrag, Stuttgart 21.8.1919  – Summe zuerst, dann Addenden
//   GA 301, 10. Vortrag, Basel 5.5.1920      – Analysieren als „völlig freie innere Tätigkeit“
//   GA 301, 5. Vortrag, Basel 26.4.1920      – Finger und „biegsame Gedanken“
//   GA 294, 7. Vortrag, Stuttgart 28.8.1919  – Schillers ästhetische Briefe
//   Schiller, Über die ästhetische Erziehung des Menschen, 15. Brief
//   GA 4, Die Philosophie der Freiheit, Kap. III („Ausnahmezustand“) und Kap. IX
//   GA 24, „Freie Schule und Dreigliederung“ (1919), S. 37

#import "@preview/tiaoma:0.3.0": qrcode

// --- Inhalt, der sich ändern kann ---------------------------------------------

// Kurz-URL auf der AG-Webseite; leitet per static/_redirects auf die Umfrage weiter.
#let survey-url = "https://go-ag.levinkeller.de/zeit"
#let survey-url-short = "go-ag.levinkeller.de/zeit"
#let website = "go-ag.levinkeller.de"

// --- Format -------------------------------------------------------------------

#let bleed = 3mm
#let trim-w = 210mm
#let trim-h = 297mm
#let page-w = trim-w + 2 * bleed
#let page-h = trim-h + 2 * bleed
#let safe = 12mm // Abstand Text ↔ Endformatrand
#let edge = bleed + safe // Abstand Text ↔ Datenformatrand
#let text-w = trim-w - 2 * safe

// --- Farben (CMYK) ------------------------------------------------------------

#let cream = cmyk(0%, 3%, 12%, 0%)
#let wood = cmyk(0%, 22%, 55%, 4%)
#let wood-edge = cmyk(0%, 35%, 70%, 22%)
#let grid-col = cmyk(0%, 40%, 60%, 70%)
#let ink = cmyk(0%, 0%, 0%, 100%) // Text: reines Schwarz
#let rich-black = cmyk(60%, 40%, 40%, 100%) // Flächen/Steine: Tiefschwarz
#let stone-white = cmyk(0%, 1%, 4%, 0%)
#let red = cmyk(0%, 88%, 82%, 4%)
#let red-dark = cmyk(0%, 90%, 85%, 35%)
#let white = cmyk(0%, 0%, 0%, 0%)
#let tint = cmyk(0%, 6%, 22%, 0%)
#let grey = cmyk(0%, 0%, 0%, 65%)

#set document(title: "Go-AG – Flyer A4", author: "Go-AG FWS Hannover Maschsee")
#set page(width: page-w, height: page-h, margin: 0pt, fill: cream)
#set text(font: "Carlito", lang: "de", fill: ink, size: 13pt, hyphenate: false)
#set par(leading: 0.5em, spacing: 0.9em, justify: false)
#set list(marker: text(fill: red-dark)[●], indent: 0pt, body-indent: 0.5em, spacing: 0.55em)

#let at(x, y, body) = place(top + left, dx: x, dy: y, body)

#let stone(x, y, r, black) = {
  if black {
    at(x - r, y - r, circle(radius: r, fill: rich-black))
    at(x - 0.63 * r, y - 0.63 * r, circle(radius: 0.28 * r, fill: cmyk(50%, 35%, 30%, 75%)))
  } else {
    at(x - 0.92 * r, y - 0.9 * r, circle(radius: r, fill: cmyk(0%, 5%, 12%, 25%)))
    at(x - r, y - r, circle(radius: r, fill: stone-white, stroke: 0.25pt + cmyk(0%, 5%, 10%, 35%)))
  }
}

#let qr-box(size, pad) = box(fill: white, inset: pad, radius: 2mm, qrcode(survey-url, options: (fg-color: ink), width: size))

#let h2(body) = block(above: 1.3em, below: 0.6em, text(weight: "bold", size: 17pt, fill: red-dark, body))

#let quote-box(body, source) = block(
  width: 100%,
  breakable: false,
  above: 0.8em,
  below: 0.9em,
  fill: tint,
  radius: (right: 1.5mm),
  stroke: (left: 1.2mm + red),
  inset: (left: 4mm, right: 3mm, y: 2.6mm),
)[
  #set par(leading: 0.45em)
  #text(style: "italic", size: 12pt, body)
  #v(0.3em)
  #align(right, text(size: 10pt, fill: grey, source))
]

// Schmale Brettleiste als Kopf: Gitter + ein paar Steine, läuft oben in den Beschnitt
#let board-strip(height, stones) = {
  let gap = 8.6mm
  at(0pt, 0pt, rect(width: page-w, height: height + 1.4mm, fill: wood-edge))
  at(0pt, 0pt, rect(width: page-w, height: height, fill: wood))
  let gy0 = height - 5mm // unterste Linie = Brettrand
  let gx0 = edge
  let cols = int((page-w - gx0) / gap) + 1
  let rows = int(gy0 / gap) + 1
  for i in range(cols) {
    let x = gx0 + i * gap
    at(0pt, 0pt, line(start: (x, 0pt), end: (x, gy0), stroke: (if i == 0 { 0.9pt } else { 0.4pt }) + grid-col))
  }
  for j in range(rows) {
    let y = gy0 - j * gap
    at(0pt, 0pt, line(start: (gx0, y), end: (page-w, y), stroke: (if j == 0 { 0.9pt } else { 0.4pt }) + grid-col))
  }
  let r = gap * 0.48
  for (i, j, b) in stones { stone(gx0 + i * gap, gy0 - j * gap, r, b) }
}

// ==============================================================================
// Vorderseite
// ==============================================================================

#board-strip(bleed + 36mm, (
  (13, 1, false), (14, 2, true), (15, 1, true), (16, 3, false), (17, 2, false), (18, 2, true),
  (15, 3, true), (19, 1, false), (20, 3, true), (16, 0, false), (12, 3, true),
))
#at(edge - 2mm, bleed + 6mm, box(fill: cream, inset: (x: 4mm, y: 3mm), radius: 2mm)[
  #text(weight: "bold", size: 50pt, top-edge: "cap-height", bottom-edge: "baseline")[Go-AG]
  #h(4mm)
  #text(font: "IPAGothic", size: 30pt, fill: red, bottom-edge: "baseline")[碁]
])

#at(edge, bleed + 46mm, block(width: text-w)[
  #text(size: 20pt, weight: "bold")[Eines der ältesten Strategiespiele der Welt – \ für Kinder, die gern tief nachdenken.]
  #v(3mm)
  #text(size: 14pt)[Go stammt aus China, ist über 2500 Jahre alt und wird bis heute in ganz Ostasien gespielt (Weiqi, Baduk). Die Regeln lernt man in fünf Minuten – und hat danach ein Leben lang zu entdecken.]

  #set text(size: 14pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 9mm,
    row-gutter: 5mm,
    [
      #h2[Für wen ist Go?]
      Für Kinder, die …
      - stundenlang an einer Sache tüfteln können,
      - Zahlen, Muster und Rätsel lieben,
      - immer noch eine Frage mehr haben,
      - beim Rechnen oder Schach längst mehr wollen,
      - lieber selbst denken als vorgesagt bekommen,
      - es mögen, still und konzentriert zu arbeiten.
      #v(0.4em)
      Die AG ist *offen für alle Klassen* – und genauso für Eltern, Lehrer:innen und Mitarbeiter:innen. Wer schon Go spielt, ist herzlich willkommen!
    ],
    [
      #h2[Warum gerade Go?]
      - *Kein Glück, nichts Verborgenes:* Alles liegt offen auf dem Brett. Es zählt nur das eigene Denken.
      - *Unerschöpflich:* Es gibt rund 2 · 10#super[170] mögliche Stellungen – unvorstellbar viel mehr, als das Universum Atome hat.
      - *Echte Mathematik:* Die Mathematiker Berlekamp und Wolfe haben für das Go-Endspiel eine eigene Theorie entwickelt.
      - *Fair zwischen Jung und Alt:* Durch Vorgabesteine können Kinder ernsthaft gegen Erwachsene spielen – und gewinnen.
      - *Ohne Bildschirm:* Holzbrett, Steine, ein Gegenüber.
    ],
    [
      #h2[So einfach geht Go]
      - Schwarz und Weiß setzen abwechselnd einen Stein auf die Kreuzungspunkte.
      - Wer Steine des Gegners ganz umzingelt, nimmt sie vom Brett.
      - Am Ende gewinnt, wer mehr Gebiet eingegrenzt hat.
    ],
    [
      #h2[So läuft die AG]
      - Im Mittelpunkt steht das *Spielen* miteinander.
      - Neulinge lernen die Regeln vor Ort – Einstieg jederzeit.
      - Bretter und Steine sind da.
      - Später: Ausflüge, z.~B. zum Messeturnier in Hannover.
    ],
  )
])

// Umfrage-Band
#{
  let band-h = bleed + 52mm
  let qr-size = 38mm
  at(0pt, page-h - band-h, rect(width: page-w, height: band-h, fill: red))
  at(page-w - edge - qr-size - 3mm, page-h - bleed - 7mm - qr-size - 3mm, qr-box(qr-size, 3mm))
  at(edge, page-h - band-h + 7mm, block(width: text-w - qr-size - 14mm)[
    #set text(fill: white)
    #text(weight: "bold", size: 30pt)[Wann hast du Zeit?]
    #v(2mm)
    #par(leading: 0.5em, text(size: 15pt)[Wir suchen einen AG-Termin, der möglichst vielen passt. Code scannen und ankreuzen, wann du kannst – dauert nur eine Minute!])
    #v(4mm)
    #text(weight: "bold", size: 14pt, survey-url-short)
  ])
}

#pagebreak()

// ==============================================================================
// Rückseite
// ==============================================================================

#at(edge, bleed + safe, block(width: text-w)[
  #text(weight: "bold", size: 28pt, top-edge: "cap-height")[Go und Waldorfpädagogik]
  #v(3mm)
  #text(size: 13pt)[Bei Rudolf Steiner kommt Go – soweit bekannt – nicht vor. Aber vieles, was im Go geübt wird, berührt Kernanliegen der Waldorfpädagogik.]

  #set text(size: 12.5pt)
  #block(height: 186mm, columns(2, gutter: 8mm)[
    #h2[Vom Ganzen ausgehen]
    Wer Go spielt, lernt zuerst auf das ganze Brett zu schauen und erst dann auf den einzelnen Kampf. Dieselbe Bewegung beschreibt Steiner für den Rechenunterricht:
    #quote-box[„… die Summe ist zuerst ins Auge zu fassen, und die ist dann zu spalten in die einzelnen Addenden.“][Rudolf Steiner, GA 294, 1. Vortrag, 1919]
    Beim Zerlegen, sagt er, sei man „in einer völlig freien inneren Tätigkeit“ (GA 301).

    #h2[Denken mit den Händen]
    Im Go wird jeder Gedanke zur Tat: Ein Stein wird gegriffen, gesetzt – und nicht mehr zurückgenommen. Denken und Wollen gehören zusammen.
    #quote-box[„… derjenige, der seine Finger ordentlich zu bewegen weiß, [hat] auch biegsame Gedanken und Ideen …“][Rudolf Steiner, GA 301, 5. Vortrag, 1920]

    #h2[Spiel in vollem Ernst]
    Steiner nannte Schillers „Briefe über die ästhetische Erziehung des Menschen“ eine der bedeutendsten pädagogischen Schriften (GA 294). Dort heißt es:
    #quote-box[„… der Mensch spielt nur, wo er in voller Bedeutung des Worts Mensch ist, und er ist nur da ganz Mensch, wo er spielt.“][Friedrich Schiller, 15. Brief]
    In China zählte Go zu den vier Künsten des Gebildeten – neben Musik, Kalligraphie und Malerei. Man nennt es auch 手談, „Gespräch mit den Händen“: zwei Menschen, die sich ohne Worte verstehen.

    #h2[Dem eigenen Denken zusehen]
    Nach jeder Partie liegt das Denken beider Spieler als Spur auf dem Brett. Man spielt sie Zug für Zug nach, bespricht sie und beobachtet so das eigene Denken – für Steiner „eine Art Ausnahmezustand“:
    #quote-box[„Wer das Denken beobachtet, lebt während der Beobachtung unmittelbar in einem geistigen, sich selbst tragenden Wesensweben darinnen.“][Rudolf Steiner, Die Philosophie der Freiheit, GA 4]

    #h2[Was im Kind veranlagt ist]
    #quote-box[„Was ist im Menschen veranlagt und was kann in ihm entwickelt werden?“][Rudolf Steiner, „Freie Schule und Dreigliederung“, GA 24]
    In der AG spielen alle miteinander. Die Go-Rätsel aber bekommt jedes Kind passend zu seiner Spielstärke – so findet auch, wer schon sehr weit ist, immer eine neue Herausforderung.

  ])
])

// Praktisches
#{
  let box-h = 52mm
  let qr-size = 30mm
  let top = page-h - bleed - safe - box-h
  at(edge, top, block(width: text-w, height: box-h, fill: rich-black, inset: 6mm)[
    #set text(fill: white, size: 12pt)
    #set par(leading: 0.45em)
    #grid(
      columns: (1fr, 1fr, qr-size + 4mm),
      column-gutter: 6mm,
      [
        #text(weight: "bold", size: 15pt)[Gut zu wissen]
        #v(1.5mm)
        Bisher mittwochs, 14–16 Uhr in der Schulbibliothek – der neue Termin richtet sich nach der Umfrage. \
        *Kostenlos*; bei fester Anmeldung 10~€ Startbeitrag, gelegentlich Kopiergeld für Rätsel.
      ],
      [
        #text(weight: "bold", size: 15pt, fill: cmyk(0%, 45%, 40%, 0%))[Wichtig für Eltern]
        #v(1.5mm)
        Die AG ist mit der Schule abgestimmt, aber *kein Betreuungsangebot*: Bei Krankheit fällt sie aus. Absagen kommen über den Mailverteiler. \
        Leitung: Levin Keller \
        *#website*
      ],
      align(center)[
        #qr-box(qr-size, 2mm)
        #v(1mm)
        #text(size: 9.5pt)[Umfrage]
      ],
    )
  ])
}
