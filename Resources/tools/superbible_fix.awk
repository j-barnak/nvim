# superbible_fix.awk -- repair extraction-wrapped code listings in OpenGL SuperBible.
#
# The print edition sets code in a narrow fixed-width frame, so long C/C++/GLSL
# statements are hard-wrapped INSIDE the PDF's own text layer (the break is
# present even with `pdftotext` and no -layout, so it is not a column-width
# artefact we can widen away). Each wrap drops the tail of the statement onto a
# new physical line flush to the code block's left margin -- exactly three
# spaces of indent in this book's extraction -- e.g.
#
#     const GLfloat color[] = { (float)sin(currentTime) * 0.5f +
#   0.5f,
#
# should read `... * 0.5f + 0.5f,`. Author-intended breaks are ALIGNED deeper
# (under the opening paren / operand), never at the 3-space base margin, so they
# are left untouched.
#
# Rule: a line matching `^   \S` (exactly 3 leading spaces) is a wrapped
# continuation and is joined onto the pending line (with one space) when that
# pending line is syntactically incomplete, judged from its LAST token (after
# stripping any // comment):
#   * ends with a binary operator or an opener ( + - * / % | & ^ = < > ( [ )
#     -> always a continuation (valid code never ends a line this way); OR
#   * ends with a comma AND we are inside unclosed round/square brackets
#     (running bracket depth > 0) -> a wrapped argument list.
# A pending line ending in ; { } or a closed token is NEVER a join target, which
# also immunises the pass against two source typos in this book (a `max(...;` and
# a `lookat(...;` each missing a `)`, which otherwise leave the bracket depth
# stuck and would swallow the following complete statements). Brace depth is
# ignored on purpose: a `{...}` body spans many base-indent lines legitimately.
# Depth and the pending line reset at every blank line and every flush-left
# (prose) line, the natural boundaries of a listing; parens never span those
# here. Author-intended breaks are ALIGNED deeper than the 3-space base margin
# and so never match, and are preserved verbatim.
#
# Pure text post-filter: prose and already-correct code pass through byte for
# byte. Safe to run over every chapter (it is a no-op where nothing wraps),
# which is how it plugs into pdf_build.sh's per-slug book_fix stage.

function delta(s,   t, i, c, n) {          # net round/square bracket change, comments ignored
    t = s; sub(/\/\/.*$/, "", t); n = 0
    for (i = 1; i <= length(t); i++) {
        c = substr(t, i, 1)
        if (c == "(" || c == "[") n++
        else if (c == ")" || c == "]") n--
    }
    return n
}
function strip(s,   t) {                    # code text with any // comment and trailing space removed
    t = s; sub(/\/\/.*$/, "", t); sub(/[ \t]+$/, "", t)
    return t
}
function flush() { if (prev != "") { print prev; prev = "" } }

{
    line = $0
    if (line ~ /^[ \t]*$/) { flush(); print line; depth = 0; next }   # blank: boundary
    ind = 0
    while (substr(line, ind + 1, 1) == " ") ind++
    if (ind == 0) { flush(); print line; depth = 0; next }            # prose: boundary
    if (line ~ /^[ \t]*#/) { flush(); print line; prev = ""; next }   # #include / #version: complete directive
    d = delta(line)
    t = strip(prev); last = substr(t, length(t), 1); prv2 = substr(t, length(t) - 1, 1)
    # operator / opener; a trailing '-' counts only as a lone minus, not '--'
    # (a split "--flag" in a shell listing, or a post-decrement), which must not
    # be space-joined.
    op = (last != "" && index("+*/%|&^=<>([", last) > 0) || (last == "-" && prv2 != "-")
    cm = (last == ",")                                               # argument comma
    if (prev != "" && line ~ /^   [^ ]/ && (op || (cm && depth > 0))) {
        c = line; sub(/^[ \t]+/, "", c)
        prev = prev " " c
    } else {
        flush(); prev = line
    }
    depth += d
    if (depth < 0) depth = 0
    next
}
END { flush() }
