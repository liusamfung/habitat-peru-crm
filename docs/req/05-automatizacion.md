# 4.5 Automatización y enrutamiento avanzado

Las tres requieren Apex. Es el área de mayor densidad técnica del proyecto.

| ID          | Tipo         | Prioridad | Estado |
| ----------- | ------------ | --------- | ------ |
| REQ-AUTO-01 | APEX         | Media     | ⬜     |
| REQ-AUTO-02 | FLOW + APEX  | Media     | ⬜     |
| REQ-AUTO-03 | APEX (Batch) | Alta      | ⬜     |

---

## REQ-AUTO-01 — Enrutamiento VIP en Hotelería por historial de estadías 🔨

**Tipo:** APEX · **Prioridad:** Media

> El sistema deberá enrutar Casos de huéspedes VIP de hotel considerando el historial
> de estadías (loyalty tier), no solo Skills.

**Diseño esperado:** un enrutamiento personalizado de Omni-Channel (interfaz de
routing en Apex) para el Service Channel de Casos de Hotelería, que priorice agentes
con mayor afinidad histórica con huéspedes de loyalty tier "Platinum", además de las
Skills estándar.

> Es probablemente el requerimiento más difícil del BRD. Déjalo para cuando ya tengas
> varios Apex funcionando. Requiere [REQ-CH-01](02-canales-omnichannel.md) configurado.

**Preguntas que debes poder responder:**

- **¿Por qué esto no se puede lograr con el routing estándar** (Least Active /
  Most Available)?
- ¿Qué objetos de Omni-Channel intervienen? (pista: `PendingServiceRouting`,
  `ServiceResource`, `AgentWork`)
- ¿Qué límites de gobernador hay que considerar en un routing personalizado, sabiendo
  que se ejecuta por cada trabajo que entra a la cola?

---

## REQ-AUTO-02 — Reasignar Caso sin respuesta en 15 minutos 🔨

**Tipo:** FLOW + APEX · **Prioridad:** Media

> El sistema deberá reasignar un Caso si el agente no responde en 15 minutos,
> devolviéndolo a la cola con prioridad elevada.

**Preguntas que debes poder responder:**

- ¿Qué opciones tienes para "esperar 15 minutos"? (Scheduled Path en Record-Triggered
  Flow, Time-Based Workflow, Queueable con `System.enqueueJob` y delay, Scheduled Apex)
- ¿Cuál eliges y por qué? ¿Cuál es más sostenible para un admin sin developer?
- ¿Cómo evitas reasignar un Caso que el agente sí respondió a los 14 minutos?

---

## REQ-AUTO-03 — Batch diario de riesgo de incumplimiento de SLA 🔨

**Tipo:** APEX (Batch) · **Prioridad:** Alta

> El sistema deberá calcular diariamente el "riesgo de incumplimiento de SLA" de
> todos los Casos abiertos.

**Diseño esperado:** una clase **`Database.Batchable`** programada diariamente vía
**`Schedulable`**, que recorra los Casos abiertos con Milestones no completados y
actualice un campo **`Riesgo_SLA__c`** (Alto / Medio / Bajo) según el tiempo restante.
Test class con `Test.startTest()` / `Test.stopTest()`.

> Buen segundo requerimiento de código, después de
> [REQ-CASE-05](01-gestion-casos.md). Depende de [REQ-SLA-01](03-sla-entitlements.md).

**Preguntas que debes poder responder:**

- ¿Cómo dimensionas el `scope` del batch para no exceder límites? ¿Qué pasa con el
  default de 200?
- ¿Cuáles son los tres métodos de `Database.Batchable` y qué hace cada uno?
- **¿Cómo pruebas esto sin esperar a que pase un día real?** (pista: control de fechas
  en el test; qué garantiza `Test.stopTest()` respecto a la ejecución asíncrona)
- ¿Por qué un batch y no un trigger o un Flow programado?
