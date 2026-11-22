#!/usr/bin/env bash
# ai-miner-governor.sh
# Monitorea actividad de inferencia de IA en Ollama / llama.cpp y pausa automáticamente
# el minero XMRig para evitar saturar el bus de memoria y la caché L3.

OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
XMRIG_API="${XMRIG_API:-http://127.0.0.1:18088}"
CHECK_INTERVAL_SEC=3
MINER_PAUSED=0

echo "==> Gobernador IA vs Criptominería iniciado (Chequeo cada ${CHECK_INTERVAL_SEC}s)..."

while true; do
    # Consultar si hay modelos activos en Ollama
    ACTIVE_MODELS=$(curl -s "${OLLAMA_HOST}/api/ps" 2>/dev/null | grep -o '"models":\[{[^]]*' || true)

    if [ -n "$ACTIVE_MODELS" ]; then
        if [ "$MINER_PAUSED" -eq 0 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ Inferencia de IA detectada. Pausando XMRig..."
            curl -s -X POST "${XMRIG_API}/1/pause" -H "Content-Type: application/json" -d '{}' >/dev/null 2>&1 || true
            MINER_PAUSED=1
        fi
    else
        if [ "$MINER_PAUSED" -eq 1 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ Inferencia concluida. Reanudando XMRig..."
            curl -s -X POST "${XMRIG_API}/1/resume" -H "Content-Type: application/json" -d '{}' >/dev/null 2>&1 || true
            MINER_PAUSED=0
        fi
    fi

    sleep "$CHECK_INTERVAL_SEC"
done
