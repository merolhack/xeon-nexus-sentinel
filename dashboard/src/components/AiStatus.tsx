"use client";

import React from "react";
import { Sparkles, Zap, Clock, ShieldCheck } from "lucide-react";
import { TelemetryData } from "../lib/api";

export default function AiStatus({ data }: { data: TelemetryData | null }) {
  const ai = data?.ai;
  const isRunning = ai?.active && ai?.status === "running";

  return (
    <div className="bg-cardbg border border-bordercolor rounded-xl p-5 shadow-lg">
      <div className="flex items-center justify-between mb-4 border-b border-bordercolor pb-3">
        <div className="flex items-center gap-2 text-accent font-semibold text-lg">
          <Sparkles className="w-5 h-5" />
          <h2>Inferencia de IA Local (CPU SSE4.2)</h2>
        </div>
        <span
          className={`text-xs px-2.5 py-1 rounded font-mono font-medium flex items-center gap-1 ${
            isRunning
              ? "bg-emerald-950/80 border border-emerald-800 text-emerald-300"
              : "bg-gray-800 text-gray-400"
          }`}
        >
          <span
            className={`w-2 h-2 rounded-full ${
              isRunning ? "bg-emerald-400 animate-pulse" : "bg-gray-500"
            }`}
          ></span>
          {ai?.status?.toUpperCase() || "OFFLINE"}
        </span>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-3">
          <div className="text-gray-400 text-xs flex items-center gap-1 mb-1">
            <ShieldCheck className="w-3.5 h-3.5" /> Modelo Activo
          </div>
          <div className="text-sm font-semibold font-mono text-white truncate">
            {ai?.model || "Ninguno en memoria"}
          </div>
          <div className="text-[11px] text-gray-500 mt-1">Cuantización Q4_K_M</div>
        </div>

        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-3">
          <div className="text-gray-400 text-xs flex items-center gap-1 mb-1">
            <Zap className="w-3.5 h-3.5 text-neoncyan" /> Velocidad Generación
          </div>
          <div className="text-xl font-bold font-mono text-white">
            {ai?.tok_s ? `${ai.tok_s} tok/s` : "0.0 tok/s"}
          </div>
          <div className="text-[11px] text-gray-500 mt-1">Límite SSE4.2 Xeon</div>
        </div>

        <div className="bg-darkbg/60 border border-bordercolor/80 rounded-lg p-3">
          <div className="text-gray-400 text-xs flex items-center gap-1 mb-1">
            <Clock className="w-3.5 h-3.5 text-neonorange" /> Latencia TTFT
          </div>
          <div className="text-xl font-bold font-mono text-white">
            {ai?.ttft_ms ? `${ai.ttft_ms} ms` : "—"}
          </div>
          <div className="text-[11px] text-gray-500 mt-1">Time To First Token</div>
        </div>
      </div>
    </div>
  );
}
