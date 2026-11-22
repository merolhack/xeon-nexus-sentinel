"""
Almacén en memoria volátil de telemetría (Ring Buffer).
Diseñado para operar con consumo mínimo de RAM (<50 MB) sin base de datos externa.
"""

from collections import deque
from typing import Dict, Any, List, Optional
from datetime import datetime, timezone

MAX_HISTORY_ENTRIES = 100

class TelemetryStore:
    def __init__(self, maxlen: int = MAX_HISTORY_ENTRIES):
        self._buffer: deque = deque(maxlen=maxlen)
        self._latest: Optional[Dict[str, Any]] = None

    def add(self, telemetry: Dict[str, Any]) -> None:
        telemetry["received_at"] = datetime.now(timezone.utc).isoformat()
        self._latest = telemetry
        self._buffer.append(telemetry)

    def get_latest(self) -> Optional[Dict[str, Any]]:
        return self._latest

    def get_history(self) -> List[Dict[str, Any]]:
        return list(self._buffer)

    def count(self) -> int:
        return len(self._buffer)

store = TelemetryStore()
