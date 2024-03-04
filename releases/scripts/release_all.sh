#!/bin/bash

new_version=$(python releases/scripts/replace_version.py drop_beta)
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "--- Aborting release ---"
else
    echo 'New version:' $new_version
fi

sh releases/scripts/export.sh

version_filename=$(echo $new_version | sed 's/\./_/g')
mv garminpadel.iq garminpadel-v$version_filename.iq

# git add resources/strings/strings.xml releases/
# git cmsg "add v$new_version exported app"
# git tag -a $new_version -m "version $new_version"

# python replace_version.py next_beta
# git add resources/strings/strings.xml
# git cmsg "bump version for next development cycle"

# git po && git ptags

# echo "Missing steps:"
# echo "close milestone https://github.com/pedrorijo91/garmin-padel/milestones"
# echo "create github release"
# echo "add exported app to release"
# echo "upload https://apps.garmin.com/en-US/developer/dashboard"