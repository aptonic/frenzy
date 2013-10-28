#!/bin/bash

# Generates Frenzy site by recursively wgeting and then placing generates files/dirs in root

LOCAL_SITE_SOURCE_URL="127.0.0.1/~john/frenzy/generator/source"
START_POINT="invite"

cd ..

# Get rid of old snapshot
cp -r generator /tmp
rm -rf *
mv /tmp/generator ./

# Create new snapshot
wget -rl 30 --adjust-extension --convert-links --html-extension $LOCAL_SITE_SOURCE_URL/$START_POINT
mv $LOCAL_SITE_SOURCE_URL/* ./

# Copy stuff that isn't linked to from site
cp -r generator/source/sparkle ./
cp generator/source/quick.txt ./
cp generator/source/quick-iphone.txt ./
cp -r generator/source/fancybox ./
cp generator/source/images/watch-h.jpg ./images/

rm -rf 127.0.0.1

echo
echo "Frenzy site snapshot created"
echo "Deploying changes..."
echo

# Commit & Deploy
git add *
git add -u *
git commit -a -m "Updated site"
git push origin gh-pages