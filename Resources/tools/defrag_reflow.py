#!/usr/bin/env python3
# De-fragment a Calibre-reflowed chapter: the epub wrapped every visual line of
# a paragraph in its own <p>, so pandoc emitted one blank-separated paragraph
# per line. Rejoin: a blank-separated block that is plain prose and does NOT end
# in sentence-terminating punctuation is a broken line, so merge it with the
# next block. Headings, lists, code fences, blank runs are preserved. Does not
# touch the (source-mangled) math glyphs - de-fragment only.
import re, sys

TERM = tuple('.!?:;)]"”’')  # sentence/clause enders + closers


def is_structural(line):
    s = line.lstrip()
    return (s.startswith('#') or s.startswith('```') or s.startswith('- ')
            or s.startswith('* ') or s.startswith('> ') or s.startswith('|')
            or re.match(r'^\d+\.\s', s) or re.match(r'^-{3,}$', s)
            or s.startswith('    '))  # indented code


def defrag(text):
    # split into blank-separated blocks, remembering nothing else
    blocks, cur = [], []
    for ln in text.split('\n'):
        if ln.strip() == '':
            if cur:
                blocks.append(cur)
                cur = []
        else:
            cur.append(ln)
    if cur:
        blocks.append(cur)

    # A numbered section heading ("9", "9.1", "9.1.1 Problem Definition") is
    # its own line in the book, so keep it standalone and never merge prose into
    # it. A block that is only a bare page number (folio) is furniture: drop it.
    heading_re = re.compile(r'^\d+(\.\d+)*\.?(\s+\S.*)?$')
    folio_re = re.compile(r'^\d{1,4}$')

    out = []          # list of finished paragraph strings
    pending = None    # a prose block awaiting possible continuation
    in_code = False
    for blk in blocks:
        joined = ' '.join(x.strip() for x in blk)
        structural = any(is_structural(x) for x in blk)
        fences = sum(1 for x in blk if x.lstrip().startswith('```'))
        if in_code or fences:
            if pending is not None:
                out.append(pending); pending = None
            out.append('\n'.join(blk))
            if fences % 2 == 1:
                in_code = not in_code
            continue
        if folio_re.match(joined):
            continue  # bare page number: drop
        if structural or (heading_re.match(joined) and len(joined) < 80):
            if pending is not None:
                out.append(pending); pending = None
            out.append('\n'.join(blk) if structural else joined)
            continue
        # prose block
        pending = joined if pending is None else (pending + ' ' + joined)
        if pending.rstrip().endswith(TERM):
            out.append(pending); pending = None
    if pending is not None:
        out.append(pending)
    return '\n\n'.join(out).rstrip() + '\n'


for path in sys.argv[1:]:
    src = open(path, encoding='utf-8').read()
    new = defrag(src)
    open(path, 'w', encoding='utf-8').write(new)
    print("%s: %d -> %d lines" % (path.split('/')[-1], src.count('\n'), new.count('\n')))
