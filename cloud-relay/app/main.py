"""
API Gateway Cloud Relay para Xeon-Sentinel.
Provee endpoints de ingestión, consulta protegida y autenticación.
"""

import os
from typing import Dict, Any, List
from fastapi import FastAPI, Depends, HTTPException, Header, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from app.store import store
from app.auth import (
    create_access_token,
    verify_admin_credentials,
    get_current_user,
    SERVER_INGEST_TOKEN
)

app = FastAPI(
    title="Xeon-Nexus Cloud Relay",
    version="1.0.0",
    description="Microservicio REST intermediario para ingestión de telemetría y distribución a Next.js"
)

# Configurar CORS para permitir peticiones desde GitHub Pages y entorno de desarrollo
ALLOWED_ORIGINS = [
    "https://merolhack.github.io",
    "http://localhost:3000",
    "http://127.0.0.1:3000"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción se puede restringir a ALLOWED_ORIGINS
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class LoginRequest(BaseModel):
    username: str
    password_hash: str


class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in_hours: int = 24


@app.get("/api/health")
def health_check():
    """Health check liviano para keep-alive en Koyeb/Zeabur/Render."""
    return {
        "status": "healthy",
        "service": "xeon-nexus-cloud-relay",
        "buffered_samples": store.count()
    }


@app.post("/api/auth/login", response_model=LoginResponse)
def login(creds: LoginRequest):
    """Valida el hash SHA-256 de la contraseña y retorna un JWT."""
    if not verify_admin_credentials(creds.username, creds.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas"
        )
    token = create_access_token(data={"sub": creds.username})
    return LoginResponse(access_token=token)


@app.post("/api/telemetry")
def ingest_telemetry(payload: Dict[str, Any], x_server_token: str = Header(None)):
    """Ingestión de telemetría enviada por el daemon de AlmaLinux."""
    expected_token = os.environ.get("SERVER_INGEST_TOKEN", SERVER_INGEST_TOKEN)
    if not x_server_token or x_server_token != expected_token:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Token de servidor inválido o ausente en X-Server-Token"
        )
    store.add(payload)
    return {"status": "accepted", "buffered": store.count()}


@app.get("/api/telemetry/latest")
def get_latest_telemetry(_: str = Depends(get_current_user)):
    """Obtiene la instantánea más reciente de telemetría (Ruta protegida)."""
    latest = store.get_latest()
    if not latest:
        # Si aún no hay muestras en memoria, retorna una plantilla de bienvenida
        return {
            "node_name": "hp-proliant-ml150-g6",
            "timestamp": "2026-11-22T00:00:00Z",
            "cpu": {"percent": 0.0, "cores_count": 8},
            "memory": {"total_mb": 24576, "used_mb": 4096, "free_mb": 20480, "percent": 16.6},
            "temperatures": [{"label": "CPU Package", "celsius": 42.0}],
            "ai": {"active": False, "status": "idle", "model": None, "tok_s": 0.0, "ttft_ms": 0},
            "mining": {"active": False, "status": "standby", "hashrate": 0.0, "threads": 4, "accepted": 0},
            "network": {"cockpit_port": 9090, "ilo_status": "standby-ok"}
        }
    return latest


@app.get("/api/telemetry/history")
def get_telemetry_history(_: str = Depends(get_current_user)):
    """Obtiene las últimas 100 muestras de telemetría (Ruta protegida)."""
    return {"history": store.get_history()}
