#!/bin/bash

# ============================
# KALI CYBERSEC CONTROL PANEL
# ============================

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAG='\033[1;35m'
NC='\033[0m'

IFACE=$(ip route | grep default | awk '{print $5}')
IP=$(hostname -I | awk '{print $1}')
GW=$(ip route | grep default | awk '{print $3}')

# ============================
# DRAGON
# ============================

dragon(){

echo -e "$RED"

cat << "EOF"

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣤⣤⣤⣀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣦
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⡿⠟⠛⠻⢿⣿⣿⣧
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⠃⠀⠀⠀⠀⠀⠈⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣧⠀⠀⠀⠀⠀⠀⣠⣿⣿⡿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠿⠿⠶⠶⠶⠶⠿⠿⠟⠋

              KALI LINUX
        Offensive Security Console

EOF

echo -e "$NC"

}

# ============================
# CPU BAR
# ============================

cpu_bar(){

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
CPU=${CPU%.*}

BAR=$(printf "%0.s█" $(seq 1 $((CPU/2))))

echo -e "CPU Usage : $GREEN$CPU% $BAR$NC"

}

# ============================
# RAM BAR
# ============================

ram_bar(){

RAM_USED=$(free | awk '/Mem:/ {print $3}')
RAM_TOTAL=$(free | awk '/Mem:/ {print $2}')
RAM_P=$((RAM_USED*100/RAM_TOTAL))

BAR=$(printf "%0.s█" $(seq 1 $((RAM_P/2))))

echo -e "RAM Usage : $GREEN$RAM_P% $BAR$NC"

}

# ============================
# NETWORK MAP
# ============================

network_map(){

echo ""
echo -e "$CYAN[ NETWORK MAP ]$NC"

echo ""
echo "           INTERNET"
echo "              │"
echo "        $GW"
echo "              │"
echo "        $IP (YOU)"
echo ""

arp-scan --localnet --interface=$IFACE 2>/dev/null | head -n 10

}

# ============================
# LIVE SNIFFER
# ============================

sniffer(){

echo ""
echo -e "$CYAN[ LIVE PACKETS ]$NC"

timeout 3 tcpdump -i $IFACE -nn 2>/dev/null | head -n 5

}

# ============================
# ATTACK DETECTOR
# ============================

attack_detector(){

echo ""
echo -e "$CYAN[ INTRUSION DETECTOR ]$NC"

SYN=$(ss -ant state syn-recv | wc -l)

if [ "$SYN" -gt 20 ]
then

echo -e "$RED⚠ Possible SYN flood attack detected ($SYN)$NC"

else

echo -e "$GREENNetwork normal$NC"

fi

}

# ============================
# OPEN PORTS
# ============================

ports(){

echo ""
echo -e "$CYAN[ OPEN PORTS ]$NC"

ss -tuln | awk 'NR>1 {print $5}' | cut -d: -f2 | sort -n | uniq | head

}

# ============================
# TRAFFIC GRAPH
# ============================

traffic(){

echo ""
echo -e "$CYAN[ NETWORK TRAFFIC ]$NC"

ifstat -i $IFACE 1 1 | tail -n 1

}

# ============================
# MAIN DASHBOARD
# ============================

dashboard(){

clear

dragon

echo -e "$MAG KALI HACKER CONTROL PANEL $NC"
echo "================================="

echo ""
echo -e "$YELLOW[ SYSTEM ]$NC"

echo "User      : $(whoami)"
echo "Host      : $(hostname)"
echo "Kernel    : $(uname -r)"
echo "Uptime    : $(uptime -p)"

cpu_bar
ram_bar

echo ""
echo -e "$YELLOW[ NETWORK ]$NC"

echo "Interface : $IFACE"
echo "IP        : $IP"
echo "Gateway   : $GW"

network_map
ports
traffic
sniffer
attack_detector

echo ""
echo "Refreshing in 5 seconds..."

}

# ============================
# MR ROBOT EFFECT
# ============================

mrrobot(){

echo ""
echo -e "$RED Initializing cyber console...$NC"
sleep 1
echo -e "$GREEN Loading modules...$NC"
sleep 1
echo -e "$CYAN Connecting to network core...$NC"
sleep 1
echo ""

}

# ============================
# LOOP
# ============================

mrrobot

while true
do

dashboard
sleep 5

done
