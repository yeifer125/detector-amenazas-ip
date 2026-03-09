from scapy.all import sniff
from queue import Queue

packet_queue = Queue()

def process_packet(pkt):
    try:
        src = pkt[0][1].src
        dst = pkt[0][1].dst
        proto = pkt.summary()
        packet_queue.put(f"{src} → {dst} | {proto}")
    except:
        pass

def start_sniffer():
    sniff(prn=process_packet, store=False)
