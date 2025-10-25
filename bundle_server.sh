#!/bin/bash

# Bundle ClaudeCodeApprovalServer into the app
# This script is called during the Xcode build phase to bundle the approval server

set -e  # Exit on error

echo "Starting to bundle ClaudeCodeApprovalServer..."

# Define paths
PRODUCT_NAME_IN_PACKAGE="ApprovalMCPServer"
SERVER_NAME="ApprovalMCPServer"
BUILD_DIR="${BUILT_PRODUCTS_DIR}"
APP_CONTENTS="${BUILD_DIR}/${PRODUCT_NAME}.app/Contents"
RESOURCES_DIR="${APP_CONTENTS}/Resources"
SERVER_DEST="${RESOURCES_DIR}/${SERVER_NAME}"

# Create Resources directory if it doesn't exist
mkdir -p "${RESOURCES_DIR}"

# Find the package checkout directory - try multiple locations
POSSIBLE_PATHS=(
  "${BUILD_DIR}/../../../SourcePackages/checkouts/ClaudeCodeApprovalServer"
  "${PROJECT_DIR}/../../../SourcePackages/checkouts/ClaudeCodeApprovalServer"
  "${SRCROOT}/../../../SourcePackages/checkouts/ClaudeCodeApprovalServer"
  "${SRCROOT}/build/derived_data/SourcePackages/checkouts/ClaudeCodeApprovalServer"
  ~/Library/Developer/Xcode/DerivedData/*/SourcePackages/checkouts/ClaudeCodeApprovalServer
)

PACKAGE_DIR=""
for path in "${POSSIBLE_PATHS[@]}"; do
  # Expand glob patterns
  for expanded_path in $path; do
    if [ -d "$expanded_path" ]; then
      PACKAGE_DIR="$expanded_path"
      break 2
    fi
  done
done

if [ -z "${PACKAGE_DIR}" ] || [ ! -d "${PACKAGE_DIR}" ]; then
    echo "Error: ClaudeCodeApprovalServer package not found"
    echo "Tried locations:"
    for path in "${POSSIBLE_PATHS[@]}"; do
      echo "  - $path"
    done
    echo "Make sure the package is added to your Xcode project"
    exit 1
fi

echo "Found package at: ${PACKAGE_DIR}"
echo "Building ${PRODUCT_NAME_IN_PACKAGE} from source..."

# Build the executable using swift build
cd "${PACKAGE_DIR}"
swift build -c release --product "${PRODUCT_NAME_IN_PACKAGE}"

# Find the built executable
SERVER_SOURCE="${PACKAGE_DIR}/.build/release/${PRODUCT_NAME_IN_PACKAGE}"

if [ ! -f "${SERVER_SOURCE}" ]; then
    echo "Error: Failed to build ClaudeCodeApprovalServer"
    exit 1
fi

echo "Found server at: ${SERVER_SOURCE}"

# Copy the server to the app bundle
cp "${SERVER_SOURCE}" "${SERVER_DEST}"

# Make sure it's executable
chmod +x "${SERVER_DEST}"

# Sign with hardened runtime and entitlements
echo "Signing ${SERVER_NAME} with hardened runtime..."
codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
  --options runtime \
  --entitlements "${SRCROOT}/Claw/Claw.entitlements" \
  --timestamp \
  "${SERVER_DEST}"

echo "Successfully bundled and signed ClaudeCodeApprovalServer to ${SERVER_DEST}"

# Verify the bundle
if [ -f "${SERVER_DEST}" ]; then
    echo "Verification: Server successfully copied to app bundle"
    ls -la "${SERVER_DEST}"
else
    echo "Error: Failed to copy server to app bundle"
    exit 1
fi

exit 0