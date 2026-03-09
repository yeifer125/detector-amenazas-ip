import sys
import psutil
import threading

from PyQt6.QtWidgets import *
from PyQt6.QtCore import *

from modules.sniffer import packet_queue, alert_queue, start_sniffer
from modules.network_map import scan_network
from modules.geoip import locate


class SOC(QWidget):

    def __init__(self):

        super().__init__()

        self.setWindowTitle("Kali SOC Dashboard")
        self.resize(1100,750)

        layout = QVBoxLayout()

        # TITLE
        self.title = QLabel("🐉 KALI SOC DASHBOARD")
        self.title.setStyleSheet("font-size:24px;color:#00ff9c")

        # SYSTEM
        self.stats = QLabel()

        # NETWORK MAP
        self.network = QTextEdit()
        self.network.setReadOnly(True)

        # SNIFFER
        self.sniffer = QTextEdit()
        self.sniffer.setReadOnly(True)

        # IDS ALERTS
        self.alerts = QTextEdit()
        self.alerts.setReadOnly(True)

        # GEO
        self.geo = QLabel()

        layout.addWidget(self.title)
        layout.addWidget(self.stats)

        layout.addWidget(QLabel("🌍 Network Map"))
        layout.addWidget(self.network)

        layout.addWidget(QLabel("📡 Live Sniffer"))
        layout.addWidget(self.sniffer)

        layout.addWidget(QLabel("🧠 IDS Alerts"))
        layout.addWidget(self.alerts)

        layout.addWidget(QLabel("🛰 Public IP Location"))
        layout.addWidget(self.geo)

        self.setLayout(layout)

        # timers
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_stats)
        self.timer.start(2000)

        self.timer2 = QTimer()
        self.timer2.timeout.connect(self.update_packets)
        self.timer2.start(300)

        self.timer3 = QTimer()
        self.timer3.timeout.connect(self.update_network)
        self.timer3.start(15000)

        self.get_geo()

        threading.Thread(target=start_sniffer, daemon=True).start()

    def update_stats(self):

        cpu = psutil.cpu_percent()
        ram = psutil.virtual_memory().percent

        self.stats.setText(f"CPU: {cpu}%   RAM: {ram}%")

    def update_packets(self):

        while not packet_queue.empty():

            pkt = packet_queue.get()
            self.sniffer.append(pkt)

        while not alert_queue.empty():

            alert = alert_queue.get()
            self.alerts.append(alert)

    def update_network(self):

        devices = scan_network()

        self.network.clear()

        for d in devices:
            self.network.append(d)

    def get_geo(self):

        ip = "8.8.8.8"
        loc = locate(ip)

        self.geo.setText(loc)


app = QApplication(sys.argv)

window = SOC()
window.show()

sys.exit(app.exec())
