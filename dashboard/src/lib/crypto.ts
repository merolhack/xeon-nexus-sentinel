/**
 * Funciones Criptográficas en Cliente mediante Web Crypto API.
 * Calcula el resumen SHA-256 de contraseñas para evitar tráfico en texto plano.
 */

export async function hashPasswordSha256(password: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
  return hashHex;
}

export function saveSessionToken(token: string): void {
  if (typeof window !== "undefined") {
    sessionStorage.setItem("xeon_jwt_token", token);
  }
}

export function getSessionToken(): string | null {
  if (typeof window !== "undefined") {
    return sessionStorage.getItem("xeon_jwt_token");
  }
  return null;
}

export function clearSessionToken(): void {
  if (typeof window !== "undefined") {
    sessionStorage.removeItem("xeon_jwt_token");
  }
}

export function isTokenValid(): boolean {
  const token = getSessionToken();
  if (!token) return false;
  try {
    const parts = token.split(".");
    if (parts.length !== 3) return false;
    const payload = JSON.parse(atob(parts[1]));
    const exp = payload.exp;
    if (!exp) return false;
    const now = Math.floor(Date.now() / 1000);
    return exp > now;
  } catch {
    return false;
  }
}
