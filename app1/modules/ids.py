from collections import defaultdict
import time

connections = defaultdict(int)
last_check = time.time()

def analyze_packet(src):

    global last_check

    connections[src] += 1

    if time.time() - last_check > 5:

        alerts = []

        for ip,count in connections.items():

            if count > 50:
                alerts.append(f"⚠ Possible port scan from {ip}")

        connections.clear()
        last_check = time.time()

        return alerts

    return []
