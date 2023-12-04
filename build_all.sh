#!/bin/bash

# exit on error
set -e
CMD_CURR="";
function trap_error_dbg {
    CMD_LAST=${CMD_CURR}
    CMD_CURR=$BASH_COMMAND
}
function trap_error_exit {
    if (($? > 0))
    then
        echo "\"${CMD_LAST}\" resulted in exit code $?."
    fi
}
trap trap_error_dbg DEBUG
trap trap_error_exit EXIT

# settings
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null || echo "none")
GIT_HEAD=$(git rev-parse HEAD || echo "none")
OUTDIR="./build/buildscript"
DIST_FOLDER="./dist"
DIST_NAME="spicecompanion-$(date +%y)-$(date +%m)-$(date +%d).zip"
DIST_COMMENT=${DIST_NAME}$'\n'"$GIT_BRANCH - $GIT_HEAD"$'\nThank you for playing.'

# clean build dir
rm -rf ./build

# build android
flutter build apk --release

# copy to outdir
rm -rf ${OUTDIR}
mkdir -p ${OUTDIR}
cp ./build/app/outputs/apk/release/app-release.apk ${OUTDIR}/spicecompanion.apk

# git archive
echo "Generating source file archive..."
git archive --format tar.gz --prefix=spicecompanion/ HEAD > ${OUTDIR}/src.tar.gz 2>/dev/null || \
	echo "WARNING: Couldn't get git to create the archive. Is this a git repository?"

# dist
echo "Building dist..."
mkdir -p ${DIST_FOLDER}
rm -rf ${DIST_FOLDER}/${DIST_NAME}
pushd ${OUTDIR} > /dev/null
zip -qrXT9 $OLDPWD/${DIST_FOLDER}/${DIST_NAME} . -z <<< "$DIST_COMMENT"
popd > /dev/null
