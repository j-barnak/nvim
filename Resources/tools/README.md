# Resources/tools

One-off generators for the frozen library under `Resources/docs`. These are
NOT loaded by the Neovim config (the config only reads the frozen output);
they exist so a book or article can be regenerated reproducibly.

- `epub_build.sh` — epub -> per-chapter markdown (`sh -c "$(cat epub_build.sh)" epub <src.epub> <out-dir> <title>`).
  Splits by the epub's ncx (anchor-split for books whose spine does not line up
  with chapters), re-fences code, strips running headers, keeps tables/figures.
- `pdf_build.sh` — pdf -> per-chapter text (`sh -c "$(cat pdf_build.sh)" pdf <src.pdf> <out-dir> "" book`).
  Splits by the outline using the printed table-of-contents shape (Parts,
  chapters, appendices), emits front matter before the first bookmark.
- `webextract.py` — article HTML -> body HTML for pandoc
  (`curl -fsSL <url> | python3 webextract.py content <css-selector> | pandoc -f html -t gfm-raw_html --wrap=none`).
  Flattens tables (outermost table, direct rows/cells only) so nothing is
  dropped or duplicated.

The out-dir basename must be the book's slug (a few books have per-slug rules).
Sources (epub/pdf) are not kept in the repo.
