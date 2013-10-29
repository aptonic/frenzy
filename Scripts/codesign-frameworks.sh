#!/bin/sh

SIGNING_IDENTITY=$*
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

FRAMEWORK_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

# Loop through all frameworks
FRAMEWORKS=`find "${FRAMEWORK_DIR}" -type d -name "*.framework" | sed -e "s/\(.*\)/\1\/Versions\/A\//"`
RESULT=$?
if [[ $RESULT != 0 ]] ; then
    exit 1
fi

echo "Found:"
echo "${FRAMEWORKS}"

for FRAMEWORK in $FRAMEWORKS;
do
    echo "Signing '${FRAMEWORK}'"
    `codesign -f -v -s "${SIGNING_IDENTITY}" "${FRAMEWORK}"`
    RESULT=$?
    if [[ $RESULT != 0 ]] ; then
        exit 1
    fi
done

# restore $IFS
IFS=$SAVEIFS