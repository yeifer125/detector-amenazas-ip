from PyQt6.QtWidgets import QGraphicsView, QGraphicsScene, QGraphicsEllipseItem, QGraphicsTextItem, QGraphicsLineItem
from PyQt6.QtCore import Qt, QPointF
from PyQt6.QtGui import QPainter, QBrush, QColor, QPen
import random
import math

class NetworkMap(QGraphicsView):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.scene = QGraphicsScene()
        self.setScene(self.scene)
        self.setRenderHint(QPainter.RenderHint.Antialiasing)
        self.setStyleSheet("background-color: #050505; border: 1px solid #333;")

        self.nodes = {}  # Diccionario para rastrear IPs y sus objetos visuales
        self.setup_central_node()

    def setup_central_node(self):
        # Nodo central (localhost / tú)
        self.add_node("LOCAL_HOST", 0, 0, QColor("#00ff9c"), is_main=True)

    def add_node(self, label, x, y, color, is_main=False):
        size = 40 if is_main else 25

        # El círculo del nodo
        node = self.scene.addEllipse(0, 0, size, size, QPen(QColor("#555")), QBrush(color))
        node.setPos(x - size/2, y - size/2)

        # Etiqueta
        text = self.scene.addText(label)
        text.setDefaultTextColor(QColor("#ffffff"))
        text.setPos(x - 20, y + size/2 + 5)

        return node

    def update_map(self, ip):
        if ip in self.nodes or ip == "127.0.0.1" or ":" in ip:
            return

        # Calcular posición aleatoria en un radio para los nuevos nodos
        angle = random.uniform(0, 2 * math.pi)
        distance = random.randint(150, 250)
        x = math.cos(angle) * distance
        y = math.sin(angle) * distance

        # Dibujar línea de conexión al centro
        line = self.scene.addLine(0, 0, x, y, QPen(QColor("#222"), 1))
        line.setZValue(-1) # Enviar al fondo

        # Añadir el nodo de la nueva IP
        color = QColor("#ff3e3e") if random.random() > 0.8 else QColor("#00aaff")
        self.nodes[ip] = self.add_node(ip, x, y, color)

        # Ajustar la vista para que todo sea visible
        self.setSceneRect(self.scene.itemsBoundingRect().adjusted(-50, -50, 50, 50))
