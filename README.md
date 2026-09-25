# 🌐 Global Status Radar & n8n Monitoring Panel

> Stack *self-hosted* en un Mini PC con Ubuntu que combina **automatización (n8n)**, **monitorización (Zabbix + Grafana)** y un **panel web PWA**, expuesto con **Cloudflare Tunnels** sin abrir puertos en el router.

![n8n](https://img.shields.io/badge/n8n-Automation-EA4B71?logo=n8n&logoColor=white)
![Zabbix](https://img.shields.io/badge/Zabbix-Monitoring-EE0000?logo=Zabbix&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-Dashboards-F46800?logo=Grafana&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=Docker&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnels-F38020?logo=Cloudflare&logoColor=white)

---

## 📌 Stack *Self-Hosted* de Monitorización y Automatización

Este repositorio contiene la arquitectura completa implementada en un Mini PC con Ubuntu (`~/stack`). Su objetivo es servir como un panel centralizado de control y observabilidad en tiempo real, totalmente autónomo, seguro y desplegado mediante contenedores Docker.

### 📊 Desglose de Componentes Principales
- **n8n:** Orquestador de flujos de trabajo (*workflow automation*). Se encarga de consultar periódicamente APIs externas de estatus, procesar feeds RSS de telecomunicaciones y gestionar las reglas de alerta.
- **Zabbix:** Monitorización robusta a nivel de infraestructura, recursos de sistema del Mini PC y métricas operativas.
- **Grafana:** Paneles de visualización avanzados y métricas en tiempo real. Configurado con acceso anónimo de solo lectura (*Viewer*) para permitir su incrustación directa y fluida dentro del panel web del proyecto.
- **Panel Web PWA (`app/`):** Dashboard ultra ligero desarrollado en HTML5, CSS3 y JavaScript nativo asíncrono que consume el webhook consolidado de n8n (`/webhook/estado-global`) para renderizar el estado de los servicios en una interfaz limpia en modo oscuro.
- **Cloudflare Tunnels (`cloudflared`):** Capa de acceso seguro hacia el exterior sin necesidad de abrir puertos en el router ni exponer IPs públicas directamente.

---

## 🤖 Flujos de Automatización en n8n (`n8n/workflows/workflows.json`)

Los flujos de trabajo de n8n se encuentran exportados, versionados y limpios de credenciales dentro de la carpeta del proyecto:

- **Flujo Radar (Global Status):** Consulta periódicamente las APIs REST de múltiples proveedores cloud e infraestructura (AWS, Cloudflare, Google Cloud, GitHub, OpenAI, Discord, Atlassian, Azure) y unifica todos los estados en un único objeto JSON estructurado (`/webhook/estado-global`).
- **Flujo de Detección RSS (Telecomunicaciones):** Monitorización automatizada de feeds RSS/XML (incluyendo Google News y fuentes especializadas del sector) mediante filtros de texto avanzados para detectar en tiempo real incidencias o caídas de operadores de red y servicios de telecomunicaciones.
- **Flujo de Alertas Multicanal:** Sistema automatizado capaz de despachar notificaciones críticas de forma inmediata ante cualquier anomalía a través de dos canales:
  - **Telegram:** Alertas directas al canal o chat privado.
  - **Correo Electrónico (SMTP):** Envío automatizado de avisos detallados con el histórico de la incidencia.
- **Bot de Telegram Interactivo:** Permite consultar el estado general del stack y abrir dashboards de forma cómoda mediante un menú interactivo con botones (`/panel`), gestionado mediante un nodo *Telegram Trigger* y un enrutador de comandos interno.

---

## 📂 Estructura del Repositorio

```text
radar-monitoring-stack/
├── app/
│   ├── index.html            # Panel principal (enlaces + dashboards Grafana)
│   ├── radar.html            # Radar de estado global en tiempo real
│   ├── manifest.json         # Manifiesto para Progressive Web App (PWA)
│   ├── service-worker.js     # Service worker para caché y offline
│   └── icon-*.png            # Iconos de la aplicación
├── n8n/
│   ├── workflows/
│   │   └── workflows.json    # Workflows exportados de n8n (purgados de secretos)
│   └── README.md             # Documentación específica de automatizaciones
├── docs/                     # Capturas de pantalla e imágenes de arquitectura
│   ├── Dashboard_Grafana.png
│   ├── Radar.png
│   ├── Respond_to_Webhook.png
│   ├── Vista_Principal.png
│   ├── Workflow_Alertas.png
│   └── Workflow_Radar.png
├── docker-compose.example.yml # Plantilla oficial de Docker Compose
├── .env.example              # Plantilla de variables de entorno requeridas
├── update-tunnels.sh         # Script de actualización dinámica de túneles
└── README.md                 # Documentación principal del proyecto
