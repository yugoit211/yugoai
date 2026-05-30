#!/usr/bin/env bash
# ============================================================
#  YUGOAI Agent — Standalone Installer (curl-pipe friendly)
# ============================================================
#  Usage:
#    curl -fsSL https://raw.githubusercontent.com/USER/yugoai-agent/main/install.sh | bash
#
#  Or locally:
#    ./install.sh
# ============================================================
set -euo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

YUGOAI_HOME="${YUGOAI_HOME:-${HOME}/YUGOAI}"
LOCAL_BIN="${HOME}/.local/bin"
HERMES_INSTALL_URL="https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh"

banner() {
    echo ""
    echo -e "${CYAN}${BOLD}   ⚡ YUGOAI Agent Installer${NC}"
    echo -e "${CYAN}   ============================${NC}"
    echo ""
}

info()  { echo -e "   ${CYAN}→${NC} $*"; }
ok()    { echo -e "   ${GREEN}✓${NC} $*"; }
warn()  { echo -e "   ${YELLOW}!${NC} $*"; }
fail()  { echo -e "   ${RED}✗${NC} $*"; }

# ─── Determine OS ───────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin)  OS="macos" ;;
        Linux)   OS="linux" ;;
        *)
            fail "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

# ─── Install Hermes if missing ──────────────────────────────
ensure_hermes() {
    if command -v hermes &>/dev/null; then
        ok "Hermes Agent already installed: $(hermes --version 2>/dev/null | head -1)"
        return 0
    fi

    info "Hermes Agent not found. Installing..."
    
    if command -v curl &>/dev/null; then
        curl -fsSL "$HERMES_INSTALL_URL" | bash
    elif command -v wget &>/dev/null; then
        wget -qO- "$HERMES_INSTALL_URL" | bash
    else
        fail "Neither curl nor wget found. Install one and retry."
        exit 1
    fi

    # Verify
    if ! command -v hermes &>/dev/null; then
        # Hermes installer puts it in ~/.local/bin
        export PATH="${HOME}/.local/bin:${PATH}"
        if ! command -v hermes &>/dev/null; then
            fail "Hermes installation failed. Install manually:"
            echo "     curl -fsSL $HERMES_INSTALL_URL | bash"
            exit 1
        fi
    fi

    ok "Hermes Agent installed: $(hermes --version 2>/dev/null | head -1)"
}

# ─── Setup PATH ─────────────────────────────────────────────
ensure_path() {
    mkdir -p "$LOCAL_BIN"

    if [[ ":$PATH:" == *":$LOCAL_BIN:"* ]]; then
        return 0
    fi

    warn "$LOCAL_BIN is not in your PATH."

    # Detect shell config
    local shell_rc=""
    case "$SHELL" in
        */zsh)  shell_rc="$HOME/.zshrc" ;;
        */bash) shell_rc="$HOME/.bashrc" ;;
        *)      shell_rc="$HOME/.profile" ;;
    esac

    if [ -f "$shell_rc" ]; then
        if ! grep -q "$LOCAL_BIN" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# Added by YUGOAI Agent installer" >> "$shell_rc"
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$shell_rc"
            ok "Added $LOCAL_BIN to $shell_rc"
        fi
    fi

    export PATH="$LOCAL_BIN:$PATH"
}

# ─── Install YUGOAI wrapper ─────────────────────────────────
install_wrapper() {
    info "Installing yugoai CLI wrapper..."

    cat > "$LOCAL_BIN/yugoai" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# YUGOAI Agent — white-label CLI wrapper for Hermes
set -euo pipefail

HERMES_BIN="${HERMES_BIN:-hermes}"
YUGOAI_PROFILE="${YUGOAI_PROFILE:-yugoai}"

if ! command -v "$HERMES_BIN" &>/dev/null; then
    echo "Error: Hermes Agent not found."
    echo "Install: curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
    exit 1
fi

exec "$HERMES_BIN" -p "$YUGOAI_PROFILE" "$@"
WRAPPER_EOF

    chmod +x "$LOCAL_BIN/yugoai"
    ok "Wrapper installed: $LOCAL_BIN/yugoai"
}

# ─── Create YUGOAI profile ──────────────────────────────────
create_profile() {
    if hermes profile list 2>/dev/null | grep -q "^◆yugoai "; then
        info "YUGOAI profile already exists"
        return 0
    fi

    info "Creating YUGOAI profile (cloning from default)..."
    hermes profile create yugoai --clone 2>&1 | tail -1
    ok "YUGOAI profile created"
}

# ─── Lock to DeepSeek ───────────────────────────────────────
lock_deepseek() {
    local profile_env="$HOME/.hermes/profiles/yugoai/.env"

    info "Locking YUGOAI to DeepSeek..."

    hermes -p yugoai config set model.provider deepseek 2>/dev/null || true
    hermes -p yugoai config set model.default deepseek-v4-pro 2>/dev/null || true
    hermes -p yugoai config set model.base_url https://api.deepseek.com 2>/dev/null || true
    hermes -p yugoai config set fallback_providers '[]' 2>/dev/null || true

    # Set API key in profile .env
    if grep -q "^DEEPSEEK_API_KEY=" "$profile_env" 2>/dev/null; then
        sed -i '' "s/^DEEPSEEK_API_KEY=.*/DEEPSEEK_API_KEY=sk-48083dad492f4e32b657cfcd2367d5f9/" "$profile_env" 2>/dev/null || \
        sed -i "s/^DEEPSEEK_API_KEY=.*/DEEPSEEK_API_KEY=sk-48083dad492f4e32b657cfcd2367d5f9/" "$profile_env" 2>/dev/null
    else
        echo "DEEPSEEK_API_KEY=***" >> "$profile_env"
    fi

    ok "Locked to DeepSeek (deepseek-v4-pro)"
}

# ─── Install YUGOAI skin ────────────────────────────────────
install_skin() {
    local skin_dir="$HOME/.hermes/profiles/yugoai/skins"
    local skin_src="$YUGOAI_HOME/skins/yugoai.yaml"

    mkdir -p "$skin_dir"

    if [ -f "$skin_src" ]; then
        cp "$skin_src" "$skin_dir/yugoai.yaml"
        hermes -p yugoai config set display.skin yugoai 2>/dev/null || true
        ok "YUGOAI skin installed"
    else
        # Self-contained: write skin from heredoc
        cat > "$skin_dir/yugoai.yaml" << 'SKINEOF'
# YUGOAI Agent Skin
name: yugoai
description: "YUGOAI — DeepSeek-powered AI agent"

colors:
  banner_border: "#00BFFF"
  banner_title: "#00BFFF"
  banner_accent: "#1E90FF"
  banner_dim: "#00688B"
  banner_text: "#E0F0FF"
  ui_accent: "#1E90FF"
  ui_label: "#00BFFF"
  ui_ok: "#4caf50"
  ui_error: "#ef5350"
  ui_warn: "#ffa726"
  prompt: "#E0F0FF"
  input_rule: "#00BFFF"
  response_border: "#1E90FF"
  status_bar_bg: "#0A1628"
  session_label: "#00BFFF"
  session_border: "#5A7A8C"

branding:
  agent_name: "YUGOAI Agent"
  welcome: "Welcome to YUGOAI Agent! Type your message or /help for commands."
  goodbye: "Goodbye! YUGOAI out."
  response_label: " YUGOAI "
  prompt_symbol: "❯"
  help_header: "Available Commands"

banner_logo: |
  [bold #00BFFF]██╗   ██╗██╗   ██╗ ██████╗  ██████╗       ██╗      █████╗ ██████╗ ███████╗[/]
  [bold #00BFFF]╚██╗ ██╔╝██║   ██║██╔════╝ ██╔═══██╗      ██║     ██╔══██╗██╔══██╗██╔════╝[/]
  [#1E90FF] ╚████╔╝ ██║   ██║██║  ███╗██║   ██║█████╗██║     ███████║██████╔╝███████╗[/]
  [#1E90FF]  ╚██╔╝  ██║   ██║██║   ██║██║   ██║╚════╝██║     ██╔══██║██╔══██╗╚════██║[/]
  [#00688B]   ██║   ╚██████╔╝╚██████╔╝╚██████╔╝      ███████╗██║  ██║██████╔╝███████║[/]
  [#00688B]   ╚═╝    ╚═════╝  ╚═════╝  ╚═════╝       ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝[/]
  [#1E90FF]       █████╗ ██╗[/]
  [#1E90FF]      ██╔══██╗██║[/]
  [#00688B]█████╗███████║██║[/]
  [#00688B]╚════╝██╔══██║██║[/]
  [#00BFFF]      ██║  ██║██║[/]
  [#00BFFF]      ╚═╝  ╚═╝╚═╝[/]

banner_hero: |
  [#00BFFF]▐▛███▜▌[/]
  [#00BFFF]▐▌[/]
  [#00BFFF]▐▌   Y U G O L A B S - A I   [/]
  [#00BFFF]▐▌[/]
  [#00688B]▐▙███▟▌[/]
SKINEOF
        hermes -p yugoai config set display.skin yugoai 2>/dev/null || true
        ok "YUGOAI skin installed (built-in)"
    fi
}

# ─── Rebrand engine banner ──────────────────────────────────
rebrand_engine() {
    local banner_py
    banner_py=$(python3 -c "import hermes_cli.banner; print(hermes_cli.banner.__file__)" 2>/dev/null) || true

    if [ -z "$banner_py" ] || [ ! -f "$banner_py" ]; then
        warn "Could not find banner.py, skipping engine rebrand"
        return 0
    fi

    info "Rebranding engine banner..."

    # "Hermes Agent v" -> "YUGOAI Agent v" in version label (inside f-string)
    if grep -q 'Hermes Agent v' "$banner_py" 2>/dev/null; then
        sed -i '' 's/Hermes Agent v/YUGOAI Agent v/g' "$banner_py" 2>/dev/null || \
        sed -i 's/Hermes Agent v/YUGOAI Agent v/g' "$banner_py" 2>/dev/null
    fi

    # "Nous Research" -> "Yugo-Labs-AI" in provider label (inside f-string)
    if grep -q 'Nous Research' "$banner_py" 2>/dev/null; then
        sed -i '' 's/Nous Research/Yugo-Labs-AI/g' "$banner_py" 2>/dev/null || \
        sed -i 's/Nous Research/Yugo-Labs-AI/g' "$banner_py" 2>/dev/null
    fi

    ok "Engine banner rebranded"
}

# ─── Main ───────────────────────────────────────────────────
main() {
    banner
    detect_os

    info "OS detected: $OS"
    echo ""

    ensure_path
    echo ""
    ensure_hermes
    echo ""
    install_wrapper
    echo ""
    create_profile
    echo ""
    lock_deepseek
    echo ""
    install_skin
    echo ""
    rebrand_engine
    echo ""

    echo -e "${GREEN}${BOLD}   ⚡ Installation complete!${NC}"
    echo ""
    echo "   YUGOAI ready. Langsung pakai:"
    echo -e "     ${BOLD}yugoai${NC}                  Interactive chat"
    echo -e "     ${BOLD}yugoai chat -q '...'${NC}   Single query"
    echo ""
}

main "$@"
