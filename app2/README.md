# SOC Panel - Security Operations Center

![Screenshot](screen.png)

Panel de monitoreo de seguridad de red con interfaz gráfica PyQt6.

## Características
- Sniffer de red en tiempo real
- Mapa de red visual
- Sistema de detección de intrusiones (IDS)
- Monitoreo de recursos (CPU/RAM)
- Sistema de alertas con niveles DEFCON
- Geolocalización de IPs
- Consola de comandos integrada

## Instalación

### Desde el ejecutable (recomendado)
1. Copia el ejecutable `dist/SOC-Panel` a `/usr/local/bin/`
2. Crea un lanzador en el escritorio con `Desktop/SOC-Panel.desktop`
3. Ejecuta con doble clic o desde el menú de aplicaciones

### Desde código fuente
1. Crea entorno virtual: `python3 -m venv venv`
2. Activa: `source venv/bin/activate`
3. Instala dependencias: `pip install PyQt6 scapy psutil requests`
4. Ejecuta: `sudo python soc_panel.py`

## Dependencias
- PyQt6
- Scapy
- psutil
- requests

## Uso
La aplicación requiere privilegios de root para el sniffing de red.

## Construcción
Para crear el ejecutable:
```bash
pip install pyinstaller
pyinstaller --onefile --windowed --name "SOC-Panel" --add-data "modules:modules" soc_panel.py
```

## Licencia
Proyecto educativo de ciberseguridad.
