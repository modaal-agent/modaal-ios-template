#!/bin/bash

set -e

debug_log() {
  if [ "$DEBUG" = "1" ]; then
    echo "[DEBUG] $*" >&2
  fi
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
debug_log "SCRIPT_DIR=$SCRIPT_DIR"

# Print module name which failed
error_handler() {
    echo -e "\033[1;31mError occurred while testing $SCHEME_NAME\033[0m"
    echo -e "To continue, run following command:"
    echo -e "\033[1;33m./test_ios.sh $SCHEME_NAME $END_MODULE\033[0m"
    exit 1
}

# Trap any error
trap 'error_handler' ERR

git config --local alias.root 'rev-parse --show-toplevel'
GIT_ROOT=$(git root)

# Shared build artifacts path (allows reuse across modules)
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$GIT_ROOT/.build}"
debug_log "DERIVED_DATA_PATH=$DERIVED_DATA_PATH"

# Helper to install a brew package if missing
install_if_missing() {
  local cmd="$1"
  local pkg="${2:-$1}"

  debug_log "Checking for $cmd..."
  if ! command -v "$cmd" >/dev/null 2>&1; then
    debug_log "$cmd not found, installing $pkg..."
    if ! "$BREW" install "$pkg" 2>&1; then
      echo "ERROR: Failed to install $pkg" >&2
      exit $EXIT_BREW_INSTALL_FAILED
    fi
  else
    debug_log "$cmd already installed at $(command -v "$cmd")"
  fi
}

install_if_missing mint
mint bootstrap -m "$SCRIPT_DIR/.mintfile"
debug_log "Prerequisites check complete"

TEST_TARGETS=(
    "$GIT_ROOT/src-ios/Libraries/MyAppMain"
    "$GIT_ROOT/src-ios/Libraries/Theming"
    "$GIT_ROOT/src-ios/SharedLibraries/CloudStorage"
    "$GIT_ROOT/src-ios/SharedLibraries/Diagnostics"
    "$GIT_ROOT/src-ios/SharedLibraries/FirAppConfigure"
    "$GIT_ROOT/src-ios/SharedLibraries/RxExtensions"
    "$GIT_ROOT/src-ios/SharedLibraries/SharedUtility"
    "$GIT_ROOT/src-ios/SharedLibraries/SimpleTheming"
    "$GIT_ROOT/src-ios/SharedLibraries/Storage"
    "$GIT_ROOT/src-ios/SharedLibraries/StringCodable"
)

START_MODULE="$1"
END_MODULE="$2"
MODULE_FOUND=false
END_MODULE_FOUND=false

# If no module specified, start from the beginning
if [ -z "$START_MODULE" ]; then
    MODULE_FOUND=true
fi

for target in "${TEST_TARGETS[@]}"; do
    scheme_name=$(basename "$target")

    # Check if we should start processing (find start module)
    if [ -n "$START_MODULE" ] && [ "$MODULE_FOUND" = false ]; then
        if [ "$scheme_name" = "$START_MODULE" ]; then
            MODULE_FOUND=true
        else
            continue
        fi
    fi

    # Check if we should stop processing (find end module)
    if [ -n "$END_MODULE" ] && [ "$END_MODULE_FOUND" = false ]; then
        if [ "$scheme_name" = "$END_MODULE" ]; then
            END_MODULE_FOUND=true
        fi
    elif [ -n "$END_MODULE" ] && [ "$END_MODULE_FOUND" = true ]; then
        # Stop after processing the end module
        break
    fi

    cd "$target"

    echo "----------------------------------------"
    echo ""
    echo -e "\033[1;33mTesting $scheme_name\033[0m"
    echo ""
    echo "----------------------------------------"

    set -o pipefail && xcodebuild test \
        -scheme "$scheme_name" \
        -derivedDataPath "$DERIVED_DATA_PATH/DerivedData" \
        -clonedSourcePackagesDirPath "$DERIVED_DATA_PATH/SourcePackages" \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro,arch=arm64' \
        -configuration "Debug" \
        -sdk "iphonesimulator" \
        -skipPackagePluginValidation \
        | mint run cpisciotta/xcbeautify --disable-colored-output --is-ci --disable-logging -q

    cd "$GIT_ROOT"
done

if [ "$MODULE_FOUND" = false ]; then
    echo -e "\033[1;31mError: Module $START_MODULE not found in TEST_TARGETS\033[0m"
    exit 1
fi

# Check if end module was specified but not found
if [ -n "$END_MODULE" ] && [ "$END_MODULE_FOUND" = false ]; then
    echo -e "\033[1;31mError: End module $END_MODULE not found in TEST_TARGETS\033[0m"
    exit 1
fi
