/**
 * Cliente de Conexión HTTP hacia el Cloud Relay.
 */

import { getSessionToken, clearSessionToken } from "./crypto";

const DEFAULT_CLOUD_RELAY_URL = "https://xeon-nexus-cloud-relay.onrender.com";

export function getCloudRelayBaseUrl(): string {
  if (typeof window !== "undefined") {
    const custom = localStorage.getItem("xeon_relay_url");
    if (custom) return custom;
  }
  return process.env.NEXT_PUBLIC_CLOUD_RELAY_URL || DEFAULT_CLOUD_RELAY_URL;
}

export function setCloudRelayBaseUrl(url: string): void {
  if (typeof window !== "undefined") {
    localStorage.setItem("xeon_relay_url", url);
  }
}

export interface TelemetryData {
  node_name: string;
  timestamp: string;
  cpu: {
    percent: number;
    cores_count: number;
  };
  memory: {
    total_mb: number;
    used_mb: number;
    free_mb: number;
    percent: number;
  };
  temperatures: Array<{
    label: string;
    celsius: number;
  }>;
  ai: {
    active: boolean;
    status: string;
    model: string | null;
    tok_s: number;
    ttft_ms: number;
  };
  mining: {
    active: boolean;
    status: string;
    hashrate: number;
    threads: number;
    accepted: number;
  };
  network: {
    cockpit_port: number;
    ilo_status: string;
  };
}

export async function loginUser(username: string, passwordHash: string): Promise<string> {
  const baseUrl = getCloudRelayBaseUrl();
  const res = await fetch(`${baseUrl}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password_hash: passwordHash }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ detail: "Error de autenticación" }));
    throw new Error(err.detail || "Credenciales inválidas");
  }
  const data = await res.json();
  return data.access_token;
}

export async function fetchLatestTelemetry(): Promise<TelemetryData> {
  const token = getSessionToken();
  const baseUrl = getCloudRelayBaseUrl();
  const res = await fetch(`${baseUrl}/api/telemetry/latest`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (res.status === 401) {
    clearSessionToken();
    if (typeof window !== "undefined") {
      window.location.href = "./login/";
    }
    throw new Error("Sesión expirada");
  }

  if (!res.ok) {
    throw new Error(`Error HTTP ${res.status} al consultar telemetría`);
  }

  return res.json();
}
