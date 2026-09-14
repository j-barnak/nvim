#!/usr/bin/env bash
# Freeze (or update) the seL4 documentation (docs.sel4.systems) into the :Docs
# frozen web-book layout used by the "seL4 -> Documentation" subpicker:
#   Resources/docs/sel4-docs/index.tsv        sidebar order, "[Section] Title"
#   Resources/docs/.webcache/<sha256(url)>.txt the rendered pages
#
# Body selector is div.theprose. Order + section grouping follow the site's own
# sidebar (which matches the requested outline). External "Sources" (GitHub) and
# the Rust "API" (external rustdoc) links are NOT included: source lives in :Src.
# Usage: sel4_docs_build.sh   (run from anywhere)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/sel4-docs"
SEL='div.theprose'
BASE="https://docs.sel4.systems"
mkdir -p "$OUT" "$CACHE"

# display <TAB> path  (site sidebar order, "[Section] / [Section / Sub]" tags)
PAGES=$(cat <<'ROWS'
[Getting Started] Overview	/getting-started.html
[Getting Started] Tutorials	/Tutorials/
[Getting Started] Setting up with Docker	/projects/dockerfiles/
[Getting Started] Repo manifest cheat sheet	/projects/buildsystem/repo-cheatsheet.html
[The seL4 Kernel] Overview	/projects/sel4/
[The seL4 Kernel] Setting up	/projects/buildsystem/host-dependencies.html
[The seL4 Kernel / Tutorial] Setting up	/Tutorials/setting-up.html
[The seL4 Kernel / Tutorial] Getting the tutorials	/Tutorials/get-the-tutorials.html
[The seL4 Kernel / Tutorial] Hello world	/Tutorials/hello-world.html
[The seL4 Kernel / Tutorial] Capabilities	/Tutorials/capabilities.html
[The seL4 Kernel / Tutorial] Untyped	/Tutorials/untyped.html
[The seL4 Kernel / Tutorial] Mapping	/Tutorials/mapping.html
[The seL4 Kernel / Tutorial] Threads	/Tutorials/threads.html
[The seL4 Kernel / Tutorial] IPC	/Tutorials/ipc.html
[The seL4 Kernel / Tutorial] Notifications	/Tutorials/notifications.html
[The seL4 Kernel / Tutorial] Interrupts	/Tutorials/interrupts.html
[The seL4 Kernel / Tutorial] Fault handling	/Tutorials/fault-handlers.html
[The seL4 Kernel / Tutorial] MCS	/Tutorials/mcs.html
[The seL4 Kernel / Tutorial] End	/Tutorials/seL4-end.html
[The seL4 Kernel] How-to	/Tutorials/how-to-seL4.html
[The seL4 Kernel] API docs	/projects/sel4/api-doc.html
[The seL4 Kernel] Manual	/projects/sel4/manual.html
[The seL4 Kernel] Supported platforms	/Hardware/
[The seL4 Kernel] Verified configurations	/projects/sel4/verified-configurations.html
[The seL4 Kernel] Configurations	/projects/sel4/configurations.html
[The seL4 Kernel] Standalone seL4 builds	/projects/buildsystem/standalone.html
[The seL4 Kernel] Bitfield generator	/projects/sel4/bfgen.html
[The seL4 Kernel / Testing & benchmarking] seL4test	/projects/sel4test/
[The seL4 Kernel / Testing & benchmarking] Debugging guide	/projects/sel4-tutorials/debugging-guide.html
[The seL4 Kernel / Testing & benchmarking] Debugging user space	/projects/sel4-tutorials/debugging-userspace.html
[The seL4 Kernel / Testing & benchmarking] sel4bench	/projects/sel4bench/
[The seL4 Kernel / Testing & benchmarking] Benchmarking guide	/projects/sel4-tutorials/benchmarking-guide.html
[The seL4 Kernel] Contributing	/projects/sel4/kernel-contribution.html
[The seL4 Kernel] Porting to a new platform	/projects/sel4/porting.html
[The seL4 Kernel] Releases	/releases/seL4.html
[Microkit] Overview	/projects/microkit/
[Microkit] Setting up your machine	/projects/microkit/setting-up.html
[Microkit / Tutorial] Welcome	/projects/microkit/tutorial/welcome.html
[Microkit / Tutorial] Part 0 - Setting up	/projects/microkit/tutorial/part0.html
[Microkit / Tutorial] Part 1 - Serial server	/projects/microkit/tutorial/part1.html
[Microkit / Tutorial] Part 2 - Client	/projects/microkit/tutorial/part2.html
[Microkit / Tutorial] Part 3 - Wordle server	/projects/microkit/tutorial/part3.html
[Microkit / Tutorial] Part 4 - Virtual machines	/projects/microkit/tutorial/part4.html
[Microkit / Tutorial] End	/projects/microkit/tutorial/end.html
[Microkit] Supported platforms	/projects/microkit/platforms.html
[Microkit] Releases	/releases/microkit.html
[CAmkES] Overview	/projects/camkes/
[CAmkES] Setting up your machine	/projects/camkes/setting-up.html
[CAmkES / Tutorials] Hello CAmkES	/Tutorials/hello-camkes-0.html
[CAmkES / Tutorials] Introduction	/Tutorials/hello-camkes-1.html
[CAmkES / Tutorials] Events	/Tutorials/hello-camkes-2.html
[CAmkES / Tutorials] Timer	/Tutorials/hello-camkes-timer.html
[CAmkES / Tutorials] Virtual Machines	/Tutorials/camkes-vm-linux.html
[CAmkES / Tutorials] Cross-VM connectors	/Tutorials/camkes-vm-crossvm.html
[CAmkES] How-to	/Tutorials/how-to-CAmkES.html
[CAmkES] Manual	/projects/camkes/manual.html
[CAmkES] Supported platforms	/projects/camkes/hardware.html
[CAmkES / Virtualisation] CAmkES VM	/projects/camkes-vm/
[CAmkES / Virtualisation] VM library	/projects/virtualization/docs/libsel4vm.html
[CAmkES / Virtualisation] VMM library	/projects/virtualization/docs/libsel4vmm.html
[CAmkES] Releases	/releases/camkes.html
[C support] C runtime	/projects/sel4runtime/
[C support] User-level libraries	/projects/user_libs/
[C support] Build System	/projects/buildsystem/
[C support / Tutorials] Init & Threads	/Tutorials/libraries-1.html
[C support / Tutorials] IPC	/Tutorials/libraries-2.html
[C support / Tutorials] ELF loading & Processes	/Tutorials/libraries-3.html
[C support / Tutorials] Timer	/Tutorials/libraries-4.html
[C support] How-to	/Tutorials/how-to-libs.html
[Rust support] Overview	/projects/rust/
[Rust support] How to use	/projects/rust/how-to-use.html
[Rust support] Tutorial	/projects/rust/tutorial/introduction.html
[Rust support] Supported configurations	/projects/rust/supported-configurations.html
[Rust support] Releases	/projects/rust/releases.html
[ELF loader] ELF loader for C	/projects/elfloader/
[capDL] Overview	/projects/capdl/
[capDL] Language Spec	/projects/capdl/lang-spec.html
[capDL] capDL loader (C)	/projects/capdl/c-loader-app.html
[capDL] Releases	/releases/capDL.html
[Examples & demos] Overview	/examples.html
ROWS
)

# a few pages render in a different container than the main site's div.theprose
sel_for() {
  case "$1" in
    */projects/rust/tutorial/*) echo 'div.content' ;;   # embedded mdBook
    */examples.html)            echo 'div#main-div' ;;   # card-grid landing
    *)                          echo "$SEL" ;;
  esac
}

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r disp path; do
  [ -z "$path" ] && continue
  url="$BASE$path"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  # drop base64 data: images (some cards embed inline SVG icons) after cleaning
  body=$(printf '%s' "$html" | python3 "$WE" content "$(sel_for "$url")" "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null \
    | sed -E 's/!\[[^]]*\]\(data:[^)]*\)//g; s/\]\(data:[^)]*\)/]()/g')
  [ "$(printf '%s' "$body" | wc -c)" -lt 40 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s' "$body" > "$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\t%s\n' "$disp" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done <<< "$PAGES"
echo "==> sel4 docs: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
