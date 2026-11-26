---
type: concept
title: "Gobernanza de Memoria RAM, Arquitectura RDIMM/UDIMM y Configuración de Arranque en HP ProLiant ML150 G6"
description: "Estándares de memoria DDR3 ECC, incompatibilidad entre RDIMM y UDIMM, configuración de BIOS AMI v02.61 y arranque con Smart Array P410"
tags: [rdimm, udimm, ecc, hp-proliant, smart-array, bios, matrox-g200, memory-rules]
created: 2026-11-26
updated: 2026-11-26
---

# Gobernanza de Memoria RAM, Arquitectura RDIMM/UDIMM y Configuración de Arranque en HP ProLiant ML150 G6

Este documento compendia las reglas de arquitectura de hardware, directivas de población de memoria RAM DDR3 ECC y procedimientos de configuración de arranque (BIOS y Option ROM de controladora RAID) para el nodo servidor HP ProLiant ML150 G6 con procesadores Intel Xeon serie 5500 (Nehalem-EP).

---

## 1. Arquitectura de Memoria del Servidor (Intel Nehalem-EP / Xeon 5500)

El procesador Intel Xeon E5504 integra su propio controlador de memoria (IMC - Integrated Memory Controller) con arquitectura de **Triple Canal (Triple-Channel)** DDR3 a 800/1066/1333 MHz.

### Comparativa Tecnológica: RDIMM vs UDIMM

| Parámetro | RDIMM (Registered DIMM / terminación "R") | UDIMM (Unbuffered DIMM / terminación "E") |
| :--- | :--- | :--- |
| **Identificador Estándar** | `PC3-10600R`, `PC3-8500R` | `PC3-10600E`, `PC3-8500E` |
| **Componente Clave** | Chip de registro de hardware (RCD - Registering Clock Driver) que amortigua señales de comando y dirección. | Conexión eléctrica directa entre las líneas del bus del IMC y cada chip DRAM. |
| **Carga Eléctrica en CPU** | Muy baja; el procesador solo maneja la carga del registro, no de los chips individuales. | Elevada; la capacitancia y carga eléctrica se multiplican por cada chip DRAM insertado. |
| **Capacidad Máxima (ML150 G6)** | Hasta **48 GB** (Xeon 5500) o hasta **96 GB / 192 GB** (Xeon 5600) poblando los 12 zócalos. | Limitada a un máximo de **24 GB** en todo el servidor (máximo 2 zócalos por canal). |
| **Estabilidad y Tolerancia 24/7** | Misión crítica empresarial, reduce jitter y ruido eléctrico en el bus. | Estaciones de trabajo de entrada o microservidores de bajo consumo. |
| **Paradoja de Precios de Mercado** | **Extremadamente económicas** en reventa (surplus de datacenters; no sirven en PCs comunes). | **Más costosas** (alta demanda por usuarios que reviven placas de escritorio y estaciones Z). |

---

## 2. Incompatibilidad Absoluta y Regla de Coexistencia de Memoria

> [!CAUTION]
> **REGLA ABSOLUTA DE HARDWARE (HP QuickSpecs & Intel Memory Reference Code):**
> **ESTÁ TERMINANTEMENTE PROHIBIDO MEZCLAR MÓDULOS RDIMM CON UDIMM EN EL MISMO SISTEMA.**
> 
> 1. **Incompatibilidad a Nivel de Placa y Sistema:** La prohibición aplica no solo al mismo canal, sino a **toda la placa base**. 
> 2. **Comportamiento en Dual Socket:** Si se instala un segundo procesador Xeon (CPU2), **NO es posible** colocar RDIMM en el CPU1 y UDIMM en el CPU2. El bus QPI (QuickPath Interconnect) y la inicialización de la BIOS exigen un único modo de temporización y búfer homogéneo.
> 3. **Consecuencia de la Mezcla:** El código MRC (Memory Reference Code) de la BIOS se detiene en POST Fase 1, emite pitidos de error de memoria y bloquea la salida de vídeo (pantalla negra permanente).

---

## 3. Inventario de Módulos del Nodo y Diagnóstico de Adquisición

### A. Módulos Adquiridos (Tecnología Correcta)
* **Modelo:** Micron 4 GB `PC3-10600R` (`MT36JBZS51272PY-1G4D1`).
* **Especificación:** DDR3-1333 Registered ECC con paridad, diseño de bajo perfil.
* **Cantidad:** 2 módulos (8 GB totales).
* **Veredicto:** Son las memorias óptimas de grado servidor. Estandarizan el equipo en arquitectura RDIMM.

### B. Módulos Preexistentes (Heredados del Propietario Anterior)
* **Módulos Azules:** 2 × Nanya 4 GB 2Rx8 `PC3-10600E-9-10-E0` (HP P/N: `500210-071` / Kit `500672-B21`).
* **Módulo Verde:** 1 × Samsung 2 GB 2Rx8 `PC3-10600E-09-10-E1` (HP Spare: `501533-001` / Kit `500670-B21`).
* **Tipo:** UDIMM Unbuffered ECC.
* **Veredicto:** Piezas originales HP de catálogo que funcionaban solas sumando 10 GB, pero incompatibles con cualquier ampliación RDIMM.

### C. Directiva de Expansión Futura
Para ampliar la memoria del servidor a 16 GB, 24 GB o 48 GB:
* Adquirir exclusivamente módulos **RDIMM** (`PC3-10600R` o `PC3-8500R`) de 4 GB u 8 GB (ej. Micron, Samsung o Hynix de servidor).
* Descartar cualquier compra de módulos terminados en "E" (`10600E`).

---

## 4. Parámetros de BIOS AMI v02.61 para Arranque Fiable

Para evitar falsos bloqueos o fallos de arranque con la controladora **HP Smart Array P410** y discos SAS de 15,000 RPM:

| Parámetro en BIOS Setup | Valor Recomendado | Justificación Operativa |
| :--- | :--- | :--- |
| **`Quick Boot`** | **`[Disabled]`** | **Crítico:** Evita que la BIOS salte al bootloader antes de que la controladora Smart Array P410 termine de acelerar (spin-up) los discos SAS y registrar el volumen lógico. |
| **`Quiet Boot`** | **`[Disabled]`** | Elimina el logo gráfico estático de HP y muestra en consola cruda todos los mensajes del POST, códigos de error y saltos de GRUB. |
| **`1st Boot Device`** | **`[Hard Drive]`** | Destina el arranque al subsistema de almacenamiento principal. |
| **`2nd Boot Device`** | **`[Disabled]`** | Previene re-arranques accidentales hacia Windows o interfaces de red cuando se desea operar localmente. |
| **Submenú `Hard Disk Drives`** | **`1st Drive: [RAID:Smart Array P]`** | Designa la Option ROM de la controladora P410 como disco duro primario (BBS Priority). |

---

## 5. Configuración de Boot Volume en Option ROM de Smart Array P410

Si la BIOS no encuentra el sector de arranque de AlmaLinux 9 en `/dev/sda`:
1. Durante el POST, observar la inicialización de la controladora:
   ```text
   HP Smart Array P410 Controller (256MB, vX.XX)
   1 Logical Drive
   Press <F8> to configure
   ```
2. Pulsar **`F8`** para ingresar a la utilidad ACU (Array Configuration Utility) embebida en ROM.
3. Ingresar a **`Select Boot Volume`**.
4. Marcar explícitamente el **`Logical Drive 1`** (419 GB SAS RAID) como disco de arranque primario.
5. Guardar con **`F8`** y reiniciar.

---

## 6. Diagnóstico de Pantalla "Sin Señal" (Matrox G200e + Conversor VGA-HDMI)

La aparición recurrente del mensaje *"Sin señal"* en el monitor o televisor HDMI responde a dos factores físicos:
1. **Pausa por Detección de Cambio de RAM:** Tras retirar módulos y variar la capacidad (de 10 GB a 8 GB), la BIOS detiene el arranque con el mensaje `Memory size has changed. Press F1 to continue`. Si el monitor aún no sincroniza, la máquina parece apagada pero está esperando la tecla `F1`.
2. **Desincronización de Reloj en el Conversor VGA-HDMI:** El chip gráfico integrado **Matrox G200e** altera su frecuencia analógica al pasar del modo texto BIOS (720×400 @ 70Hz) al framebuffer del kernel Linux (`mgag200`). Los convertidores pasivos o activos de bajo costo pierden el enganche de fase y el monitor se apaga.
   * **Mitigación:** Esperar 60-90 segundos a que concluya el arranque del sistema operativo y acceder remotamente por red (SSH / Cockpit) o reconectar el cable de alimentación auxiliar USB del conversor.
