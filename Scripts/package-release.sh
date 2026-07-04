#!/bin/bash
# Packages a versioned, zipped release artifact of FXConvert.app suitable for a Homebrew cask URL.
# Usage: Scripts/package-release.sh <version>   e.g. Scripts/package-release.sh 1.1.0
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:?Usage: Scripts/package-release.sh <version>}"
ZIP_NAME="FXConvert.zip"

./Scripts/build-app.sh

# ditto (not plain zip) preserves resource forks/extended attributes correctly for .app bundles.
rm -f "$ZIP_NAME"
ditto -c -k --sequesterRsrc --keepParent FXConvert.app "$ZIP_NAME"

SHA256=$(shasum -a 256 "$ZIP_NAME" | awk '{print $1}')

echo "Packaged $ZIP_NAME for version $VERSION"
echo "sha256: $SHA256"
echo
echo "Next steps:"
echo "  1. Bump CFBundleVersion/CFBundleShortVersionString in Resources/Info.plist to $VERSION"
echo "  2. git tag v$VERSION && git push origin v$VERSION"
echo "  3. gh release create v$VERSION $ZIP_NAME"
echo "  4. Update version/sha256/url in the homebrew-fxconvert repo's Casks/fxconvert.rb"
