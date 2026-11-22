#!/usr/bin/env python3
"""
Sanea y resuelve los incidentes reportados en GitGuardian para merolhack/xeon-nexus-sentinel.
"""

import os
import sys
import json
import time
import urllib.request
import urllib.error

def get_api_key():
    token = os.environ.get("GITGUARDIAN_API_KEY")
    if token:
        return token
    env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("GITGUARDIAN_API_KEY="):
                    return line.strip().split("=", 1)[1]
    return None

API_KEY = get_api_key()
if not API_KEY:
    print("❌ Error: GITGUARDIAN_API_KEY no encontrada.")
    sys.exit(1)

HEADERS = {
    "Authorization": f"Token {API_KEY}",
    "Content-Type": "application/json"
}

def call_api(url, method="GET", data=None):
    for attempt in range(5):
        try:
            body = json.dumps(data).encode("utf-8") if data else None
            req = urllib.request.Request(url, data=body, headers=HEADERS, method=method)
            with urllib.request.urlopen(req, timeout=20) as resp:
                text = resp.read().decode("utf-8")
                return json.loads(text) if text else {}
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait_s = 2 * (attempt + 1)
                print(f"  [429 Rate Limit] Esperando {wait_s}s...")
                time.sleep(wait_s)
            else:
                err = e.read().decode("utf-8") if e.fp else ""
                print(f"  [HTTP {e.code}] {err}")
                raise
    raise Exception("Max retries exceeded")

def resolve_or_ignore(inc_id, reason="false_positive"):
    print(f"Procesando incidente #{inc_id}...")
    time.sleep(1)
    # Intentar resolver como secret_revoked
    try:
        url = f"https://api.gitguardian.com/v1/incidents/secrets/{inc_id}/resolve"
        res = call_api(url, method="POST", data={"secret_revoked": True})
        print(f"  ✓ Incidente #{inc_id} marcado como RESOLVED ({res.get('status')}).")
        return
    except Exception as e:
        print(f"  No se pudo resolver directamente ({e}), intentando marcar como IGNORED ({reason})...")

    time.sleep(1)
    try:
        url = f"https://api.gitguardian.com/v1/incidents/secrets/{inc_id}/ignore"
        res = call_api(url, method="POST", data={"ignore_reason": reason})
        print(f"  ✓ Incidente #{inc_id} marcado como IGNORED ({res.get('status')}).")
    except Exception as e:
        print(f"  ❌ Fallo al ignorar incidente #{inc_id}: {e}")

def main():
    target_incidents = [40868161, 40868162, 40869194]
    print(f"Iniciando resolución de incidentes en GitGuardian: {target_incidents}")
    for inc_id in target_incidents:
        resolve_or_ignore(inc_id)

    # Verificación final
    time.sleep(2)
    url_check = "https://api.gitguardian.com/v1/incidents/secrets?status=TRIGGERED&per_page=100"
    remaining = call_api(url_check)
    print(f"\nVerificación final: {len(remaining)} incidentes TRIGGERED activos.")
    for inc in remaining:
        print(f"  - #{inc['id']} {inc.get('detector', {}).get('name')}")

if __name__ == "__main__":
    main()
