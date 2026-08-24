#!/bin/sh

set -eu

SWIFTLINT_VERSION="0.65.0"
SWIFTLINT_CHECKSUM="d6cb0aa7a2f5f1ef306fc9e37bcb54dc9a26facc8f7784ac0c3dd3eccf5c6ba6"
SWIFTLINT_ARCHIVE_URL="https://github.com/realm/SwiftLint/releases/download/${SWIFTLINT_VERSION}/portable_swiftlint.zip"
SWIFTLINT_ARCHIVE_PATH="$(mktemp)"
SWIFTLINT_EXTRACT_DIRECTORY="$(mktemp -d)"

cleanup() {
  rm -f "${SWIFTLINT_ARCHIVE_PATH}"
  rm -rf "${SWIFTLINT_EXTRACT_DIRECTORY}"
}

trap cleanup EXIT

curl --fail --location --retry 3 --output "${SWIFTLINT_ARCHIVE_PATH}" "${SWIFTLINT_ARCHIVE_URL}"

ACTUAL_CHECKSUM="$(shasum -a 256 "${SWIFTLINT_ARCHIVE_PATH}" | cut -d ' ' -f 1)"
if [ "${ACTUAL_CHECKSUM}" != "${SWIFTLINT_CHECKSUM}" ]; then
  echo "error: SwiftLint archive checksum verification failed."
  exit 1
fi

ditto -x -k "${SWIFTLINT_ARCHIVE_PATH}" "${SWIFTLINT_EXTRACT_DIRECTORY}"
sudo install -m 0755 "${SWIFTLINT_EXTRACT_DIRECTORY}/swiftlint" /usr/local/bin/swiftlint

if [ "$(/usr/local/bin/swiftlint version)" != "${SWIFTLINT_VERSION}" ]; then
  echo "error: SwiftLint installation failed."
  exit 1
fi

echo "SwiftLint ${SWIFTLINT_VERSION} installed."
