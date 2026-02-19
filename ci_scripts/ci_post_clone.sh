#!/bin/sh

set -eu

# Keep this value in sync with the version expected by the project lint rules.
# To bump SwiftLint, change this value and validate locally before merging.
EXPECTED_SWIFTLINT_VERSION="0.57.1"

if test -d "/opt/homebrew/bin/"; then
  PATH="/opt/homebrew/bin:${PATH}"
fi

export PATH

if ! command -v brew >/dev/null 2>&1; then
  echo "error: Homebrew is required to install SwiftLint on Xcode Cloud."
  exit 1
fi

brew install swiftlint

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "error: SwiftLint installation failed."
  exit 1
fi

INSTALLED_SWIFTLINT_VERSION="$(swiftlint version)"
if [ "${INSTALLED_SWIFTLINT_VERSION}" != "${EXPECTED_SWIFTLINT_VERSION}" ]; then
  echo "error: SwiftLint version mismatch. Expected ${EXPECTED_SWIFTLINT_VERSION}, got ${INSTALLED_SWIFTLINT_VERSION}."
  exit 1
fi

echo "SwiftLint ${INSTALLED_SWIFTLINT_VERSION} installed and validated."
