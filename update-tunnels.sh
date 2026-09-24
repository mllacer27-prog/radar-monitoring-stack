#!/bin/bash
set -e

echo "🔍 Obteniendo URLs actuales de los túneles..."

URL_N8N=$(sudo journalctl -u cloudflared-quicktunnel -n 50 --no-pager | grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' | tail -1)
URL_GRAFANA=$(sudo journalctl -u cloudflared-grafana -n 50 --no-pager | grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' | tail -1)
URL_ZABBIX=$(sudo journalctl -u cloudflared-zabbix -n 50 --no-pager | grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' | tail -1)
URL_APP=$(sudo journalctl -u cloudflared-app -n 50 --no-pager | grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' | tail -1)

if [ -z "$URL_N8N" ] || [ -z "$URL_GRAFANA" ] || [ -z "$URL_ZABBIX" ] || [ -z "$URL_APP" ]; then
  echo "❌ No se pudo obtener alguna URL. Comprueba que los 4 servicios cloudflared estén activos."
  exit 1
fi

echo "✅ n8n:     $URL_N8N"
echo "✅ Grafana: $URL_GRAFANA"
echo "✅ Zabbix:  $URL_ZABBIX"
echo "✅ App:     $URL_APP"

echo ""
echo "📝 Actualizando docker-compose.yml (línea 14, WEBHOOK_URL de n8n)..."
sed -i "14s#WEBHOOK_URL=https://[a-z0-9-]*\.trycloudflare\.com/#WEBHOOK_URL=${URL_N8N}/#" ~/stack/docker-compose.yml

echo "📝 Actualizando index.html (líneas fijas: 95=Zabbix, 96=Grafana, 97=n8n, 102 y 107=iframes Grafana)..."
sed -i "95s#href=\"[^\"]*\"#href=\"${URL_ZABBIX}\"#" ~/stack/app/index.html
sed -i "96s#href=\"[^\"]*\"#href=\"${URL_GRAFANA}\"#" ~/stack/app/index.html
sed -i "97s#href=\"[^\"]*\"#href=\"${URL_N8N}\"#" ~/stack/app/index.html
sed -i "102s#src=\"[^\"]*\"#src=\"${URL_GRAFANA}/d/adppndj/dsm?orgId=1\&kiosk\"#" ~/stack/app/index.html
sed -i "107s#src=\"[^\"]*\"#src=\"${URL_GRAFANA}/d/adppndj/dsm?orgId=1\&kiosk\"#" ~/stack/app/index.html

echo "📝 Actualizando radar.html (línea 19, WEBHOOK_URL)..."
sed -i "19s#const WEBHOOK_URL = '[^']*'#const WEBHOOK_URL = '${URL_N8N}/webhook/estado-global'#" ~/stack/app/radar.html

echo ""
echo "🔄 Recreando el contenedor de n8n..."
cd ~/stack
docker compose up -d n8n

echo ""
echo "✅ TERMINADO"
echo ""
echo "⚠️  Recuerda actualizar A MANO estos 2 sitios dentro de n8n (no se pueden automatizar por script):"
echo "   1. Nodo 'Enviar Enlace Grafana' → URL: ${URL_GRAFANA}/d/adppndj/dsm"
echo "   2. Nodo 'Enviar Resumen /estado' → Reply Markup → botón Dashboard → misma URL"
echo "   Y luego pulsa 'Publish' en el workflow de n8n."
echo ""
echo "📱 URL de la app para el móvil: ${URL_APP}"
echo ""
echo "🔎 Verificación rápida recomendada tras ejecutar esto:"
echo "   sed -n '95,97p;102p;107p' ~/stack/app/index.html"
echo "   sed -n '19p' ~/stack/app/radar.html"
echo "   sed -n '14p' ~/stack/docker-compose.yml"
