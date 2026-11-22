---
type: concept
title: "Afinamiento de Inferencia de IA en CPU Xeon Legada"
description: "Estrategias de cuantización y compilación para inferencia de LLM en procesadores Intel Xeon sin soporte AVX2"
tags: [ia, llm, llama-cpp, cuantizacion, sse4-2, xeon, cpu]
created: 2026-11-22
updated: 2026-11-22
---

# Afinamiento de Inferencia de IA en CPU Xeon Legada

## 1. Desafío Arquitectónico: Ausencia de AVX2

Los procesadores Intel Xeon de la generación Nehalem y Westmere (LGA1366) carecen de los conjuntos de instrucciones vectoriales AVX y AVX2. Su límite vectorial se encuentra en **SSE4.2**. La mayoría de binarios precompilados modernos de PyTorch, TensorFlow o `llama.cpp` fallan con error de instrucción ilegal (`Illegal instruction (core dumped)`) si se ejecutan directamente.

## 2. Soluciones y Reglas de Optimización

1. **Compilación Nativa de `llama.cpp`:**
   - La herramienta debe compilarse desde el código fuente desactivando AVX y activando SSE4.2:
     `cmake -B build -DLLAMA_AVX=OFF -DLLAMA_AVX2=OFF -DLLAMA_FMA=OFF -DLLAMA_F16C=OFF`
2. **Selección de Modelos Cuantizados:**
   - Para CPUs con ancho de banda de memoria limitado (DDR3 ECC), los modelos óptimos son de 1B a 3B parámetros con cuantización agresiva `Q4_K_M` o `Q3_K_M`.
   - Ejemplos recomendados: Llama-3.2-1B-Instruct, Qwen2.5-0.5B / 1.5B, SmolLM2-1.7B.
3. **Mapeo en Memoria y Bloqueo de Paginación:**
   - Se debe utilizar la bandera `--mlock` para impedir que el sistema operativo mueva los pesos del modelo al espacio de intercambio (swap) en disco.
4. **Asignación de Hilos:**
   - El número de hilos de cómputo (`-t`) debe coincidir exactamente con el número de núcleos físicos del socket asignado (excluyendo Hyper-Threading para evitar contención de caché L1/L2).
