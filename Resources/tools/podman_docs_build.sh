#!/usr/bin/env bash
# Freeze the Podman documentation into the :Docs two-level frozen layout read by
# frozen_nested_provider("podman"):
#   Resources/docs/podman/index.tsv            "<category>\t<title>\t<url>"
#   Resources/docs/.webcache/<sha256(url)>.txt  the rendered page
#
# Five categories, in the order the picker shows them:
#   Introduction   docs.podman.io/en/latest/Introduction.html (one page)
#   Commands       every podman command page linked from Commands.html
#                  (markdown/podman-<cmd>.1.html), each followed by the
#                  subcommand pages it links (podman-<cmd>-<sub>.1.html), titled
#                  "podman <cmd>" / "podman <cmd> <sub>" so fzf matches either word
#   Reference      Reference.html, podman(1) and podman-systemd.unit(5), the one
#                  section-5 page docs.podman.io hosts
#   Tutorials      the Markdown tutorials Tutorials.html links on GitHub, fetched
#                  raw (already Markdown, no pandoc) with the blurbs the page uses
#                  as titles, plus the Go bindings README it points at
#   Podman Python  podman-py.readthedocs.io: the SDK index and every module page
#                  in its toctree (podman.client, podman.domain.*, exceptions),
#                  titled by the short module name (client, containers, ...)
#
# Both Sphinx sites use the alabaster theme: the page body is div.body; the
# `sphinx` webextract opt restores the code-block languages Sphinx hides in
# its highlight-<lang> wrappers.
# Usage: podman_docs_build.sh   (needs curl, python3+bs4+lxml, pandoc)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/podman"
DOCS="https://docs.podman.io/en/latest"
PY="https://podman-py.readthedocs.io/en/latest"
UA="Mozilla/5.0 (personal-docs-archive)"
mkdir -p "$OUT" "$CACHE"
: > "$OUT/index.tsv"
ok=0; fail=0

cachefile() { printf '%s/%s.txt' "$CACHE" "$(printf '%s' "$1" | sha256sum | awk '{print $1}')"; }
get() { curl -fsSL --compressed --max-time 40 -A "$UA" "$1" 2>/dev/null; }

# page <category> <title> <url>: render a Sphinx page and index it.
page() {
  local cat="$1" title="$2" url="$3" body
  body=$(get "$url" | python3 "$WE" content div.body "$url" abs,sphinx 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  if [ "$(printf '%s' "$body" | wc -c)" -lt 40 ]; then
    echo "FAIL empty $url" >&2; fail=$((fail+1)); return 1
  fi
  printf '%s\n' "$body" > "$(cachefile "$url")"
  printf '%s\t%s\t%s\n' "$cat" "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
}

# markdown <category> <title> <raw-url>: a GitHub Markdown file, cached as-is
# (a "# Title" heading prepended when the file does not start with one).
markdown() {
  local cat="$1" title="$2" url="$3" body
  body=$(get "$url")
  if [ "$(printf '%s' "$body" | wc -c)" -lt 40 ]; then
    echo "FAIL empty $url" >&2; fail=$((fail+1)); return 1
  fi
  if ! printf '%s\n' "$body" | grep -q '^# '; then
    body=$(printf '# %s\n\n%s' "$title" "$body")
  fi
  printf '%s\n' "$body" > "$(cachefile "$url")"
  printf '%s\t%s\t%s\n' "$cat" "$title" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.2
}

# ── Introduction ────────────────────────────────────────────────────────────
page "Introduction" "Introduction" "$DOCS/Introduction.html"

# ── Commands: the 62 command pages and, under each, its subcommand pages ────
cmds=$(get "$DOCS/Commands.html" | grep -o 'href="markdown/podman-[^"]*\.1\.html"' | sed 's/href="markdown\///;s/"//' | sort -u)
for f in $cmds; do
  name=${f%.1.html}                       # podman-container
  cmd=${name#podman-}                     # container
  page "Commands" "podman $cmd" "$DOCS/markdown/$f" || continue
  subs=$(get "$DOCS/markdown/$f" | grep -o "href=\"$name-[^\"]*\.1\.html\"" | sed 's/href="//;s/"//' | sort -u)
  for s in $subs; do
    sub=${s%.1.html}; sub=${sub#"$name"-}
    page "Commands" "podman $cmd ${sub//-/ }" "$DOCS/markdown/$s"
  done
done

# ── Reference ───────────────────────────────────────────────────────────────
page "Reference" "Reference" "$DOCS/Reference.html"
page "Reference" "podman(1)" "$DOCS/markdown/podman.1.html"
page "Reference" "podman-systemd.unit(5) — Quadlet" "$DOCS/markdown/podman-systemd.unit.5.html"

# ── Tutorials: GitHub Markdown, titles as Tutorials.html words them ─────────
GH="https://raw.githubusercontent.com/containers/podman/main"
while IFS=$'\t' read -r title url; do
  [ -z "$url" ] && continue
  markdown "Tutorials" "$title" "$url"
done <<TUT
Basic Setup and Use of Podman	$GH/docs/tutorials/podman_tutorial.md
Basic Setup and Use of Podman in a Rootless environment	$GH/docs/tutorials/rootless_tutorial.md
Podman for Windows	$GH/docs/tutorials/podman-for-windows.md
Podman Remote Clients on Mac/Windows	$GH/docs/tutorials/mac_win_client.md
How to sign and distribute container images using Podman	$GH/docs/tutorials/image_signing.md
Podman remote-client tutorial	$GH/docs/tutorials/remote_client.md
How to use libpod for custom/derivative projects	$GH/docs/tutorials/podman-derivative-api.md
How to use Podman's Go RESTful bindings	$GH/pkg/bindings/README.md
Common network setups	$GH/docs/tutorials/basic_networking.md
Socket activation	$GH/docs/tutorials/socket_activation.md
Customizing the Podman Machine OS image	https://raw.githubusercontent.com/podman-container-tools/podman/main/docs/tutorials/podman_machine_os_customization.md
TUT

# ── Podman Python (SDK): the index, then every toctree page ─────────────────
page "Podman Python" "Podman Python SDK (index)" "$PY/"
mods=$(get "$PY/" | grep -o 'href="podman\.[^"]*\.html"' | sed 's/href="//;s/"//' | awk '!seen[$0]++')
for f in $mods; do
  short=${f%.html}; short=${short##*.}   # podman.domain.containers_run -> containers_run
  page "Podman Python" "$short" "$PY/$f"
done

echo "==> Podman: $ok pages, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
