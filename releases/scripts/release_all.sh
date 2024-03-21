#!/bin/bash

echo "have you updated README and screenshots already?"
read ans

if [ "$ans" == "y" ]; then
    echo "Continuing"
else
    echo "---- Aborting ----"
    exit 1
fi

new_version=$(python releases/scripts/replace_version.py drop_beta)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "--- Aborting release ---"
else
    echo 'New version:' $new_version
fi

sh releases/scripts/export.sh

version_filename=$(echo $new_version | sed 's/\./_/g')
mv releases/garminpadel.iq releases/garminpadel-v$version_filename.iq

git add resources/strings/strings.xml releases/
git cmsg "add v$new_version exported app"
git tag -a $new_version -m "version $new_version"

python releases/scripts/replace_version.py next_beta
git add resources/strings/strings.xml
git cmsg "bump version for next development cycle"

git po && git ptags

echo "\n\n----------------\n\n"
echo "Missing steps:"
echo "close milestone https://github.com/pedrorijo91/garmin-padel/milestones"
echo "create github release https://github.com/pedrorijo91/garmin-padel/tags"
echo "add exported app to release"
echo "upload https://apps.garmin.com/en-US/developer/dashboard"