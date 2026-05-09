#!/usr/bin/env bash
#
# fwqaaq/dot bootstrap installer
#
# Usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/fwqaaq/dot/main/install.sh)"
#
# Environment variables:
#   ASSUME_YES=1      answer "yes" to every prompt (non-interactive mode)
#   SKIP_DEBIAN=1     skip the debian.sh bootstrap on Linux

set -uo pipefail

# ============================================================
# Constants
# ============================================================
readonly REPO_URL="https://github.com/fwqaaq/dot.git"
readonly REPO_RAW="https://raw.githubusercontent.com/fwqaaq/dot/main"
readonly OHMYZSH_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
readonly NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh"
readonly TPM_URL="https://github.com/tmux-plugins/tpm"
readonly P10K_URL="https://github.com/romkatv/powerlevel10k.git"
readonly NVIM_RELEASE_BASE="https://github.com/neovim/neovim/releases/download/stable"

# zsh plugin name -> repo url
ZSH_PLUGIN_NAMES=(
	zsh-autosuggestions
	zsh-history-substring-search
	zsh-syntax-highlighting
)
ZSH_PLUGIN_URLS=(
	"https://github.com/zsh-users/zsh-autosuggestions"
	"https://github.com/zsh-users/zsh-history-substring-search"
	"https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

# ============================================================
# Logging (all to stderr so $(fn) captures don't pick them up)
# ============================================================
info()    { printf '\033[32m[INFO]\033[0m  %s\n' "$*" >&2; }
warn()    { printf '\033[33m[WARN]\033[0m  %s\n' "$*" >&2; }
error()   { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; }
success() { printf '\033[42;30m %s \033[0m\n'        "$*" >&2; }
step()    { printf '\n\033[1;36m==> %s\033[0m\n'     "$*" >&2; }

print_banner() {
	cat >&2 <<'EOF'

                 ____ _____  _    ____ _____
          __/\__/ ___|_   _|/ \  |  _ \_   _|_/\__
          \    /\___ \ | | / _ \ | |_) || | \    /
          /_  _\ ___) || |/ ___ \|  _ < | | /_  _\
            \/  |____/ |_/_/   \_\_| \_\|_|   \/

EOF
}

# ============================================================
# Generic helpers
# ============================================================
require_cmd() {
	if ! command -v "$1" >/dev/null 2>&1; then
		error "Required command not found: $1"
		return 1
	fi
}

# Read y/n from terminal even when stdin is a pipe (curl | bash).
confirm() {
	local prompt="${1:-Continue?}"
	local answer

	if [[ "${ASSUME_YES:-0}" == "1" ]]; then
		info "$prompt -> auto-yes (ASSUME_YES=1)"
		return 0
	fi

	if [[ -t 0 ]]; then
		read -r -p "$prompt (y/n) " answer
	elif [[ -r /dev/tty ]]; then
		read -r -p "$prompt (y/n) " answer </dev/tty
	else
		warn "No TTY available; skipping: $prompt"
		return 1
	fi

	[[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

ensure_dir() {
	[[ -d "$1" ]] || mkdir -p "$1"
}

# Move existing path aside with a timestamped suffix (idempotent re-runs).
backup_path() {
	local target="$1"
	if [[ -e "$target" || -L "$target" ]]; then
		local backup="${target}.bak.$(date +%Y%m%d-%H%M%S)"
		info "Backing up $target -> $backup"
		mv "$target" "$backup"
	fi
}

clone_shallow() {
	local url="$1" dest="$2"
	if [[ -d "$dest" ]]; then
		info "Skip clone (already exists): $dest"
		return 0
	fi
	info "Cloning $url -> $dest"
	git clone --depth=1 "$url" "$dest"
}

# ============================================================
# Platform detection
# ============================================================
detect_os() {
	case "$(uname -s)" in
		Linux)  echo linux ;;
		Darwin) echo macos ;;
		*)      echo unknown ;;
	esac
}

detect_arch() {
	case "$(uname -m)" in
		x86_64|amd64)   echo x86_64 ;;
		aarch64|arm64)  echo arm64 ;;
		*)              echo unknown ;;
	esac
}

nvim_archive_name() {
	case "$(detect_os)/$(detect_arch)" in
		linux/x86_64) echo "nvim-linux-x86_64.tar.gz" ;;
		linux/arm64)  echo "nvim-linux-arm64.tar.gz" ;;
		macos/x86_64) echo "nvim-macos-x86_64.tar.gz" ;;
		macos/arm64)  echo "nvim-macos-arm64.tar.gz" ;;
		*)            error "Unsupported platform: $(uname -s)/$(uname -m)"; return 1 ;;
	esac
}

# ============================================================
# Repo cache (clone once, reused by nvim & ghostty installers)
# ============================================================
REPO_CACHE=""

get_repo_cache() {
	if [[ -z "$REPO_CACHE" || ! -d "$REPO_CACHE" ]]; then
		REPO_CACHE="$(mktemp -d)"
		info "Cloning dotfiles to cache: $REPO_CACHE"
		git clone --depth=1 "$REPO_URL" "$REPO_CACHE" >&2
	fi
	echo "$REPO_CACHE"
}

cleanup() {
	if [[ -n "$REPO_CACHE" && -d "$REPO_CACHE" ]]; then
		rm -rf "$REPO_CACHE"
	fi
}
trap cleanup EXIT

# ============================================================
# Component installers
# ============================================================

ensure_zsh_default_shell() {
	if [[ "${SHELL##*/}" == "zsh" ]]; then
		return 0
	fi
	if ! command -v zsh >/dev/null 2>&1; then
		error "zsh is not installed. Install it first."
		return 1
	fi
	if chsh -s "$(command -v zsh)"; then
		warn "Default shell changed to zsh. Log out and back in to apply."
	else
		warn "chsh failed. Run 'chsh -s $(command -v zsh)' manually."
	fi
}

install_oh_my_zsh() {
	local zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
	if [[ -f "$zsh_dir/oh-my-zsh.sh" ]]; then
		info "oh-my-zsh already installed"
		export ZSH="$zsh_dir"
		return 0
	fi
	info "Installing oh-my-zsh"
	# RUNZSH=no  : do not switch into zsh after install
	# CHSH=no    : do not change login shell here (we handle it)
	RUNZSH=no CHSH=no sh -c "$(curl -fsSL "$OHMYZSH_URL")"
	export ZSH="$HOME/.oh-my-zsh"
}

install_zshrc_and_p10k() {
	info "Downloading .zshrc and .p10k.zsh"
	curl -fsSL "$REPO_RAW/.zshrc"    -o "$HOME/.zshrc"
	curl -fsSL "$REPO_RAW/.p10k.zsh" -o "$HOME/.p10k.zsh"
}

install_zsh_plugins() {
	if [[ -z "${ZSH:-}" ]]; then
		error "\$ZSH is not set; install oh-my-zsh first."
		return 1
	fi
	local custom="$ZSH/custom"
	ensure_dir "$custom/plugins"
	ensure_dir "$custom/themes"

	local i
	for i in "${!ZSH_PLUGIN_NAMES[@]}"; do
		clone_shallow "${ZSH_PLUGIN_URLS[$i]}" "$custom/plugins/${ZSH_PLUGIN_NAMES[$i]}"
	done
	clone_shallow "$P10K_URL" "$custom/themes/powerlevel10k"
}

install_node_via_nvm() {
	if command -v nvm >/dev/null 2>&1; then
		info "nvm already available; skipping installer"
	else
		info "Installing nvm (PROFILE=/dev/null to avoid touching .zshrc)"
		# Repo .zshrc already sources nvm; don't let installer append duplicates.
		curl -fsSL "$NVM_URL" | PROFILE=/dev/null bash
	fi

	export NVM_DIR="$HOME/.nvm"
	# shellcheck disable=SC1091
	[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"

	if ! command -v nvm >/dev/null 2>&1; then
		error "nvm function not loadable in current shell."
		return 1
	fi

	info "Installing latest LTS Node"
	nvm install --lts
	nvm use --lts

	if ! command -v pnpm >/dev/null 2>&1; then
		info "Installing pnpm globally"
		npm install -g pnpm
	fi

	info "node $(node -v)  pnpm $(pnpm -v)"
}

install_tmux_config() {
	if ! command -v tmux >/dev/null 2>&1; then
		warn "tmux is not installed; skipping tmux config."
		return 1
	fi
	info "Installing ~/.tmux.conf"
	curl -fsSL "$REPO_RAW/.tmux.conf" -o "$HOME/.tmux.conf"
	clone_shallow "$TPM_URL" "$HOME/.tmux/plugins/tpm"
	warn "Open tmux and press 'Ctrl-a' + 'Shift-i' to install tpm plugins."
}

install_nvim_binary() {
	if command -v nvim >/dev/null 2>&1; then
		info "nvim already installed: $(nvim --version | head -1)"
		return 0
	fi

	# Prefer Homebrew on macOS when available.
	if [[ "$(detect_os)" == "macos" ]] && command -v brew >/dev/null 2>&1; then
		info "Installing neovim via Homebrew"
		brew install neovim
		return 0
	fi

	local archive_name url tmp_archive extract_dir
	archive_name="$(nvim_archive_name)" || return 1
	url="$NVIM_RELEASE_BASE/$archive_name"
	tmp_archive="$(mktemp)"
	extract_dir="${archive_name%.tar.gz}"

	info "Downloading $url"
	curl -fsSL -o "$tmp_archive" "$url"

	info "Extracting to /opt/$extract_dir"
	sudo mkdir -p /opt
	sudo tar -xzf "$tmp_archive" -C /opt/
	sudo ln -sf "/opt/$extract_dir/bin/nvim" /usr/local/bin/nvim
	rm -f "$tmp_archive"

	info "nvim installed: $(nvim --version | head -1)"
}

install_nvim_config() {
	ensure_dir "$HOME/.config"
	backup_path "$HOME/.config/nvim"
	local cache
	cache="$(get_repo_cache)"
	cp -R "$cache/.config/nvim" "$HOME/.config/nvim"
	info "nvim config installed at ~/.config/nvim"
}

install_ghostty_config() {
	ensure_dir "$HOME/.config"
	backup_path "$HOME/.config/ghostty"
	local cache
	cache="$(get_repo_cache)"
	cp -R "$cache/.config/ghostty" "$HOME/.config/ghostty"
	info "ghostty config installed at ~/.config/ghostty"
}

# ============================================================
# Main flow
# ============================================================
main() {
	print_banner

	require_cmd git  || exit 1
	require_cmd curl || exit 1

	# Linux: optionally run distro-specific bootstrap (apt, etc.)
	if [[ "$(detect_os)" == "linux" && "${SKIP_DEBIAN:-0}" != "1" ]]; then
		if confirm "Run debian.sh (apt packages bootstrap)?"; then
			bash -c "$(curl -fsSL "$REPO_RAW/debian.sh")" || warn "debian.sh exited non-zero"
		fi
	fi

	step "1/5  zsh + oh-my-zsh + .zshrc + plugins"
	ensure_zsh_default_shell || true
	install_oh_my_zsh

	if confirm "Overwrite ~/.zshrc and ~/.p10k.zsh from repo?"; then
		install_zshrc_and_p10k
	elif [[ ! -f "$HOME/.zshrc" ]]; then
		error "No ~/.zshrc found; you must generate one before continuing."
		exit 1
	fi
	install_zsh_plugins

	step "2/5  nvm + Node LTS + pnpm"
	if confirm "Install nvm, Node LTS, and pnpm?"; then
		install_node_via_nvm || warn "node/nvm install failed; continuing"
	fi

	step "3/5  tmux config + tpm"
	if confirm "Install ~/.tmux.conf and tpm?"; then
		install_tmux_config || warn "tmux config install failed; continuing"
	fi

	step "4/5  Neovim binary + config"
	if confirm "Install Neovim and its config?"; then
		install_nvim_binary  || warn "nvim binary install failed; continuing"
		install_nvim_config  || warn "nvim config install failed; continuing"
	fi

	step "5/5  Ghostty config"
	if confirm "Install Ghostty config?"; then
		install_ghostty_config || warn "ghostty config install failed; continuing"
	fi

	success "All done! Run: source ~/.zshrc  (or restart your terminal)"
}

main "$@"
