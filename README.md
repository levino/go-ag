# Go-AG Freie Waldorfschule Hannover Maschsee

Webseite der Go-AG der FWS Hannover Maschsee: <https://go-ag.levinkeller.de>

Gebaut mit [Astro](https://astro.build/) und [shipyard](https://shipyard.levinkeller.de/).

## Entwicklung

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
```

Erzeugt die statische Seite in `build/`. Vorher installiert `npm run build` das
[Typst](https://typst.app/)-Binary, mit dem die Partieprotokolle (`kifu*.typ`) als PDF gebaut werden.

`npm run check` prüft die Typen von Seite und Pages Functions.

## Inhalte

- `infos/` – Informationsseiten (Über die AG, Spielmaterial, Online-Go, Partieprotokoll)
- `src/pages/zeit.astro` – Terminumfrage (Ziel des QR-Codes auf dem Flyer)
- `src/pages/impressum.md` – Impressum und Datenschutz
- `src/pages/kifu/[file].ts` – baut die Partieprotokoll-PDFs aus `kifu*.typ`
- `flyer/` – Werbeflyer (Typst), siehe `flyer/README.md`

## Deployment

Die Seite läuft auf **Cloudflare Pages** und wird bei jedem Push auf `main` gebaut.

- Build command: `npm run build`
- Build output directory: `build`

### Terminumfrage (Cloudflare D1)

Die Umfrage speichert ihre Stimmen über die Pages Function `functions/api/zeit.ts` in einer
D1-Datenbank. Einmalig einrichten:

1. Cloudflare-Dashboard → *Storage & Databases* → *D1* → Datenbank anlegen (z. B. `go-ag`).
2. Pages-Projekt `go-ag` → *Settings* → *Bindings* → *Add* → *D1 database*:
   Variablenname `DB`, Datenbank `go-ag`. Für *Production* und *Preview* setzen.
3. Neu deployen. Die Tabelle `stimmen` legt die Funktion beim ersten Aufruf selbst an.

Ohne Binding zeigt die Umfrageseite „Die Umfrage ist noch nicht eingerichtet“.

Auswerten im D1-Dashboard (*Console*):

```sql
SELECT COUNT(*) AS stimmen, SUM(montag) AS montag, SUM(dienstag) AS dienstag FROM stimmen;
```

Lokal testen (mit lokaler D1-Datenbank):

```bash
npm run build && npm run preview
```

## Lizenz

Siehe [LICENSE](LICENSE).
