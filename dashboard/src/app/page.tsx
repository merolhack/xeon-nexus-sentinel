"use client";

import React, { useEffect, useState } from "react";
import AuthGuard from "../components/AuthGuard";
import ServerMetrics from "../components/ServerMetrics";
import AiStatus from "../components/AiStatus";
import MiningStatus from "../components/MiningStatus";
import { fetchLatestTelemetry, TelemetryData, getCloudRelayBaseUrl, setCloudRelayBaseUrl } from "../lib/api";
import { clearSessionToken } from "../lib/crypto";
import { Server, Terminal, RefreshCw, LogOut, Settings, ShieldCheck, Wifi } from "lucide-react";

export default function DashboardPage() {
  const [telemetry, setTelemetry] = useState<TelemetryData | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [lastUpdated, setLastUpdated] = useState<string>("—");
  const [relayUrl, setRelayUrl] = useState<string>("");
  const [showSettings, setShowSettings] = useState<boolean>(false);

  const loadData = async () => {
    try {
      setLoading(true);
      const data = await fetchLatestTelemetry();
      setTelemetry(data);
      setLastUpdated(new Date().toLocaleTimeString());
    } catch (err) {
      console.error("Error al obtener telemetría:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    setRelayUrl(getCloudRelayBaseUrl());
    loadData();
    const interval = setInterval(loadData, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleLogout = () => {
    clearSessionToken();
    window.location.href = "./login/";
  };

  const handleSaveRelay = (e: React.FormEvent) => {
    e.preventDefault();
    setCloudRelayBaseUrl(relayUrl);
    setShowSettings(false);
    loadData();
  };

  return (
    <AuthGuard>
      <div className="min-h-screen bg-[#080c14] text-gray-100 flex flex-col">
        {/* Header Bar */}
        <header className="border-b border-bordercolor bg-cardbg/80 backdrop-blur sticky top-0 z-20 px-4 lg:px-8 py-3.5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-600/20 text-accent rounded-lg border border-blue-500/30">
              <Server className="w-5 h-5" />
            </div>
            <div>
              <h1 className="text-base lg:text-lg font-bold tracking-tight text-white flex items-center gap-2">
                Xeon-Nexus-Sentinel
                <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-950 border border-emerald-800 text-emerald-400 font-mono">
                  HEADLESS
                </span>
              </h1>
              <p className="text-xs text-gray-400 hidden sm:block">
                HP ProLiant ML150 G6 · AlmaLinux 9 · Ollama · XMRig
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 sm:gap-3">
            <button
              onClick={loadData}
              disabled={loading}
              className="p-2 rounded-lg bg-darkbg border border-bordercolor hover:border-gray-600 text-gray-300 hover:text-white transition flex items-center gap-1.5 text-xs"
              title="Refrescar métricas"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? "animate-spin text-accent" : ""}`} />
              <span className="hidden md:inline">{lastUpdated}</span>
            </button>

            <button
              onClick={() => setShowSettings(!showSettings)}
              className="p-2 rounded-lg bg-darkbg border border-bordercolor hover:border-gray-600 text-gray-300 hover:text-white transition"
              title="Ajustes de conexión"
            >
              <Settings className="w-4 h-4" />
            </button>

            <button
              onClick={handleLogout}
              className="px-3 py-1.5 rounded-lg bg-red-950/60 border border-red-800/80 hover:bg-red-900/60 text-red-200 transition flex items-center gap-1.5 text-xs font-medium"
            >
              <LogOut className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">Cerrar Sesión</span>
            </button>
          </div>
        </header>

        {/* Modal / Panel de Ajustes de URL de Relay */}
        {showSettings && (
          <div className="bg-cardbg border-b border-bordercolor p-4 px-4 lg:px-8">
            <form onSubmit={handleSaveRelay} className="max-w-2xl flex flex-col sm:flex-row gap-2 items-center">
              <label className="text-xs text-gray-300 font-medium shrink-0">URL Cloud Relay:</label>
              <input
                type="text"
                value={relayUrl}
                onChange={(e) => setRelayUrl(e.target.value)}
                placeholder="https://tu-relay.koyeb.app"
                className="w-full bg-darkbg border border-bordercolor rounded-lg px-3 py-1.5 text-xs text-white focus:outline-none focus:border-accent"
              />
              <button
                type="submit"
                className="w-full sm:w-auto px-4 py-1.5 bg-accent hover:bg-blue-600 text-white rounded-lg text-xs font-semibold shrink-0 transition"
              >
                Guardar
              </button>
            </form>
          </div>
        )}

        {/* Main Dashboard Container */}
        <main className="flex-1 max-w-7xl w-full mx-auto p-4 lg:p-8 space-y-6">
          {/* Server Metrics */}
          <ServerMetrics data={telemetry} />

          {/* AI & Mining Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <AiStatus data={telemetry} />
            <MiningStatus data={telemetry} />
          </div>

          {/* Network & Management Panel */}
          <div className="bg-cardbg border border-bordercolor rounded-xl p-5 shadow-lg">
            <div className="flex items-center justify-between mb-4 border-b border-bordercolor pb-3">
              <div className="flex items-center gap-2 text-neongreen font-semibold text-lg">
                <Wifi className="w-5 h-5" />
                <h2>Gestión y Red Fuera de Banda (OOB)</h2>
              </div>
              <span className="text-xs text-gray-400 font-mono">Topología Red Local</span>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-4 flex flex-col justify-between">
                <div>
                  <div className="text-xs text-gray-400 mb-1 flex items-center gap-1.5 font-medium">
                    <Terminal className="w-4 h-4 text-neoncyan" /> Cockpit Web Console
                  </div>
                  <p className="text-xs text-gray-400 mt-1">
                    Terminal web e inspección de servicios systemd sin entorno gráfico.
                  </p>
                </div>
                <div className="mt-4 flex items-center justify-between">
                  <span className="text-xs font-mono text-neoncyan">Puerto 9090</span>
                  <a
                    href="https://192.168.1.150:9090"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-xs px-2.5 py-1 rounded bg-blue-600/30 border border-blue-500/40 text-blue-300 hover:bg-blue-600/50 transition font-medium"
                  >
                    Abrir Cockpit →
                  </a>
                </div>
              </div>

              <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-4 flex flex-col justify-between">
                <div>
                  <div className="text-xs text-gray-400 mb-1 flex items-center gap-1.5 font-medium">
                    <ShieldCheck className="w-4 h-4 text-emerald-400" /> HP iLO 100i (BMC)
                  </div>
                  <p className="text-xs text-gray-400 mt-1">
                    Control de energía, encendido remoto e interfaz web de diagnóstico del chasis.
                  </p>
                </div>
                <div className="mt-4 flex items-center justify-between">
                  <span className="text-xs font-mono text-emerald-400">Standby 5V OK</span>
                  <span className="text-xs text-gray-400">IP Dedicada OOB</span>
                </div>
              </div>

              <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-4 flex flex-col justify-between">
                <div>
                  <div className="text-xs text-gray-400 mb-1 flex items-center gap-1.5 font-medium">
                    <Server className="w-4 h-4 text-neonorange" /> Sesión OpenSSH
                  </div>
                  <p className="text-xs text-gray-400 mt-1">
                    Consola nativa desde Windows Terminal con llave ED25519 en AlmaLinux.
                  </p>
                </div>
                <div className="mt-4">
                  <code className="text-[11px] block bg-black/60 p-1.5 rounded text-gray-300 font-mono truncate">
                    ssh admin@192.168.1.150
                  </code>
                </div>
              </div>
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="border-t border-bordercolor/80 py-4 px-4 text-center text-xs text-gray-500">
          Xeon-Nexus-Sentinel · Ecosistema Híbrido IA & Criptominería · Google OKF v0.2 + Karpathy LLM Wiki
        </footer>
      </div>
    </AuthGuard>
  );
}
