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

### Decisiones de diseño (2026-09-23)

**Record Types.** Un solo objeto `Case` con tres Record Types:

| `DeveloperName` | Label (español)  |
| --------------- | ---------------- |
| `Real_Estate`   | Inmobiliaria     |
| `Parking`       | Estacionamientos |
| `Hospitality`   | Hotelería        |

**`Status`.** Un flujo compartido entre las tres unidades, confirmado el 2026-09-23,
con seis valores: `New`, `Working`, `Waiting_on_Customer`, `Escalated`, `Resolved` y
`Closed`. **Solo `Closed` es un estado cerrado**; `Resolved` es **abierto**, para que
REQ-INT-02 (al resolver) y REQ-CASE-05 (al cerrar) disparen en momentos distintos y no
se pisen. `Waiting_on_Customer` es el estado en el que REQ-SLA-02 pausa el cronómetro.
Sin estados propios por unidad hasta que un requerimiento lo exija.

**`Type`.** Tres valores compartidos (`Inquiry`, `Complaint`, `Request`) y dos
exclusivos de `Real_Estate` (`Warranty_Claim`, `Post_Sale_Follow_Up`).

**`Reason`.** Filtrado solo por Record Type, con unos 3 valores por unidad. Se descarta
por ahora la dependencia Type→Reason. Agregar valores después es barato. Tres valores
por unidad, decididos el 2026-09-23:

| Record Type   | Valor guardado         | Traducción al español   |
| ------------- | ---------------------- | ----------------------- |
| `Real_Estate` | `Delivery`             | Entrega                 |
| `Real_Estate` | `Documentation`        | Documentación           |
| `Real_Estate` | `Construction_Defect`  | Defecto de construcción |
| `Parking`     | `Lost_Ticket`          | _(por definir)_         |
| `Parking`     | `Monthly_Subscription` | _(por definir)_         |
| `Parking`     | `Vehicle_Damage`       | _(por definir)_         |
| `Hospitality` | `Special_Request`      | _(por definir)_         |
| `Hospitality` | `Operational_Incident` | _(por definir)_         |
| `Hospitality` | `Service_Quality`      | Calidad del servicio    |

Las traducciones que faltan se definen al configurar cada valor. La forma final de los
valores con guion bajo depende de la verificación del API name (ver más abajo).

**Acceso a los Record Types.** Un solo Permission Set, `Case_All_Record_Types`, que da
acceso a los tres Record Types al administrador y al desarrollo. Se crea en Setup y se
trae al repo con `retrieve`. No se usa el perfil Admin, porque su archivo es enorme y
cada `retrieve` lo reescribe con cambios ajenos. Los permission sets por unidad quedan
para [REQ-SEC-01](10-seguridad.md), junto con la visibilidad de los registros.

**Page layouts.** Un solo page layout compartido por los tres Record Types. La
asignación de layout a cada Record Type se guarda en el perfil, no en el permission
set, así que un layout por unidad volvería a meter el perfil (y su ruido) en el repo.
Se crean layouts por unidad solo cuando un requerimiento lo exija.

**Idioma.** Los valores de picklist se guardan en inglés y el español va como
traducción vía Translation Workbench (pendiente de verificar). Los labels de los
Record Types se teclean directo en español. Ver
[Idioma — regla estricta](../01-convenciones.md#idioma--regla-estricta).

**Decisiones de diseño abiertas: ninguna.** Solo quedan las comprobaciones en la
scratch org y el trabajo posterior que se indica abajo. Los `Reason` de Parking cubren
la pérdida de boleta ([REQ-PK-01](07-parking.md)), el abono mensual (REQ-PK-02) y el
daño vehicular ([REQ-PK-03](07-parking.md)).

**Cuando el permission set ya exista en el repo** (creado, traído con `retrieve` y
commiteado):

- Añadir `sf org assign permset -n Case_All_Record_Types` a `ci.yml`, **después del
  deploy y antes de los tests**.
- Añadirlo también al flujo local de creación de scratch orgs (ver el
  [flujo por feature](../devops/01-flujo-git-y-orgs.md)).

La asignación es dato y no metadata, así que hay que repetirla en cada scratch org
nueva.

**Pendiente de verificar en la scratch org** (antes de configurar los `Status`):

1. Que la scratch org traiga por defecto los `Status` `New`, `Working`, `Escalated` y
   `Closed`. Es lo que devuelve el Dev Hub, pero falta comprobarlo en la scratch org.
2. Cómo se asigna el _support process_ a los Record Types. El support process es lo que
   define qué valores de `Status` están disponibles para cada Record Type.
3. Si un valor de picklist tiene **API name propio** además de su label. Con eso se
   decide si el guion bajo de `Waiting_on_Customer` va solo en el API name o en todo el
   valor. El nombre está confirmado; lo que falta decidir es su forma. Esta comprobación
   se hace junto con la prueba de
   [Translation Workbench](../01-convenciones.md#translation-workbench-pendiente-de-verificar).

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

- Un Apex Trigger sobre `Case` que detecte el cambio a `Status = 'Closed'`. Recuerda
  que `Resolved` es un estado **abierto**: esta encuesta se dispara al cerrar, no al
  resolver (ver las [decisiones de diseño](#decisiones-de-diseño-2026-09-23) de
  REQ-CASE-01).
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
