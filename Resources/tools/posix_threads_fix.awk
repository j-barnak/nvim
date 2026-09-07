# posix_threads_fix.awk - per-slug code-listing repair for
# "Programming with POSIX Threads" (slug programming-with-posix-threads).
#
# That book's PDF is a Ghostscript print of a Word .doc whose text layer is a
# poor OCR: hundreds of prose glyphs are mangled and it is peppered with raw
# 0x7f (DEL) bytes. `pdftotext -layout` reproduces the SAME wrong glyphs (the
# damage is baked into the text stream, not a layout artefact), so re-extraction
# cannot recover them and the bulk of that OCR noise is source-limited and left
# as-is. This filter touches ONLY a short, closed set of C code listings where
# the intended token is a standard pthreads API name or operator and therefore
# 100% mechanical and unambiguous - never prose. Each rule keys on text unique
# to its one line in the book, so the filter is a no-op on every other line and
# on every other book (pdf_build.sh runs it only for this slug).
#
# Fixes (chapter file : what and why):
#   005 3. Synchronization
#     PTHREAD_MUNEX_INITIALIZER -> PTHREAD_MUTEX_INITIALIZER  (OCR N for T)
#     pthread_mitex_t           -> pthread_mutex_t            (OCR i for u)
#     ...trylock (... *mutex)s  -> ...*mutex);                (OCR s for ;)
#   011 9. POSIX threads mini-reference
#     getstacksize ( - -        -> getstacksize (             (stray "- -" tail)
#     pthread cond t *cond,     -> pthread_cond_t *cond,      (lost underscores)
#     p<DEL> hreaLcondattr_t    -> pthread_condattr_t         (garbled type name)
#     pthread_create prototype  -> re-pair types with args    (see below)
#
# The pthread_create signature was emitted as all four parameter TYPES stacked,
# then all four parameter NAMES stacked (the two columns of the printed table
# collapsed to one x-position and were read top-to-bottom), scrambling the
# type/name pairing. The block is rewritten so each type sits with its name,
# restoring reading order without adding or dropping a token.

BEGIN { n = 0 }

# --- pthread_create: buffer the 9-line block and re-pair types with names ---
# Trigger only on the exact opening line, then require the exact 8 following
# lines; if anything differs, flush the buffer unchanged (fail safe).
$0 == "int pthread_create (" && n == 0 { buf[n++] = $0; next }
n > 0 {
    buf[n++] = $0
    if (n < 9) next
    if (buf[1] == "pthread_t" && buf[2] == "const pthread_attr_t" &&
        buf[3] == "void" && buf[4] == "void" &&
        buf[5] == "*tid," && buf[6] == "*attr," &&
        buf[7] == "*(*start) (void *)," && buf[8] == "*arg);") {
        print "int pthread_create ("
        print "pthread_t *tid,"
        print "const pthread_attr_t *attr,"
        print "void *(*start) (void *),"
        print "void *arg);"
    } else {
        for (i = 0; i < n; i++) print buf[i]
    }
    n = 0
    next
}

# --- single-line mechanical repairs ---
{
    sub(/PTHREAD_MUNEX_INITIALIZER/, "PTHREAD_MUTEX_INITIALIZER")
    sub(/pthread_mitex_t/, "pthread_mutex_t")
    if ($0 ~ /pthread_mutex_trylock .*\*mutex\)s$/) sub(/\)s$/, ");")
    if ($0 == "int pthread_attr_getstacksize ( - -") $0 = "int pthread_attr_getstacksize ("
    if ($0 == "pthread cond t *cond,") $0 = "pthread_cond_t *cond,"
    if ($0 ~ /hreaLcondattr_t \*attr\);$/) $0 = "const pthread_condattr_t *attr);"
    print
}

# Flush any unterminated pthread_create buffer (EOF mid-block: emit verbatim).
END { for (i = 0; i < n; i++) print buf[i] }
