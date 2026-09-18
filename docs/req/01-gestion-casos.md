# 4.1 Gestión de casos (transversal)

Requerimientos comunes a las tres unidades de negocio. Es el núcleo del proyecto:
todo lo demás se apoya en cómo quede modelado el objeto `Case`.

| ID          | Tipo            | Prioridad | Estado |
| ----------- | --------------- | --------- | ------ |
| REQ-CASE-01 | DEC             | Alta      | ⬜     |
| REQ-CASE-02 | FLOW / IA       | Media     | ⬜     |
| REQ-CASE-03 | DEC             | Alta      | ⬜     |
| REQ-CASE-04 | DEC             | Alta      | ⬜     |
| REQ-CASE-05 | APEX            | Media     | ⬜     |
| REQ-CASE-06 | FLOW + Approval | Alta      | ⬜     |
| REQ-CASE-07 | DEC             | Baja      | ⬜     |

---

## REQ-CASE-01 — Creación multi-canal con Record Type por Unidad de Negocio

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá permitir crear un Caso desde múltiples canales identificando
> automáticamente la Unidad de Negocio mediante Record Type.

Es el requerimiento raíz. Los Record Types que definas aquí determinan Queues,
Assignment Rules, Entitlement Processes, layouts, picklist values y reportería
del resto del proyecto.

**Preguntas que debes poder responder:**

- ¿Por qué un solo objeto `Case` con tres Record Types en lugar de tres objetos custom?
- ¿Cómo se determina el Record Type según el canal de origen (Email-to-Case,
  Web-to-Case, Omni-Channel, manual)?
- ¿Qué relación hay entre Record Type, Page Layout y Profile/Permission Set?

---

## REQ-CASE-02 — Sugerencia de Tipo, Motivo y Prioridad

**Tipo:** FLOW / IA · **Prioridad:** Media

> El sistema deberá sugerir Tipo, Motivo y Prioridad del Caso en base a los datos
> de origen.

Tiene dos caminos posibles: un Flow con reglas explícitas, o Einstein Case
Classification (ver [REQ-AI-02](12-ia-agentforce.md)). Decidir cuál — y saber
justificarlo — es parte del ejercicio.

---

## REQ-CASE-03 — Asignación a la Queue correspondiente

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá asignar cada Caso a la Queue correspondiente a su Unidad de
> Negocio y sub-proceso.

**Pasos de Setup:** crea las Queues (una por sub-proceso), luego Assignment Rules
con entradas ordenadas por Record Type / Origen → Queue correspondiente. No requiere
Apex.

**Preguntas que debes poder responder:**

- ¿En qué orden se evalúan las entradas de una Assignment Rule y qué pasa cuando
  una coincide?
- ¿Cuántas Assignment Rules pueden estar activas a la vez en Case?
- ¿Qué pasa con un Caso que no coincide con ninguna entrada?

---

## REQ-CASE-04 — Evitar duplicados por respuesta de correo

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá evitar Casos duplicados cuando un cliente responde un correo de
> un Caso existente.

Funcionalidad estándar de Email-to-Case (thread ID / Lightning Threading). Entender
cómo Salesforce correlaciona la respuesta con el Caso original es el punto.

---

## REQ-CASE-05 — Encuesta de satisfacción al cerrar Caso 🔨

**Tipo:** APEX · **Prioridad:** Media

> El sistema deberá disparar, al cerrar un Caso, el envío asíncrono de una encuesta
> de satisfacción diferenciada por Unidad de Negocio.

**Este es el requerimiento recomendado para empezar a programar.** Toca los cuatro
temas que se repiten en todo el resto: patrón handler, bulkificación, asincronía y
testing.

**Diseño esperado:**

- Un Apex Trigger sobre `Case` que detecte el cambio a `Status = 'Closed'`.
- El envío encolado en un **Queueable**, con la plantilla de encuesta distinta según
  el Record Type (Inmobiliaria / Parking / Hotelería).
- Patrón **handler class** (el trigger no contiene lógica).
- **Guard de recursividad**.
- Clase de test con escenario bulk de 200 Casos.

**Preguntas que debes poder responder:**

- ¿Por qué el envío va en un Queueable y no directamente en el trigger?
  (pista: callouts y DML pesado dentro de la transacción síncrona)
- ¿Cómo diferencias el Record Type sin hacer una query por registro?
- ¿Cómo garantiza tu test que 200 Casos cerrados en una sola transacción no generan
  envíos duplicados?
- ¿Qué pasa exactamente si omites el guard de recursividad?

---

## REQ-CASE-06 — Bloquear cierre de Caso de garantía sin evidencia

**Tipo:** FLOW + Approval Process · **Prioridad:** Alta

> El sistema deberá impedir cerrar un Caso de garantía de vivienda sin evidencia
> fotográfica ni aprobación técnica.

Combina validación (¿Validation Rule o Flow?) con un Approval Process. La evidencia
fotográfica implica verificar `ContentDocumentLink` / Files asociados al Caso.

---

## REQ-CASE-07 — Fusionar Casos duplicados

**Tipo:** DEC · **Prioridad:** Baja

> El sistema deberá permitir fusionar Casos duplicados conservando el historial
> combinado.
