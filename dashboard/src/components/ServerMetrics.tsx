"use client";

import React from "react";
import { Cpu, HardDrive, Thermometer, Activity } from "lucide-react";
import { TelemetryData } from "../lib/api";

export default function ServerMetrics({ data }: { data: TelemetryData | null }) {
  const cpuPercent = data?.cpu.percent ?? 0;
  const cores = data?.cpu.cores_count ?? 8;
  const memUsed = data?.memory.used_mb ?? 0;
  const memTotal = data?.memory.total_mb ?? 1;
  const memPercent = data?.memory.percent ?? 0;
  const temps = data?.temperatures ?? [];

  return (
    <div className="bg-cardbg border border-bordercolor rounded-xl p-5 shadow-lg">
      <div className="flex items-center justify-between mb-4 border-b border-bordercolor pb-3">
        <div className="flex items-center gap-2 text-neoncyan font-semibold text-lg">
          <Activity className="w-5 h-5" />
          <h2>Nodo Servidor: HP ProLiant (Xeon)</h2>
        </div>
        <span className="text-xs px-2.5 py-1 rounded bg-blue-950/70 border border-blue-800 text-blue-300 font-mono">
          {data?.node_name || "Conectando..."}
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* CPU Metric */}
        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-4">
          <div className="flex items-center justify-between mb-2 text-gray-400 text-xs">
            <span className="flex items-center gap-1.5 font-medium">
              <Cpu className="w-4 h-4 text-accent" /> Carga Total CPU
            </span>
            <span>{cores} núcleos lógicos</span>
          </div>
          <div className="flex items-baseline justify-between mb-2">
            <span className="text-2xl font-bold font-mono text-white">{cpuPercent}%</span>
            <span className="text-xs text-gray-400">AlmaLinux 9</span>
          </div>
          <div className="w-full bg-gray-800 rounded-full h-2 overflow-hidden">
            <div
              className={`h-2 rounded-full transition-all duration-500 ${
                cpuPercent > 85 ? "bg-red-500" : cpuPercent > 60 ? "bg-neonorange" : "bg-neongreen"
              }`}
              style={{ width: `${Math.min(cpuPercent, 100)}%` }}
            ></div>
          </div>
        </div>

        {/* RAM Metric */}
        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-4">
          <div className="flex items-center justify-between mb-2 text-gray-400 text-xs">
            <span className="flex items-center gap-1.5 font-medium">
              <HardDrive className="w-4 h-4 text-neoncyan" /> Memoria RAM (NUMA)
            </span>
            <span>{memPercent}%</span>
          </div>
          <div className="flex items-baseline justify-between mb-2">
            <span className="text-2xl font-bold font-mono text-white">
              {(memUsed / 1024).toFixed(1)} GB
            </span>
            <span className="text-xs text-gray-400">de {(memTotal / 1024).toFixed(1)} GB</span>
          </div>
          <div className="w-full bg-gray-800 rounded-full h-2 overflow-hidden">
            <div
              className="h-2 rounded-full bg-neoncyan transition-all duration-500"
              style={{ width: `${Math.min(memPercent, 100)}%` }}
            ></div>
          </div>
        </div>

        {/* Temperature Metric */}
        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-4">
          <div className="flex items-center justify-between mb-2 text-gray-400 text-xs">
            <span className="flex items-center gap-1.5 font-medium">
              <Thermometer className="w-4 h-4 text-neonorange" /> Sensores Térmicos
            </span>
            <span>iLO 100i / Core</span>
          </div>
          <div className="space-y-1.5">
            {temps.slice(0, 2).map((t, idx) => (
              <div key={idx} className="flex items-center justify-between text-sm">
                <span className="text-gray-400 text-xs truncate max-w-[140px]">{t.label}</span>
                <span
                  className={`font-mono font-semibold ${
                    t.celsius > 75 ? "text-red-400" : t.celsius > 60 ? "text-neonorange" : "text-emerald-400"
                  }`}
                >
                  {t.celsius} °C
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
