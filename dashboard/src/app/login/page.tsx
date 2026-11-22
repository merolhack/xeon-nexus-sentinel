"use client";

import React, { useState } from "react";
import { hashPasswordSha256, saveSessionToken } from "../../lib/crypto";
import { loginUser } from "../../lib/api";
import { Shield, Lock, User, AlertCircle, KeyRound } from "lucide-react";

export default function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (!username.trim() || !password) {
      setError("Por favor completa usuario y contraseña");
      return;
    }

    try {
      setLoading(true);
      // Hash en cliente mediante Web Crypto API (SHA-256)
      const pwHash = await hashPasswordSha256(password);
      // Autenticar contra Cloud Relay
      const token = await loginUser(username.trim(), pwHash);
      saveSessionToken(token);
      // Redirigir al dashboard principal
      window.location.href = "../";
    } catch (err: any) {
      setError(err.message || "Credenciales inválidas o servidor inalcanzable");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#080c14] flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-cardbg border border-bordercolor rounded-2xl p-6 sm:p-8 shadow-2xl">
        <div className="flex flex-col items-center text-center mb-6">
          <div className="p-3 bg-blue-600/20 text-accent rounded-xl border border-blue-500/30 mb-3">
            <Shield className="w-8 h-8" />
          </div>
          <h1 className="text-xl font-bold text-white tracking-tight">Acceso a Xeon-Sentinel</h1>
          <p className="text-xs text-gray-400 mt-1">
            Panel de control y telemetría headless protegida con Web Crypto API
          </p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-950/70 border border-red-800 rounded-lg flex items-center gap-2 text-xs text-red-300">
            <AlertCircle className="w-4 h-4 shrink-0 text-red-400" />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-medium text-gray-300 mb-1.5">Usuario Administrador</label>
            <div className="relative">
              <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                <User className="w-4 h-4" />
              </span>
              <input
                type="text"
                required
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="admin"
                className="w-full bg-darkbg border border-bordercolor rounded-lg pl-9 pr-3 py-2 text-sm text-white focus:outline-none focus:border-accent"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-300 mb-1.5">Contraseña Criptográfica</label>
            <div className="relative">
              <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                <Lock className="w-4 h-4" />
              </span>
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full bg-darkbg border border-bordercolor rounded-lg pl-9 pr-3 py-2 text-sm text-white focus:outline-none focus:border-accent"
              />
            </div>
            <p className="text-[11px] text-gray-500 mt-1">
              Cifrado SHA-256 en navegador antes del envío
            </p>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-2.5 px-4 bg-accent hover:bg-blue-600 disabled:opacity-50 text-white rounded-lg text-sm font-semibold transition flex items-center justify-center gap-2 shadow-lg shadow-blue-500/20"
          >
            {loading ? (
              <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
            ) : (
              <>
                <KeyRound className="w-4 h-4" />
                <span>Desbloquear Consola</span>
              </>
            )}
          </button>
        </form>

        <div className="mt-6 pt-4 border-t border-bordercolor/80 text-center text-xs text-gray-500">
          Credencial predeterminada: <code className="text-gray-400 font-mono">admin</code> / <code className="text-gray-400 font-mono">xeonsentinel2026</code>
        </div>
      </div>
    </div>
  );
}
