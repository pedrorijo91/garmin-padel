#!/bin/bash

echo "exporting app"
java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar /Users/pedrorijo/Library/Application\ Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.4.1-2026-02-03-e9f77eeaa/bin/monkeybrains.jar -o /Users/pedrorijo/repo/garmin-padel/releases/garminpadel.iq -f /Users/pedrorijo/repo/garmin-padel/monkey.jungle -y /Users/pedrorijo/repo/garmin-padel/developer_key -e -r -w 
