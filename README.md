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

## Typst-PDFs & Schriften

`.typ`-Dateien (z. B. `flyer.typ`, `kifu*.typ`) werden beim Build über den
Typst-Loader (`plugins/docusaurus-typst/`) zu PDF gerendert.

Damit das Rendern auf jedem Build-Host **identisch und ohne fehlende Glyphen**
(„Tofu"-Kästchen) funktioniert, liegen alle benötigten Schriften im Ordner
`fonts/` und werden vom Loader per `--font-path` an Typst übergeben:

| Schrift | Verwendung | Dateien |
| --- | --- | --- |
| **Caveat** | Handschrift (Überschriften, Termin) | `Caveat-Regular/-Bold.ttf` |
| **Andada Pro** | Fließtext (erdiger Serif) | `AndadaPro-Regular/-Bold.ttf` |
| **Noto Color Emoji** (Subset) | farbige Emojis | `NotoColorEmoji-subset.ttf` |

Caveat und Andada Pro sind statische Instanzen der jeweiligen Variable-Fonts
(Typst unterstützt keine Variable-Fonts), erzeugt mit:

```bash
python3 -m fontTools.varLib.instancer Caveat[wght].ttf wght=700 -o fonts/Caveat-Bold.ttf
```

Der Emoji-Font ist ein Subset (nur die genutzten Emojis 📅 📍 👋 🆓 🙌 📱 🎉 ✨
🏆 🎈). Wird ein neues Emoji verwendet, das Subset erweitern:

```bash
pyftsubset /usr/share/fonts/truetype/noto/NotoColorEmoji.ttf \
  --unicodes=1F4C5,1F4CD,1F44B,1F193,1F64C,1F4F1,1F389,2728,1F3C6,1F388 \
  --output-file=fonts/NotoColorEmoji-subset.ttf
```

> Tipp: Mit `typst compile --ignore-system-fonts --font-path fonts flyer.typ`
> lässt sich ein „nackter" Build-Host simulieren — so fallen fehlende Glyphen
> sofort auf.

## Lizenz

Siehe [LICENSE](LICENSE) Datei.
