#!/bin/bash
cd "$HOME/server" || exit 1
/mnt/D/shelter/NON-IMP-programs/Linux-programs/jdk-25.0.4.1/bin/java -Xmx2G -Xms1G -jar server.jar nogui
