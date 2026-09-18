# 4.7 Habitat Parking (específico)

Playas de estacionamiento en zonas de alta demanda y centros comerciales. Su rasgo
distintivo es la dependencia de un sistema externo de control de acceso.

| ID        | Tipo       | Prioridad | Estado |
| --------- | ---------- | --------- | ------ |
| REQ-PK-01 | INT + FLOW | Media     | ⬜     |
| REQ-PK-02 | FLOW + INT | Media     | ⬜     |
| REQ-PK-03 | DEC        | Alta      | ⬜     |

---

## REQ-PK-01 — Validación de pérdida de boleta (integración simulada) 🔨

**Tipo:** INT + FLOW · **Prioridad:** Media

> El sistema deberá validar reclamos de "pérdida de boleta" cruzando placa y horario
> contra el sistema de control de acceso.

**Diseño esperado (dos piezas):**

1. Una clase **Apex REST (`@RestResource`)** que reciba placa vehicular y horario
   desde el sistema externo simulado de control de acceso.
2. Una clase Apex que, **desde un Flow de pantalla**, haga un **callout vía Named
   Credential** a ese endpoint para validar el reclamo antes de aprobar el Caso.

**Preguntas que debes poder responder:**

- **¿Por qué el callout no puede ir directo en un trigger?** (pista: los triggers no
  permiten callouts síncronos)
- Si esto se disparara desde automatización en lugar de una pantalla de Flow,
  ¿usarías `@future(callout=true)` o Queueable? ¿Qué gana Queueable?
- ¿Qué resuelve una Named Credential que no resuelve hardcodear la URL y el token?
- ¿Cómo se testea un callout si los tests no pueden hacer llamadas reales?
  (pista: `HttpCalloutMock`)

---

## REQ-PK-02 — Abono mensual con aprobación y activación automática 🔨

**Tipo:** FLOW + INT · **Prioridad:** Media

> El sistema deberá gestionar solicitudes de abono mensual con aprobación y
> activación automática en el sistema de acceso.

Combina Approval Process (declarativo) con un callout de salida tras la aprobación.
Reutiliza la Named Credential de REQ-PK-01.

**Preguntas que debes poder responder:**

- ¿Cómo disparas un callout _después_ de que se aprueba un Approval Process?
- ¿Qué pasa si el sistema externo está caído en ese momento? ¿Cómo reintentas?

---

## REQ-PK-03 — Daño vehicular → prioridad Alta + Case Team

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá priorizar como "Alta" los reclamos por daño vehicular y activar
> un Case Team con Legal/Seguros.

**Preguntas que debes poder responder:**

- ¿Qué es un Predefined Case Team y cómo se asigna automáticamente?
- ¿Cómo interactúa el Case Team con el OWD Privado de [REQ-SEC-01](10-seguridad.md)?
