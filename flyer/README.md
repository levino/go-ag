# Flyer Go-AG

`go-ag-flyer-a5.pdf` – DIN A5, beidseitig 4/4-farbig, CMYK, druckfertig für Flyeralarm & Co.

- Datenformat 154 × 216 mm = Endformat 148 × 210 mm + 3 mm Beschnitt
- Seite 1 Vorderseite, Seite 2 Rückseite; alle Schriften eingebettet
- Texte ≥ 7 mm vom Endformatrand

Der QR-Code zeigt auf `https://go-ag.levinkeller.de/zeit`. Wohin das führt, steht in
`static/_redirects` – dort die Umfrage-URL eintragen, dann muss der Flyer nicht neu gedruckt werden.

Neu erzeugen (Schriften Carlito und IPAGothic müssen installiert sein,
Debian: `fonts-crosextra-carlito fonts-ipafont-gothic`):

```bash
typst compile flyer/flyer.typ flyer/go-ag-flyer-a5.pdf
```
