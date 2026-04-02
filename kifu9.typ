// Partieprotokoll 9×9 – Go/Baduk/Weiqi

#import "@preview/cetz:0.3.4"
#import "@preview/showybox:2.0.4": showybox

#let lw          = 0.2mm
#let board       = 9
#let col-labels  = ("A","B","C","D","E","F","G","H","J")
#let text-col    = luma(20%)
#let board-col   = green.mix((white, 45%))
#let gap         = 4mm

#let underline_box = box(
  width: 1fr,
  line(length: 100%, stroke: (dash: "dotted", paint: text-col))
)

#let hoshi = (
  (3,3),(3,7),(5,5),(7,3),(7,7),
).map(v => (v.at(0)-1, v.at(1)-1))

#let titlebox(title, body) = showybox(
  frame: (
    border-color: text-col,
    inset: .75em,
    title-color: white,
    thickness: lw,
  ),
  title-style: (
    color: text-col,
    align: center,
    boxed-style: (anchor: (y: horizon, x: center))
  ),
  body-style: (align: center),
  align: center,
  spacing: .75em,
  width: 100%,
  title: title,
  body
)

#set text(fill: text-col, font: "Liberation Sans", size: 10pt)
#set line(stroke: text-col)
#set page("a4", margin: (x: 12mm, top: 10mm, bottom: 10mm), footer: none)

#grid(
  rows: (auto, gap, 1fr, gap, auto, gap, auto),

  // 1: Metadaten
  titlebox(
    [#text(size: 13pt, weight: "bold")[Partieprotokoll — 9×9]],
    grid(
      columns: (1fr, 1fr, 1fr),
      inset: .4em,
      [#emoji.pin Veranstaltung #h(1em) #underline_box],
      [#emoji.calendar Datum    #h(1em) #underline_box],
      [#emoji.clock Runde       #h(1em) #underline_box],
      [#emoji.circle.black Schwarz #h(1em) #underline_box],
      [#emoji.circle.white Weiß   #h(1em) #underline_box],
      [#emoji.plaster Vorgabe     #h(1em) #underline_box],
      [#emoji.hourglass Zeit      #h(1em) #underline_box],
      [#emoji.chart Komi          #h(1em) #underline_box],
      [#emoji.flag.red Ergebnis   #h(1em) #underline_box],
    )
  ),

  // 2: gap
  none,

  // 3: Goban – füllt den verbleibenden Platz
  layout(size => {
    let sp-h = size.height / 10.2
    let sp-w = size.width  / 10.0
    let sp   = calc.min(sp-h, sp-w)

    align(center,
      cetz.canvas(debug: false, length: sp, {
        import cetz.draw: *
        let stroke-n = (paint: board-col.mix((white, 60%)), thickness: lw)
        let font-s   = 1.15

        for i in range(board) {
          line((0, i), (board - 1, i), stroke: stroke-n)
          line((i, 0), (i, board - 1), stroke: stroke-n)
        }

        for h in hoshi {
          circle(h, radius: 0.06, fill: board-col.mix((white, 40%)), stroke: none)
        }

        for row in range(board) {
          for col in range(board) {
            circle((col, row), radius: 0.47,
              fill: none,
              stroke: (paint: board-col.mix((white, 20%)), thickness: 0.35mm)
            )
          }
        }

        for col in range(board) {
          let lbl = col-labels.at(col)
          content((col,  board - 0.3), text(size: font-s * 1em, fill: text-col)[#lbl], anchor: "center")
          content((col, -0.7),         text(size: font-s * 1em, fill: text-col)[#lbl], anchor: "center")
        }

        for row in range(board) {
          let num = str(row + 1)
          content((-0.75,        row), text(size: font-s * 1em, fill: text-col)[#num], anchor: "center")
          content((board - 0.25, row), text(size: font-s * 1em, fill: text-col)[#num], anchor: "center")
        }
      })
    )
  }),

  // 4: gap
  none,

  // 5: Züge
  titlebox(
    [_Aktueller Zug_ #sym.numero #sym.mapsto _Vorheriger Zug_ #sym.numero],
    {
      let entry = grid(
        columns: (2em, auto, 3em),
        gutter: .3em,
        align: horizon,
        underline_box, sym.mapsto, underline_box
      )
      stack(spacing: 0em,
        v(0.6em),
        grid(
          columns: (1fr,) * 6,
          row-gutter: 1.5em,
          column-gutter: .6em,
          ..range(18).map(_ => entry)
        )
      )
    }
  ),

  // 6: gap
  none,

  // 7: Notizen
  titlebox(
    [Notizen],
    stack(spacing: 1.5em,
      v(0.6em),
      ..range(5).map(_ => line(length: 100%, stroke: (dash: "dotted", paint: text-col)))
    )
  ),
)
