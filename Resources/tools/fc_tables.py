#!/usr/bin/env python3
# Normalise felixcloutier.com/x86 instruction pages BEFORE webextract/pandoc so
# their tables render as readable markdown. The pages embed Intel-manual tables
# that use rowspan/colspan; pandoc leaves the spanned cells EMPTY (collapsed
# columns) and full-width sub-header rows become a cell + a blank column. This
# rewrites every <table> into a rectangular grid with NO empty cells:
#   - drop <header>/<nav>/<footer> (page chrome, no wrapper div on these pages)
#   - expand rowspan/colspan by copying each source cell's INNER HTML into every
#     grid position it spans (inline links/code survive for pandoc)
#   - lift a full-width row (one cell spanning the whole table, i.e. Intel's
#     "Basic CPUID Information" sub-headers) OUT of the table as a bold heading,
#     splitting the table into clean segments instead of a row with a blank column
# Runs first in the pipeline; compact_tables.py narrows the widths afterwards.
import sys
from bs4 import BeautifulSoup


def cell_html(cell):
    return cell.decode_contents().strip()


def normalise(table):
    rows = table.find_all("tr")
    if not rows:
        return None
    grid, occ, ncols = {}, {}, 0
    for r, tr in enumerate(rows):
        c = 0
        for cell in tr.find_all(["td", "th"], recursive=False) or tr.find_all(["td", "th"]):
            while occ.get((r, c)):
                c += 1
            rs = int(cell.get("rowspan", 1) or 1)
            cs = int(cell.get("colspan", 1) or 1)
            html = cell_html(cell)
            for dr in range(rs):
                for dc in range(cs):
                    grid[(r + dr, c + dc)] = html
                    occ[(r + dr, c + dc)] = True
            c += cs
            ncols = max(ncols, c)
    nrows = len(rows)
    if ncols <= 1:
        return None  # single-column table: leave it for pandoc/flatten_tables

    def rowcells(r):
        return [grid.get((r, c), "") for c in range(ncols)]

    def nonempty(cells):
        return [i for i, c in enumerate(cells) if c.strip()]

    # A source row that is one cell spanning the full width is a sub-header
    # ("Basic CPUID Information"); grid-fill would otherwise duplicate its text
    # across every column, so capture its text from the source before that.
    srcfull = {}
    for r, tr in enumerate(rows):
        cells = tr.find_all(["td", "th"])
        if len(cells) == 1 and int(cells[0].get("colspan", 1) or 1) >= ncols:
            srcfull[r] = cell_html(cells[0])

    # Classify each row:
    #   empty - drop (a gap left by a span, or a blank source row)
    #   head  - a full-width sub-header, OR a row where only the first column has
    #           content (a malformed header with blank trailing columns) -> lift
    #           OUT as a bold line, never a table row trailed by empty columns
    #   data  - keep
    kind, headtext = {}, {}
    for r in range(nrows):
        ne = nonempty(rowcells(r))
        if r in srcfull:
            kind[r] = "head"; headtext[r] = srcfull[r]
        elif not ne:
            kind[r] = "empty"
        elif ne == [0] and ncols > 1:
            kind[r] = "head"; headtext[r] = rowcells(r)[0]
        else:
            kind[r] = "data"

    # emit table segments broken by lifted sub-headers. A segment with no <th>
    # header of its own would make pandoc write an empty header row, so the
    # segment's first data row is promoted to <th>.
    parts, seg, seg_has_header = [], [], [False]

    def flush():
        if seg:
            parts.append("<table>" + "".join(seg) + "</table>")
            seg.clear()
        seg_has_header[0] = False

    for r in range(nrows):
        k = kind[r]
        if k == "empty":
            continue
        if k == "head":
            flush()
            parts.append("<p><strong>" + headtext[r] + "</strong></p>")
            continue
        src = rows[r].find_all(["td", "th"])
        is_th = bool(src) and all(c.name == "th" for c in src)
        if not seg and not is_th and not seg_has_header[0]:
            is_th = True  # promote the first data row of a headerless segment
        if is_th:
            seg_has_header[0] = True
        tag = "th" if is_th else "td"
        seg.append("<tr>" + "".join("<%s>%s</%s>" % (tag, c, tag) for c in rowcells(r)) + "</tr>")
    flush()
    return BeautifulSoup("".join(parts), "lxml")


def run(html):
    soup = BeautifulSoup(html, "lxml")
    for t in soup.find_all(["header", "nav", "footer"]):
        t.decompose()
    for table in list(soup.find_all("table")):
        frag = normalise(table)
        if frag is not None:
            table.replace_with(frag)
    return str(soup)


if __name__ == "__main__":
    sys.stdout.write(run(sys.stdin.read()))
