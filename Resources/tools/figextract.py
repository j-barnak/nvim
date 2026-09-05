import sys, os, re, subprocess
import xml.etree.ElementTree as ET

PDF, OUTDIR = sys.argv[1], sys.argv[2]
DPI = 300  # crisp enough to zoom; figures are cached under stdpath("data")
SCALE = DPI / 72.0
os.makedirs(OUTDIR, exist_ok=True)

# pdftotext emits UTF-8 XML regardless of locale, so decode it explicitly:
# text=True would use the locale encoding and fail under LC_ALL=C.
raw = subprocess.run(["pdftotext", "-bbox-layout", PDF, "-"],
                     capture_output=True, check=True,
                     encoding="utf-8", errors="replace").stdout
raw = re.sub(r'<!DOCTYPE[^>]*>', '', raw)
raw = re.sub(r'\sxmlns="[^"]*"', '', raw, count=1)
# Some PDFs carry glyphs that pdftotext emits as raw C0 control characters,
# which XML 1.0 forbids (only tab, newline and carriage return are legal), so
# the parse would fail on the whole document for a handful of bytes.
raw = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f]', '', raw)
root = ET.fromstring(raw)

FIG_RE = re.compile(r'^Figure\s+([0-9A-Z]+-[0-9A-Z]+)\.', re.I)

def block_text(b):
    return " ".join((w.text or "") for w in b.iter("word")).strip()

def fget(el, attr):
    return float(el.get(attr))

count = 0
pagenum = 0
for page in root.iter("page"):
    pagenum += 1
    pw, ph = fget(page, "width"), fget(page, "height")
    blocks = list(page.iter("block"))
    if not blocks:
        continue
    blocks.sort(key=lambda b: fget(b, "yMin"))
    cl, cr = 45.0, pw - 45.0
    cw = cr - cl
    HEADER_Y, FOOTER_Y = 55.0, ph - 45.0

    def is_body(b):
        w = fget(b, "xMax") - fget(b, "xMin")
        return w >= 0.55 * cw and fget(b, "xMin") <= cl + 0.12 * cw

    CAP_RE = re.compile(r'^(Figure|Table)\s+[0-9A-Z]+-', re.I)

    for b in blocks:
        m = FIG_RE.match(block_text(b))
        if not m:
            continue
        fid = m.group(1)
        final = os.path.join(OUTDIR, "Figure " + fid + ".png")
        if os.path.exists(final):
            continue  # keep the first occurrence (main figure, not a "(Contd.)")
        cap_ymin, cap_ymax = fget(b, "yMin"), fget(b, "yMax")
        # Top boundary: the nearest body paragraph OR another figure/table
        # caption above (so stacked figures on one page don't merge).
        top = HEADER_Y
        for pb in blocks:
            if pb is b:
                continue
            pby = fget(pb, "yMax")
            if pby <= cap_ymin - 2 and pby > top and (is_body(pb) or CAP_RE.match(block_text(pb))):
                top = pby
        top += 3
        bottom = min(cap_ymax + 4, FOOTER_Y)
        if bottom - top < 30:
            continue
        xs0, xs1 = [], []
        for ib in blocks:
            if fget(ib, "yMin") >= top - 2 and fget(ib, "yMax") <= bottom + 2:
                xs0.append(fget(ib, "xMin")); xs1.append(fget(ib, "xMax"))
        left = max(cl, min(xs0) - 8) if xs0 else cl
        right = min(cr, max(xs1) + 8) if xs1 else cr
        x, y = int(left * SCALE), int(top * SCALE)
        w, h = int((right - left) * SCALE), int((bottom - top) * SCALE)
        if w <= 0 or h <= 0:
            continue
        out = os.path.join(OUTDIR, "Figure " + fid)
        subprocess.run(["pdftoppm", "-png", "-r", str(DPI), "-f", str(pagenum), "-l", str(pagenum),
                        "-x", str(x), "-y", str(y), "-W", str(w), "-H", str(h), PDF, out],
                       capture_output=True)
        produced = next((os.path.join(OUTDIR, f) for f in os.listdir(OUTDIR)
                         if f.startswith("Figure " + fid + "-") and f.endswith(".png")), None)
        if produced:
            final = os.path.join(OUTDIR, "Figure " + fid + ".png")
            if produced != final:
                os.replace(produced, final)
            subprocess.run(["convert", final, "-trim", "+repage",
                            "-bordercolor", "white", "-border", "14", final], capture_output=True)
            count += 1
print("figures:", count)
