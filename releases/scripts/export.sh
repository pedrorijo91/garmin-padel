#!/bin/bash

echo "exporting app"
java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar /Users/pedrorijo/Library/Application\ Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-9.1.0-2026-03-09-6a872a80b/bin/monkeybrains.jar -o /Users/pedrorijo/repo/garmin-padel/releases/garminpadel.iq -f /Users/pedrorijo/repo/garmin-padel/monkey.jungle -y /Users/pedrorijo/repo/garmin-padel/developer_key -e -r -w 
