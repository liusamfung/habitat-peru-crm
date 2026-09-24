# 4.11 Integraciones

Las tres requieren Apex. Junto con [4.5](05-automatizacion.md), es el área más
técnica del proyecto y la que mejor demuestra perfil de developer (no de admin).

| ID         | Tipo | Prioridad | Estado |
| ---------- | ---- | --------- | ------ |
| REQ-INT-01 | INT  | Media     | ⬜     |
| REQ-INT-02 | APEX | Media     | ⬜     |
| REQ-INT-03 | APEX | Media     | ⬜     |

---

## REQ-INT-01 — Endpoint para crear Casos desde el PMS de Hotelería 🔨

**Tipo:** INT · **Prioridad:** Media

> El sistema deberá exponer un endpoint para crear Casos desde el PMS de Hotelería
> ante incidencias operativas.

Integración **entrante** (inbound): Salesforce expone, el sistema externo llama.
Compárala con [REQ-PK-01](07-parking.md), que tiene ambas direcciones.

**Preguntas que debes poder responder:**

- ¿`@RestResource` con `@HttpPost`, o Apex SOAP, o Composite API estándar? ¿Cuándo
  justifica escribir un endpoint custom en vez de usar la REST API estándar de
  Salesforce?
- ¿Cómo se autentica el sistema externo contra tu endpoint? (Connected App /
  External Client App + OAuth — ver [devops/03-autenticacion-jwt.md](../devops/03-autenticacion-jwt.md))
- ¿Cómo devuelves errores de forma útil? ¿Qué códigos HTTP?
- ¿Cómo haces el endpoint idempotente, para que un reintento del PMS no cree un Caso
  duplicado?

---

## REQ-INT-02 — Platform Event al resolver un Caso 🔨

**Tipo:** APEX · **Prioridad:** Media

> El sistema deberá publicar un Platform Event cuando un Caso pase a "Resuelto" para
> un sistema externo de garantías/facturación.

"Resuelto" es el nombre que ve el usuario; el **valor guardado** de `Status` es
`Resolved`, y es el que compara el código. Es un estado **abierto** (el cerrado es
`Closed`, que dispara [REQ-CASE-05](01-gestion-casos.md)), de modo que ambos
requerimientos reaccionan en momentos distintos.

**Diseño esperado:** un Platform Event **`Case_Resolved__e`** y un Apex Trigger en
`Case` que lo publique cuando el Estado cambie a "Resuelto" (`Resolved`), incluyendo
**Record Type y fecha de resolución** como campos del evento.

> Buen requerimiento de dificultad media una vez que [REQ-CASE-05](01-gestion-casos.md)
> esté hecho: reutiliza el mismo patrón de trigger + handler, pero con publicación de
> eventos en vez de Queueable.

**Preguntas que debes poder responder:**

- **¿Por qué un Platform Event es preferible a un callout síncrono aquí?**
  (pista: desacoplamiento, reintentos del lado suscriptor)
- ¿Cómo se suscribe un sistema externo a un Platform Event? (CometD / Pub-Sub API)
- ¿Diferencia entre `Publish Immediately` y `Publish After Commit`? ¿Cuál usas y por qué?
- ¿Qué pasa con el evento si la transacción hace rollback?

---

## REQ-INT-03 — Sincronización asíncrona con el sistema contable 🔨

**Tipo:** APEX · **Prioridad:** Media

> El sistema deberá sincronizar de forma asíncrona los Casos resueltos con el sistema
> contable, sin bloquear al agente.

**Preguntas que debes poder responder:**

- ¿Queueable, `@future(callout=true)`, Batch o suscriptor del Platform Event de
  REQ-INT-02? ¿Cuál eliges y por qué?
- "Sin bloquear al agente" — ¿qué significa técnicamente eso respecto a la transacción?
- ¿Cómo manejas un fallo de sincronización? ¿Reintentas, registras, alertas?
- ¿Cuál es el límite de callouts por transacción y cómo lo respetas con muchos Casos?
