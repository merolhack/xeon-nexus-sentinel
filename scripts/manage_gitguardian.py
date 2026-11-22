#!/usr/bin/env python3
"""
Herramienta de gestión e inspección de incidentes en GitGuardian REST API.
Permite listar fuentes, consultar incidentes activos para el repositorio y
resolverlos/cerrarlos tras sanear el código.
"""

import os
import sys
import json
import time
import urllib.request
import urllib.error

API_BASE = "https://api.gitguardian.com/v1"

def get_api_key():
    token = os.environ.get("GITGUARDIAN_API_KEY")
    if token:
        return token
    # Buscar en .env local
    env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("GITGUARDIAN_API_KEY="):
                    return line.strip().split("=", 1)[1]
    return None

API_KEY = get_api_key()
if not API_KEY:
    print("❌ Error: GITGUARDIAN_API_KEY no encontrada en entorno ni en .env")
    sys.exit(1)

HEADERS = {
    "Authorization": f"Token {API_KEY}",
    "Content-Type": "application/json"
}

def request_api(endpoint, method="GET", data=None):
    url = f"{API_BASE}{endpoint}" if not endpoint.startswith("http") else endpoint
    body = json.dumps(data).encode("utf-8") if data else None
    req = urllib.request.Request(url, data=body, headers=HEADERS, method=method)
    try:
        with urllib.request.urlopen(req, timeout=25) as resp:
            text = resp.read().decode("utf-8")
            return json.loads(text) if text else {}
    except urllib.error.HTTPError as e:
        err_text = e.read().decode("utf-8") if e.fp else ""
        print(f"HTTPError {e.code} en {url}: {err_text}")
        raise

def get_sources():
    sources = []
    cursor = None
    while True:
        url = "/sources?per_page=100"
        if cursor:
            url += f"&cursor={cursor}"
        res = request_api(url)
        if isinstance(res, list):
            sources.extend(res)
            break
        elif isinstance(res, dict):
            sources.extend(res.get("data", []))
            cursor = res.get("pagination", {}).get("next")
            if not cursor:
                break
        else:
            break
    return sources

def get_incidents_for_source(source_id, status=None):
    url = f"/incidents/secrets?source_id={source_id}&per_page=100"
    if status:
        url += f"&status={status}"
    return request_api(url)

def resolve_incident(inc_id, secret_revoked=True):
    url = f"/incidents/secrets/{inc_id}/resolve"
    payload = {"secret_revoked": secret_revoked}
    return request_api(url, method="POST", data=payload)

def ignore_incident(inc_id, reason="false_positive"):
    url = f"/incidents/secrets/{inc_id}/ignore"
    payload = {"ignore_reason": reason}
    return request_api(url, method="POST", data=payload)

def main():
    print("🔍 Consultando fuentes en GitGuardian...")
    sources = get_sources()
    target_source = None
    for s in sources:
        name = s.get("full_name") or s.get("name") or ""
        if "xeon-nexus-sentinel" in name.lower():
            target_source = s
            break

    if not target_source:
        print("⚠️ No se encontró la fuente específica de 'xeon-nexus-sentinel'. Fuentes disponibles:")
        for s in sources[:10]:
            print(f"  - [{s.get('id')}] {s.get('full_name') or s.get('name')}")
        # Consultar incidentes globales sin filtrar por source
        print("\n🔍 Consultando incidentes TRIGGERED globales en la cuenta...")
        incidents = request_api("/incidents/secrets?status=TRIGGERED&per_page=100")
        print(f"Total de incidentes TRIGGERED globales: {len(incidents)}")
        for inc in incidents:
            print(f"  Incidente #{inc.get('id')} - {inc.get('detector', {}).get('name')} - Fuente: {inc.get('source', {}).get('full_name')}")
        return

    source_id = target_source["id"]
    source_name = target_source.get("full_name") or target_source.get("name")
    print(f"✅ Fuente identificada: [{source_id}] {source_name}")

    incidents = get_incidents_for_source(source_id)
    print(f"📌 Total incidentes encontrados: {len(incidents)}")
    for inc in incidents:
        print(f"  - Incidente #{inc['id']} | Estado: {inc.get('status')} | Severidad: {inc.get('severity')} | Detector: {inc.get('detector', {}).get('name')}")

if __name__ == "__main__":
    main()
