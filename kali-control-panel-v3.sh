#!/bin/bash

# ============================
# KALI CYBERSEC CONTROL PANEL V3
# ============================

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAG='\033[1;35m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
ORANGE='\033[1;93m'
NC='\033[0m'

# Configuración
LOG_FILE="/tmp/kali-soc.log"
HISTORY_FILE="/tmp/kali-soc-history.txt"
ALERT_FILE="/tmp/kali-soc-alerts.txt"
THRESHOLD_CPU=80
THRESHOLD_RAM=85
THRESHOLD_CONNECTIONS=50
THRESHOLD_DISK=90

# Variables globales
IFACE=$(ip route | grep default | awk '{print $5}')
IP=$(hostname -I | awk '{print $1}')
GW=$(ip route | grep default | awk '{print $3}')
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unknown")
START_TIME=$(date +%s)

# Archivos de log
> "$LOG_FILE"
> "$HISTORY_FILE"
> "$ALERT_FILE"

# ============================
# DRAGON V3
# ============================

dragon_v3(){
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

              KALI LINUX V3
        ULTIMATE Offensive Security Console

EOF
echo -e "$NC"
}

# ============================
# BARRAS DE PROGRESO V3
# ============================

cpu_bar_v3(){
    # Obtener CPU de forma robusta
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr ',' '.')
    CPU=$(echo "$CPU" | cut -d'.' -f1)
    
    # Validar que sea un número
    if ! [[ "$CPU" =~ ^[0-9]+$ ]]; then
        CPU=0
    fi
    
    # Color dinámico basado en uso
    if [ "$CPU" -gt "$THRESHOLD_CPU" ]; then
        COLOR="$RED"
        STATUS="🔥 CRITICAL"
        echo "$(date): CPU CRITICAL - $CPU%" >> "$ALERT_FILE"
    elif [ "$CPU" -gt 60 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ WARNING"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    # Barra de progreso
    FILLED=$((CPU/2))
    EMPTY=$((50-FILLED))
    BAR=$(printf "%0.s█" $(seq 1 $FILLED))
    EMPTY_BAR=$(printf "%0.s░" $(seq 1 $EMPTY))
    
    echo -e "CPU Usage : $COLOR$CPU% [$BAR$EMPTY_BAR]$NC $STATUS"
}

ram_bar_v3(){
    RAM_USED=$(free | awk '/Mem:/ {print $3}')
    RAM_TOTAL=$(free | awk '/Mem:/ {print $2}')
    RAM_P=$((RAM_USED*100/RAM_TOTAL))
    
    # Color dinámico
    if [ "$RAM_P" -gt "$THRESHOLD_RAM" ]; then
        COLOR="$RED"
        STATUS="🔥 CRITICAL"
        echo "$(date): RAM CRITICAL - $RAM_P%" >> "$ALERT_FILE"
    elif [ "$RAM_P" -gt 70 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ WARNING"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    # Barra de progreso
    FILLED=$((RAM_P/2))
    EMPTY=$((50-FILLED))
    BAR=$(printf "%0.s█" $(seq 1 $FILLED))
    EMPTY_BAR=$(printf "%0.s░" $(seq 1 $EMPTY))
    
    echo -e "RAM Usage : $COLOR$RAM_P% [$BAR$EMPTY_BAR]$NC $STATUS"
}

disk_bar_v3(){
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    
    # Color dinámico
    if [ "$DISK_USAGE" -gt "$THRESHOLD_DISK" ]; then
        COLOR="$RED"
        STATUS="🔥 CRITICAL"
        echo "$(date): DISK CRITICAL - $DISK_USAGE%" >> "$ALERT_FILE"
    elif [ "$DISK_USAGE" -gt 80 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ WARNING"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    # Barra de progreso
    FILLED=$((DISK_USAGE/2))
    EMPTY=$((50-FILLED))
    BAR=$(printf "%0.s█" $(seq 1 $FILLED))
    EMPTY_BAR=$(printf "%0.s░" $(seq 1 $EMPTY))
    
    echo -e "Disk Usage: $COLOR$DISK_USAGE% [$BAR$EMPTY_BAR]$NC $STATUS"
}

# ============================
# MAPA DE RED V3
# ============================

network_map_v3(){
    echo ""
    echo -e "$CYAN[ NETWORK MAP V3 ]$NC"
    echo ""
    echo "           INTERNET"
    echo "              │"
    echo "        $GW (Gateway)"
    echo "              │"
    echo "        $IP (YOU) -> $PUBLIC_IP"
    echo ""
    
    # Escaneo mejorado
    echo -e "$YELLOW[ Discovered Devices ]$NC"
    device_count=0
    arp-scan --localnet --interface=$IFACE 2>/dev/null | while read line; do
        if echo "$line" | grep -q "^[0-9]"; then
            device_count=$((device_count + 1))
            ip=$(echo "$line" | awk '{print $1}')
            mac=$(echo "$line" | awk '{print $2}')
            vendor=$(echo "$line" | cut -d' ' -f3-)
            echo -e "  $GREEN$ip$NC | $CYAN$mac$NC | $YELLOW${vendor:0:30}$NC"
        fi
    done
}

# ============================
# SNIFFER AVANZADO V3
# ============================

sniffer_v3(){
    echo ""
    echo -e "$CYAN[ ADVANCED PACKET ANALYSIS V3 ]$NC"
    
    # Captura con análisis
    timeout 2 tcpdump -i $IFACE -nn -c 8 2>/dev/null | while read line; do
        timestamp=$(date '+%H:%M:%S')
        
        # Analizar tipo de tráfico
        if echo "$line" | grep -qi "http"; then
            traffic_type="🌐 HTTP"
        elif echo "$line" | grep -qi "https"; then
            traffic_type="🔒 HTTPS"
        elif echo "$line" | grep -qi "ssh"; then
            traffic_type="🔐 SSH"
        elif echo "$line" | grep -qi "dns"; then
            traffic_type="🔍 DNS"
        else
            traffic_type="📦 DATA"
        fi
        
        echo -e "  $MAG[$timestamp]$NC $traffic_type $GREEN$line$NC"
    done
}

# ============================
# DETECTOR DE AMENAZAS V3
# ============================

attack_detector_v3(){
    echo ""
    echo -e "$CYAN[ ADVANCED THREAT DETECTION V3 ]$NC"
    
    threat_level=0
    
    # Detección SYN flood
    SYN=$(ss -ant state syn-recv | wc -l)
    if [ "$SYN" -gt 20 ]; then
        echo -e "$RED🚨 SYN flood attack detected ($SYN connections)$NC"
        echo "$(date): SYN FLOOD ATTACK - $SYN connections" >> "$ALERT_FILE"
        threat_level=$((threat_level + 3))
    fi
    
    # Detección de conexiones sospechosas
    SUSPICIOUS=$(ss -ant | grep -E ":22|:3389|:5900" | wc -l)
    if [ "$SUSPICIOUS" -gt 5 ]; then
        echo -e "$YELLOW⚠️ High number of remote connections ($SUSPICIOUS)$NC"
        threat_level=$((threat_level + 1))
    fi
    
    # Detección de escaneo de puertos
    PORT_SCAN=$(journalctl -u sshd --since "1 minute ago" 2>/dev/null | grep -c "Invalid user" || echo 0)
    if [ "$PORT_SCAN" -gt 10 ]; then
        echo -e "$RED🔥 Port scanning detected ($PORT_SCAN attempts)$NC"
        echo "$(date): PORT SCAN ATTACK - $PORT_SCAN attempts" >> "$ALERT_FILE"
        threat_level=$((threat_level + 2))
    fi
    
    # Detección de conexiones establecidas inusuales
    ESTABLISHED=$(ss -ant state established | wc -l)
    if [ "$ESTABLISHED" -gt 100 ]; then
        echo -e "$ORANGE🔥 Unusual number of established connections ($ESTABLISHED)$NC"
        threat_level=$((threat_level + 1))
    fi
    
    # Estado general basado en nivel de amenaza
    if [ "$threat_level" -ge 5 ]; then
        echo -e "$RED🔴 THREAT LEVEL: CRITICAL$NC"
    elif [ "$threat_level" -ge 3 ]; then
        echo -e "$YELLOW🟡 THREAT LEVEL: HIGH$NC"
    elif [ "$threat_level" -ge 1 ]; then
        echo -e "$ORANGE🟠 THREAT LEVEL: MEDIUM$NC"
    else
        echo -e "$GREEN🟢 THREAT LEVEL: LOW$NC"
    fi
}

# ============================
# ANÁLISIS DE PUERTOS V3
# ============================

ports_v3(){
    echo ""
    echo -e "$CYAN[ PORT ANALYSIS V3 ]$NC"
    
    echo -e "$YELLOW[ Open Ports ]$NC"
    ss -tuln | awk 'NR>1 && $5!="" {print $1" "$5}' | while read proto port; do
        if [ -n "$port" ]; then
            port_num=$(echo "$port" | cut -d: -f2)
            if [ -n "$port_num" ] && [[ "$port_num" =~ ^[0-9]+$ ]]; then
                service=$(getent services "$port_num" 2>/dev/null | awk '{print $1}' || echo "Unknown")
                
                # Clasificación de peligrosidad
                case $port_num in
                    23|135|139|445|3389) danger="$RED🔴 HIGH$NC" ;;
                    21|25|53|80|110|143|443) danger="$YELLOW🟡 MEDIUM$NC" ;;
                    22|8080|8443) danger="$ORANGE🟠 LOW$NC" ;;
                    *) danger="$GREEN🟢 SAFE$NC" ;;
                esac
                
                echo -e "  $GREEN$proto$NC | $CYAN$port_num$NC | $YELLOW${service:0:12}$NC | $danger"
            fi
        fi
    done
}

# ============================
# ANÁLISIS DE TRÁFICO V3
# ============================

traffic_v3(){
    echo ""
    echo -e "$CYAN[ TRAFFIC ANALYSIS V3 ]$NC"
    
    # Estadísticas de interfaz
    if [ -d "/sys/class/net/$IFACE" ]; then
        rx_bytes=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
        tx_bytes=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        rx_packets=$(cat /sys/class/net/$IFACE/statistics/rx_packets)
        tx_packets=$(cat /sys/class/net/$IFACE/statistics/tx_packets)
        
        echo -e "  RX: $GREEN${rx_bytes} bytes ($rx_packets packets)$NC"
        echo -e "  TX: $BLUE${tx_bytes} bytes ($tx_packets packets)$NC"
        
        # Cálculo de tasa si ifstat está disponible
        if command -v ifstat >/dev/null 2>&1; then
            traffic_data=$(ifstat -i $IFACE 1 1 2>/dev/null | tail -n 1)
            if [ -n "$traffic_data" ]; then
                rx_rate=$(echo "$traffic_data" | awk '{print $1}')
                tx_rate=$(echo "$traffic_data" | awk '{print $2}')
                echo -e "  Rate: RX $GREEN${rx_rate} KB/s$NC | TX $BLUE${tx_rate} KB/s$NC"
            fi
        fi
    else
        echo -e "  $RED Interface $IFACE not found$NC"
    fi
}

# ============================
# SISTEMA DE LOGS V3
# ============================

show_logs_v3(){
    echo ""
    echo -e "$CYAN[ SECURITY LOGS V3 ]$NC"
    
    # Alertas recientes
    if [ -f "$ALERT_FILE" ] && [ -s "$ALERT_FILE" ]; then
        echo -e "$RED[ Recent Alerts ]$NC"
        tail -n 5 "$ALERT_FILE" | while read line; do
            echo -e "  $RED🚨 $line$NC"
        done
    else
        echo -e "  $GREEN✅ No security alerts$NC"
    fi
    
    # Historial de eventos
    if [ -f "$HISTORY_FILE" ] && [ -s "$HISTORY_FILE" ]; then
        echo -e "$YELLOW[ Event History ]$NC"
        tail -n 3 "$HISTORY_FILE" | while read line; do
            echo -e "  $CYAN📝 $line$NC"
        done
    fi
}

# ============================
# ESTADÍSTICAS DEL SISTEMA V3
# ============================

system_stats_v3(){
    echo ""
    echo -e "$CYAN[ SYSTEM STATISTICS V3 ]$NC"
    
    # Uptime
    uptime_formatted=$(uptime -p)
    echo -e "  Uptime: $GREEN$uptime_formatted$NC"
    
    # Carga del sistema
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | tr -d ' ')
    echo -e "  Load Average: $YELLOW$load_avg$NC"
    
    # Procesos
    process_count=$(ps aux | wc -l)
    echo -e "  Running Processes: $CYAN$process_count$NC"
    
    # Usuarios conectados
    users=$(who | wc -l)
    echo -e "  Active Users: $MAG$users$NC"
    
    # Tiempo de ejecución del panel
    current_time=$(date +%s)
    runtime=$((current_time - START_TIME))
    hours=$((runtime / 3600))
    minutes=$(((runtime % 3600) / 60))
    seconds=$((runtime % 60))
    echo -e "  Panel Runtime: $BLUE${hours}h ${minutes}m ${seconds}s$NC"
    
    # Versión del kernel
    echo -e "  Kernel: $ORANGE$(uname -r)$NC"
}

# ============================
# DASHBOARD PRINCIPAL V3
# ============================

dashboard_v3(){
    clear
    
    dragon_v3
    
    echo -e "$MAG🔥 KALI HACKER CONTROL PANEL V3 🔥$NC"
    echo "=========================================="
    
    echo ""
    echo -e "$YELLOW[ SYSTEM INFORMATION V3 ]$NC"
    echo "User      : $(whoami)"
    echo "Host      : $(hostname)"
    echo "Public IP : $PUBLIC_IP"
    
    cpu_bar_v3
    ram_bar_v3
    disk_bar_v3
    system_stats_v3
    
    echo ""
    echo -e "$YELLOW[ NETWORK SECURITY V3 ]$NC"
    echo "Interface : $IFACE"
    echo "Local IP  : $IP"
    echo "Gateway   : $GW"
    
    network_map_v3
    ports_v3
    traffic_v3
    sniffer_v3
    attack_detector_v3
    show_logs_v3
    
    echo ""
    echo -e "$GREEN[ Press Ctrl+C to exit | Refresh in 5s ]$NC"
    
    # Guardar en historial
    echo "$(date): Dashboard V3 refreshed" >> "$HISTORY_FILE"
}

# ============================
# EFECTO MR ROBOT V3
# ============================

mrrobot_v3(){
    echo ""
    echo -e "$RED[+] Initializing cyber console v3...$NC"
    sleep 0.3
    echo -e "$GREEN[+] Loading advanced security modules...$NC"
    sleep 0.3
    echo -e "$CYAN[+] Connecting to network core...$NC"
    sleep 0.3
    echo -e "$BLUE[+] Activating AI threat detection...$NC"
    sleep 0.3
    echo -e "$MAG[+] Quantum encryption enabled...$NC"
    sleep 0.3
    echo -e "$ORANGE[+] System ready for cyber operations.$NC"
    echo ""
}

# ============================
# LIMPIEZA AL SALIR
# ============================

cleanup_v3(){
    echo ""
    echo -e "$GREEN[+] Shutting down gracefully...$NC"
    echo -e "$CYAN[+] Session logged to $HISTORY_FILE$NC"
    echo -e "$YELLOW[+] Security alerts saved to $ALERT_FILE$NC"
    echo -e "$MAG[+] Total runtime: $(( ($(date +%s) - START_TIME) / 60 )) minutes$NC"
    echo -e "$GREEN[+] Stay safe, hacker!$NC"
    exit 0
}

trap cleanup_v3 SIGINT SIGTERM

# ============================
# INICIO
# ============================

mrrobot_v3

while true
do
    dashboard_v3
    sleep 5
done
