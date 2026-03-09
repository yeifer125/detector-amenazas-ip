import requests

def locate(ip):
    try:
        r = requests.get(f"https://ipinfo.io/{ip}/json").json()
        city = r.get("city","?")
        country = r.get("country","?")
        return f"{city}, {country}"
    except:
        return "Unknown"
