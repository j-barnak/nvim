# Resources/tools

Build scripts, kept as files so the Neovim config carries no embedded shell or
python. Two kinds:

Frozen-library generators (run once by hand; the config only reads their
output under `Resources/docs`):

- `epub_build.sh`: epub -> per-chapter markdown
  (`sh -c "$(cat epub_build.sh)" epub <src.epub> <out-dir> <title>`).
  Splits by the epub's ncx (anchor-split for books whose spine does not line up
  with chapters), re-fences code, strips running headers, keeps tables/figures.
- `pdf_build.sh`: pdf -> per-chapter text
  (`sh -c "$(cat pdf_build.sh)" pdf <src.pdf> <out-dir> "" book`).
  Splits by the outline using the printed table-of-contents shape (Parts,
  chapters, appendices), emits front matter before the first bookmark. The
  config also runs it (without the `book` mode) for the downloaded PDF specs.
- `webextract.py`: article HTML -> body HTML for pandoc
  (`curl -fsSL <url> | python3 webextract.py content <css-selector> | pandoc -f html -t gfm-raw_html --wrap=none`).
  Flattens tables (outermost table, direct rows/cells only) so nothing is
  dropped or duplicated. The `mediawiki` mode does the same for a rendered
  MediaWiki page (`python3 webextract.py mediawiki "" https://wiki.osdev.org`):
  it keeps `div.mw-parser-output`, drops the table of contents and the other
  in-body chrome, turns SyntaxHighlight `div.mw-highlight` wrappers back into
  language-tagged fences, and absolutises the relative wiki links. It built the
  frozen OSDev wiki provider from the site's offline dump.

Loaded on demand by `lua/config/docs.lua` (`tool_script()`), only when a live
provider builds its cache for the first time:

- `api_build.sh`: kernel-doc index for `:Docs kernel-api` (`$1` = kernel tree).
- `dox_pipeline.sh`: doxygen -> markdown for the doxygen-based providers.
- `sdm_build.sh` + `figextract.py`: Intel SDM download, split and figure crop.
- `aya_api_idx.sh`: aya crate item index.

The out-dir basename must be the book's slug (a few books have per-slug rules).
Sources (epub/pdf) are not kept in the repo.
