#!/usr/bin/env bash
set -euo pipefail

# Winn installer
# Usage: curl -fsSL https://winn.ws/install.sh | bash
#
# Options (via env vars):
#   WINN_VERSION=v0.8.1   install a specific version (default: latest)
#   WINN_INSTALL_DIR=...  install location (default: ~/.local/bin)

WINN_VERSION="${WINN_VERSION:-latest}"
INSTALL_DIR="${WINN_INSTALL_DIR:-$HOME/.local/bin}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

err()  { echo -e "${RED}error:${NC} $*" >&2; exit 1; }
info() { echo -e "${GREEN}==>${NC} ${BOLD}$*${NC}"; }
warn() { echo -e "${YELLOW}warn:${NC} $*"; }

echo ""
echo -e "${BOLD}Winn Installer${NC}"
echo "────────────────────────────────────"
echo ""

# ── 1. Check Erlang/OTP ──────────────────────────────────────────────────────

if ! command -v erl &>/dev/null; then
  err "Erlang/OTP is not installed. Winn requires OTP 25 or newer.

  Install it first:
    macOS:    brew install erlang
    Ubuntu:   sudo apt install erlang
    Fedora:   sudo dnf install erlang
    Other:    https://www.erlang.org/downloads"
fi

OTP_RELEASE=$(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt()' -noshell 2>/dev/null | tr -d '"')
if [ -z "$OTP_RELEASE" ]; then
  warn "Could not detect OTP version — proceeding anyway."
elif [ "$OTP_RELEASE" -lt 25 ] 2>/dev/null; then
  err "Erlang/OTP $OTP_RELEASE is too old. Winn requires OTP 25 or newer."
else
  info "Found Erlang/OTP $OTP_RELEASE"
fi

# ── 2. Resolve version ───────────────────────────────────────────────────────

if [ "$WINN_VERSION" = "latest" ]; then
  info "Resolving latest release..."
  WINN_VERSION=$(curl -fsSL https://api.github.com/repos/gregwinn/winn-lang/releases/latest \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
  if [ -z "$WINN_VERSION" ]; then
    err "Could not resolve latest version from GitHub. Check your internet connection."
  fi
fi

info "Installing Winn $WINN_VERSION"

# ── 3. Download ──────────────────────────────────────────────────────────────

DOWNLOAD_URL="https://github.com/gregwinn/winn-lang/releases/download/$WINN_VERSION/winn"

mkdir -p "$INSTALL_DIR"

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"; then
  err "Download failed from $DOWNLOAD_URL
  Check that version $WINN_VERSION exists: https://github.com/gregwinn/winn-lang/releases"
fi

chmod +x "$TMP_FILE"
mv "$TMP_FILE" "$INSTALL_DIR/winn"

# ── 4. PATH check ────────────────────────────────────────────────────────────

SHELL_NAME=$(basename "${SHELL:-bash}")

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    warn "$INSTALL_DIR is not in your PATH."
    echo ""
    echo "  Add the following to your shell profile and restart your terminal:"
    echo ""
    case "$SHELL_NAME" in
      fish) echo "    fish_add_path $INSTALL_DIR" ;;
      *)    echo "    export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
    esac
    echo ""
    ;;
esac

# ── 5. Verify ────────────────────────────────────────────────────────────────

if INSTALLED_VERSION=$("$INSTALL_DIR/winn" version 2>/dev/null); then
  echo ""
  info "Winn $INSTALLED_VERSION installed at $INSTALL_DIR/winn"
  echo ""
  echo "  Get started:"
  echo "    winn new my-app"
  echo "    cd my-app && winn run src/main.winn"
  echo "    https://winn.ws/docs/getting-started/"
  echo ""
else
  err "Installation failed — could not run $INSTALL_DIR/winn version"
fi
