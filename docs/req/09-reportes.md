# 4.9 Reportes y analítica

| ID         | Tipo | Prioridad | Estado |
| ---------- | ---- | --------- | ------ |
| REQ-RPT-01 | DEC  | Alta      | ⬜     |
| REQ-RPT-02 | DEC  | Media     | ⬜     |
| REQ-RPT-03 | DEC  | Baja      | ⬜     |

---

## REQ-RPT-01 — Dashboard consolidado a nivel Holding

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá tener un dashboard consolidado a nivel Holding con AHT, FCR, CSAT
> y cumplimiento de SLA por unidad.

**Pasos de Setup:** crea Report Types custom sobre Case + Milestone, arma los reportes
de AHT / FCR / CSAT / SLA por unidad, y un Dashboard con filtros dinámicos por Unidad
de Negocio. Todo en la UI de Reportes de Salesforce.

**Antes de construirlo, define las métricas:**

- **AHT** (Average Handle Time) — ¿desde creación hasta cierre, o tiempo activo del agente?
- **FCR** (First Contact Resolution) — ¿cómo lo detectas? ¿número de interacciones = 1?
- **CSAT** — viene de [REQ-CASE-05](01-gestion-casos.md). Sin ese requerimiento hecho,
  no hay dato que reportar.
- **Cumplimiento de SLA** — de los Milestones de [REQ-SLA-01](03-sla-entitlements.md).

> Este requerimiento depende de casi todo lo demás. Es natural dejarlo para el final,
> pero conviene definir las métricas temprano: determinan qué campos necesitas ir
> capturando desde el principio.

---

## REQ-RPT-02 — Restringir reportes por línea de negocio

**Tipo:** DEC · **Prioridad:** Media

> El sistema deberá restringir a cada Gerente de Unidad la visibilidad a los reportes
> de su línea de negocio.

Se apoya en el modelo de sharing de [REQ-SEC-01](10-seguridad.md), más carpetas de
reportes con acceso por Role/Public Group.

---

## REQ-RPT-03 — Primera respuesta en mensajería

**Tipo:** DEC · **Prioridad:** Baja

> El sistema deberá reportar el tiempo de primera respuesta en mensajería vía
> `MessagingSessionMetrics`.

Objeto estándar que Salesforce alimenta solo. Relacionado con
[REQ-SLA-03](03-sla-entitlements.md).
