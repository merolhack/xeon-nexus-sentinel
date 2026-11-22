"use client";

import React, { useState, useEffect } from "react";
import { hashPasswordSha256, saveSessionToken } from "../../lib/crypto";
import { loginUser, getCloudRelayBaseUrl, setCloudRelayBaseUrl } from "../../lib/api";
import { Shield, Lock, User, AlertCircle, KeyRound, Settings, Check } from "lucide-react";

export default function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [relayUrl, setRelayUrl] = useState("");
  const [savedSuccess, setSavedSuccess] = useState(false);

  useEffect(() => {
    setRelayUrl(getCloudRelayBaseUrl());
  }, []);

  const handleSaveRelay = (e: React.FormEvent) => {
    e.preventDefault();
    if (!relayUrl.trim()) return;
    setCloudRelayBaseUrl(relayUrl.trim());
    setSavedSuccess(true);
    setTimeout(() => {
      setSavedSuccess(false);
      setShowSettings(false);
    }, 1200);
  };

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
      const currentUrl = getCloudRelayBaseUrl();
      if (err.message && err.message.includes("Failed to fetch")) {
        setError(
          `No se pudo conectar al Cloud Relay en: ${currentUrl}. Asegúrate de que el servicio esté activo y use HTTPS (o configura la URL con el botón de ajustes arriba a la derecha).`
        );
      } else {
        setError(err.message || "Credenciales inválidas o servidor inalcanzable");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#080c14] flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-cardbg border border-bordercolor rounded-2xl p-6 sm:p-8 shadow-2xl relative">
        {/* Botón de Ajustes de URL de Relay */}
        <button
          type="button"
          onClick={() => setShowSettings(!showSettings)}
          className="absolute top-5 right-5 p-2 rounded-lg bg-darkbg border border-bordercolor hover:border-gray-500 text-gray-400 hover:text-white transition"
          title="Configurar URL del Cloud Relay"
        >
          <Settings className="w-4 h-4" />
        </button>

        <div className="flex flex-col items-center text-center mb-6">
          <div className="p-3 bg-blue-600/20 text-accent rounded-xl border border-blue-500/30 mb-3">
            <Shield className="w-8 h-8" />
          </div>
          <h1 className="text-xl font-bold text-white tracking-tight">Acceso a Xeon-Sentinel</h1>
          <p className="text-xs text-gray-400 mt-1">
            Panel de control y telemetría headless protegida con Web Crypto API
          </p>
        </div>

        {/* Modal / Acordeón de Configuración de Relay */}
        {showSettings && (
          <form onSubmit={handleSaveRelay} className="mb-5 p-3.5 bg-darkbg/90 border border-blue-900/60 rounded-xl space-y-2">
            <div className="flex items-center justify-between">
              <label className="text-xs font-semibold text-blue-300">URL del Cloud Relay (FastAPI):</label>
              {savedSuccess && (
                <span className="text-[11px] text-emerald-400 flex items-center gap-1">
                  <Check className="w-3 h-3" /> Guardado
                </span>
              )}
            </div>
            <input
              type="url"
              required
              value={relayUrl}
              onChange={(e) => setRelayUrl(e.target.value)}
              placeholder="https://tu-relay.onrender.com"
              className="w-full bg-[#0b0f19] border border-bordercolor rounded-lg px-3 py-1.5 text-xs text-white focus:outline-none focus:border-accent font-mono"
            />
            <p className="text-[10px] text-gray-400">
              Usa una URL con <strong>HTTPS</strong> (ej. Render o Koyeb) para evitar bloqueos por contenido mixto en GitHub Pages.
            </p>
            <div className="flex justify-end gap-2 pt-1">
              <button
                type="submit"
                className="px-3 py-1 bg-accent hover:bg-blue-600 text-white rounded text-xs font-medium transition"
              >
                Guardar URL
              </button>
            </div>
          </form>
        )}

        {error && (
          <div className="mb-4 p-3 bg-red-950/70 border border-red-800 rounded-lg flex items-start gap-2 text-xs text-red-300">
            <AlertCircle className="w-4 h-4 shrink-0 text-red-400 mt-0.5" />
            <span className="leading-relaxed">{error}</span>
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
                placeholder="Usuario administrador"
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
          Autenticación criptográfica protegida con Web Crypto API y tokens JWT
        </div>
      </div>
    </div>
  );
}
