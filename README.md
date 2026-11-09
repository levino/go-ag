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

Erzeugt den Worker in `dist/` (statische Seiten in `dist/client`, Worker in `dist/server`).
Vorher installiert `npm run build` das [Typst](https://typst.app/)-Binary, mit dem die
Partieprotokolle (`kifu*.typ`) als PDF gebaut werden.

`npm run check` erzeugt die Binding-Typen (`wrangler types`) und prüft alles mit `astro check`.

Lokal im Worker-Runtime testen (mit lokaler D1-Datenbank):

```bash
npm run build && npm run preview
```

## Inhalte

- `src/pages/index.astro` – Startseite
- `infos/` – Informationsseiten (Über die AG, Spielmaterial, Online-Go, Partieprotokoll)
- `src/pages/zeit.astro` – Terminumfrage (Ziel des QR-Codes auf dem Flyer)
- `src/pages/api/zeit.ts` – Umfrage-API, speichert in Cloudflare D1
- `src/pages/impressum.md` – Impressum und Datenschutz
- `src/pages/kifu/[file].ts` – baut die Partieprotokoll-PDFs aus `kifu*.typ`
- `flyer/` – Werbeflyer (Typst), siehe `flyer/README.md`

## Deployment (Cloudflare Workers)

Die Seite läuft als Cloudflare Worker `go-ag` (Konfiguration in `wrangler.jsonc`). Alle Seiten
werden beim Build vorgerendert, nur `/api/zeit` läuft zur Laufzeit.

### Einmalig einrichten

1. **Datenbank in der EU anlegen** – *vor* dem ersten Deploy:

   ```bash
   npx wrangler d1 create go-ag --jurisdiction=eu
   ```

   Oder im Dashboard: *D1* → *Create Database*, Name `go-ag`, *Data location* →
   *Specify jurisdiction* → *European Union*. Der Rechtsraum lässt sich später nicht ändern.

   `wrangler.jsonc` nennt die Datenbank nur beim Namen; Wrangler bindet sie beim Deploy
   automatisch. Gibt es sie noch nicht, legt Wrangler sie selbst an – dann aber ohne
   EU-Vorgabe. Deshalb diesen Schritt zuerst.

2. **Worker mit GitHub verbinden:** *Workers & Pages* → *Create* → *Import a repository* →
   `levino/go-ag`. Build command `npm run build`, Deploy command `npx wrangler deploy`.

3. **Domain umziehen:** `go-ag.levinkeller.de` im alten Pages-Projekt entfernen und beim Worker
   unter *Settings* → *Domains & Routes* als Custom Domain eintragen. Danach das Pages-Projekt
   löschen.

Die Tabelle `stimmen` legt die API beim ersten Aufruf selbst an.

### Auswerten

Im D1-Dashboard (*Console*) oder per Wrangler:

```bash
npx wrangler d1 execute go-ag --remote --command "SELECT COUNT(*) AS stimmen, SUM(montag) AS montag, SUM(dienstag) AS dienstag FROM stimmen"
```

Sobald der Termin feststeht, die Stimmen löschen (so steht es im Impressum):

```bash
npx wrangler d1 execute go-ag --remote --command "DELETE FROM stimmen"
```

## Lizenz

Siehe [LICENSE](LICENSE).
