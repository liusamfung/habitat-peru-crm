# 4.3 SLA / Entitlements

| ID         | Tipo       | Prioridad | Estado |
| ---------- | ---------- | --------- | ------ |
| REQ-SLA-01 | DEC        | Alta      | ⬜     |
| REQ-SLA-02 | DEC        | Alta      | ⬜     |
| REQ-SLA-03 | APEX       | Media     | ⬜     |
| REQ-SLA-04 | DEC / FLOW | Media     | ⬜     |

---

## REQ-SLA-01 — Entitlement Processes por Unidad y segmento

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá definir Entitlement Processes por Unidad de Negocio y segmento
> de cliente.

Cimiento de toda esta área. Habilita Entitlement Management en Setup antes de nada.

**Preguntas que debes poder responder:**

- ¿Cadena completa: Entitlement → Entitlement Process → Milestone → Milestone Action?
- ¿Qué diferencia hay entre Business Hours globales y por Entitlement Process?
- ¿Cómo se asigna un Entitlement a un Caso (manual, Flow, Apex, Entitlement Template)?

---

## REQ-SLA-02 — Pausar el cronómetro de SLA

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá pausar el cronómetro de SLA cuando el estado sea "Esperando al
> Cliente" y reanudarlo al recibir respuesta.

"Esperando al Cliente" es el nombre visible. Su valor guardado en inglés es
`Waiting_on_Customer` (confirmado el 2026-09-23). Falta verificar en la scratch org si
el guion bajo va solo en el API name o en todo el valor; ver las
[decisiones de REQ-CASE-01](01-gestion-casos.md#decisiones-de-diseño-2026-09-23) y los
[valores de `Status`](README.md#valores-de-status-mencionados-en-el-tablero).

Funcionalidad estándar: _Stopped / Stopped Since_ en el Entitlement Process. Ojo con
cómo afecta al cálculo del tiempo restante del milestone.

---

## REQ-SLA-03 — Completar Milestone "Primera Respuesta" desde WhatsApp 🔨

**Tipo:** APEX · **Prioridad:** Media

> El sistema deberá completar programáticamente el Milestone "Primera Respuesta"
> cuando un agente responda por WhatsApp.

**Diseño esperado:** una clase Apex **invocable desde Flow** que, al recibir el Id de
un `MessagingSession`, complete el `CaseMilestone` de "Primera Respuesta" del Caso
asociado **si aún no está completado**. Debe ser **bulk-safe**: Flow puede llamarla
con varios registros a la vez.

**Preguntas que debes poder responder:**

- ¿Cuál es la diferencia entre completar un milestone "a mano" y dejar que el
  Entitlement Process lo complete solo?
- **¿Por qué aquí hace falta código?** (pista: el canal de mensajería no dispara el
  milestone automáticamente, a diferencia de Email)
- ¿Cómo se estructura un `@InvocableMethod` para recibir y devolver colecciones?
- ¿Cómo evitas completar dos veces el mismo milestone?

---

## REQ-SLA-04 — Notificar supervisor ante riesgo de incumplimiento

**Tipo:** DEC / FLOW · **Prioridad:** Media

> El sistema deberá notificar a un supervisor cuando un Caso de garantía esté por
> incumplir su SLA.

Se puede resolver con **Milestone Actions** (Warning Action) sin código. Relacionado
con [REQ-AUTO-03](05-automatizacion.md), que calcula el riesgo en batch — decide qué
resuelve cada uno y no dupliques lógica.
