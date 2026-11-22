# SPEC.md — Especificación de Memoria Google OKF v0.2 + LLM Wiki

## 1. Visión General

Este repositorio implementa el estándar **Google Open Knowledge Format (OKF v0.2)** combinado con el patrón de diseño **Karpathy LLM Wiki**. Su objetivo es proporcionar una memoria estructurada, determinista y navegable para modelos de lenguaje y agentes de IA, eliminando la necesidad de RAG probabilístico en favor de conocimiento precompilado y enlaces explícitos.

## 2. Taxonomía de Documentos

Toda la base de conocimiento en `wiki/` y `raw/` se clasifica en los siguientes tipos formales:

| Tipo | Directorio | Descripción | Mutabilidad |
| :--- | :--- | :--- | :--- |
| `raw` | `raw/` | Documentos fuente inmutables, manuales de fabricante y especificaciones técnicas | Solo lectura (Inmutable) |
| `system` | `wiki/systems/` | Componentes de software y servicios ejecutables del ecosistema | Versionado continuo |
| `concept` | `wiki/concepts/` | Principios teóricos, decisiones de diseño, algoritmos y protocolos | Versionado continuo |
| `entity` | `wiki/entities/` | Nodos físicos, servidores, dispositivos y recursos computacionales | Versionado continuo |
| `spec` | Raíz (`SPEC.md`) | Metarreglas y esquemas que definen la estructura de la memoria | Estable |

## 3. Esquema de Frontmatter Obligatorio (OKF v0.2)

Cada archivo en `wiki/` DEBE contener un bloque YAML formal de encabezado con los siguientes atributos:

```yaml
---
type: concept | system | entity | spec
title: "Título Descriptivo y Preciso"
description: "Resumen conciso en una o dos oraciones para indexación rápida por el LLM"
tags: [etiqueta-1, etiqueta-2, etiqueta-3]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

## 4. Estructura de Navegación del Grafo

- **`index.md`**: Punto de entrada canónico del agente. Contiene el mapa de relaciones entre sistemas, conceptos y entidades físicas.
- **`log.md`**: Bitácora cronológica acumulativa (append-only) que documenta las sesiones de trabajo, decisiones arquitectónicas y cambios de infraestructura.
- **`AGENTS.md`**: Manual de conducta y directivas operacionales del agente.
