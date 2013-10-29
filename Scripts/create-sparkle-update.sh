set -o errexit
exec > /Users/john/Desktop/create_sparkle_update.txt 2>&1

echo "Creating Sparkle Update..."
[ $BUILD_STYLE = Release ] || { echo Distribution target requires "'Release'" build style; false; }

BUILT_PRODUCTS_DIR="$ARCHIVE_PRODUCTS_PATH/Users/john/Applications"

BUILD_VERSION=$(defaults read "$BUILT_PRODUCTS_DIR/$PROJECT.app/Contents/Info" CFBundleVersion)
VERSION=$(defaults read "$BUILT_PRODUCTS_DIR/$PROJECT.app/Contents/Info" CFBundleShortVersionString)

x=`/usr/bin/osascript <<EOT
tell application "System Events"
    activate
    set myReply to button returned of (display dialog "Create Sparkle update for version $VERSION (build: $BUILD_VERSION)?" buttons {"Yes", "No"} default button 2)
end tell
EOT
`
[ $x = Yes ] || { echo "Sparkle update creation aborted"; false; }

DOWNLOAD_BASE_URL="http://aptonic.github.io/frenzy/downloads"
RELEASENOTES_URL="http://aptonic.github.io/frenzy/sparkle/releasenotes/$VERSION.html"
WEB_PATH="/Users/john/Sites/frenzy/generator/source/sparkle"

ARCHIVE_FILENAME="$PROJECT-$VERSION.zip"
DOWNLOAD_URL="$DOWNLOAD_BASE_URL/$ARCHIVE_FILENAME"
KEYCHAIN_PRIVKEY_NAME="Sparkle Frenzy Private Key"

WD=$PWD
cd "$BUILT_PRODUCTS_DIR"
rm -f "$PROJECT_NAME"*.zip
zip -qr "$ARCHIVE_FILENAME" "$PROJECT_NAME.app"

SIZE=$(stat -f %z "$ARCHIVE_FILENAME")
PUBDATE=$(date +"%a, %d %b %G %T %z")
SIGNATURE=$(
	openssl dgst -sha1 -binary < "$ARCHIVE_FILENAME" \
	| openssl dgst -dss1 -sign <(security find-generic-password -g -s "$KEYCHAIN_PRIVKEY_NAME" 2>&1 1>/dev/null | grep -oe "-----.*-----" | perl -pe 's/\\012/\n/g') \
	| openssl enc -base64
)

[ $SIGNATURE ] || { echo Unable to load signing private key with name "'$KEYCHAIN_PRIVKEY_NAME'" from keychain; false; }

# Add this update to Sparkle updates feed
head -n 7 "$WEB_PATH/updates.xml" > "$WEB_PATH/tmp"
cat >> "$WEB_PATH/tmp" <<EOF
		<item>
			<title>Version $VERSION</title>
			<sparkle:releaseNotesLink>$RELEASENOTES_URL</sparkle:releaseNotesLink>
			<pubDate>$PUBDATE</pubDate>
			<enclosure
				url="$DOWNLOAD_URL"
				sparkle:version="$VERSION"
				type="application/octet-stream"
				length="$SIZE"
				sparkle:dsaSignature="$SIGNATURE"
			/>
		</item>
EOF
sed -n -e '8,$p' "$WEB_PATH/updates.xml" >> "$WEB_PATH/tmp";
cat "$WEB_PATH/tmp" > "$WEB_PATH/updates.xml"
rm -f "$WEB_PATH/tmp"

# Create sample release notes
cat > "$WEB_PATH/releasenotes/$VERSION.html" <<EOF
<html>
  <head>
    <title>
      Frenzy Release Notes
    </title>
    <link rel="stylesheet" href="style.css" type="text/css" media="screen" charset="utf-8">
  </head>
  <body>
    <h2>New in Frenzy $VERSION</h2>

    <div id="content">

      <ul>
        <li>Cool new stuff goes here</li>
      </ul>

    </div>
  </body>
</html>
EOF

cat > "$WEB_PATH/../version.php" <<EOF
<?php

\$frenzy_version = "$VERSION";

?>
EOF

cp "$BUILT_PRODUCTS_DIR/$ARCHIVE_FILENAME" "$WEB_PATH/../downloads"

/usr/bin/mate "$WEB_PATH"
