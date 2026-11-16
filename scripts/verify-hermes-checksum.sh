#!/bin/bash
# Helper script to verify and configure Hermes installer checksum
# This script downloads the official Hermes installer and calculates its SHA256 checksum.
# Usage: ./scripts/verify-hermes-checksum.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$REPO_ROOT/config-files/config.yaml"

echo "MiniRack AI Lab - Hermes Installer Checksum Verification"
echo "========================================================"
echo ""

# Download and verify the Hermes installer
echo "Downloading Hermes installer from official source..."
INSTALLER_URL="https://hermes-agent.nousresearch.com/install.sh"
INSTALLER_PATH="/tmp/hermes-install-verify.sh"

if ! curl -sL -o "$INSTALLER_PATH" "$INSTALLER_URL"; then
    echo "ERROR: Failed to download Hermes installer from $INSTALLER_URL"
    echo "Please check your internet connection and try again."
    exit 1
fi

# Calculate checksum
echo "Calculating SHA256 checksum..."
CHECKSUM=$(sha256sum "$INSTALLER_PATH" | awk '{print $1}')

echo ""
echo "✓ Checksum calculated successfully:"
echo "  SHA256: $CHECKSUM"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found at $CONFIG_FILE"
    exit 1
fi

# Display current configuration
echo "Current configuration in $CONFIG_FILE:"
grep hermes_install_checksum "$CONFIG_FILE" || echo "  (not yet configured)"
echo ""

echo "To update your configuration:"
echo "  1. Edit $CONFIG_FILE"
echo "  2. Find the line: hermes_install_checksum: \"sha256:PLACEHOLDER_CHECKSUM_VALUE\""
echo "  3. Replace with: hermes_install_checksum: \"sha256:$CHECKSUM\""
echo ""

# Cleanup
rm "$INSTALLER_PATH"
echo "✓ Verification complete! (temporary installer deleted)"
echo ""
echo "Next: Update config.yaml and run deployment with:"
echo "  ./scripts/ansible-execute.bash"
