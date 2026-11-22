"""
Módulo de autenticación y seguridad para Cloud Relay.
Manejo de tokens JWT y validación contra credenciales de entorno.
"""

import os
import hmac
import hashlib
from datetime import datetime, timedelta, timezone
from typing import Optional
import jwt
from fastapi import HTTPException, Security, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

import secrets

JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY")
if not JWT_SECRET_KEY:
    JWT_SECRET_KEY = secrets.token_hex(32)

JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_HOURS = 24

ADMIN_USER = os.environ.get("ADMIN_USER", "administrador")
# Hash SHA-256 de contraseña autorizada
ADMIN_PASSWORD_HASH = os.environ.get("ADMIN_PASSWORD_HASH", "ea51164dd668d869a14e71ec9a54f1ea60df5f71e7db86fa3a7fdd79c74e9e2a")

SERVER_INGEST_TOKEN = os.environ.get("SERVER_INGEST_TOKEN", "dev-insecure-ingest-token-placeholder")

security_bearer = HTTPBearer(auto_error=False)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(hours=JWT_EXPIRATION_HOURS))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)


def verify_admin_credentials(username: str, password_hash: str) -> bool:
    user_match = hmac.compare_digest(username.strip(), ADMIN_USER.strip())
    pass_match = hmac.compare_digest(password_hash.strip().lower(), ADMIN_PASSWORD_HASH.strip().lower())
    return user_match and pass_match


def get_current_user(credentials: Optional[HTTPAuthorizationCredentials] = Security(security_bearer)) -> str:
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Falta encabezado de autorización Bearer",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = credentials.credentials
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido (sub ausente)"
            )
        return username
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expirado o firma inválida",
            headers={"WWW-Authenticate": "Bearer"},
        )
