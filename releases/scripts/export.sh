#!/bin/bash

echo "exporting app"
java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar /Users/pedro/Library/Application\ Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-7.3.0-2024-08-27-36488f6f5/bin/monkeybrains.jar -o /Users/pedro/repos/garmin/garminpadel/releases/garminpadel.iq -f /Users/pedro/repos/garmin/garminpadel/monkey.jungle -y /Users/pedro/repos/garmin/developer_key -e -r -w 
