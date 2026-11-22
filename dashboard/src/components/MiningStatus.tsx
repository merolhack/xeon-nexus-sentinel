"use client";

import React from "react";
import { Pickaxe, Cpu, Layers, CheckCircle } from "lucide-react";
import { TelemetryData } from "../lib/api";

export default function MiningStatus({ data }: { data: TelemetryData | null }) {
  const mining = data?.mining;
  const isMining = mining?.active && mining?.status === "mining";

  return (
    <div className="bg-cardbg border border-bordercolor rounded-xl p-5 shadow-lg">
      <div className="flex items-center justify-between mb-4 border-b border-bordercolor pb-3">
        <div className="flex items-center gap-2 text-neonorange font-semibold text-lg">
          <Pickaxe className="w-5 h-5" />
          <h2>Criptominería RandomX (XMRig)</h2>
        </div>
        <span
          className={`text-xs px-2.5 py-1 rounded font-mono font-medium flex items-center gap-1 ${
            isMining
              ? "bg-amber-950/80 border border-amber-800 text-amber-300"
              : "bg-gray-800 text-gray-400"
          }`}
        >
          <span
            className={`w-2 h-2 rounded-full ${
              isMining ? "bg-amber-400 animate-pulse" : "bg-gray-500"
            }`}
          ></span>
          {mining?.status?.toUpperCase() || "OFFLINE"}
        </span>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-3">
          <div className="text-gray-400 text-xs flex items-center gap-1 mb-1">
            <Pickaxe className="w-3.5 h-3.5 text-neonorange" /> Hashrate Instantáneo
          </div>
          <div className="text-xl font-bold font-mono text-white">
            {mining?.hashrate ? `${mining.hashrate.toFixed(1)} H/s` : "0.0 H/s"}
          </div>
          <div className="text-[11px] text-gray-500 mt-1">Algoritmo RandomX</div>
        </div>

        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-3">
          <div className="text-gray-400 text-xs flex items-center gap-1 mb-1">
            <Cpu className="w-3.5 h-3.5 text-accent" /> Hilos Activos (Caché L3)
          </div>
          <div className="text-xl font-bold font-mono text-white">
            {mining?.threads || 0} hilos
          </div>
          <div className="text-[11px] text-gray-500 mt-1">Regla 2 MB L3 por hilo</div>
        </div>

        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-3">
          <div className="text-gray-400 text-xs flex items-center gap-1 mb-1">
            <CheckCircle className="w-3.5 h-3.5 text-neongreen" /> Shares Validados
          </div>
          <div className="text-xl font-bold font-mono text-white">
            {mining?.accepted || 0}
          </div>
          <div className="text-[11px] text-gray-500 mt-1">Gobernador IA: Activo</div>
        </div>
      </div>
    </div>
  );
}
