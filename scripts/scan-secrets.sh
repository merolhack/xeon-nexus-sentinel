#!/usr/bin/env bash
# ==============================================================================
# Xeon-Nexus-Sentinel — Secret Scanner & Zero-Leak Enforcement
# ==============================================================================
# Escanea cambios preparados en git (staged) o archivos del repositorio buscando
# firmas de credenciales, API keys, tokens o claves privadas antes de commit/push.
# ==============================================================================

set -eo pipefail

MODE="${1:-staged}"

echo "🔍 Escaneando secretos y credenciales (Modo: ${MODE})..."

if [ "$MODE" = "staged" ]; then
    DIFF_CONTENT=$(git diff --cached -U0 --no-color 2>/dev/null || true)
    
    if [ -z "$DIFF_CONTENT" ]; then
        echo "✅ No hay cambios en stage para escanear."
        exit 0
    fi
    
    # Filtrar solo líneas agregadas (+), excluyendo encabezados de archivo (+++)
    LEAKS=$(echo "$DIFF_CONTENT" | grep -E '^\+[^+]' | grep -E 'GOCSPX-[a-zA-Z0-9_\-]{20,}|(ghp|gho)_[a-zA-Z0-9]{30,}|github_pat_[a-zA-Z0-9_]{30,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[0-9a-zA-Z]{10,}|AIza[0-9A-Za-z\-_]{35}|eyJhbGciOi[a-zA-Z0-9_\-\.]+' || true)

    if [ -n "$LEAKS" ]; then
        echo "❌ ERROR: Intento de commit bloqueado por Política de Cero Secretos (Zero Secrets Policy)."
        echo "Se detectaron posibles credenciales o secretos en los cambios preparados (staged):"
        echo "--------------------------------------------------------------------------------"
        echo "$LEAKS" | head -n 10
        echo "--------------------------------------------------------------------------------"
        echo "⚠️ Acción requerida:"
        echo "  1. Remueve el secreto del archivo."
        echo "  2. Usa variables de entorno en .env (ignorado por .gitignore) o secretos en el Cloud Relay."
        echo "  3. En documentación, usa placeholders como [PROTEGIDO_EN_VARIABLES_DE_ENTORNO]."
        exit 1
    fi

elif [ "$MODE" = "repo" ]; then
    FOUND_LEAKS=$(git grep -EI 'GOCSPX-[a-zA-Z0-9_\-]{20,}|(ghp|gho)_[a-zA-Z0-9]{30,}|github_pat_[a-zA-Z0-9_]{30,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|AIza[0-9A-Za-z\-_]{35}' -- ':!package-lock.json' ':!scripts/scan-secrets.sh' || true)

    if [ -n "$FOUND_LEAKS" ]; then
        echo "❌ ERROR: Se detectaron secretos en archivos rastreados por Git:"
        echo "$FOUND_LEAKS"
        exit 1
    fi
fi

echo "✅ Escaneo de secretos superado: 0 credenciales expuestas."
exit 0
