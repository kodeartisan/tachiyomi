#!/bin/bash

git fetch --unshallow #required for commit count

if [ -z "$TRAVIS_TAG" ]; then
    ./gradlew clean buildStandardDebug

    COMMIT_COUNT=$(git rev-list --count HEAD)
    export ARTIFACT="tachiyomi-r${COMMIT_COUNT}.apk"

    mv app/build/outputs/apk/app-standard-debug.apk $ARTIFACT
else
    ./gradlew clean buildStandardRelease

    TOOLS="${ANDROID_HOME}/build-tools/26.0.1"
    export ARTIFACT="tachiyomi-${TRAVIS_TAG}.apk"

    ${TOOLS}/zipalign -v -p 4 app/build/outputs/apk/app-standard-release-unsigned app-aligned.apk
    ${TOOLS}/apksigner sign --ks $STORE_PATH --ks-key-alias $STORE_ALIAS --ks-pass env:STORE_PASS --key-pass env:KEY_PASS --out $ARTIFACT app-aligned.apk
fi
