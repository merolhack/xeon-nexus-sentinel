---
type: concept
title: "Aislamiento de Recursos y Caché L3 en Minería RandomX"
description: "Fórmula de dimensionamiento de hilos para RandomX basada en 2 MB de caché L3 y gobernanza contra la inferencia de IA"
tags: [randomx, xmrig, cache-l3, numa, mineria, cpu, xeon]
created: 2026-11-22
updated: 2026-11-22
---

# Aislamiento de Recursos y Caché L3 en Minería RandomX

## 1. La Regla de Oro de RandomX (2 MB L3 por Hilo)

El algoritmo RandomX utilizado por Monero está diseñado para resistir ASICs mediante el uso intensivo de la memoria caché de nivel 3 (L3 Cache) y accesos de memoria aleatorios con alta sensibilidad a la latencia.

Cada hilo de minería en RandomX requiere estrictamente **2 MB de memoria caché L3**.

### Cálculo de Hilos Máximos

Para dimensionar los hilos de XMRig sin saturar el procesador:

`Hilos Máximos = Piso(Caché L3 Total en MB / 2)`

Por ejemplo:
- Intel Xeon E5520 (8 MB Caché L3): Hilos Máximos = 8 / 2 = 4 hilos.
- Intel Xeon X5670 (12 MB Caché L3): Hilos Máximos = 12 / 2 = 6 hilos.

Si se configuran más hilos de los permitidos por la caché física, los hilos excedentes deben acceder a la memoria RAM DDR3 para buscar los datos de Scratchpad, multiplicando la latencia por un factor de 10× y provocando una caída catastrófica del hashrate global.

## 2. Competencia de Memoria: IA vs Minería

Tanto la inferencia de modelos de lenguaje en CPU como la minería RandomX saturan por completo los canales de memoria del bus IMC. Ejecutar ambas tareas en paralelo degrada el rendimiento de la IA a menos de 1 token por segundo y reduce el hashrate en más del 70%.

### Algoritmo del Gobernador (`ai-miner-governor.sh`)

1. El script vigila la presencia de peticiones de inferencia activas en el puerto de Ollama / `llama.cpp`.
2. Al detectar inferencia en curso:
   - Envía comando HTTP `POST /1/pause` al minero XMRig.
   - Libera el 100% del ancho de banda del bus de memoria y núcleos para el modelo de IA.
3. Al concluir la generación del texto:
   - Envía comando HTTP `POST /1/resume` al minero.
   - Restablece la minería de fondo.
