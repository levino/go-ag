# Go-AG Freie Waldorfschule Hannover Maschsee

Webseite der Go-AG der FWS Hannover Maschsee.

Diese Website wurde mit [Docusaurus](https://docusaurus.io/) erstellt, einem modernen Static-Site-Generator.

## Installation

```bash
npm install
```

## Lokale Entwicklung

```bash
npm start
```

Dieser Befehl startet einen lokalen Entwicklungsserver und öffnet ein Browserfenster. Die meisten Änderungen werden live übernommen, ohne den Server neu starten zu müssen.

Die Seite ist dann unter `http://localhost:3000` erreichbar.

## Build

```bash
npm run build
```

Dieser Befehl generiert statische Inhalte im `build`-Verzeichnis, die von jedem Static-Hosting-Service bereitgestellt werden können.

## Deployment

Die Seite wird auf **Cloudflare Pages** gehostet und automatisch bei jedem Push auf den Main-Branch deployed.

**Build-Einstellungen:**
- Build command: `npm run build`
- Build output directory: `build`
- Root directory: `/`

## Inhalte

- **Hauptseite** (`docs/intro.md`): Informationen zur Go-AG
- **Spielmaterial** (`docs/spielmaterial.md`): Empfehlungen für Go-Spielmaterial
- **Impressum** (`src/pages/impressum.md`): Rechtliche Informationen

## Lizenz

Siehe [LICENSE](LICENSE) Datei.
