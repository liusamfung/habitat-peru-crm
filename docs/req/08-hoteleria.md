# 4.8 Habitat Hospitality (específico)

Hoteles para segmento corporativo y vacacional. Su rasgo distintivo es la urgencia:
un problema durante una estadía activa no admite el mismo SLA que un reclamo posventa.

| ID        | Tipo       | Prioridad | Estado |
| --------- | ---------- | --------- | ------ |
| REQ-HT-01 | DEC        | Alta      | ⬜     |
| REQ-HT-02 | DEC + FLOW | Alta      | ⬜     |
| REQ-HT-03 | FLOW       | Media     | ⬜     |

---

## REQ-HT-01 — Vincular Caso a la Reserva del huésped

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá vincular cada Caso a la Reserva del huésped (fechas, habitación,
> estado de la estadía).

Objeto base de esta unidad (`Reserva_Hotel__c` según el BRD). Del que dependen
[REQ-CH-02](02-canales-omnichannel.md) (WhatsApp vinculado a la Reserva),
[REQ-HT-02](#req-ht-02--escalar-a-gerencia-durante-estadía-activa) (estadía activa) y
[REQ-AUTO-01](05-automatizacion.md) (loyalty tier).

**Preguntas que debes poder responder:**

- ¿Qué campos necesita la Reserva para que "estadía activa" sea calculable?
- ¿Dónde vive el loyalty tier: en la Reserva, en el Contact o en el Account?
  ¿Qué implica cada opción para REQ-AUTO-01?

---

## REQ-HT-02 — Escalar a Gerencia durante estadía activa

**Tipo:** DEC + FLOW · **Prioridad:** Alta

> El sistema deberá escalar a Gerencia de Hotel cualquier Caso de Prioridad Alta
> durante la estadía activa, con atención <30 min.

El "<30 min" es un Entitlement Process distinto al del resto de Hotelería — conecta
con [REQ-SLA-01](03-sla-entitlements.md).

**Preguntas que debes poder responder:**

- ¿Cómo determinas "estadía activa" en tiempo de ejecución sin hacer una query por
  registro?
- ¿Escalation Rules estándar o Flow? ¿Qué puede hacer cada uno?

---

## REQ-HT-03 — Solicitud Especial → tarea para recepción/housekeeping

**Tipo:** FLOW · **Prioridad:** Media

> El sistema deberá convertir una "Solicitud Especial" en una tarea visible para
> recepción/housekeeping antes del check-in.

**Preguntas que debes poder responder:**

- ¿`Task` estándar u objeto custom? ¿Qué gana cada uno en visibilidad y reportería?
- ¿Cómo garantizas el "antes del check-in" — Scheduled Path del Flow basado en la
  fecha de la Reserva?
