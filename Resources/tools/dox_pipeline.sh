set -e
INPUT="$1"; OUT="$2"; TOOLS="$3"; PATTERNS="$4"
DOXY=$(ls "$TOOLS"/doxygen-*/bin/doxygen 2>/dev/null | head -1)
if [ -z "$DOXY" ]; then
  mkdir -p "$TOOLS"
  ( cd "$TOOLS" && curl -fsSL https://www.doxygen.nl/files/doxygen-1.14.0.linux.bin.tar.gz -o d.tgz && tar xzf d.tgz && rm -f d.tgz )
  DOXY=$(ls "$TOOLS"/doxygen-*/bin/doxygen 2>/dev/null | head -1)
fi
# Kill-atomic: build the whole markdown set in $OUT.stage, then rename it in.
# A doxygen/moxygen run killed midway must not leave a partial $OUT that the
# glob check treats as a finished build.
# Keep the existing $OUT untouched until the new set is built: a failed
# download or doxygen run must leave the working docs in place.
STAGE="$OUT.stage"; rm -rf "$STAGE"; mkdir -p "$STAGE"
XML="$STAGE/.xml"; mkdir -p "$XML"
{
  echo "INPUT = $INPUT"
  echo "FILE_PATTERNS = $PATTERNS"
  echo "RECURSIVE = YES"
  # Pin every output under the throwaway stage and disable LaTeX: doxygen
  # defaults GENERATE_LATEX=YES and writes relative dirs into its cwd (the nvim
  # repo when run from there), which previously leaked a 498-file latex/ tree.
  echo "OUTPUT_DIRECTORY = $STAGE"
  echo "GENERATE_HTML = NO"
  echo "GENERATE_LATEX = NO"
  echo "GENERATE_XML = YES"
  echo "XML_OUTPUT = $XML"
  echo "XML_PROGRAMLISTING = NO"
  echo "EXTRACT_ALL = YES"
  echo "QUIET = YES"
  echo "WARN_IF_UNDOCUMENTED = NO"
} > "$XML/Doxyfile"
"$DOXY" "$XML/Doxyfile" >/dev/null 2>&1
moxygen --classes --groups --anchors --output "$STAGE/%s.md" "$XML" >/dev/null 2>&1
rm -rf "$XML"
rm -rf "$OUT"; mv "$STAGE" "$OUT"
