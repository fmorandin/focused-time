#!/bin/sh

set -eu

# Installs the latest SwiftLint available via Homebrew. No version is pinned —
# the project's lint rules are version-agnostic.

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

echo "SwiftLint $(swiftlint version) installed."
