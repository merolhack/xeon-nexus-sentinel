---
type: system
title: "Topología de Red Autónoma: Repetidor AC1200, IP Aliasing y Estrategia Multi-ISP"
description: "Arquitectura de desacoplamiento de la laptop para operación 24/7 del servidor HP mediante repetidor WiFi, direccionamiento IP múltiple y aprovechamiento de Megacable (Fibra) y EniNetworks (WISP)"
tags: [networking, repeater-bridge, ip-aliasing, dual-wan, megacable, eninetworks, headless-24-7, depin-multi-ip]
created: 2026-11-26
updated: 2026-11-26
---

# Topología de Red Autónoma: Repetidor AC1200, IP Aliasing y Estrategia Multi-ISP

## 1. El Desafío: Desacoplamiento de la Estación de Trabajo
* **Situación Inicial:** El servidor HP ProLiant ML150 G6 se encontraba conectado directamente al puerto Ethernet de la laptop mediante Conexión Compartida a Internet (ICS) en Windows (`192.168.137.1` -> `192.168.137.50`).
* **Limitación Operativa:** La laptop es una estación móvil de trabajo que no puede permanecer conectada por cable de forma permanente. Apagarla, reiniciarla o trasladarla desconectaba al servidor de Internet e interrumpía los servicios desatendidos.
* **Objetivo de Infraestructura:** Otorgar al servidor HP ProLiant conectividad de red y salida a Internet **100% autónoma 24/7**, accesible desde cualquier punto de la casa por WiFi sin necesidad de cables hacia la laptop.

---

## 2. Topología Física con Repetidor WiFi Dual-Band AC1200

El repetidor AC1200 dispone de radio dual (2.4 GHz y 5 GHz hasta 867 Mbps) y **2 puertos LAN Ethernet RJ-45 (10/100 Mbps)**:

```text
[ Módem Megacable (Fibra Óptica) ]
         │
         │  (Enlace WiFi 5 GHz)
         ▼
[ Repetidor AC1200 en Modo Puente / Extender ] (Junto al servidor)
         ├── Puerto LAN 1 (RJ45) ──► HP ProLiant Puerto Inferior (enp4s0) -> AlmaLinux 9
         └── Puerto LAN 2 (RJ45) ──► HP ProLiant Puerto Superior (iLO 100i) -> Gestión Hardware
```

### Protocolo de Despliegue Físico:
1. **Ubicación:** Enchufe eléctrico inmediato al chasis HP ProLiant ML150 G6.
2. **Vinculación Inalámbrica:** El repetidor se asocia por WiFi en la banda de **5 GHz** al módem de **Megacable** para garantizar mínima latencia y máxima tasa de transferencia sin saturación del espectro de 2.4 GHz.
3. **Conexiones Cableadas Cortas:**
   * **Puerto LAN 1 del Repetidor:** Conectado al puerto inferior Gigabit (`enp4s0`, controlador Broadcom BCM5723) del servidor. Cursa el tráfico de producción de AlmaLinux 9 (SSH, DeNet Storage, DePIN y APIs).
   * **Puerto LAN 2 del Repetidor:** Conectado al puerto superior Fast Ethernet (`iLO 100i Mgmt`) del servidor. Permite gestión remota fuera de banda (encendido, apagado, ciclos de energía y consola BIOS remota) a través de la red local.
4. **Acceso Inalámbrico desde la Laptop:** La laptop se conecta normalmente a la red WiFi del hogar y accede al servidor por SSH (`ssh root@<IP_Megacable>`) con total movilidad.

---

## 3. Direccionamiento IP y Gestión Multi-IP en AlmaLinux 9

Para mantener la compatibilidad con el entorno de laboratorio actual y permitir reconectar el cable directo de la laptop cuando se requiera máxima velocidad (1 Gbps) para inferencia de IA distribuida, se implementa una estrategia de **IP Aliasing (Múltiples IPs en la misma tarjeta física)**:

### A. Estructura de Direcciones en `enp4s0`:
1. **IP Primaria (Dinámica o Estática en LAN de Megacable):**
   * Asignada por el servidor DHCP del módem/repetidor (ej. `192.168.1.150/24` o `192.168.0.150/24`).
   * Configurada con la puerta de enlace predeterminada (*Default Gateway*) hacia Internet.
   * Utilizada para navegación, actualizaciones, DeNet Storage, DePIN y SSH general desde la casa.
2. **IP Secundaria Fija (Laboratorio de IA y Scripts):**
   * Configurada estáticamente como alias: `192.168.137.50/24`.
   * **Sin Gateway**, para evitar conflictos de enrutamiento con la salida principal a Internet.
   * Permite que si en algún momento se conecta el cable de la laptop directamente al servidor, la comunicación funcione de inmediato sin modificar scripts ni configuraciones.

### B. Comando de Configuración en AlmaLinux 9 (`nmcli`):
```bash
# Agregar la IP secundaria fija manteniendo la primaria del módem
nmcli connection modify enp4s0 +ipv4.addresses 192.168.137.50/24
nmcli connection up enp4s0
```

---

## 4. Opciones de Expansión Hardware (Dual-NIC Físico)

En caso de requerir aislamiento físico estricto de redes o conexión cableada simultánea a dos módems:
* **Slot PCIe Libre:** Instalar una tarjeta PCIe x1 Gigabit Ethernet (controlador Intel 82574L o Realtek RTL8111, costo aprox. 150 a 250 pesos MXN).
* **Adaptador USB-Ethernet:** Adaptador USB a Gigabit Ethernet conectado en los puertos traseros.
* **Separación de Tráfico:**
  * **NIC 1 (`enp4s0` Integrada):** Conectada 24/7 al repetidor/módem para tráfico público y DePIN.
  * **NIC 2 (PCIe / USB Nueva):** Enlace privado punto a punto de 1 Gbps reservado para la laptop (`192.168.137.50`) para inferencia RPC con `llama.cpp`.

---

## 5. Estrategia Multi-ISP: Megacable (Fibra) vs. EniNetworks (Antena WISP)

La disponibilidad de dos conexiones a Internet independientes y activas 24/7 bajo tecnologías físicas distintas ofrece una ventaja competitiva excepcional para la arquitectura:

| Parámetro | Conexión A: Megacable | Conexión B: EniNetworks |
| :--- | :--- | :--- |
| **Medio de Acceso** | Fibra Óptica (FTTH) | Inalámbrico de Microondas (Antena en Techo / WISP) |
| **Perfil de Tráfico** | Ancho de banda elevado (100–500+ Mbps), latencia ultra-baja (<10 ms), estabilidad frente a tormentas | Ancho de banda moderado, latencia 20–60 ms sensible al clima |
| **Dirección IP Pública** | Pool residencial / dinámico de Megacable | Pool de direcciones IP públicas de EniNetworks |
| **Rol Óptimo en el Ecosistema** | **Tráfico Crítico y Almacenamiento:**<br>• Nodo **DeNet Storage** (traslado veloz de fragmentos de datos)<br>• Acceso administrativo SSH, Cockpit y API Cloud Relay<br>• Descarga de modelos y paquetes RPM | **Monetización DePIN y Redundancia:**<br>• Nodo **Grass Network** (aprovecha una segunda IP pública residencial)<br>• **Failover de Respaldo:** Salida de emergencia si la fibra física sufre corte exterior<br>• Bots de scraping y monitoreo blockchain distribuido |

### Caso de Uso de Doble Monetización Residencial (Grass Network):
Las redes de compartición de ancho de banda descentralizado (DePIN) recompensan nodos según su dirección IP pública única:
* Colocar la laptop en la red de Megacable y el servidor en la de EniNetworks (o viceversa mediante dos interfaces de red) permite operar **dos nodos residenciales genuinos simultáneos**, duplicando la acumulación de recompensas de forma legítima sin incurrir en penalizaciones por duplicidad de IP.
