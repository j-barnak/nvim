#!/usr/bin/env bash
# Freeze (or update) the Dioxus 0.7 guide (dioxuslabs.com/learn/0.7) into the
# :Docs frozen web-book layout used by the "Dioxus -> Guide" picker:
#   Resources/docs/dioxus-guide/index.tsv        sidebar order, "[Section] Title"
#   Resources/docs/.webcache/<sha256(url)>.txt    the rendered pages
#
# The site renders its body into article.markdown-body. The crate API reference
# is NOT frozen (browsed live from docs.rs).
# Usage: dioxus_guide_build.sh   (run from anywhere)
set -u
CFG="${CFG:-$(cd "$(dirname "$0")/../.." && pwd)}"
WE="$CFG/Resources/tools/webextract.py"
CACHE="$CFG/Resources/docs/.webcache"
OUT="$CFG/Resources/docs/dioxus-guide"
SEL='article.markdown-body'
BASE="https://dioxuslabs.com"
mkdir -p "$OUT" "$CACHE"

# display <TAB> path, in the dioxuslabs.com/learn/0.7 sidebar order.
PAGES=$(cat <<'ROWS'
[Introduction] Welcome	/learn/0.7/
[Introduction] Getting Started	/learn/0.7/getting_started/
[Take a Tour] Overview	/learn/0.7/tutorial/
[Take a Tour] Tooling Setup	/learn/0.7/tutorial/tooling
[Take a Tour] Creating a new app	/learn/0.7/tutorial/new_app
[Take a Tour] Your First Component	/learn/0.7/tutorial/component
[Take a Tour] Creating UI with RSX	/learn/0.7/tutorial/rsx
[Take a Tour] Styling and Assets	/learn/0.7/tutorial/assets
[Take a Tour] Adding State	/learn/0.7/tutorial/state
[Take a Tour] Fetching Data	/learn/0.7/tutorial/data_fetching
[Take a Tour] Add a Backend	/learn/0.7/tutorial/backend
[Take a Tour] Working with Databases	/learn/0.7/tutorial/databases
[Take a Tour] Routing and Structure	/learn/0.7/tutorial/routing
[Take a Tour] Bundling	/learn/0.7/tutorial/bundle
[Take a Tour] Deploying	/learn/0.7/tutorial/deploy
[Take a Tour] Next Steps	/learn/0.7/tutorial/next_steps
[Core Concepts] Overview	/learn/0.7/essentials/
[Core Concepts / Building UI] Building User Interfaces	/learn/0.7/essentials/ui/
[Core Concepts / Building UI] Introducing RSX	/learn/0.7/essentials/ui/rsx
[Core Concepts / Building UI] Elements and Text	/learn/0.7/essentials/ui/elements
[Core Concepts / Building UI] Dynamic Attributes	/learn/0.7/essentials/ui/attributes
[Core Concepts / Building UI] Conditional Rendering	/learn/0.7/essentials/ui/conditional
[Core Concepts / Building UI] Rendering Lists	/learn/0.7/essentials/ui/iteration
[Core Concepts / Building UI] Components	/learn/0.7/essentials/ui/components
[Core Concepts / Building UI] Reconciliation	/learn/0.7/essentials/ui/render
[Core Concepts / Building UI] Assets	/learn/0.7/essentials/ui/assets
[Core Concepts / Building UI] Styling	/learn/0.7/essentials/ui/styling
[Core Concepts / Building UI] Hot-Reload	/learn/0.7/essentials/ui/hotreload
[Core Concepts / Building UI] Escape Hatches	/learn/0.7/essentials/ui/escape
[Core Concepts / Basics of State] The Basics of State	/learn/0.7/essentials/basics/
[Core Concepts / Basics of State] Intro to Reactivity	/learn/0.7/essentials/basics/reactivity
[Core Concepts / Basics of State] Storing State in Hooks	/learn/0.7/essentials/basics/hooks
[Core Concepts / Basics of State] Reactive Signals	/learn/0.7/essentials/basics/signals
[Core Concepts / Basics of State] User Input	/learn/0.7/essentials/basics/event_handlers
[Core Concepts / Basics of State] Async and Futures	/learn/0.7/essentials/basics/async
[Core Concepts / Basics of State] Data Fetching	/learn/0.7/essentials/basics/resources
[Core Concepts / Basics of State] Effects and Memos	/learn/0.7/essentials/basics/effects
[Core Concepts / Basics of State] Hoisting State	/learn/0.7/essentials/basics/hoisting
[Core Concepts / Basics of State] Global Context	/learn/0.7/essentials/basics/context
[Core Concepts / Basics of State] Stores and Collections	/learn/0.7/essentials/basics/collections
[Core Concepts / Basics of State] Error Handling	/learn/0.7/essentials/basics/error_handling
[Core Concepts / Basics of State] Suspense	/learn/0.7/essentials/basics/suspense
[Core Concepts / Fullstack] Fullstack	/learn/0.7/essentials/fullstack/
[Core Concepts / Fullstack] Project Setup	/learn/0.7/essentials/fullstack/project_setup
[Core Concepts / Fullstack] Server Side Rendering	/learn/0.7/essentials/fullstack/ssr
[Core Concepts / Fullstack] Server Functions	/learn/0.7/essentials/fullstack/server_functions
[Core Concepts / Fullstack] Custom Error Pages	/learn/0.7/essentials/fullstack/errors
[Core Concepts / Fullstack] Router and State	/learn/0.7/essentials/fullstack/axum
[Core Concepts / Fullstack] Middleware	/learn/0.7/essentials/fullstack/middleware
[Core Concepts / Fullstack] Websockets	/learn/0.7/essentials/fullstack/websockets
[Core Concepts / Fullstack] Streams and SSE	/learn/0.7/essentials/fullstack/streams
[Core Concepts / Fullstack] Forms and Multipart	/learn/0.7/essentials/fullstack/forms
[Core Concepts / Fullstack] Authentication	/learn/0.7/essentials/fullstack/authentication
[Core Concepts / Fullstack] Native Clients	/learn/0.7/essentials/fullstack/native
[Core Concepts / Fullstack] HTML Streaming	/learn/0.7/essentials/fullstack/streaming
[Core Concepts / Fullstack] Static Site Generation	/learn/0.7/essentials/fullstack/static_site_generation
[Core Concepts / Routing] Routing	/learn/0.7/essentials/router/
[Core Concepts / Routing] Defining Routes	/learn/0.7/essentials/router/routes
[Core Concepts / Routing] Navigation	/learn/0.7/essentials/router/navigation
[Core Concepts / Routing] Layouts	/learn/0.7/essentials/router/layouts
[Core Concepts / Advanced Topics] Advanced Topics	/learn/0.7/essentials/advanced/
[Core Concepts / Advanced Topics] Custom Hooks	/learn/0.7/essentials/advanced/custom_hooks
[Core Concepts / Advanced Topics] Component Lifecycle	/learn/0.7/essentials/advanced/lifecycle
[Core Concepts / Advanced Topics] Breaking Out	/learn/0.7/essentials/advanced/breaking_out
[Guides] Overview	/learn/0.7/guides/
[Guides / Overview] Tools	/learn/0.7/guides/tools/
[Guides / Overview] Create a Project	/learn/0.7/guides/tools/creating
[Guides / Overview] Configure Project	/learn/0.7/guides/tools/configure
[Guides / Overview] Translate HTML	/learn/0.7/guides/tools/translate
[Guides / Platform Support] Platform Support	/learn/0.7/guides/platforms/
[Guides / Platform Support] Web	/learn/0.7/guides/platforms/web
[Guides / Platform Support] Desktop	/learn/0.7/guides/platforms/desktop
[Guides / Platform Support] Mobile	/learn/0.7/guides/platforms/mobile
[Guides / Publishing] Publishing	/learn/0.7/guides/deploy/
[Guides / Publishing] Bundle Config	/learn/0.7/guides/deploy/config
[Guides / Testing and Debugging] Testing and Debugging	/learn/0.7/guides/testing/
[Guides / Testing and Debugging] Web Testing	/learn/0.7/guides/testing/web
[Guides / Testing and Debugging] Optimizing	/learn/0.7/guides/tips/optimizing
[Guides / Testing and Debugging] Anti-patterns	/learn/0.7/guides/tips/antipatterns
[Guides / Utilities] Utilities	/learn/0.7/guides/utilities/
[Guides / Utilities] Logging	/learn/0.7/guides/utilities/logging
[Guides / Utilities] Internationalization	/learn/0.7/guides/utilities/internationalization
[Guides / Utilities] Tailwind	/learn/0.7/guides/utilities/tailwind
[Guides / In-Depth] In-Depth	/learn/0.7/guides/depth/
[Guides / In-Depth] Custom Renderer	/learn/0.7/guides/depth/custom_renderer
[Guides / Migration] Migration	/learn/0.7/migration/
[Guides / Migration] To 0.7	/learn/0.7/migration/to_07
[Guides / Migration] To 0.6	/learn/0.7/migration/to_06
[Guides / Migration] To 0.5	/learn/0.7/migration/to_05/
[Beyond] Overview	/learn/0.7/beyond/
[Beyond] Contributing	/learn/0.7/beyond/contributing
[Beyond] Project Structure	/learn/0.7/beyond/project_structure
ROWS
)

: > "$OUT/index.tsv"; ok=0; fail=0
while IFS=$'\t' read -r disp path; do
  [ -z "$path" ] && continue
  url="$BASE$path"
  html=$(curl -fsSL --compressed --max-time 40 "$url" 2>/dev/null)
  [ -z "$html" ] && { echo "FAIL fetch $url" >&2; fail=$((fail+1)); continue; }
  body=$(printf '%s' "$html" | python3 "$WE" content "$SEL" "$url" abs 2>/dev/null \
    | pandoc -f html -t gfm-raw_html --wrap=none --preserve-tabs 2>/dev/null \
    | python3 "$WE" clean "" "" 2>/dev/null)
  [ "$(printf '%s' "$body" | wc -c)" -lt 50 ] && { echo "FAIL empty $url" >&2; fail=$((fail+1)); continue; }
  printf '%s' "$body" > "$CACHE/$(printf '%s' "$url" | sha256sum | awk '{print $1}').txt"
  printf '%s\t%s\n' "$disp" "$url" >> "$OUT/index.tsv"; ok=$((ok+1))
  sleep 0.3
done <<< "$PAGES"
echo "==> dioxus guide: $ok ok, $fail failed, index rows: $(wc -l < "$OUT/index.tsv")"
