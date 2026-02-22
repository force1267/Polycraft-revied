#!/usr/bin/env bash
#
# Package Polycraft with NW.js into a distributable executable.
# Produces: dist/Polycraft.app (macOS)
#
# Prerequisites: nwjs.app in project root (or set NWJS_PATH)
# Usage: ./build.sh           # include debug toolbar
#        ./build.sh --release # production build, no toolbar

set -e

RELEASE_BUILD=false
[[ "$1" == "--release" ]] && RELEASE_BUILD=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
DIST_DIR="$PROJECT_ROOT/dist"
BUILD_DIR="$PROJECT_ROOT/build"
APP_NAME="Polycraft"
NWJS_APP="${NWJS_PATH:-$PROJECT_ROOT/nwjs.app}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[build]${NC} $*"; }
warn() { echo -e "${YELLOW}[build]${NC} $*"; }
err() { echo -e "${RED}[build]${NC} $*"; exit 1; }

# Check NW.js exists
if [[ ! -d "$NWJS_APP" ]]; then
    err "NW.js app not found at $NWJS_APP. Download from https://nwjs.io and extract, or set NWJS_PATH."
fi

log "Cleaning previous build..."
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

log "Copying app files..."
APP_SRC="$BUILD_DIR/app-src"
mkdir -p "$APP_SRC"

# For release, prepare package.json without toolbar
if $RELEASE_BUILD; then
    log "Release build: disabling debug toolbar"
    sed 's/"toolbar":\s*true/"toolbar": false/' "$PROJECT_ROOT/package.json" > "$BUILD_DIR/package.json.release"
fi

# Copy app files (exclude nwjs, build artifacts, dev files)
rsync -a --exclude='.git' --exclude='.cursor' --exclude='nwjs.app' \
    --exclude='dist' --exclude='build' --exclude='node_modules' \
    --exclude='.DS_Store' --exclude='build.sh' --exclude='*.plan.md' \
    "$PROJECT_ROOT/" "$APP_SRC/"
$RELEASE_BUILD && cp "$BUILD_DIR/package.json.release" "$APP_SRC/package.json"

log "Creating app.nw package..."
cd "$APP_SRC"
zip -r "$BUILD_DIR/app.nw" . -q
cd "$PROJECT_ROOT"

log "Copying NW.js runtime to dist/$APP_NAME.app..."
cp -R "$NWJS_APP" "$DIST_DIR/$APP_NAME.app"

log "Installing app.nw into app bundle..."
cp "$BUILD_DIR/app.nw" "$DIST_DIR/$APP_NAME.app/Contents/Resources/"

# Optional: use game icon for the app (replace default NW.js icon)
if [[ -f "$PROJECT_ROOT/128.png" ]]; then
    log "App icon: 128.png (to customize app icon, replace $APP_NAME.app/Contents/Resources/app.icns)"
fi

log "Build complete: $DIST_DIR/$APP_NAME.app"
log "Run: open $DIST_DIR/$APP_NAME.app"
log "Or: $DIST_DIR/$APP_NAME.app/Contents/MacOS/nwjs"
