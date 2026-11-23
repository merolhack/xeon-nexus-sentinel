#!/usr/bin/env bash
# clean-zone-identifiers.sh
# Elimina artefactos Zone.Identifier generados por Windows / WSL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "==> Eliminando archivos Zone.Identifier en ${ROOT_DIR}..."
find "${ROOT_DIR}" -name "*:Zone.Identifier" -delete 2>/dev/null || true
find "${ROOT_DIR}" -name "*Zone.Identifier*" -delete 2>/dev/null || true
echo "==> Limpieza de Zone.Identifier completada exitosamente."
