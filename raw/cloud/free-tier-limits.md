# Restricciones y Cuotas Inmutables de Plataformas SaaS Gratuitas

## 1. GitHub Pages
- **Tipo de Hosting:** Distribución estática pura (HTML, JS, CSS, Media).
- **Límite de Ancho de Banda:** 100 GB por mes.
- **Tamaño Máximo del Repositorio:** 1 GB recomendado.
- **Límite de Compilación (Build):** 10 minutos por ejecución.
- **Requisito Clave:** Para aplicaciones Next.js se requiere compilación estática (`output: 'export'`) y `images: { unoptimized: true }`.

## 2. Koyeb (Nivel Free Eco)
- **Instancia:** MicroVM con 512 MB de RAM y 0.1 vCPU compartida.
- **Tráfico:** 100 GB mensuales de transferencia de salida (egress).
- **Inactividad:** Se suspende automáticamente tras 60 minutos sin recibir tráfico HTTP.
- **Arranque en Frío:** Reactivación rápida en ~3 a 5 segundos.

## 3. Zeabur (Crédito Gratuito)
- **Crédito:** $5 USD mensuales sin vencimiento con renovación periódica.
- **Consumo:** Cobro por segundo de CPU y memoria RAM.
- **Inactividad:** Posibilidad de configurar suspensión ante bajo uso.
- **Ventaja:** Despliegue directo desde repositorio GitHub y sin requerimiento de tarjeta de crédito.

## 4. Render (Nivel Free Web Service)
- **Instancia:** 512 MB RAM compartida y 0.1 vCPU.
- **Tiempo de Cómputo:** 750 horas por mes (suficiente para un servicio 24/7 continuo).
- **Inactividad:** Entra en suspensión (*sleep*) tras 15 minutos sin tráfico entrante.
- **Arranque en Frío (Cold Start):** Demora entre 50 y 90 segundos al recibir la primera petición tras suspensión.
