set -o errexit
echo "Copying browser extensions to app bundle Extensions directory"

EXTENSIONS_PATH="/Users/john/Documents/XcodeProjects/Frenzy/Extensions"
EXTENSIONS_DIR="$BUILT_PRODUCTS_DIR/$PROJECT_NAME.app/Contents/Extensions"

rm -rf "$EXTENSIONS_DIR"
cp -r "$EXTENSIONS_PATH" "$EXTENSIONS_DIR"
