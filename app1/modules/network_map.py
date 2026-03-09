import subprocess

def scan_network():

    try:

        out = subprocess.check_output(
            ["nmap", "-sn", "192.168.1.0/24"],
            text=True
        )

        devices = []

        for line in out.split("\n"):

            if "Nmap scan report" in line:
                ip = line.split()[-1]
                devices.append(ip)

        return devices

    except:

        return []
