# Requerimientos funcionales — tablero

43 requerimientos repartidos en 12 áreas. Marca el estado conforme avances.

**Leyenda de estado:** ⬜ Pendiente · 🟨 En curso · ✅ Hecho · ⏸️ Diferido

## Resumen por área

| Área                            | Archivo                                                | Reqs | Alta | Media | Baja |
| ------------------------------- | ------------------------------------------------------ | ---- | ---- | ----- | ---- |
| 4.1 Gestión de casos            | [01-gestion-casos.md](01-gestion-casos.md)             | 7    | 4    | 2     | 1    |
| 4.2 Canales / Omni-Channel      | [02-canales-omnichannel.md](02-canales-omnichannel.md) | 5    | 2    | 2     | 1    |
| 4.3 SLA / Entitlements          | [03-sla-entitlements.md](03-sla-entitlements.md)       | 4    | 2    | 2     | 0    |
| 4.4 Conocimiento / autoservicio | [04-conocimiento.md](04-conocimiento.md)               | 3    | 0    | 2     | 1    |
| 4.5 Automatización avanzada     | [05-automatizacion.md](05-automatizacion.md)           | 3    | 1    | 2     | 0    |
| 4.6 Inmobiliaria                | [06-inmobiliaria.md](06-inmobiliaria.md)               | 4    | 2    | 1     | 1    |
| 4.7 Estacionamientos            | [07-parking.md](07-parking.md)                         | 3    | 1    | 2     | 0    |
| 4.8 Hotelería                   | [08-hoteleria.md](08-hoteleria.md)                     | 3    | 2    | 1     | 0    |
| 4.9 Reportes y analítica        | [09-reportes.md](09-reportes.md)                       | 3    | 1    | 1     | 1    |
| 4.10 Seguridad y cumplimiento   | [10-seguridad.md](10-seguridad.md)                     | 3    | 2    | 1     | 0    |
| 4.11 Integraciones              | [11-integraciones.md](11-integraciones.md)             | 3    | 0    | 3     | 0    |
| 4.12 IA / Agentforce            | [12-ia-agentforce.md](12-ia-agentforce.md)             | 2    | 0    | 0     | 2    |

## Tablero completo

| ID          | Tipo                 | Prio  | Estado | Resumen                                                         |
| ----------- | -------------------- | ----- | ------ | --------------------------------------------------------------- |
| REQ-CASE-01 | DEC                  | Alta  | ⬜     | Crear Caso multi-canal con Record Type por Unidad de Negocio    |
| REQ-CASE-02 | FLOW / IA            | Media | ⬜     | Sugerir Tipo, Motivo y Prioridad según datos de origen          |
| REQ-CASE-03 | DEC                  | Alta  | ⬜     | Asignar Caso a la Queue de su Unidad y sub-proceso              |
| REQ-CASE-04 | DEC                  | Alta  | ⬜     | Evitar Casos duplicados al responder correo de Caso existente   |
| REQ-CASE-05 | **APEX**             | Media | ⬜     | Encuesta de satisfacción asíncrona al cerrar Caso               |
| REQ-CASE-06 | FLOW + Approval      | Alta  | ⬜     | Bloquear cierre de Caso de garantía sin evidencia ni aprobación |
| REQ-CASE-07 | DEC                  | Baja  | ⬜     | Fusionar Casos duplicados conservando historial                 |
| REQ-CH-01   | DEC                  | Alta  | ⬜     | Service Channels independientes enrutados por Skills            |
| REQ-CH-02   | INT + DEC            | Alta  | ⬜     | WhatsApp para huésped vinculado a su Reserva                    |
| REQ-CH-03   | DEC                  | Media | ⬜     | Parking prioridad Alta → agente senior (Most Available + Skill) |
| REQ-CH-04   | DEC + **LWC**        | Media | ⬜     | Web-to-Case con campos dinámicos                                |
| REQ-CH-05   | DEC                  | Baja  | ⬜     | Enrutamiento programado a fecha futura                          |
| REQ-SLA-01  | DEC                  | Alta  | ⬜     | Entitlement Processes por Unidad y segmento                     |
| REQ-SLA-02  | DEC                  | Alta  | ⬜     | Pausar SLA en "Esperando al Cliente"                            |
| REQ-SLA-03  | **APEX**             | Media | ⬜     | Completar Milestone "Primera Respuesta" desde WhatsApp          |
| REQ-SLA-04  | DEC / FLOW           | Media | ⬜     | Notificar supervisor ante riesgo de incumplimiento              |
| REQ-KM-01   | DEC                  | Media | ⬜     | Knowledge segmentado por Data Category                          |
| REQ-KM-02   | DEC                  | Media | ⬜     | Sugerir artículos según Tipo y Motivo                           |
| REQ-KM-03   | DEC + **LWC**        | Baja  | ⬜     | Portal de autoservicio en Experience Cloud                      |
| REQ-AUTO-01 | **APEX**             | Media | ⬜     | Enrutamiento VIP de hotel por loyalty tier                      |
| REQ-AUTO-02 | FLOW + **APEX**      | Media | ⬜     | Reasignar Caso sin respuesta en 15 min                          |
| REQ-AUTO-03 | **APEX (Batch)**     | Alta  | ⬜     | Cálculo diario de riesgo de incumplimiento de SLA               |
| REQ-RE-01   | DEC                  | Alta  | ⬜     | Vincular Caso a Unidad Inmobiliaria                             |
| REQ-RE-02   | DEC                  | Alta  | ⬜     | Garantía de Vivienda con Entitlement propio                     |
| REQ-RE-03   | DEC + **LWC**        | Baja  | ⬜     | Partner Community para corredores externos                      |
| REQ-RE-04   | **APEX (Scheduled)** | Media | ⬜     | Casos de seguimiento post-venta 30/90/180 días                  |
| REQ-PK-01   | **INT** + FLOW       | Media | ⬜     | Validar pérdida de boleta contra control de acceso              |
| REQ-PK-02   | FLOW + **INT**       | Media | ⬜     | Abono mensual con aprobación y activación automática            |
| REQ-PK-03   | DEC                  | Alta  | ⬜     | Daño vehicular → prioridad Alta + Case Team Legal/Seguros       |
| REQ-HT-01   | DEC                  | Alta  | ⬜     | Vincular Caso a Reserva del huésped                             |
| REQ-HT-02   | DEC + FLOW           | Alta  | ⬜     | Escalar a Gerencia durante estadía activa (<30 min)             |
| REQ-HT-03   | FLOW                 | Media | ⬜     | Solicitud Especial → tarea para recepción/housekeeping          |
| REQ-RPT-01  | DEC                  | Alta  | ⬜     | Dashboard consolidado Holding (AHT, FCR, CSAT, SLA)             |
| REQ-RPT-02  | DEC                  | Media | ⬜     | Restringir reportes por línea de negocio                        |
| REQ-RPT-03  | DEC                  | Baja  | ⬜     | Tiempo de primera respuesta vía `MessagingSessionMetrics`       |
| REQ-SEC-01  | DEC                  | Alta  | ⬜     | OWD de Case Privado + Case Team + jerarquía acotada             |
| REQ-SEC-02  | DEC                  | Alta  | ⬜     | Ley 29733 — campos sensibles vía FLS                            |
| REQ-SEC-03  | DEC                  | Media | ⬜     | Field History Tracking en campos con implicancia legal          |
| REQ-INT-01  | **INT**              | Media | ⬜     | Endpoint REST para crear Casos desde PMS de hotel               |
| REQ-INT-02  | **APEX**             | Media | ⬜     | Platform Event `Case_Resolved__e`                               |
| REQ-INT-03  | **APEX**             | Media | ⬜     | Sincronización asíncrona con sistema contable                   |
| REQ-AI-01   | IA                   | Baja  | ⬜     | Agente Agentforce de autoservicio                               |
| REQ-AI-02   | IA                   | Baja  | ⬜     | Clasificación predictiva de Tipo y Motivo                       |

## Orden de ataque sugerido

El BRD no impone un orden. Este es el que tiene menos dependencias hacia atrás:

### Fase 0 — Cimientos (sin esto, nada de lo demás tiene dónde apoyarse)

1. **REQ-CASE-01** — Record Types de Case. Es la raíz de todo el modelo.
2. **REQ-SEC-01** — OWD de Case en Privado. Cambiar el modelo de sharing _después_
   de tener datos y automatizaciones es mucho más caro.
3. **REQ-CASE-03** — Queues + Assignment Rules.
4. **REQ-RE-01 / REQ-HT-01** — objetos custom (Unidad Inmobiliaria, Reserva) que
   varios requerimientos posteriores necesitan como referencia.

### Fase 1 — Primer requerimiento de código

5. **REQ-CASE-05** — trigger + handler + Queueable + test bulk. Es el "hola mundo"
   ideal: toca el patrón handler, bulkificación, asincronía y testing, que son los
   cuatro temas que se repiten en todo lo demás.

### Fase 2 — SLA y automatización

6. REQ-SLA-01, REQ-SLA-02 (DEC) → luego **REQ-AUTO-03** (Batch + Schedulable) →
   REQ-SLA-04, REQ-SLA-03.

### Fase 3 — Especializaciones por unidad de negocio

7. Inmobiliaria (REQ-RE-02, **REQ-RE-04**), Parking (REQ-PK-03, **REQ-PK-01**),
   Hotelería (REQ-HT-02, REQ-HT-03).

### Fase 4 — Canales, integraciones, LWC

8. REQ-CH-01, **REQ-INT-02**, **REQ-INT-01**, **REQ-CH-04** (primer LWC).

### Fase 5 — Reportería, Knowledge, IA

9. REQ-RPT-_, REQ-KM-_, REQ-AI-*.

> **Sobre el LWC (REQ-CH-04):** el BRD anota que JavaScript es el punto más débil.
> Déjalo para cuando el Apex ya sea cómodo — no vale la pena pelear dos lenguajes
> nuevos a la vez.
