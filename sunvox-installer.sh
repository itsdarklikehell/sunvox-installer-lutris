#!/usr/bin/env bash
#
# sunvox-installer.sh — SunVox installer for Linux
#
# Downloads and installs SunVox from the official warmplace.ru server.
# Supports x86_64 and ARM architectures.
#
# Usage:
#   ./sunvox-installer.sh [OPTIONS] [VERSION]
#
# Options:
#   -h, --help      Show this help message
#   -v, --version   Show script version
#   -u, --uninstall Remove SunVox installation
#   -d, --dry-run   Show what would be done without making changes
#
# Examples:
#   ./sunvox-installer.sh 2.1.1c
#   ./sunvox-installer.sh --uninstall
#   ./sunvox-installer.sh --dry-run 2.1.1c
#

set -euo pipefail

# ── Constants ──────────────────────────────────────────────────────────────────
readonly SCRIPT_VERSION="2.0.0"
readonly INSTALL_DIR="/opt/sunvox"
readonly BIN_DIR="/usr/local/bin"
readonly DESKTOP_DIR="/usr/share/applications"
readonly DOWNLOAD_BASE="https://warmplace.ru/soft/sunvox"
readonly ICON_URL="https://warmplace.ru/soft/sunvox/images/icon.png"
readonly LOG_FILE="/tmp/sunvox-installer.log"

# ── Colors ─────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly NC=''
fi

# ── Logging ────────────────────────────────────────────────────────────────────
log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    log "INFO" "$*"
}

success() {
    echo -e "${GREEN}[OK]${NC} $*"
    log "OK" "$*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
    log "WARN" "$*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    log "ERROR" "$*"
}

die() {
    error "$*"
    exit 1
}

# ── Help ───────────────────────────────────────────────────────────────────────
show_help() {
    cat <<EOF
SunVox Installer v${SCRIPT_VERSION}

Usage: $(basename "$0") [OPTIONS] [VERSION]

Downloads and installs SunVox from the official warmplace.ru server.

Arguments:
  VERSION         SunVox version to install (e.g., 2.1.1c)

Options:
  -h, --help      Show this help message
  -v, --version   Show script version
  -u, --uninstall Remove SunVox installation
  -d, --dry-run   Show what would be done without making changes

Examples:
  $(basename "$0") 2.1.1c          Install SunVox 2.1.1c
  $(basename "$0") --uninstall     Remove SunVox
  $(basename "$0") --dry-run 2.1.1c  Preview installation steps

Log file: ${LOG_FILE}
EOF
}

show_version() {
    echo "sunvox-installer.sh version ${SCRIPT_VERSION}"
}

# ── Architecture Detection ────────────────────────────────────────────────────
detect_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            echo "linux_x86_64"
            ;;
        aarch64|arm64)
            echo "linux_arm64"
            ;;
        armv7l|armv6l)
            echo "linux_arm"
            ;;
        *)
            die "Unsupported architecture: $arch"
            ;;
    esac
}

# ── Dependency Checks ─────────────────────────────────────────────────────────
check_dependencies() {
    local missing=()
    local deps=("wget" "unzip" "curl")

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing required tools: ${missing[*]}. Install them and retry."
    fi
}

# ── Version Validation ────────────────────────────────────────────────────────
validate_version() {
    local version="$1"
    if [[ -z "$version" ]]; then
        die "No version specified. Use --help for usage."
    fi
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?[a-z]?$ ]]; then
        die "Invalid version format: '$version'. Expected format: X.Y.Z[a-z] (e.g., 2.1.1c)"
    fi
}

# ── Download with Retry ───────────────────────────────────────────────────────
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry=0

    while [[ $retry -lt $max_retries ]]; do
        info "Downloading $url (attempt $((retry + 1))/$max_retries)"
        if wget --timeout=30 --tries=1 -q --show-progress -O "$output" "$url" 2>/dev/null; then
            success "Download complete: $output"
            return 0
        fi
        warn "Download failed, retrying..."
        retry=$((retry + 1))
        sleep 2
    done

    die "Failed to download $url after $max_retries attempts"
}

# ── Uninstall ─────────────────────────────────────────────────────────────────
uninstall() {
    info "Uninstalling SunVox..."

    if [[ -d "$INSTALL_DIR" ]]; then
        sudo rm -rf "$INSTALL_DIR"
        success "Removed $INSTALL_DIR"
    fi

    local symlinks=("sunvox" "sunvox_opengl")
    for link in "${symlinks[@]}"; do
        local path="${BIN_DIR}/${link}"
        if [[ -L "$path" ]]; then
            sudo rm -f "$path"
            success "Removed symlink $path"
        fi
    done

    local desktop_files=("sunvox.desktop" "sunvox-opengl.desktop" "sunvox-fix.desktop")
    for file in "${desktop_files[@]}"; do
        local path="${DESKTOP_DIR}/${file}"
        if [[ -f "$path" ]]; then
            sudo rm -f "$path"
            success "Removed desktop file $path"
        fi
    done

    success "SunVox has been uninstalled."
}

# ── Install ───────────────────────────────────────────────────────────────────
install() {
    local version="$1"
    local dry_run="${2:-false}"
    local arch
    arch=$(detect_arch)

    info "Installing SunVox $version for $arch"

    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN — no changes will be made"
        echo "  Would download: ${DOWNLOAD_BASE}/sunvox-${version}.zip"
        echo "  Would download: ${ICON_URL}"
        echo "  Would install to: ${INSTALL_DIR}"
        echo "  Would create symlinks in: ${BIN_DIR}"
        echo "  Would create desktop files in: ${DESKTOP_DIR}"
        return 0
    fi

    # Check if already installed
    if [[ -d "$INSTALL_DIR" ]]; then
        warn "Existing installation found at $INSTALL_DIR"
        warn "Removing previous version..."
        sudo rm -rf "$INSTALL_DIR"
    fi

    # Clean up old symlinks
    for link in sunvox sunvox_opengl; do
        local path="${BIN_DIR}/${link}"
        if [[ -L "$path" ]]; then
            sudo rm -f "$path"
        fi
    done

    # Clean up old desktop files
    for file in sunvox.desktop sunvox-opengl.desktop sunvox-fix.desktop; do
        local path="${DESKTOP_DIR}/${file}"
        if [[ -f "$path" ]]; then
            sudo rm -f "$path"
        fi
    done

    # Create temp directory
    local tmpdir
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    # Download
    local zipfile="${tmpdir}/sunvox-${version}.zip"
    download_with_retry "${DOWNLOAD_BASE}/sunvox-${version}.zip" "$zipfile"

    local iconfile="${tmpdir}/icon.png"
    download_with_retry "${ICON_URL}" "$iconfile"

    # Verify download
    if [[ ! -f "$zipfile" ]] || [[ ! -s "$zipfile" ]]; then
        die "Downloaded zip file is missing or empty"
    fi

    # Extract
    info "Extracting SunVox..."
    unzip -q "$zipfile" -d "$tmpdir"
    if [[ ! -d "${tmpdir}/sunvox" ]]; then
        die "Extraction failed: sunvox directory not found in archive"
    fi

    # Install
    info "Installing to $INSTALL_DIR..."
    sudo mkdir -p "$INSTALL_DIR"
    sudo cp -r "${tmpdir}/sunvox/"* "$INSTALL_DIR/"
    sudo cp "$iconfile" "$INSTALL_DIR/icon.png"

    # Set permissions
    sudo chown -R root:root "$INSTALL_DIR"
    sudo chmod -R 755 "$INSTALL_DIR"

    # Create symlinks
    local sunvox_bin="${INSTALL_DIR}/sunvox/${arch}/sunvox"
    local sunvox_opengl_bin="${INSTALL_DIR}/sunvox/${arch}/sunvox_opengl"

    if [[ ! -f "$sunvox_bin" ]]; then
        die "SunVox binary not found at $sunvox_bin"
    fi

    sudo ln -sf "$sunvox_bin" "${BIN_DIR}/sunvox"
    success "Created symlink: ${BIN_DIR}/sunvox"

    if [[ -f "$sunvox_opengl_bin" ]]; then
        sudo ln -sf "$sunvox_opengl_bin" "${BIN_DIR}/sunvox_opengl"
        success "Created symlink: ${BIN_DIR}/sunvox_opengl"
    fi

    # Create desktop files
    info "Creating desktop entries..."

    sudo tee "${DESKTOP_DIR}/sunvox.desktop" > /dev/null <<EOF
[Desktop Entry]
Name=SunVox
Comment=Modular synthesizer with pattern-based sequencer
Exec=${INSTALL_DIR}/sunvox/${arch}/sunvox
Icon=${INSTALL_DIR}/icon.png
Type=Application
Categories=Audio;Music;Midi;Sequencer;
Keywords=synth;music;midi;tracker;
Terminal=false
StartupNotify=true
EOF

    sudo tee "${DESKTOP_DIR}/sunvox-opengl.desktop" > /dev/null <<EOF
[Desktop Entry]
Name=SunVox (OpenGL)
Comment=Modular synthesizer with pattern-based sequencer (OpenGL renderer)
Exec=${INSTALL_DIR}/sunvox/${arch}/sunvox_opengl
Icon=${INSTALL_DIR}/icon.png
Type=Application
Categories=Audio;Music;Midi;Sequencer;
Keywords=synth;music;midi;tracker;opengl;
Terminal=false
StartupNotify=true
EOF

    sudo tee "${DESKTOP_DIR}/sunvox-fix.desktop" > / /dev/null <<'EOF'
[Desktop Entry]
Name=SunVox Gnome-Integration
Comment=Fix SunVox window class for GNOME integration
Exec=xdotool search --name 'Sunvox' set_window --class 'Sunvox'
Icon=/opt/sunvox/icon.png
Type=Application
Categories=Utility;
Keywords=gnome;window;fix;
Terminal=false
EOF

    success "Desktop entries created"

    # Cleanup
    rm -rf "$tmpdir"
    trap - EXIT

    echo ""
    success "SunVox $version has been installed successfully!"
    echo ""
    echo "You can now start SunVox with:"
    echo "  sunvox          # Standard version"
    echo "  sunvox_opengl   # OpenGL version"
    echo ""
    echo "Or find it in your application menu under Audio/Music."
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
    local version=""
    local dry_run="false"
    local do_uninstall="false"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -u|--uninstall)
                do_uninstall="true"
                shift
                ;;
            -d|--dry-run)
                dry_run="true"
                shift
                ;;
            -*)
                die "Unknown option: $1. Use --help for usage."
                ;;
            *)
                version="$1"
                shift
                ;;
        esac
    done

    # Initialize log
    echo "=== SunVox Installer v${SCRIPT_VERSION} — $(date) ===" > "$LOG_FILE"

    # Check dependencies
    check_dependencies

    if [[ "$do_uninstall" == "true" ]]; then
        uninstall
        exit 0
    fi

    # Validate version
    validate_version "$version"

    # Install
    install "$version" "$dry_run"
}

main "$@"
