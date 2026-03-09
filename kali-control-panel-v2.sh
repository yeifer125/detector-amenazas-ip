#!/bin/bash

# ============================
# KALI CYBERSEC CONTROL PANEL V2
# ============================

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAG='\033[1;35m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuración
LOG_FILE="/tmp/kali-soc.log"
HISTORY_FILE="/tmp/kali-soc-history.txt"
THRESHOLD_CPU=80
THRESHOLD_RAM=85
THRESHOLD_CONNECTIONS=50

# Variables globales
IFACE=$(ip route | grep default | awk '{print $5}')
IP=$(hostname -I | awk '{print $1}')
GW=$(ip route | grep default | awk '{print $3}')
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
START_TIME=$(date +%s)

# Archivos de log
> "$LOG_FILE"
> "$HISTORY_FILE"

# ============================
# DRAGON V2
# ============================

dragon_v2(){
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

              KALI LINUX V2
        Advanced Offensive Security Console

EOF
echo -e "$NC"
}

# ============================
# BARRAS DE PROGRESO MEJORADAS
# ============================

cpu_bar_v2(){
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr ',' '.')
    CPU=$(echo "$CPU" | cut -d'.' -f1)
    
    # Color dinámico basado en uso
    if [ "$CPU" -gt "$THRESHOLD_CPU" ]; then
        COLOR="$RED"
        STATUS="🔥 CRITICAL"
    elif [ "$CPU" -gt 60 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ WARNING"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    BAR=$(printf "%0.s█" $(seq 1 $((CPU/2))))
    EMPTY=$(printf "%0.s░" $(seq 1 $((50-CPU/2))))
    
    echo -e "CPU Usage : $COLOR$CPU% [$BAR$EMPTY]$NC $STATUS"
    
    # Alerta si supera umbral
    if [ "$CPU" -gt "$THRESHOLD_CPU" ]; then
        echo "$(date): CPU CRITICAL - $CPU%" >> "$LOG_FILE"
    fi
}

ram_bar_v2(){
    RAM_USED=$(free | awk '/Mem:/ {print $3}')
    RAM_TOTAL=$(free | awk '/Mem:/ {print $2}')
    RAM_P=$((RAM_USED*100/RAM_TOTAL))
    
    # Color dinámico
    if [ "$RAM_P" -gt "$THRESHOLD_RAM" ]; then
        COLOR="$RED"
        STATUS="🔥 CRITICAL"
    elif [ "$RAM_P" -gt 70 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ WARNING"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    BAR=$(printf "%0.s█" $(seq 1 $((RAM_P/2))))
    EMPTY=$(printf "%0.s░" $(seq 1 $((50-RAM_P/2))))
    
    echo -e "RAM Usage : $COLOR$RAM_P% [$BAR$EMPTY]$NC $STATUS"
    
    # Alerta si supera umbral
    if [ "$RAM_P" -gt "$THRESHOLD_RAM" ]; then
        echo "$(date): RAM CRITICAL - $RAM_P%" >> "$LOG_FILE"
    fi
}

# ============================
# MAPA DE RED MEJORADO
# ============================

network_map_v2(){
    echo ""
    echo -e "$CYAN[ NETWORK MAP V2 ]$NC"
    echo ""
    echo "           INTERNET"
    echo "              │"
    echo "        $GW (Gateway)"
    echo "              │"
    echo "        $IP (YOU) -> $PUBLIC_IP"
    echo ""
    
    # Escaneo más detallado
    echo -e "$YELLOW[ Discovered Devices ]$NC"
    arp-scan --localnet --interface=$IFACE 2>/dev/null | head -n 15 | while read line; do
        if echo "$line" | grep -q "^[0-9]"; then
            ip=$(echo "$line" | awk '{print $1}')
            mac=$(echo "$line" | awk '{print $2}')
            vendor=$(echo "$line" | cut -d' ' -f3-)
            echo -e "  $GREEN$ip$NC | $CYAN$mac$NC | $YELLOW$vendor$NC"
        fi
    done
}

# ============================
# SNIFFER AVANZADO
# ============================

sniffer_v2(){
    echo ""
    echo -e "$CYAN[ ADVANCED PACKET ANALYSIS ]$NC"
    
    # Captura con más detalles
    timeout 2 tcpdump -i $IFACE -nn -c 10 2>/dev/null | while read line; do
        timestamp=$(date '+%H:%M:%S')
        echo -e "  $MAG[$timestamp]$NC $GREEN$line$NC"
    done
}

# ============================
# DETECTOR DE AMENAZAS AVANZADO
# ============================

attack_detector_v2(){
    echo ""
    echo -e "$CYAN[ ADVANCED THREAT DETECTION ]$NC"
    
    # Detección SYN flood
    SYN=$(ss -ant state syn-recv | wc -l)
    if [ "$SYN" -gt 20 ]; then
        echo -e "$RED🚨 SYN flood attack detected ($SYN connections)$NC"
        echo "$(date): SYN FLOOD ATTACK - $SYN connections" >> "$LOG_FILE"
    fi
    
    # Detección de conexiones sospechosas
    SUSPICIOUS=$(ss -ant | grep -E ":22|:3389|:5900" | wc -l)
    if [ "$SUSPICIOUS" -gt 5 ]; then
        echo -e "$YELLOW⚠️ High number of remote connections ($SUSPICIOUS)$NC"
    fi
    
    # Detección de escaneo de puertos
    PORT_SCAN=$(journalctl -u sshd --since "1 minute ago" | grep -c "Invalid user")
    if [ "$PORT_SCAN" -gt 10 ]; then
        echo -e "$RED🔥 Port scanning detected ($PORT_SCAN attempts)$NC"
    fi
    
    # Estado general
    if [ "$SYN" -lt 20 ] && [ "$SUSPICIOUS" -lt 5 ] && [ "$PORT_SCAN" -lt 10 ]; then
        echo -e "$GREEN✅ Network security status: NORMAL$NC"
    fi
}

# ============================
# ANÁLISIS DE PUERTOS
# ============================

ports_v2(){
    echo ""
    echo -e "$CYAN[ PORT ANALYSIS V2 ]$NC"
    
    echo -e "$YELLOW[ Open Ports ]$NC"
    ss -tuln | awk 'NR>1 {print $1" "$5}' | while read proto port; do
        port_num=$(echo "$port" | cut -d: -f2)
        service=$(getent services "$port_num" 2>/dev/null | awk '{print $1}' || echo "Unknown")
        echo -e "  $GREEN$proto$NC | $CYAN$port_num$NC | $YELLOW$service$NC"
    done
    
    # Puertos peligrosos abiertos
    dangerous_ports=$(ss -tuln | grep -E ":23|:135|:139|:445|:3389")
    if [ -n "$dangerous_ports" ]; then
        echo -e "$RED⚠️ Dangerous ports open:$NC"
        echo "$dangerous_ports"
    fi
}

# ============================
# ANÁLISIS DE TRÁFICO
# ============================

traffic_v2(){
    echo ""
    echo -e "$CYAN[ TRAFFIC ANALYSIS V2 ]$NC"
    
    if command -v ifstat >/dev/null 2>&1; then
        traffic_data=$(ifstat -i $IFACE 1 1 | tail -n 1)
        rx=$(echo "$traffic_data" | awk '{print $1}')
        tx=$(echo "$traffic_data" | awk '{print $2}')
        echo -e "  RX: $GREEN${rx} KB/s$NC | TX: $BLUE${tx} KB/s$NC"
    else
        # Alternativa si ifstat no está disponible
        rx_bytes=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
        tx_bytes=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        echo -e "  Total RX: $GREEN${rx_bytes} bytes$NC | Total TX: $BLUE${tx_bytes} bytes$NC"
    fi
}

# ============================
# SISTEMA DE LOGS
# ============================

show_logs(){
    echo ""
    echo -e "$CYAN[ SECURITY LOGS ]$NC"
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        tail -n 10 "$LOG_FILE" | while read line; do
            echo -e "  $RED$line$NC"
        done
    else
        echo -e "  $GREEN No security events logged$NC"
    fi
}

# ============================
# ESTADÍSTICAS DEL SISTEMA
# ============================

system_stats(){
    echo ""
    echo -e "$CYAN[ SYSTEM STATISTICS ]$NC"
    
    # Uptime
    uptime_formatted=$(uptime -p)
    echo -e "  Uptime: $GREEN$uptime_formatted$NC"
    
    # Carga del sistema
    load_avg=$(uptime | awk -F'load average:' '{print $2}')
    echo -e "  Load Average: $YELLOW$load_avg$NC"
    
    # Procesos
    process_count=$(ps aux | wc -l)
    echo -e "  Running Processes: $CYAN$process_count$NC"
    
    # Espacio en disco
    disk_usage=$(df -h / | awk 'NR==2 {print $5}')
    echo -e "  Disk Usage: $MAG$disk_usage$NC"
    
    # Tiempo de ejecución del panel
    current_time=$(date +%s)
    runtime=$((current_time - START_TIME))
    echo -e "  Panel Runtime: $BLUE$((runtime / 60))m $((runtime % 60))s$NC"
}

# ============================
# DASHBOARD PRINCIPAL V2
# ============================

dashboard_v2(){
    clear
    
    dragon_v2
    
    echo -e "$MAG🔥 KALI HACKER CONTROL PANEL V2 🔥$NC"
    echo "=========================================="
    
    echo ""
    echo -e "$YELLOW[ SYSTEM INFORMATION V2 ]$NC"
    echo "User      : $(whoami)"
    echo "Host      : $(hostname)"
    echo "Kernel    : $(uname -r)"
    echo "Public IP : $PUBLIC_IP"
    
    cpu_bar_v2
    ram_bar_v2
    system_stats
    
    echo ""
    echo -e "$YELLOW[ NETWORK SECURITY V2 ]$NC"
    echo "Interface : $IFACE"
    echo "Local IP  : $IP"
    echo "Gateway   : $GW"
    
    network_map_v2
    ports_v2
    traffic_v2
    sniffer_v2
    attack_detector_v2
    show_logs
    
    echo ""
    echo -e "$GREEN[ Press Ctrl+C to exit ]$NC"
    echo "Refreshing in 5 seconds..."
    
    # Guardar en historial
    echo "$(date): Dashboard refreshed" >> "$HISTORY_FILE"
}

# ============================
# EFECTO MR ROBOT V2
# ============================

mrrobot_v2(){
    echo ""
    echo -e "$RED[+] Initializing cyber console v2...$NC"
    sleep 0.5
    echo -e "$GREEN[+] Loading security modules...$NC"
    sleep 0.5
    echo -e "$CYAN[+] Connecting to network core...$NC"
    sleep 0.5
    echo -e "$BLUE[+] Activating threat detection...$NC"
    sleep 0.5
    echo -e "$MAG[+] System ready.$NC"
    echo ""
}

# ============================
# LIMPIEZA AL SALIR
# ============================

cleanup(){
    echo ""
    echo -e "$GREEN[+] Shutting down gracefully...$NC"
    echo -e "$CYAN[+] Session logged to $HISTORY_FILE$NC"
    echo -e "$YELLOW[+] Security events saved to $LOG_FILE$NC"
    exit 0
}

trap cleanup SIGINT SIGTERM

# ============================
# INICIO
# ============================

mrrobot_v2

while true
do
    dashboard_v2
    sleep 5
done
