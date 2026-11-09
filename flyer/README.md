# Flyer Go-AG

`go-ag-flyer-a4.pdf` – DIN A4, beidseitig 4/4-farbig, CMYK, druckfertig für Flyeralarm & Co.

- Datenformat 216 × 303 mm = Endformat 210 × 297 mm + 3 mm Beschnitt
- Seite 1 Vorderseite, Seite 2 Rückseite; alle Schriften eingebettet
- Texte ≥ 12 mm vom Endformatrand

Der QR-Code zeigt auf `https://go-ag.levinkeller.de/zeit`. Wohin das führt, steht in
`static/_redirects` – dort die Umfrage-URL eintragen, dann muss der Flyer nicht neu gedruckt werden.

Neu erzeugen (Schriften Carlito und IPAGothic müssen installiert sein,
Debian: `fonts-crosextra-carlito fonts-ipafont-gothic`):

```bash
typst compile flyer/flyer.typ flyer/go-ag-flyer-a4.pdf
```

Das Steiner-Zitat auf der Rückseite ist am Volltext des Rudolf Steiner Online Archivs
(anthroposophie.byu.edu) geprüft; die Quellen stehen im Kopf von `flyer.typ`.
