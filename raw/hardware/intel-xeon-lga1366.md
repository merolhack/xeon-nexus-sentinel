# Ficha Técnica Inmutable: Arquitectura Intel Xeon LGA1366 (Nehalem / Westmere)

## Características del Microprocesador

* **Zócalo:** LGA 1366 (Socket B)
* **Familias Comunes:**
  * Nehalem-EP (45nm): Xeon 5500 Series (ej. E5520, X5570) - 4 núcleos / 8 hilos
  * Westmere-EP (32nm): Xeon 5600 Series (ej. E5620, X5650, X5675) - 4 o 6 núcleos / 8 o 12 hilos
* **Conjunto de Instrucciones:**
  * x86-64, MMX, SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2
  * **NOTA CRÍTICA:** No soporta instrucciones AVX, AVX2 ni AVX-512. La inferencia de modelos de lenguaje debe compilarse específicamente para SSE4.2 en `llama.cpp`.
* **Topología de Caché:**
  * L1: 32 KB datos + 32 KB instrucciones por núcleo
  * L2: 256 KB dedicados por núcleo
  * L3 (Smart Cache Compartida): 8 MB (Nehalem 4 núcleos) o 12 MB (Westmere 6 núcleos)
* **Interconexión QuickPath Interconnect (QPI):**
  * Enlaces punto a punto entre procesadores y chipset a 4.8 GT/s, 5.86 GT/s o 6.4 GT/s.
* **Controlador de Memoria Integrado (IMC) y NUMA:**
  * Arquitectura Non-Uniform Memory Access (NUMA).
  * Cada procesador posee acceso directo a sus bancos de memoria local de triple canal. El acceso a la memoria del segundo socket atraviesa el bus QPI, incrementando la latencia en ~30-40%.
