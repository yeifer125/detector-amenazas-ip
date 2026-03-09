from scapy.all import sniff
from queue import Queue
from modules.ids import analyze_packet

packet_queue = Queue()
alert_queue = Queue()

def process_packet(pkt):

    try:
        src = pkt[0][1].src
        dst = pkt[0][1].dst
        proto = pkt.summary()

        packet_queue.put(f"{src} → {dst} | {proto}")

        alerts = analyze_packet(src)

        for a in alerts:
            alert_queue.put(a)

    except:
        pass


def start_sniffer():

    sniff(prn=process_packet, store=False)
