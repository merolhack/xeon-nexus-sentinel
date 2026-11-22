#!/usr/bin/env bash
# numa-tuning.sh
# Optimiza la asignación de memoria NUMA y HugePages para servidores HP ProLiant Dual-Socket

set -euo pipefail

echo "==> Configurando balanceo NUMA y HugePages en AlmaLinux 9..."

# Habilitar HugePages de 2MB para RandomX y llama.cpp
if [ -d "/sys/kernel/mm/transparent_hugepage" ]; then
    echo "madvise" > /sys/kernel/mm/transparent_hugepage/enabled || true
    echo "madvise" > /sys/kernel/mm/transparent_hugepage/defrag || true
fi

# Asignar 1280 HugePages estáticas (2560 MB) si hay suficiente RAM
if [ -f "/proc/sys/vm/nr_hugepages" ]; then
    echo 1280 > /proc/sys/vm/nr_hugepages || true
    echo "HugePages asignadas: $(cat /proc/sys/vm/nr_hugepages)"
fi

# Desactivar zone_reclaim_mode para reducir la latencia de acceso entre sockets
if [ -f "/proc/sys/vm/zone_reclaim_mode" ]; then
    echo 0 > /proc/sys/vm/zone_reclaim_mode
fi

echo "==> Estado de memoria NUMA:"
numastat 2>/dev/null || echo "numastat no instalado (ejecuta: dnf install numactl)"
echo "==> Afinamiento NUMA completado exitosamente."
