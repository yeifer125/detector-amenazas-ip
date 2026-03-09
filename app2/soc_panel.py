import sys, psutil, threading, subprocess, os, ipaddress, time, json
from collections import defaultdict, deque
from PyQt6.QtWidgets import *
from PyQt6.QtCore import *
from PyQt6.QtGui import QFont, QColor, QPainter, QPen
from modules.sniffer import packet_queue, start_sniffer
from modules.network_map import NetworkMap
from modules.ids import analyze_packet
from modules.geoip import locate

# Configuración de Entorno
LOG_DIR = "logs"
WHITELIST_FILE = os.path.join(LOG_DIR, "whitelist.txt")
SECURITY_LOG = os.path.join(LOG_DIR, "security.log")
TOP_TALKERS_LOG = os.path.join(LOG_DIR, "top_talkers.log")

if not os.path.exists(LOG_DIR): os.makedirs(LOG_DIR)

def load_whitelist():
    if os.path.exists(WHITELIST_FILE):
        with open(WHITELIST_FILE, "r") as f: return set(ip.strip() for ip in f.readlines() if ip.strip())
    return {"127.0.0.1", "::1"}

def save_whitelist(whitelist):
    with open(WHITELIST_FILE, "w") as f:
        for ip in whitelist: f.write(f"{ip}\n")

class ScanlineOverlay(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setAttribute(Qt.WidgetAttribute.WA_TransparentForMouseEvents)
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setOpacity(0.02)
        painter.setPen(QPen(QColor("#00ff9c"), 1))
        for i in range(0, self.height(), 4): painter.drawLine(0, i, self.width(), i)

class SOC(QWidget):
    def __init__(self):
        super().__init__()
        self.last_threat_ip = None
        self.blocked_ips = set()
        self.geoip_cache = {}
        self.ip_counts = {}
        self.defcon_level = 5
        self.whitelist = load_whitelist()
        self.init_ui()
        self.scanline = ScanlineOverlay(self)

    def resizeEvent(self, event):
        if hasattr(self, 'scanline'): self.scanline.resize(self.size())
        super().resizeEvent(event)

    def is_whitelisted(self, ip):
        try: return ip in self.whitelist or ipaddress.ip_address(ip).is_private
        except: return False

    def get_location(self, ip):
        if ip in self.geoip_cache: return self.geoip_cache[ip]
        loc = "INTERNAL" if self.is_whitelisted(ip) else locate(ip)
        self.geoip_cache[ip] = loc
        return loc

    def init_ui(self):
        self.setWindowTitle("FEDERAL DEFENSE SOC - v5.5 RESIZABLE")
        self.showMaximized()

        self.setStyleSheet("""
            QWidget { background-color: #000000; color: #00ff41; font-family: 'Monospace'; }
            QLabel#DefconLabel { font-size: 14px; font-weight: bold; border: 1px solid #00ff41; padding: 5px; background: #050505; }
            QLabel#SidebarHeader { font-size: 10px; color: #0088ff; font-weight: bold; margin-top: 5px; }
            QTextEdit { background-color: #000000; border: 1px solid #111; color: #00ff41; font-size: 8px; }
            QSplitter::handle { background-color: #1a1a1a; border: 1px solid #333; }
            QLineEdit { background-color: #000; border: 1px solid #00ff41; color: #00ff41; height: 25px; font-size: 10px; }
            QPushButton#PanicBtn { background-color: #330000; color: #f00; border: 1px solid #f00; font-weight: bold; font-size: 9px; height: 20px; }
            QProgressBar { border: 1px solid #111; background: #000; text-align: center; color: white; height: 8px; font-size: 7px; }
            QProgressBar::chunk { background-color: #0088ff; }
        """)

        # Layout principal
        main_box_layout = QVBoxLayout(self)
        main_box_layout.setContentsMargins(0, 0, 0, 0)
        main_box_layout.setSpacing(0)

        # Splitter Horizontal Principal
        self.main_splitter = QSplitter(Qt.Orientation.Horizontal)
        main_box_layout.addWidget(self.main_splitter)

        # --- SIDEBAR IZQUIERDO ---
        left_sidebar = QWidget()
        left_sidebar_layout = QVBoxLayout(left_sidebar)
        left_sidebar_layout.setContentsMargins(5, 5, 5, 5)

        # 1. DEFCON
        self.defcon_label = QLabel("DEFCON 5 - CONDITION: GREEN")
        self.defcon_label.setObjectName("DefconLabel")
        self.defcon_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        left_sidebar_layout.addWidget(self.defcon_label)

        # 2. Stats CPU/RAM
        left_sidebar_layout.addWidget(QLabel("> CORE_RESOURCES", objectName="SidebarHeader"))
        self.stats_display = QLabel("CPU: 0% | RAM: 0%")
        self.stats_display.setStyleSheet("font-size: 11px; color: #00ff41; background: #050505; border: 1px solid #111; padding: 5px;")
        left_sidebar_layout.addWidget(self.stats_display)

        # 3. Arte ASCII Kali Linux
        self.ascii_logo = QLabel("""
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣤⣤⣤⣀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣦
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⡿⠟⠛⠻⢿⣿⣿⣧
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⠃⠀⠀⠀⠀⠀⠈⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣧⠀⠀⠀⠀⠀⠀⣠⣿⣿⡿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠿⠿⠶⠶⠶⠶⠿⠿⠟⠋

              KALI LINUX
        Offensive Security Console""")
        self.ascii_logo.setStyleSheet("font-size: 6px; color: #ffffff; line-height: 1.0; border: none; background: transparent;")
        self.ascii_logo.setAlignment(Qt.AlignmentFlag.AlignCenter)
        left_sidebar_layout.addWidget(self.ascii_logo)

        # 4. Telemetría
        left_sidebar_layout.addWidget(QLabel("> LIVE_TELEMETRY", objectName="SidebarHeader"))
        self.sniffer_box = QTextEdit()
        self.sniffer_box.setReadOnly(True)
        self.sniffer_box.setUndoRedoEnabled(False)
        left_sidebar_layout.addWidget(self.sniffer_box)

        self.main_splitter.addWidget(left_sidebar)

        # --- PANEL DERECHO (OPS CENTER) ---
        right_panel_container = QWidget()
        right_panel_layout = QVBoxLayout(right_panel_container)
        right_panel_layout.setContentsMargins(0, 0, 0, 0)
        right_panel_layout.setSpacing(0)

        # Splitter Vertical Derecho
        self.right_vertical_splitter = QSplitter(Qt.Orientation.Vertical)
        right_panel_layout.addWidget(self.right_vertical_splitter)

        # MAPA
        self.netmap = NetworkMap()
        self.right_vertical_splitter.addWidget(self.netmap)

        # Panel inferior
        bottom_box_container = QWidget()
        bottom_box_layout = QVBoxLayout(bottom_box_container)
        bottom_box_layout.setContentsMargins(0, 0, 0, 0)
        self.bottom_horizontal_splitter = QSplitter(Qt.Orientation.Horizontal)
        bottom_box_layout.addWidget(self.bottom_horizontal_splitter)

        # Alertas
        threat_widget = QWidget()
        threat_layout = QVBoxLayout(threat_widget)
        threat_layout.setContentsMargins(5, 0, 5, 0)
        threat_layout.addWidget(QLabel("> THREAT_AUDIT"))
        self.alerts_box = QTextEdit()
        self.alerts_box.setReadOnly(True)
        self.alerts_box.setStyleSheet("color: #f00; background: #050000; border: 1px solid #200;")
        threat_layout.addWidget(self.alerts_box)
        self.panic_btn = QPushButton("NEUTRALIZE THREAT")
        self.panic_btn.setObjectName("PanicBtn")
        self.panic_btn.clicked.connect(self.panic_action)
        threat_layout.addWidget(self.panic_btn)
        self.bottom_horizontal_splitter.addWidget(threat_widget)

        # Top IPs
        talkers_widget = QWidget()
        talkers_layout = QVBoxLayout(talkers_widget)
        talkers_layout.setContentsMargins(5, 0, 5, 0)
        talkers_layout.addWidget(QLabel("> TOP_SOURCES"))
        self.talkers_container = QVBoxLayout()
        talkers_layout.addLayout(self.talkers_container)
        talkers_layout.addStretch()
        self.bottom_horizontal_splitter.addWidget(talkers_widget)

        self.right_vertical_splitter.addWidget(bottom_box_container)

        # Consola
        self.console_input = QLineEdit()
        self.console_input.setPlaceholderText("SYS_INPUT_PROMPT...")
        self.console_input.returnPressed.connect(self.handle_command)
        right_panel_layout.addWidget(self.console_input)

        self.main_splitter.addWidget(right_panel_container)

        # Proporciones Iniciales
        self.main_splitter.setStretchFactor(0, 1)
        self.main_splitter.setStretchFactor(1, 6)
        self.right_vertical_splitter.setStretchFactor(0, 15)
        self.right_vertical_splitter.setStretchFactor(1, 1)

        # Timers
        self.timer_stats = QTimer(); self.timer_stats.timeout.connect(self.update_stats); self.timer_stats.start(3000)
        self.timer_packets = QTimer(); self.timer_packets.timeout.connect(self.process_incoming_data); self.timer_packets.start(50)

        threading.Thread(target=start_sniffer, daemon=True).start()

    def update_stats(self):
        cpu = psutil.cpu_percent(); ram = psutil.virtual_memory().percent
        self.stats_display.setText(f"CPU: {cpu}% | RAM: {ram}%")
        self.refresh_top_ips(); self.save_top_talkers_log(); self.evaluate_defcon()

    def update_defcon(self, level):
        levels = {5: ("GREEN", "#0f4"), 4: ("BLUE", "#08f"), 3: ("YELLOW", "#ff0"), 2: ("ORANGE", "#f80"), 1: ("RED", "#f00")}
        text, color = levels[level]
        self.defcon_label.setText(f"DEFCON {level} - {text}")
        self.defcon_label.setStyleSheet(f"QLabel#DefconLabel {{ color: {color}; border: 1px solid {color}; background: #050505; padding: 5px; font-weight: bold; }}")

    def evaluate_defcon(self):
        count = len(self.alerts_box.toPlainText().split("\n"))
        if count > 50: self.update_defcon(1)
        elif count > 20: self.update_defcon(2)
        elif count > 5: self.update_defcon(3)
        else: self.update_defcon(5)

    def refresh_top_ips(self):
        for i in reversed(range(self.talkers_container.count())):
            item = self.talkers_container.itemAt(i)
            if item.widget(): item.widget().setParent(None)
        sorted_ips = sorted(self.ip_counts.items(), key=lambda x: x[1], reverse=True)[:5]
        if not sorted_ips: return
        max_val = sorted_ips[0][1]
        for ip, count in sorted_ips:
            bar = QProgressBar(); bar.setMaximum(max_val); bar.setValue(count); bar.setFormat(f"{ip} ({count})")
            self.talkers_container.addWidget(bar)

    def save_top_talkers_log(self):
        if not self.ip_counts: return
        sorted_ips = sorted(self.ip_counts.items(), key=lambda x: x[1], reverse=True)[:5]
        with open(TOP_TALKERS_LOG, "a") as f:
            f.write(f"--- {time.ctime()} ---\n")
            for ip, count in sorted_ips: f.write(f"{ip}: {count}\n")
            f.flush(); os.fsync(f.fileno())

    def process_incoming_data(self):
        count = 0
        while not packet_queue.empty() and count < 10:
            pkt = packet_queue.get()
            self.sniffer_box.append(f"· {pkt}")
            try:
                src = pkt.split(" → ")[0].strip()
                if self.is_whitelisted(src): count += 1; continue
                self.ip_counts[src] = self.ip_counts.get(src, 0) + 1
                alerts = analyze_packet(src)
                for a in alerts:
                    self.last_threat_ip = src
                    self.alerts_box.append(f"!! ALERT: {a} ({self.get_location(src)})")
                if "." in src or ":" in src: self.netmap.update_map(src)
            except: pass
            count += 1
        if count > 0:
            if self.sniffer_box.document().blockCount() > 50: self.sniffer_box.clear()
            self.sniffer_box.moveCursor(self.sniffer_box.textCursor().MoveOperation.End)

    def handle_command(self):
        text = self.console_input.text().strip().lower(); self.console_input.clear()
        if not text: return
        if text == "clear": self.sniffer_box.clear(); self.alerts_box.clear(); self.ip_counts.clear()
        elif text == "panic": self.panic_action()
        elif text.startswith("scan "):
            ip = text.split(" ")[1]
            threading.Thread(target=lambda: self.alerts_box.append(f"[SCAN] {subprocess.getoutput('nmap -F '+ip)}"), daemon=True).start()

    def panic_action(self):
        if self.last_threat_ip:
            self.alerts_box.append(f"[NEUTRALIZED] {self.last_threat_ip}")
            self.blocked_ips.add(self.last_threat_ip)

if __name__ == "__main__":
    app = QApplication(sys.argv); window = SOC(); window.show(); sys.exit(app.exec())
