#!/bin/bash

echo "exporting app"
java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar /Users/pedro/Library/Application\ Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-6.4.2-2024-01-04-a1dd13ee0/bin/monkeybrains.jar -o /Users/pedro/repos/garmin/garminpadel/releases/garminpadel.iq -f /Users/pedro/repos/garmin/garminpadel/monkey.jungle -y /Users/pedro/repos/garmin/developer_key -e -r -w 