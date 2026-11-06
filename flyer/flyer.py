"""Werbeflyer Go-AG – DIN A5, beidseitig, 4/4-farbig (CMYK), 3 mm Beschnitt.

Erzeugt flyer/go-ag-flyer-a5.pdf (Seite 1 = Vorderseite, Seite 2 = Rückseite),
druckfertig für Onlinedruckereien wie Flyeralarm:
  Datenformat 154 × 216 mm (Endformat 148 × 210 mm + 3 mm Beschnitt rundum),
  Texte mindestens 5 mm vom Endformatrand entfernt.

Aufruf:  python3 flyer/flyer.py
Benötigt: reportlab, Schriften Carlito und IPAGothic (Debian: fonts-crosextra-carlito,
fonts-ipafont-gothic).
"""

from pathlib import Path

from reportlab.graphics import renderPDF
from reportlab.graphics.barcode.qr import QrCodeWidget
from reportlab.graphics.shapes import STATE_DEFAULTS, Drawing
from reportlab.lib.colors import CMYKColor
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph

# --- Inhalt, der sich ändern kann -------------------------------------------

# Kurz-URL auf der AG-Webseite; leitet per static/_redirects auf die Umfrage weiter.
# So bleibt der gedruckte QR-Code gültig, auch wenn sich die Umfrage-URL ändert.
SURVEY_URL = "https://go-ag.levinkeller.de/zeit"
SURVEY_URL_SHORT = "go-ag.levinkeller.de/zeit"
WEBSITE = "go-ag.levinkeller.de"

# --- Format -----------------------------------------------------------------

BLEED = 3 * mm
TRIM_W, TRIM_H = 148 * mm, 210 * mm
PAGE_W, PAGE_H = TRIM_W + 2 * BLEED, TRIM_H + 2 * BLEED
SAFE = 7 * mm  # Abstand Text ↔ Endformatrand (Flyeralarm verlangt ≥ 3 mm, besser 5 mm)

OUT = Path(__file__).with_name("go-ag-flyer-a5.pdf")

# --- Farben (CMYK) -----------------------------------------------------------

CREAM = CMYKColor(0, 0.03, 0.12, 0)
WOOD = CMYKColor(0, 0.22, 0.55, 0.04)
WOOD_EDGE = CMYKColor(0, 0.35, 0.7, 0.22)
LINE = CMYKColor(0, 0.4, 0.6, 0.7)
INK = CMYKColor(0, 0, 0, 1)  # Text: reines Schwarz
RICH_BLACK = CMYKColor(0.6, 0.4, 0.4, 1)  # Flächen/Steine: Tiefschwarz
STONE_WHITE = CMYKColor(0, 0.01, 0.04, 0)
RED = CMYKColor(0, 0.88, 0.82, 0.04)
RED_DARK = CMYKColor(0, 0.9, 0.85, 0.35)
WHITE = CMYKColor(0, 0, 0, 0)
GREY = CMYKColor(0, 0, 0, 0.65)
TINT = CMYKColor(0, 0.06, 0.2, 0)

# --- Schriften ---------------------------------------------------------------

FONT_DIR = Path("/usr/share/fonts/truetype/crosextra")
pdfmetrics.registerFont(TTFont("Carlito", FONT_DIR / "Carlito-Regular.ttf"))
pdfmetrics.registerFont(TTFont("Carlito-Bold", FONT_DIR / "Carlito-Bold.ttf"))
pdfmetrics.registerFont(TTFont("Carlito-Italic", FONT_DIR / "Carlito-Italic.ttf"))
pdfmetrics.registerFont(TTFont("Carlito-BoldItalic", FONT_DIR / "Carlito-BoldItalic.ttf"))
pdfmetrics.registerFontFamily(
    "Carlito",
    normal="Carlito",
    bold="Carlito-Bold",
    italic="Carlito-Italic",
    boldItalic="Carlito-BoldItalic",
)
pdfmetrics.registerFont(TTFont("IPAGothic", "/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf"))


# renderPDF setzt sonst Times-Roman (nicht eingebettet) – Druckereien mögen das nicht.
STATE_DEFAULTS["fontName"] = "Carlito"


def PS(name, **kw):
    """ParagraphStyle ohne Verweis auf nicht eingebettete Standardschriften."""
    kw.setdefault("bulletFontName", "Carlito")
    return ParagraphStyle(name, **kw)


# --- Helfer ------------------------------------------------------------------


def tx(x):
    """x im Endformat → x im Datenformat."""
    return BLEED + x


def ty(y):
    return BLEED + y


def set_boxes(c):
    c.setTrimBox((BLEED, BLEED, BLEED + TRIM_W, BLEED + TRIM_H))
    c.setBleedBox((0, 0, PAGE_W, PAGE_H))


def fill_page(c, color):
    c.setFillColor(color)
    c.rect(0, 0, PAGE_W, PAGE_H, stroke=0, fill=1)


def stone(c, x, y, r, black):
    if black:
        c.setFillColor(RICH_BLACK)
        c.circle(x, y, r, stroke=0, fill=1)
        # dezenter Glanzpunkt
        c.setFillColor(CMYKColor(0.5, 0.35, 0.3, 0.75))
        c.circle(x - r * 0.35, y + r * 0.35, r * 0.28, stroke=0, fill=1)
    else:
        c.setFillColor(CMYKColor(0, 0.05, 0.12, 0.25))
        c.circle(x + r * 0.08, y - r * 0.1, r, stroke=0, fill=1)  # Schatten
        c.setFillColor(STONE_WHITE)
        c.setStrokeColor(CMYKColor(0, 0.05, 0.1, 0.35))
        c.setLineWidth(0.25)
        c.circle(x, y, r, stroke=1, fill=1)


def para(c, text, style, x, y_top, width):
    """Absatz mit Oberkante y_top zeichnen, liefert Unterkante."""
    p = Paragraph(text, style)
    _, h = p.wrap(width, 1000 * mm)
    p.drawOn(c, x, y_top - h)
    return y_top - h


def qr(c, data, x, y, size):
    w = QrCodeWidget(data, barLevel="M", barBorder=0)
    x0, y0, x1, y1 = w.getBounds()
    d = Drawing(size, size, transform=[size / (x1 - x0), 0, 0, size / (y1 - y0), 0, 0])
    w.barFillColor = INK
    d.add(w)
    renderPDF.draw(d, c, x, y)


# --- Vorderseite -------------------------------------------------------------


def front(c):
    set_boxes(c)
    fill_page(c, CREAM)

    # Brett: linke untere Ecke eines 19×19-Bretts, läuft oben/rechts in den Beschnitt
    gap = 8.6 * mm
    gx0, gy0 = tx(14 * mm), ty(108 * mm)  # Ecke des Gitters (Punkt A1)
    margin = 5.5 * mm
    bx, by = gx0 - margin, gy0 - margin
    c.setFillColor(WOOD_EDGE)
    c.roundRect(bx + 0.8 * mm, by - 1.6 * mm, PAGE_W, PAGE_H, 3 * mm, stroke=0, fill=1)
    c.setFillColor(WOOD)
    c.roundRect(bx, by, PAGE_W, PAGE_H, 3 * mm, stroke=0, fill=1)

    # Maserung
    c.setStrokeColor(CMYKColor(0, 0.28, 0.6, 0.09))
    c.setLineWidth(0.6)
    for i in range(14):
        yy = by + 4 * mm + i * 7.7 * mm
        p = c.beginPath()
        p.moveTo(bx, yy)
        p.curveTo(bx + 40 * mm, yy + 2.5 * mm, bx + 90 * mm, yy - 2.5 * mm, PAGE_W, yy + 1.2 * mm)
        c.drawPath(p, stroke=1, fill=0)

    cols = int((PAGE_W - gx0) / gap) + 1
    rows = int((PAGE_H - gy0) / gap) + 1
    c.setStrokeColor(LINE)
    for i in range(cols):
        c.setLineWidth(0.9 if i == 0 else 0.4)
        c.line(gx0 + i * gap, gy0, gx0 + i * gap, PAGE_H)
    for j in range(rows):
        c.setLineWidth(0.9 if j == 0 else 0.4)
        c.line(gx0, gy0 + j * gap, PAGE_W, gy0 + j * gap)
    c.setFillColor(LINE)
    for i, j in [(3, 3), (9, 3), (3, 9), (9, 9), (15, 3), (3, 15), (15, 9), (9, 15)]:
        c.circle(gx0 + i * gap, gy0 + j * gap, 0.9 * mm, stroke=0, fill=1)

    # Steine (eine Ecken-Stellung mit Kampf)
    blacks = [(3, 3), (2, 5), (4, 4), (5, 2), (3, 6), (8, 2), (6, 6), (2, 9), (10, 4), (5, 9), (12, 7)]
    whites = [(2, 2), (2, 3), (3, 2), (4, 1), (1, 4), (2, 4), (6, 3), (5, 5), (7, 5), (4, 7), (11, 9), (8, 8)]
    r = gap * 0.48
    for (i, j) in whites:
        stone(c, gx0 + i * gap, gy0 + j * gap, r, black=False)
    for (i, j) in blacks:
        stone(c, gx0 + i * gap, gy0 + j * gap, r, black=True)

    # Titel
    c.setFillColor(INK)
    c.setFont("Carlito-Bold", 78)
    c.drawString(tx(SAFE - 1.5 * mm), ty(76 * mm), "Go-AG")
    c.setFont("IPAGothic", 34)
    c.setFillColor(RED)
    c.drawRightString(tx(TRIM_W - SAFE), ty(78 * mm), "碁")

    sub = PS(
        "sub", fontName="Carlito", fontSize=14.5, leading=17.5, textColor=INK
    )
    para(
        c,
        "Das über 2500 Jahre alte Strategiespiel aus Ostasien – "
        "<b>bei uns an der Schule!</b>",
        sub,
        tx(SAFE),
        ty(72 * mm),
        TRIM_W - 2 * SAFE,
    )

    # Chips
    chips = ["kostenlos", "alle Klassen", "Bretter & Steine da", "Einstieg jederzeit"]
    c.setFont("Carlito-Bold", 10.5)
    x = tx(SAFE)
    y = ty(50 * mm)
    for chip in chips:
        w = c.stringWidth(chip, "Carlito-Bold", 10.5) + 6 * mm
        c.setFillColor(INK)
        c.roundRect(x, y, w, 6.6 * mm, 3.3 * mm, stroke=0, fill=1)
        c.setFillColor(WHITE)
        c.drawString(x + 3 * mm, y + 2.1 * mm, chip)
        x += w + 2 * mm

    # Umfrage-Band
    band_top = ty(44 * mm)
    c.setFillColor(RED)
    c.rect(0, 0, PAGE_W, band_top, stroke=0, fill=1)

    qr_size = 32 * mm
    qx = tx(TRIM_W - SAFE - qr_size)
    qy = ty(6.5 * mm)
    c.setFillColor(WHITE)
    c.roundRect(qx - 2.5 * mm, qy - 2.5 * mm, qr_size + 5 * mm, qr_size + 5 * mm, 2 * mm, stroke=0, fill=1)
    qr(c, SURVEY_URL, qx, qy, qr_size)

    text_w = TRIM_W - 2 * SAFE - qr_size - 7 * mm
    h1 = PS("h1", fontName="Carlito-Bold", fontSize=21, leading=22, textColor=WHITE)
    body = PS("b", fontName="Carlito", fontSize=11, leading=13.5, textColor=WHITE)
    small = PS("s", fontName="Carlito-Bold", fontSize=10, leading=12, textColor=WHITE)
    y = para(c, "Wann hast du Zeit?", h1, tx(SAFE), band_top - 6 * mm, text_w)
    y = para(
        c,
        "Wir suchen einen AG-Termin, der möglichst vielen passt. "
        "Code scannen und ankreuzen, wann du kannst – dauert nur eine Minute!",
        body,
        tx(SAFE),
        y - 2 * mm,
        text_w,
    )
    para(c, SURVEY_URL_SHORT, small, tx(SAFE), y - 2.5 * mm, text_w)

    c.showPage()


# --- Rückseite ---------------------------------------------------------------


def back(c):
    set_boxes(c)
    fill_page(c, CREAM)

    # Kopfband
    head_h = 30 * mm
    c.setFillColor(RICH_BLACK)
    c.rect(0, PAGE_H - BLEED - head_h, PAGE_W, head_h + BLEED, stroke=0, fill=1)
    # kleine Steinreihe als Schmuck
    for k, black in enumerate([False, True, False, False, True]):
        sx = tx(TRIM_W - SAFE - 4 * mm - k * 8.6 * mm)
        sy = ty(TRIM_H - 15 * mm)
        if black:
            c.setFillColor(CMYKColor(0, 0, 0, 0.55))
            c.circle(sx, sy, 3.6 * mm, stroke=0, fill=1)
        else:
            c.setFillColor(STONE_WHITE)
            c.circle(sx, sy, 3.6 * mm, stroke=0, fill=1)
    c.setFillColor(WHITE)
    c.setFont("Carlito-Bold", 26)
    c.drawString(tx(SAFE), ty(TRIM_H - 14.5 * mm), "Was ist Go?")
    c.setFont("Carlito", 11)
    c.drawString(tx(SAFE), ty(TRIM_H - 21.5 * mm), "China: Wéiqí  ·  Japan: Go  ·  Korea: Baduk")

    w = TRIM_W - 2 * SAFE
    x = tx(SAFE)
    h2 = PS("h2", fontName="Carlito-Bold", fontSize=13.5, leading=16, textColor=RED_DARK)
    body = PS("b", fontName="Carlito", fontSize=10.5, leading=13.2, textColor=INK)
    bullet = PS(
        "li", parent=body, leftIndent=3.5 * mm, bulletIndent=0, bulletFontName="Carlito-Bold"
    )

    y = ty(TRIM_H - head_h - 6 * mm)
    y = para(
        c,
        "Go ist eines der ältesten Brettspiele der Welt. Schwarz und Weiß setzen abwechselnd "
        "Steine und versuchen, auf dem Brett Gebiete abzustecken. Die Regeln lernt man in "
        "wenigen Minuten – und trotzdem entdeckt man ein Leben lang Neues. "
        "Go fördert <b>Konzentration</b>, <b>strategisches Denken</b>, <b>Kreativität</b> "
        "und <b>räumliches Vorstellungsvermögen</b>.",
        body,
        x,
        y,
        w,
    )

    def section(y, title, items):
        y = para(c, title, h2, x, y - 4.5 * mm, w)
        for it in items:
            y = para(c, f"<bullet>•</bullet>{it}", bullet, x, y - 0.8 * mm, w)
        return y

    y = section(
        y,
        "So läuft die AG",
        [
            "<b>Im Mittelpunkt steht das Spielen</b> – miteinander, auf kleinen und großen Brettern.",
            "Neulinge lernen die Regeln direkt vor Ort. Ein Einstieg ist jederzeit möglich.",
            "Dazu gibt es Go-Rätsel, passend zur eigenen Spielstärke, und eine eigene Rätsel-Mappe.",
            "Bretter und Steine sind vorhanden – mitbringen muss niemand etwas.",
            "Später geplant: Ausflüge, z.&nbsp;B. zum Messeturnier des Go-Vereins in Hannover.",
        ],
    )
    y = section(
        y,
        "Für wen?",
        [
            "Schüler:innen <b>aller Klassen</b> – und genauso Eltern, Lehrer:innen und Mitarbeiter:innen.",
            "Wer schon Go spielt, ist herzlich eingeladen, mitzuspielen und zu helfen!",
        ],
    )
    y = section(
        y,
        "Kosten",
        [
            "Die AG ist grundsätzlich <b>kostenlos</b>. Bei fester Anmeldung bitten wir um einen "
            "Startbeitrag von 10&nbsp;€ in bar; für Rätsel-Kopien gelegentlich ein kleines Kopiergeld.",
        ],
    )

    # Hinweisbox für Eltern
    box_style = PS("box", parent=body, fontSize=9.8, leading=12.4)
    inner_w = w - 8 * mm
    p = Paragraph(
        "<b>Wichtig für Eltern:</b> Die Go-AG ist mit der Schule abgestimmt, aber "
        "<b>kein Betreuungsangebot</b>. Ist der AG-Leiter krank oder verhindert, fällt die AG aus "
        "und die Kinder müssen anderweitig betreut werden. Kurzfristige Absagen kommen über "
        "den Mailverteiler – Anmeldung auf der Webseite.",
        box_style,
    )
    _, ph = p.wrap(inner_w, 200 * mm)
    box_top = y - 5 * mm
    box_h = ph + 7 * mm
    c.setFillColor(TINT)
    c.roundRect(x, box_top - box_h, w, box_h, 2 * mm, stroke=0, fill=1)
    c.setFillColor(RED)
    c.rect(x, box_top - box_h, 1.6 * mm, box_h, stroke=0, fill=1)
    p.drawOn(c, x + 5 * mm, box_top - 3.5 * mm - ph)

    # Fußbereich: QR + Kontakt
    qr_size = 24 * mm
    qx = tx(TRIM_W - SAFE - qr_size)
    qy = ty(SAFE)
    c.setFillColor(WHITE)
    c.roundRect(qx - 2 * mm, qy - 2 * mm, qr_size + 4 * mm, qr_size + 4 * mm, 1.5 * mm, stroke=0, fill=1)
    qr(c, SURVEY_URL, qx, qy, qr_size)

    fw = TRIM_W - 2 * SAFE - qr_size - 6 * mm
    foot_h = PS("fh", fontName="Carlito-Bold", fontSize=15, leading=17, textColor=RED)
    foot = PS("f", fontName="Carlito", fontSize=10, leading=12.6, textColor=INK)
    fy = ty(SAFE + qr_size + 2 * mm)
    fy = para(c, "Neuer Termin – stimm mit ab!", foot_h, x, fy, fw)
    para(
        c,
        f"Umfrage: <b>{SURVEY_URL_SHORT}</b><br/>"
        f"Alle Infos zur AG: <b>{WEBSITE}</b><br/>"
        "Leitung: Levin Keller",
        foot,
        x,
        fy - 1.5 * mm,
        fw,
    )

    c.showPage()


def main():
    c = canvas.Canvas(str(OUT), pagesize=(PAGE_W, PAGE_H), initialFontName="Carlito")
    c.setTitle("Go-AG – Flyer A5")
    c.setAuthor("Go-AG FWS Hannover Maschsee")
    front(c)
    back(c)
    c.save()
    print(f"geschrieben: {OUT}")


if __name__ == "__main__":
    main()
