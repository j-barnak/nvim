#!/usr/bin/env bash
# Install.sh - set up this Neovim configuration with everything it needs.
#
# You may not need this. A bare  `git clone <repo> ~/.config/nvim && nvim`
# already works: init.lua self-bootstraps lazy.nvim (clones the plugins on the
# first launch), and the whole :Docs library is frozen INSIDE this repo
# (Resources/docs/), so every book opens offline with no build step. All a
# clone assumes is the pickers' CLI tools (fzf, fd, ripgrep) and one-time
# network for the plugin bootstrap.
#
# This script is the convenience layer around that: it installs those CLI tools
# (and the heavier pandoc/pdftotext/ctags/texinfo toolchain used only to REBUILD
# docs or explore :Src source) across the common package managers, installs the
# three Python libraries the doc builders import, links this checkout to
# ~/.config/nvim, and syncs the plugins headlessly.
#
# What this script does:
#   1. installs the system packages the config uses (Neovim + the :Docs toolchain)
#   2. installs the three Python libraries the doc builders import
#   3. links this checkout to ~/.config/nvim (or $XDG_CONFIG_HOME/nvim)
#   4. bootstraps the plugins (lazy.nvim) headlessly so the first real launch is ready
#
# It is idempotent: re-running it re-checks packages and re-syncs plugins.
# Usage:  ./Install.sh            (interactive: asks before sudo installs)
#         ./Install.sh --yes      (assume yes; for CI / unattended)
set -euo pipefail

ASSUME_YES=0
case "${1:-}" in --yes|-y) ASSUME_YES=1 ;; esac

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

ask() { # ask "question" -> 0 for yes
  [ "$ASSUME_YES" = 1 ] && return 0
  printf '%s [Y/n] ' "$1"; read -r a || true
  case "$a" in [nN]*) return 1 ;; *) return 0 ;; esac
}

SUDO=""
if [ "$(id -u)" -ne 0 ]; then have sudo && SUDO="sudo" || warn "not root and no sudo; package installs may fail"; fi

# ── 1. system packages ──────────────────────────────────────────────────────
# The logical tools the config needs, mapped per package manager below:
#   neovim git curl  - the editor and the fetch/clone machinery
#   ripgrep fd fzf   - fzf-lua pickers, :Docs and :Src search
#   pandoc           - HTML->markdown stage of every frozen web book
#   poppler(pdftotext) - PDF book extraction
#   ctags            - :Src symbol index
#   texinfo(makeinfo) - info/texi doc rendering
#   python3          - runs the doc builders
# Optional (installed if the manager has them, never fatal): cppman, tmux.
detect_pm() {
  for pm in apt-get dnf pacman zypper apk brew; do have "$pm" && { echo "$pm"; return; }; done
  echo ""
}

install_packages() {
  local pm; pm="$(detect_pm)"
  [ -z "$pm" ] && { warn "no known package manager found; install the tools listed above manually"; return; }
  log "using package manager: $pm"
  case "$pm" in
    apt-get)
      $SUDO apt-get update
      $SUDO apt-get install -y neovim git curl ripgrep fd-find fzf pandoc \
        poppler-utils universal-ctags texinfo python3 python3-pip \
        python3-bs4 python3-lxml python3-yaml || warn "some apt packages failed"
      # Debian names the binary fd-find/fdfind; fzf-lua looks for 'fd'.
      if ! have fd && have fdfind; then
        $SUDO ln -sf "$(command -v fdfind)" /usr/local/bin/fd 2>/dev/null || true
      fi
      $SUDO apt-get install -y cppman tmux 2>/dev/null || true
      ;;
    dnf)
      $SUDO dnf install -y neovim git curl ripgrep fd-find fzf pandoc \
        poppler-utils ctags texinfo python3 python3-pip \
        python3-beautifulsoup4 python3-lxml python3-pyyaml || warn "some dnf packages failed"
      $SUDO dnf install -y cppman tmux 2>/dev/null || true
      ;;
    pacman)
      $SUDO pacman -Sy --needed --noconfirm neovim git curl ripgrep fd fzf pandoc \
        poppler ctags texinfo python python-beautifulsoup4 python-lxml python-yaml \
        || warn "some pacman packages failed"
      $SUDO pacman -S --needed --noconfirm tmux 2>/dev/null || true
      ;;
    zypper)
      $SUDO zypper install -y neovim git curl ripgrep fd fzf pandoc \
        poppler-tools ctags texinfo python3 python3-pip \
        python3-beautifulsoup4 python3-lxml python3-PyYAML || warn "some zypper packages failed"
      ;;
    apk)
      $SUDO apk add neovim git curl ripgrep fd fzf pandoc poppler-utils \
        ctags texinfo python3 py3-pip py3-beautifulsoup4 py3-lxml py3-yaml \
        || warn "some apk packages failed"
      ;;
    brew)
      brew install neovim git curl ripgrep fd fzf pandoc poppler universal-ctags texinfo python3 \
        || warn "some brew packages failed"
      brew install cppman tmux 2>/dev/null || true
      ;;
  esac
}

# ── 2. Python libraries the doc builders import (bs4, lxml, pyyaml) ──────────
# Distro packages above usually cover these; this is the fallback for when they
# do not, or on macOS/brew. Never touches system site-packages destructively.
install_python_libs() {
  python3 - <<'PY' && return 0 || true
import importlib.util as u, sys
missing=[m for m in ("bs4","lxml","yaml") if u.find_spec(m) is None]
sys.exit(1 if missing else 0)
PY
  log "installing Python libs (beautifulsoup4, lxml, pyyaml)"
  if python3 -m pip install --user --upgrade beautifulsoup4 lxml pyyaml 2>/dev/null; then
    :
  elif have pipx; then
    warn "pip --user blocked; the builders need bs4/lxml/pyyaml in python3 — install them via your distro"
  else
    # PEP 668 externally-managed environments: try a venv the builders can use.
    python3 -m pip install --user --break-system-packages beautifulsoup4 lxml pyyaml 2>/dev/null \
      || warn "could not pip install bs4/lxml/pyyaml; install them with your package manager"
  fi
}

# ── 3. link this checkout into place ────────────────────────────────────────
link_config() {
  if [ "$REPO_DIR" = "$CONFIG_DIR" ]; then
    log "config already at $CONFIG_DIR"
    return
  fi
  if [ -e "$CONFIG_DIR" ] || [ -L "$CONFIG_DIR" ]; then
    warn "$CONFIG_DIR already exists; not touching it."
    warn "This checkout is at $REPO_DIR. Point Neovim at it with NVIM_APPNAME or move it into place yourself."
    return
  fi
  mkdir -p "$(dirname "$CONFIG_DIR")"
  if ask "Symlink $CONFIG_DIR -> $REPO_DIR?"; then
    ln -s "$REPO_DIR" "$CONFIG_DIR"
    log "symlinked $CONFIG_DIR -> $REPO_DIR"
  fi
}

# ── 4. plugins ──────────────────────────────────────────────────────────────
bootstrap_plugins() {
  have nvim || { err "neovim not installed; skipping plugin bootstrap"; return; }
  log "bootstrapping plugins (lazy.nvim) — first run clones them, needs network"
  # Lazy auto-clones itself from init.lua; +Lazy! sync installs/updates the rest.
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -20 || warn "plugin sync reported an issue; open nvim and run :Lazy"
}

# ── run ─────────────────────────────────────────────────────────────────────
log "Neovim config installer  (repo: $REPO_DIR)"
if ask "Install system packages (needs sudo)?"; then install_packages; else warn "skipping system packages"; fi
install_python_libs
link_config
bootstrap_plugins

# ── report ──────────────────────────────────────────────────────────────────
echo
log "checking the toolchain:"
ok=1
for t in nvim git curl rg fd fzf pandoc pdftotext ctags python3; do
  if have "$t" || { [ "$t" = fd ] && have fdfind; }; then
    printf '  \033[1;32m✓\033[0m %s\n' "$t"
  else
    printf '  \033[1;31m✗\033[0m %s (missing)\n' "$t"; ok=0
  fi
done
python3 - <<'PY' || true
import importlib.util as u
ok="\033[1;32m✓\033[0m"; no="\033[1;31m✗\033[0m"
for m,label in (("bs4","beautifulsoup4"),("lxml","lxml"),("yaml","pyyaml")):
    mark = ok if u.find_spec(m) else no
    print("  %s python:%s" % (mark, label))
PY
echo
if [ "$ok" = 1 ]; then
  log "Done. The frozen :Docs library works offline; :Src clones sources on demand."
  log "Launch:  nvim   then try  :Docs   and  :Src"
else
  warn "Some tools are missing above; :Docs mostly works but install them for full function."
fi
