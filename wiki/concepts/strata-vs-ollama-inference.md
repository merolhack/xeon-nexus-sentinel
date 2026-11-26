# Strata vs Ollama: Análisis Arquitectónico e Inferencia MoE en Hardware Restringido

## 1. Visión General de Strata
**Strata** (`Niko1221/Strata` y bifurcaciones como `Strata-GLM`) es un motor de inferencia de alto rendimiento desarrollado en **C++20** sobre el ecosistema `llama.cpp` y `ggml`. Prescinde por completo del intérprete de Python, PyTorch o TensorFlow en la ruta de inferencia, eliminando la contención por el GIL (*Global Interpreter Lock*) y la fragmentación de memoria.

Su propósito fundamental es la ejecución eficiente de modelos masivos de arquitectura **Mixture-of-Experts (MoE)** —tales como **Qwen3.8-Flash-Next** (125B parámetros totales, 24,576 expertos, 10 activos / ~6B efectivos por token) o **GLM-5.3-Flash** (320B)— en hardware accesible.

```text
               ┌────────────────────────────────────────────────────────┐
               │             Jerarquía de Memoria de Strata             │
               └────────────────────────────────────────────────────────┘
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         ▼                                 ▼                                 ▼
   [Tier 1: VRAM GPU]             [Tier 2: Host RAM Arena]          [Tier 3: NVMe Page Cache]
   - Capas compartidas            - Espacio anclado (mlock)         - Tabla n-gram 28.8 GB
   - Atención y router            - Todos los expertos enrutados    - Búsqueda no matricial
   - Caché de expertos activos    - Cómputo CPU paralelo (SIMD)     - Mapeo directo de páginas
```

---

## 2. Ventajas Arquitectónicas frente a Ollama / llama.cpp Tradicional

| Característica | **Strata** | **Ollama / llama.cpp** |
| :--- | :--- | :--- |
| **Enfoque de Diseño** | Ultra-especializado en MoE dispersos gigantes (125B a 320B). | Motor generalista para decenas de arquitecturas densas (1B a 70B). |
| **Gestión de Expertos** | Caché dinámico en VRAM + arena de RAM fija + ejecución paralela GPU/CPU. | Carga estática de capas en GPU/RAM o descarga completa secuencial. |
| **Aceleración Algorítmica** | Multi-Token Prediction (MTP) especulativo (1.6x a 1.8x), Prompt Lookup Cache y Chunked Prefill. | Autoregresión estándar token por token; soporte MTP limitado o manual. |
| **Cuantización Avanzada** | Cuantización GSQ-RCO (IQ2_XS, IQ3_S) garantizando 4 bits mínimos en caches. | Cuantizaciones k-quants tradicionales (Q4_K_M, Q5_K_M, Q8_0). |
| **Throughput Reportado** | 60 a 140+ tokens/segundo en GPUs de consumo (RTX 3090/4090/5070 con 64 GB RAM). | 15 a 35 tokens/segundo en arquitecturas MoE comparables. |
| **APIs Expuestas** | Endpoints nativos compatibles con OpenAI, Anthropic Messages y servidor MCP integrado. | API nativa de Ollama y emulación OpenAI. |

---

## 3. Viabilidad y Requerimientos en el HP ProLiant ML150 G6

El análisis de compatibilidad frente a las especificaciones del nodo servidor revela cuatro condiciones determinantes:

1. **Conjunto de Instrucciones del Procesador (SSE4.2 vs AVX2/AVX-512):**
   * Strata compila sus kernels de CPU para AVX-512 y AVX2.
   * El procesador **Intel Xeon E5504 (Nehalem LGA1366)** carece de AVX y AVX2, limitándose a **SSE4.2**.
   * Los binarios precompilados arrojan de inmediato `Illegal instruction (core dumped)`. Requeriría compilación manual con banderas `-DLLAMA_AVX=OFF -DLLAMA_AVX2=OFF`.
2. **Capacidad de Memoria Física (8 GB actuales vs 32–64 GB mínimos):**
   * Strata exige anclar (`mlock`) todos los pesos de los expertos en memoria física, rechazando el mapeo perezoso bajo demanda.
   * Modelos MoE comprimidos requieren un mínimo absoluto de 32 GB a 64 GB de RAM. En 8 GB de RAM, la ejecución falla por agotamiento de memoria (**OOM Killer**).
3. **Almacenamiento (Discos SAS 15K RPM vs NVMe):**
   * El desacople de la tabla n-gram (28.8 GB) asume lecturas aleatorias ultrarrápidas sobre bus PCIe/NVMe. En discos rotacionales SAS, los tiempos de búsqueda mecánica degradan la latencia.
4. **Ausencia de GPU Dedicada:**
   * Sin acelerador gráfico con VRAM para alojar la atención y el router, todo el flujo recae en el bus QPI de memoria DDR3 de 800 MHz.

---

## 4. Estrategia Híbrida Recomendada para Xeon Nexus Sentinel

* **En el Servidor HP ProLiant (Bare-Metal Headless):**
  * Mantener **`llama.cpp` nativo optimizado para SSE4.2** (o Ollama ligero).
  * Desplegar modelos densos de 1B a 3B (**Llama-3.2-1B-Instruct**, **Qwen2.5-1.5B** en cuantización `Q4_K_M`) que ocupan entre 1.1 GB y 2.2 GB de RAM, permitiendo inferencias locales rápidas de 12 a 18 tokens/s y dejando libres 5 GB de RAM para el daemon y HugePages de RandomX.
* **Evolución Futura para Habilitar Strata:**
  1. Instalar los 3 módulos RAM restantes y ampliar el servidor a 48 GB DDR3 ECC (máximo por CPU).
  2. Incorporar una tarjeta gráfica PCIe de consumo (ej. NVIDIA RTX 3060 12GB o superior) con alimentación adaptada.
  3. Desplegar Strata mediante su contenedor Docker oficial para servir APIs OpenAI/Anthropic hacia la red interna.
