#!/bin/bash

# ============================
# PANEL DE CONTROL KALI CIBERSEGURIDAD V4
# ============================

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAG='\033[1;35m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
ORANGE='\033[1;93m'
PURPLE='\033[1;95m'
NC='\033[0m'

# Configuración
LOG_FILE="/tmp/kali-soc.log"
HISTORY_FILE="/tmp/kali-soc-history.txt"
ALERT_FILE="/tmp/kali-soc-alerts.txt"
THREAT_FILE="/tmp/kali-soc-threats.txt"
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
> "$THREAT_FILE"

# ============================
# DRAGON V4
# ============================

dragon_v4(){
echo -e "$PURPLE"
cat << "EOF"

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣤⣤⣤⣀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣦
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⡿⠟⠛⠻⢿⣿⣿⣧
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⠃⠀⠀⠀⠀⠀⠈⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣧⠀⠀⠀⠀⠀⠀⣠⣿⣿⡿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠿⠿⠶⠶⠶⠶⠿⠿⠟⠋

              KALI LINUX V4
        CONSOLA CUÁNTICA OFENSIVA DE SEGURIDAD

EOF
echo -e "$NC"
}

# ============================
# BARRAS DE PROGRESO V4
# ============================

cpu_bar_v4(){
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
        STATUS="🔥 CRÍTICO"
        echo "$(date): CPU CRÍTICO - $CPU%" >> "$ALERT_FILE"
    elif [ "$CPU" -gt 60 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ ADVERTENCIA"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    # Barra de progreso
    FILLED=$((CPU/2))
    EMPTY=$((50-FILLED))
    BAR=$(printf "%0.s█" $(seq 1 $FILLED))
    EMPTY_BAR=$(printf "%0.s░" $(seq 1 $EMPTY))
    
    echo -e "Uso CPU : $COLOR$CPU% [$BAR$EMPTY_BAR]$NC $STATUS"
}

ram_bar_v4(){
    RAM_USED=$(free | awk '/Mem:/ {print $3}')
    RAM_TOTAL=$(free | awk '/Mem:/ {print $2}')
    RAM_P=$((RAM_USED*100/RAM_TOTAL))
    
    # Color dinámico
    if [ "$RAM_P" -gt "$THRESHOLD_RAM" ]; then
        COLOR="$RED"
        STATUS="🔥 CRÍTICO"
        echo "$(date): RAM CRÍTICO - $RAM_P%" >> "$ALERT_FILE"
    elif [ "$RAM_P" -gt 70 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ ADVERTENCIA"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    # Barra de progreso
    FILLED=$((RAM_P/2))
    EMPTY=$((50-FILLED))
    BAR=$(printf "%0.s█" $(seq 1 $FILLED))
    EMPTY_BAR=$(printf "%0.s░" $(seq 1 $EMPTY))
    
    echo -e "Uso RAM : $COLOR$RAM_P% [$BAR$EMPTY_BAR]$NC $STATUS"
}

disk_bar_v4(){
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    
    # Validar que sea un número
    if ! [[ "$DISK_USAGE" =~ ^[0-9]+$ ]]; then
        DISK_USAGE=0
    fi
    
    # Color dinámico
    if [ "$DISK_USAGE" -gt "$THRESHOLD_DISK" ]; then
        COLOR="$RED"
        STATUS="🔥 CRÍTICO"
        echo "$(date): DISCO CRÍTICO - $DISK_USAGE%" >> "$ALERT_FILE"
    elif [ "$DISK_USAGE" -gt 80 ]; then
        COLOR="$YELLOW"
        STATUS="⚠️ ADVERTENCIA"
    else
        COLOR="$GREEN"
        STATUS="✅ NORMAL"
    fi
    
    # Barra de progreso
    FILLED=$((DISK_USAGE/2))
    EMPTY=$((50-FILLED))
    BAR=$(printf "%0.s█" $(seq 1 $FILLED))
    EMPTY_BAR=$(printf "%0.s░" $(seq 1 $EMPTY))
    
    echo -e "Uso Disco: $COLOR$DISK_USAGE% [$BAR$EMPTY_BAR]$NC $STATUS"
}

# ============================
# MAPA DE RED V4
# ============================

network_map_v4(){
    echo ""
    echo -e "$CYAN[ MAPA DE RED V4 ]$NC"
    echo ""
    echo "           INTERNET"
    echo "              │"
    echo "        $GW (Gateway)"
    echo "              │"
    echo "        $IP (TÚ) -> $PUBLIC_IP"
    echo ""
    
    # Escaneo mejorado con conteo
    echo -e "$YELLOW[ Dispositivos Descubiertos ]$NC"
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
    
    # Mostrar conteo total
    total_devices=$(arp-scan --localnet --interface=$IFACE 2>/dev/null | grep -c "^[0-9]" 2>/dev/null || echo "0")
    echo -e "  Total dispositivos: $MAG$total_devices$NC"
}

# ============================
# SNIFFER AVANZADO V4
# ============================

sniffer_v4(){
    echo ""
    echo -e "$CYAN[ ANÁLISIS CUÁNTICO DE PAQUETES V4 ]$NC"
    
    # Captura con análisis mejorado
    timeout 2 tcpdump -i $IFACE -nn -c 8 2>/dev/null | while read line; do
        timestamp=$(date '+%H:%M:%S')
        
        # Análisis avanzado de tráfico
        if echo "$line" | grep -qi "http"; then
            traffic_type="🌐 HTTP"
        elif echo "$line" | grep -qi "https"; then
            traffic_type="🔒 HTTPS"
        elif echo "$line" | grep -qi "ssh"; then
            traffic_type="🔐 SSH"
        elif echo "$line" | grep -qi "dns"; then
            traffic_type="🔍 DNS"
        elif echo "$line" | grep -qi "ftp"; then
            traffic_type="📁 FTP"
        elif echo "$line" | grep -qi "icmp"; then
            traffic_type="📡 ICMP"
        else
            traffic_type="📦 DATOS"
        fi
        
        # Extraer IPs si es posible
        if echo "$line" | grep -q "IP"; then
            src_ip=$(echo "$line" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
            dst_ip=$(echo "$line" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | tail -1)
            if [ -n "$src_ip" ] && [ -n "$dst_ip" ]; then
                echo -e "  $MAG[$timestamp]$NC $traffic_type $GREEN$src_ip$NC → $BLUE$dst_ip$NC"
            else
                echo -e "  $MAG[$timestamp]$NC $traffic_type $GREEN$line$NC"
            fi
        else
            echo -e "  $MAG[$timestamp]$NC $traffic_type $GREEN$line$NC"
        fi
    done
}

# ============================
# DETECTOR DE AMENAZAS V4
# ============================

attack_detector_v4(){
    echo ""
    echo -e "$CYAN[ DETECCIÓN CUÁNTICA DE AMENAZAS V4 ]$NC"
    
    threat_level=0
    threats_found=()
    
    # Detección SYN flood
    SYN=$(ss -ant state syn-recv | wc -l)
    if [ "$SYN" -gt 20 ]; then
        echo -e "$RED🚨 ¡Ataque SYN flood detectado! ($SYN conexiones)$NC"
        echo "$(date): ATAQUE SYN FLOOD - $SYN conexiones" >> "$ALERT_FILE"
        threats_found+=("SYN FLOOD: $SYN")
        threat_level=$((threat_level + 3))
    fi
    
    # Detección de conexiones sospechosas
    SUSPICIOUS=$(ss -ant | grep -E ":22|:3389|:5900" | wc -l)
    if [ "$SUSPICIOUS" -gt 5 ]; then
        echo -e "$YELLOW⚠️ Alto número de conexiones remotas ($SUSPICIOUS)$NC"
        threats_found+=("CONEXIONES REMOTAS: $SUSPICIOUS")
        threat_level=$((threat_level + 1))
    fi
    
    # Detección de escaneo de puertos (corregido)
    PORT_SCAN=$(journalctl -u sshd --since "1 minute ago" 2>/dev/null | grep -c "Invalid user" 2>/dev/null || echo "0")
    if [ -n "$PORT_SCAN" ] && [[ "$PORT_SCAN" =~ ^[0-9]+$ ]]; then
        if [ "$PORT_SCAN" -gt 10 ]; then
            echo -e "$RED🔥 ¡Escaneo de puertos detectado! ($PORT_SCAN intentos)$NC"
            echo "$(date): ATAQUE DE ESCANEO DE PUERTOS - $PORT_SCAN intentos" >> "$ALERT_FILE"
            threats_found+=("ESCANEO PUERTOS: $PORT_SCAN")
            threat_level=$((threat_level + 2))
        fi
    fi
    
    # Detección de conexiones establecidas inusuales
    ESTABLISHED=$(ss -ant state established | wc -l)
    if [ "$ESTABLISHED" -gt 100 ]; then
        echo -e "$ORANGE🔥 Número inusual de conexiones establecidas ($ESTABLISHED)$NC"
        threats_found+=("ESTABLECIDAS: $ESTABLISHED")
        threat_level=$((threat_level + 1))
    fi
    
    # Guardar amenazas detectadas
    if [ ${#threats_found[@]} -gt 0 ]; then
        echo "$(date): Amenazas detectadas: ${threats_found[*]}" >> "$THREAT_FILE"
    fi
    
    # Estado general basado en nivel de amenaza
    if [ "$threat_level" -ge 5 ]; then
        echo -e "$RED🔴 NIVEL DE AMENAZA: CRÍTICO$NC"
    elif [ "$threat_level" -ge 3 ]; then
        echo -e "$YELLOW🟡 NIVEL DE AMENAZA: ALTO$NC"
    elif [ "$threat_level" -ge 1 ]; then
        echo -e "$ORANGE🟠 NIVEL DE AMENAZA: MEDIO$NC"
    else
        echo -e "$GREEN🟢 NIVEL DE AMENAZA: BAJO$NC"
    fi
}

# ============================
# ANÁLISIS DE PUERTOS V4
# ============================

ports_v4(){
    echo ""
    echo -e "$CYAN[ ANÁLISIS AVANZADO DE PUERTOS V4 ]$NC"
    
    echo -e "$YELLOW[ Puertos Abiertos ]$NC"
    ss -tuln | awk 'NR>1 && $5!="" {print $1" "$5}' | while read proto port; do
        if [ -n "$port" ]; then
            port_num=$(echo "$port" | cut -d: -f2)
            if [ -n "$port_num" ] && [[ "$port_num" =~ ^[0-9]+$ ]]; then
                service=$(getent services "$port_num" 2>/dev/null | awk '{print $1}' || echo "Unknown")
                
                # Clasificación de peligrosidad mejorada
                case $port_num in
                    23|135|139|445|3389) danger="$RED🔴 ALTO$NC" ;;
                    21|25|53|80|110|143|443|993|995) danger="$YELLOW🟡 MEDIO$NC" ;;
                    22|8080|8443|9050) danger="$ORANGE🟠 BAJO$NC" ;;
                    *) danger="$GREEN🟢 SEGURO$NC" ;;
                esac
                
                # Añadir descripción para puertos comunes
                case $port_num in
                    22) desc="Shell Seguro" ;;
                    80) desc="Web HTTP" ;;
                    443) desc="Web HTTPS" ;;
                    53) desc="Servidor DNS" ;;
                    25) desc="Correo SMTP" ;;
                    110) desc="Correo POP3" ;;
                    143) desc="Correo IMAP" ;;
                    21) desc="Transferencia FTP" ;;
                    3389) desc="Escritorio Remoto" ;;
                    5432) desc="Base PostgreSQL" ;;
                    3306) desc="Base MySQL" ;;
                    *) desc="${service:0:20}" ;;
                esac
                
                echo -e "  $GREEN$proto$NC | $CYAN$port_num$NC | $YELLOW${desc:0:15}$NC | $danger"
            fi
        fi
    done
}

# ============================
# ANÁLISIS DE TRÁFICO V4
# ============================

traffic_v4(){
    echo ""
    echo -e "$CYAN[ ANÁLISIS AVANZADO DE TRÁFICO V4 ]$NC"
    
    # Estadísticas de interfaz
    if [ -d "/sys/class/net/$IFACE" ]; then
        rx_bytes=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
        tx_bytes=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
        rx_packets=$(cat /sys/class/net/$IFACE/statistics/rx_packets)
        tx_packets=$(cat /sys/class/net/$IFACE/statistics/tx_packets)
        rx_errors=$(cat /sys/class/net/$IFACE/statistics/rx_errors)
        tx_errors=$(cat /sys/class/net/$IFACE/statistics/tx_errors)
        
        # Formatear bytes a MB/GB
        rx_mb=$((rx_bytes / 1048576))
        tx_mb=$((tx_bytes / 1048576))
        
        echo -e "  RX: $GREEN${rx_mb} MB ($rx_packets paquetes, $rx_errors errores)$NC"
        echo -e "  TX: $BLUE${tx_mb} MB ($tx_packets paquetes, $tx_errors errores)$NC"
        
        # Cálculo de tasa si ifstat está disponible
        if command -v ifstat >/dev/null 2>&1; then
            traffic_data=$(ifstat -i $IFACE 1 1 2>/dev/null | tail -n 1)
            if [ -n "$traffic_data" ]; then
                rx_rate=$(echo "$traffic_data" | awk '{print $1}')
                tx_rate=$(echo "$traffic_data" | awk '{print $2}')
                echo -e "  Tasa: RX $GREEN${rx_rate} KB/s$NC | TX $BLUE${tx_rate} KB/s$NC"
            fi
        fi
        
        # Calcular ratio de errores
        if [ "$rx_packets" -gt 0 ]; then
            rx_error_ratio=$((rx_errors * 100 / rx_packets))
            if [ "$rx_error_ratio" -gt 1 ]; then
                echo -e "  Ratio Errores RX: $RED${rx_error_ratio}%$NC"
            else
                echo -e "  Ratio Errores RX: $GREEN${rx_error_ratio}%$NC"
            fi
        fi
    else
        echo -e "  $RED Interfaz $IFACE no encontrada$NC"
    fi
}

# ============================
# SISTEMA DE LOGS V4
# ============================

show_logs_v4(){
    echo ""
    echo -e "$CYAN[ REGISTROS DE SEGURIDAD CUÁNTICA V4 ]$NC"
    
    # Alertas críticas recientes
    if [ -f "$ALERT_FILE" ] && [ -s "$ALERT_FILE" ]; then
        alert_count=$(wc -l < "$ALERT_FILE" 2>/dev/null || echo 0)
        echo -e "$RED[ Alertas Críticas ($alert_count) ]$NC"
        tail -n 3 "$ALERT_FILE" | while read line; do
            echo -e "  $RED🚨 $line$NC"
        done
    else
        echo -e "  $GREEN✅ Sin alertas críticas$NC"
    fi
    
    # Amenazas detectadas
    if [ -f "$THREAT_FILE" ] && [ -s "$THREAT_FILE" ]; then
        threat_count=$(wc -l < "$THREAT_FILE" 2>/dev/null || echo 0)
        echo -e "$ORANGE[ Amenazas Detectadas ($threat_count) ]$NC"
        tail -n 2 "$THREAT_FILE" | while read line; do
            echo -e "  $ORANGE⚠️ $line$NC"
        done
    fi
    
    # Historial de eventos
    if [ -f "$HISTORY_FILE" ] && [ -s "$HISTORY_FILE" ]; then
        echo -e "$YELLOW[ Historial de Eventos ]$NC"
        tail -n 2 "$HISTORY_FILE" | while read line; do
            echo -e "  $CYAN📝 $line$NC"
        done
    fi
}

# ============================
# ESTADÍSTICAS DEL SISTEMA V4
# ============================

system_stats_v4(){
    echo ""
    echo -e "$CYAN[ ESTADÍSTICAS CUÁNTICAS DEL SISTEMA V4 ]$NC"
    
    # Uptime
    uptime_formatted=$(uptime -p)
    echo -e "  Tiempo Activo: $GREEN$uptime_formatted$NC"
    
    # Carga del sistema
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | tr -d ' ')
    echo -e "  Carga Promedio: $YELLOW$load_avg$NC"
    
    # Procesos
    process_count=$(ps aux | wc -l)
    echo -e "  Procesos Activos: $CYAN$process_count$NC"
    
    # Usuarios conectados
    users=$(who | wc -l)
    user_list=$(who | awk '{print $1}' | sort -u | tr '\n' ', ' | sed 's/,$//')
    echo -e "  Usuarios Activos: $MAG$users$NC ($user_list)"
    
    # Tiempo de ejecución del panel
    current_time=$(date +%s)
    runtime=$((current_time - START_TIME))
    hours=$((runtime / 3600))
    minutes=$(((runtime % 3600) / 60))
    seconds=$((runtime % 60))
    echo -e "  Tiempo del Panel: $BLUE${hours}h ${minutes}m ${seconds}s$NC"
    
    # Versión del kernel
    echo -e "  Kernel: $ORANGE$(uname -r)$NC"
    
    # Arquitectura
    arch=$(uname -m)
    echo -e "  Arquitectura: $PURPLE$arch$NC"
    
    # Memoria swap (corregido)
    swap_info=$(free | awk '/Swap:/ {print $3" "$4}')
    swap_used=$(echo $swap_info | awk '{print $1}')
    swap_total=$(echo $swap_info | awk '{print $2}')
    
    if [ -n "$swap_total" ] && [ "$swap_total" -gt 0 ]; then
        swap_total_calc=$((swap_used + swap_total))
        if [ "$swap_total_calc" -gt 0 ]; then
            swap_p=$((swap_used * 100 / swap_total_calc))
            echo -e "  Uso Swap: $YELLOW${swap_p}%$NC"
        else
            echo -e "  Uso Swap: $GREENDesactivado$NC"
        fi
    else
        echo -e "  Uso Swap: $GREENDesactivado$NC"
    fi
}

# ============================
# DASHBOARD PRINCIPAL V4
# ============================

dashboard_v4(){
    clear
    
    dragon_v4
    
    echo -e "$MAG🔥 PANEL CUÁNTICO DE CONTROL KALI V4 🔥$NC"
    echo "=========================================="
    
    echo ""
    echo -e "$YELLOW[ SISTEMA CUÁNTICO V4 ]$NC"
    echo "Usuario   : $(whoami)"
    echo "Host      : $(hostname)"
    echo "IP Pública: $PUBLIC_IP"
    
    cpu_bar_v4
    ram_bar_v4
    disk_bar_v4
    system_stats_v4
    
    echo ""
    echo -e "$YELLOW[ SEGURIDAD DE RED CUÁNTICA V4 ]$NC"
    echo "Interfaz  : $IFACE"
    echo "IP Local  : $IP"
    echo "Gateway   : $GW"
    
    network_map_v4
    ports_v4
    traffic_v4
    sniffer_v4
    attack_detector_v4
    show_logs_v4
    
    echo ""
    echo -e "$GREEN[ Presiona Ctrl+C para salir | Auto-refresco en 5s ]$NC"
    
    # Guardar en historial
    echo "$(date): Dashboard Cuántico V4 actualizado" >> "$HISTORY_FILE"
}

# ============================
# EFECTO MR ROBOT V4
# ============================

mrrobot_v4(){
    echo ""
    echo -e "$RED[+] Inicializando consola ciber cuántica v4...$NC"
    sleep 0.2
    echo -e "$GREEN[+] Cargando módulos de seguridad con IA...$NC"
    sleep 0.2
    echo -e "$CYAN[+] Conectando al núcleo de red cuántico...$NC"
    sleep 0.2
    echo -e "$BLUE[+] Activando detección neuronal de amenazas...$NC"
    sleep 0.2
    echo -e "$MAG[+] Protocolos de encriptación cuántica activados...$NC"
    sleep 0.2
    echo -e "$PURPLE[+] Monitoreo de dark web activo...$NC"
    sleep 0.2
    echo -e "$ORANGE[+] Sistema listo para operaciones ciber avanzadas.$NC"
    echo ""
}

# ============================
# LIMPIEZA AL SALIR
# ============================

cleanup_v4(){
    echo ""
    echo -e "$GREEN[+] Apagando consola cuántica...$NC"
    echo -e "$CYAN[+] Sesión registrada en $HISTORY_FILE$NC"
    echo -e "$YELLOW[+] Alertas de seguridad guardadas en $ALERT_FILE$NC"
    echo -e "$MAG[+] Análisis de amenazas guardado en $THREAT_FILE$NC"
    
    current_time=$(date +%s)
    runtime=$((current_time - START_TIME))
    echo -e "$BLUE[+] Tiempo total de ejecución: $((runtime / 60)) minutos$NC"
    
    # Estadísticas finales
    if [ -f "$ALERT_FILE" ]; then
        alert_count=$(wc -l < "$ALERT_FILE" 2>/dev/null || echo 0)
        echo -e "$YELLOW[+] Total alertas generadas: $alert_count$NC"
    fi
    
    if [ -f "$THREAT_FILE" ]; then
        threat_count=$(wc -l < "$THREAT_FILE" 2>/dev/null || echo 0)
        echo -e "$ORANGE[+] Total amenazas detectadas: $threat_count$NC"
    fi
    
    echo -e "$GREEN[+] Mantente seguro en la matrix, hacker!$NC"
    exit 0
}

trap cleanup_v4 SIGINT SIGTERM

# ============================
# INICIO
# ============================

mrrobot_v4

while true
do
    dashboard_v4
    sleep 5
done
