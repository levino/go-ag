// Werbeflyer Go-AG – DIN A5, beidseitig, 4/4-farbig (CMYK), 3 mm Beschnitt.
//
// Datenformat 154 × 216 mm = Endformat 148 × 210 mm + 3 mm Beschnitt rundum,
// druckfertig für Onlinedruckereien wie Flyeralarm. Seite 1 = Vorderseite, Seite 2 = Rückseite.
//
//   typst compile flyer/flyer.typ flyer/go-ag-flyer-a5.pdf

#import "@preview/tiaoma:0.3.0": qrcode

// --- Inhalt, der sich ändern kann ---------------------------------------------

// Kurz-URL auf der AG-Webseite; leitet per static/_redirects auf die Umfrage weiter.
// So bleibt der gedruckte QR-Code gültig, auch wenn sich die Umfrage-URL ändert.
#let survey-url = "https://go-ag.levinkeller.de/zeit"
#let survey-url-short = "go-ag.levinkeller.de/zeit"
#let website = "go-ag.levinkeller.de"

// --- Format -------------------------------------------------------------------

#let bleed = 3mm
#let trim-w = 148mm
#let trim-h = 210mm
#let page-w = trim-w + 2 * bleed
#let page-h = trim-h + 2 * bleed
#let safe = 7mm // Abstand Text ↔ Endformatrand
#let edge = bleed + safe // Abstand Text ↔ Datenformatrand

// --- Farben (CMYK) ------------------------------------------------------------

#let cream = cmyk(0%, 3%, 12%, 0%)
#let wood = cmyk(0%, 22%, 55%, 4%)
#let wood-edge = cmyk(0%, 35%, 70%, 22%)
#let wood-grain = cmyk(0%, 28%, 60%, 9%)
#let grid-col = cmyk(0%, 40%, 60%, 70%)
#let ink = cmyk(0%, 0%, 0%, 100%) // Text: reines Schwarz
#let rich-black = cmyk(60%, 40%, 40%, 100%) // Flächen/Steine: Tiefschwarz
#let stone-white = cmyk(0%, 1%, 4%, 0%)
#let red = cmyk(0%, 88%, 82%, 4%)
#let red-dark = cmyk(0%, 90%, 85%, 35%)
#let white = cmyk(0%, 0%, 0%, 0%)
#let tint = cmyk(0%, 6%, 20%, 0%)

#set document(title: "Go-AG – Flyer A5", author: "Go-AG FWS Hannover Maschsee")
#set page(width: page-w, height: page-h, margin: 0pt, fill: cream)
#set text(font: "Carlito", lang: "de", fill: ink, size: 10.5pt)
#set par(leading: 0.55em, spacing: 0pt)

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

#let qr-box(size, pad) = box(
  fill: white,
  inset: pad,
  radius: 2mm,
  qrcode(survey-url, options: (fg-color: ink), width: size),
)

// ==============================================================================
// Vorderseite
// ==============================================================================

// Brett: linke untere Ecke eines 19×19-Bretts, läuft oben/rechts in den Beschnitt
#{
  let gap = 8.6mm
  let gx0 = bleed + 14mm // Gitterecke (A1), von links
  let gy0 = page-h - bleed - 108mm // Gitterecke, von oben
  let margin = 5.5mm
  let bx = gx0 - margin
  let by = gy0 + margin // Unterkante Brett, von oben

  at(bx + 0.8mm, -5mm, rect(width: page-w, height: by + 5mm + 1.6mm, radius: 3mm, fill: wood-edge))
  at(bx, -5mm, rect(width: page-w, height: by + 5mm, radius: 3mm, fill: wood))

  // Maserung
  for i in range(14) {
    let yy = by - 4mm - i * 7.7mm
    at(0pt, 0pt, curve(
      stroke: 0.6pt + wood-grain,
      curve.move((bx, yy)),
      curve.cubic((bx + 40mm, yy - 2.5mm), (bx + 90mm, yy + 2.5mm), (page-w, yy - 1.2mm)),
    ))
  }

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
  for (i, j) in ((3, 3), (9, 3), (3, 9), (9, 9), (15, 3), (3, 15), (15, 9), (9, 15)) {
    at(gx0 + i * gap - 0.9mm, gy0 - j * gap - 0.9mm, circle(radius: 0.9mm, fill: grid-col))
  }

  // Steine (eine Ecken-Stellung mit Kampf)
  let blacks = ((3, 3), (2, 5), (4, 4), (5, 2), (3, 6), (8, 2), (6, 6), (2, 9), (10, 4), (5, 9), (12, 7))
  let whites = ((2, 2), (2, 3), (3, 2), (4, 1), (1, 4), (2, 4), (6, 3), (5, 5), (7, 5), (4, 7), (11, 9), (8, 8))
  let r = gap * 0.48
  for (i, j) in whites { stone(gx0 + i * gap, gy0 - j * gap, r, false) }
  for (i, j) in blacks { stone(gx0 + i * gap, gy0 - j * gap, r, true) }
}

// Titel, Untertitel, Stichpunkte
#at(edge, page-h - bleed - 97mm, block(width: trim-w - 2 * safe)[
  #grid(
    columns: (1fr, auto),
    align: (left + bottom, right + bottom),
    text(weight: "bold", size: 78pt, top-edge: "cap-height", bottom-edge: "baseline")[Go-AG],
    text(font: "IPAGothic", size: 34pt, fill: red, bottom-edge: "baseline")[碁],
  )
  #v(5mm)
  #text(size: 14.5pt)[Das über 2500 Jahre alte Strategiespiel aus Ostasien – *bei uns an der Schule!*]
  #v(5mm)
  #let chip(label) = box(
    fill: ink, radius: 3.3mm, inset: (x: 3mm, y: 1.9mm),
    text(fill: white, weight: "bold", size: 10.5pt, label),
  )
  #chip[kostenlos] #h(1mm) #chip[alle Klassen] #h(1mm) #chip[Bretter & Steine da] #h(1mm) #chip[Einstieg jederzeit]
])

// Umfrage-Band
#{
  let band-h = bleed + 44mm
  let qr-size = 32mm
  at(0pt, page-h - band-h, rect(width: page-w, height: band-h, fill: red))
  at(page-w - edge - qr-size - 2.5mm, page-h - bleed - 6.5mm - qr-size - 2.5mm, qr-box(qr-size, 2.5mm))
  at(edge, page-h - band-h + 6mm, block(width: trim-w - 2 * safe - qr-size - 7mm)[
    #set text(fill: white)
    #text(weight: "bold", size: 21pt)[Wann hast du Zeit?]
    #v(3mm)
    #par(leading: 0.55em, text(size: 11pt)[Wir suchen einen AG-Termin, der möglichst vielen passt. Code scannen und ankreuzen, wann du kannst – dauert nur eine Minute!])
    #v(3.5mm)
    #text(weight: "bold", size: 10pt, survey-url-short)
  ])
}

#pagebreak()

// ==============================================================================
// Rückseite
// ==============================================================================

#let head-h = bleed + 30mm
#at(0pt, 0pt, rect(width: page-w, height: head-h, fill: rich-black))
#for (k, black) in (false, true, false, false, true).enumerate() {
  let r = 3.6mm
  let sx = page-w - edge - 4mm - k * 8.6mm
  let sy = bleed + 15mm
  at(sx - r, sy - r, circle(radius: r, fill: if black { cmyk(0%, 0%, 0%, 55%) } else { stone-white }))
}
#at(edge, bleed + 8mm, block[
  #set text(fill: white)
  #text(weight: "bold", size: 26pt, top-edge: "cap-height")[Was ist Go?]
  #v(3mm)
  #text(size: 11pt)[China: Wéiqí #h(0.6em)·#h(0.6em) Japan: Go #h(0.6em)·#h(0.6em) Korea: Baduk]
])

#let h2(title) = {
  v(6mm)
  text(weight: "bold", size: 14pt, fill: red-dark, title)
  v(1.5mm)
}
#let items(..xs) = {
  set par(hanging-indent: 3.5mm)
  for x in xs.pos() {
    par[#box(width: 3.5mm)[•]#x]
    v(1.8mm)
  }
}

#at(edge, head-h + 7mm, block(width: trim-w - 2 * safe)[
  #set text(size: 11pt)
  #set par(leading: 0.55em)
  Go ist eines der ältesten Brettspiele der Welt. Schwarz und Weiß setzen abwechselnd Steine und versuchen, auf dem Brett Gebiete abzustecken. Die Regeln lernt man in wenigen Minuten – und trotzdem entdeckt man ein Leben lang Neues. Go fördert *Konzentration*, *strategisches Denken*, *Kreativität* und *räumliches Vorstellungsvermögen*.

  #h2[So läuft die AG]
  #items(
    [*Im Mittelpunkt steht das Spielen* – miteinander, auf kleinen und großen Brettern.],
    [Neulinge lernen die Regeln direkt vor Ort. Ein Einstieg ist jederzeit möglich.],
    [Dazu gibt es Go-Rätsel, passend zur eigenen Spielstärke, und eine eigene Rätsel-Mappe.],
    [Bretter und Steine sind vorhanden – mitbringen muss niemand etwas.],
    [Später geplant: Ausflüge, z.~B. zum Messeturnier des Go-Vereins in Hannover.],
  )

  #h2[Für wen?]
  #items(
    [Schüler:innen *aller Klassen* – und genauso Eltern, Lehrer:innen und Mitarbeiter:innen.],
    [Wer schon Go spielt, ist herzlich eingeladen, mitzuspielen und zu helfen!],
  )

  #h2[Kosten]
  #items(
    [Die AG ist grundsätzlich *kostenlos*. Bei fester Anmeldung bitten wir um einen Startbeitrag von 10~€ in bar; für Rätsel-Kopien gelegentlich ein kleines Kopiergeld.],
  )

  #v(6mm)
  #block(
    width: 100%,
    fill: tint,
    radius: (right: 2mm),
    stroke: (left: 1.6mm + red),
    inset: (left: 5mm, right: 4mm, y: 4mm),
    text(size: 10.5pt)[*Wichtig für Eltern:* Die Go-AG ist mit der Schule abgestimmt, aber *kein Betreuungsangebot*. Ist der AG-Leiter krank oder verhindert, fällt die AG aus und die Kinder müssen anderweitig betreut werden. Kurzfristige Absagen kommen über den Mailverteiler – Anmeldung auf der Webseite.],
  )
])

// Fußbereich: QR + Kontakt
#{
  let qr-size = 24mm
  at(page-w - edge - qr-size - 2mm, page-h - edge - qr-size - 2mm, qr-box(qr-size, 2mm))
  place(bottom + left, dx: edge, dy: -edge, block(width: trim-w - 2 * safe - qr-size - 6mm)[
    #text(weight: "bold", size: 15pt, fill: red)[Neuer Termin – stimm mit ab!]
    #v(2.5mm)
    #set par(leading: 0.5em)
    #set text(size: 10.5pt)
    Umfrage: *#survey-url-short* \
    Alle Infos zur AG: *#website* \
    Leitung: Levin Keller
  ])
}
