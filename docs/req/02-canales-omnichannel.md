# 4.2 Canales de contacto / Omni-Channel

| ID        | Tipo      | Prioridad | Estado |
| --------- | --------- | --------- | ------ |
| REQ-CH-01 | DEC       | Alta      | ⬜     |
| REQ-CH-02 | INT + DEC | Alta      | ⬜     |
| REQ-CH-03 | DEC       | Media     | ⬜     |
| REQ-CH-04 | DEC + LWC | Media     | ⬜     |
| REQ-CH-05 | DEC       | Baja      | ⬜     |

---

## REQ-CH-01 — Service Channels independientes por Skills

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá habilitar Service Channels independientes (Caso, Mensajería, Voz)
> enrutados por Skills según Unidad de Negocio.

Base de todo Omni-Channel en el proyecto. Configúralo antes de REQ-CH-03 y
[REQ-AUTO-01](05-automatizacion.md).

**Preguntas que debes poder responder:**

- ¿Qué es un Service Channel, un Routing Configuration y una Presence Configuration,
  y cómo se relacionan?
- ¿Diferencia entre Queue-Based Routing y Skills-Based Routing?

---

## REQ-CH-02 — WhatsApp para huéspedes de hotel

**Tipo:** INT + DEC · **Prioridad:** Alta

> El sistema deberá permitir a un huésped de hotel conversar por WhatsApp
> antes/durante/después de su estadía, vinculado a su Reserva.

Depende de [REQ-HT-01](08-hoteleria.md) (objeto Reserva). Relacionado con
[REQ-SLA-03](03-sla-entitlements.md), que completa el milestone de primera respuesta
en este canal.

---

## REQ-CH-03 — Parking prioridad Alta a agente senior

**Tipo:** DEC · **Prioridad:** Media

> El sistema deberá enrutar Casos de Parking de prioridad Alta a un agente senior
> mediante routing "Most Available" con Skill obligatoria.

**Preguntas que debes poder responder:**

- ¿Diferencia entre routing _Least Active_ y _Most Available_?
- ¿Qué distingue una Skill obligatoria (required) de una adicional (additional) y
  qué pasa si ningún agente la tiene?

---

## REQ-CH-04 — Formulario dinámico de Web-to-Case 🔨

**Tipo:** DEC + LWC · **Prioridad:** Media

> El sistema deberá exponer un formulario Web-to-Case con campos dinámicos según
> tipo de propiedad/servicio.

**Diseño esperado:** un componente LWC que muestre campos distintos según la Unidad
de Negocio seleccionada (Inmobiliaria / Parking / Hotelería) y cree el Caso vía un
Apex controller al enviarse, sin recargar la página.

> ⚠️ **Este es el requerimiento donde JavaScript pesa más.** El BRD lo marca
> explícitamente como el punto débil a reforzar. Recomendación: no lo ataques hasta
> que el Apex ya sea cómodo. Cuando llegues, pide explicación de sintaxis paso a
> paso, no solo del resultado.

**Preguntas que debes poder responder:**

- ¿Cómo maneja LWC la reactividad de campos condicionales? (`@track` vs. campos
  reactivos por defecto, getters, `template if:true` / `lwc:if`)
- ¿Cuándo usas `@wire` y cuándo una llamada imperativa a Apex?
- ¿Qué necesita un método Apex para ser invocable desde LWC?

---

## REQ-CH-05 — Enrutamiento programado a fecha futura

**Tipo:** DEC · **Prioridad:** Baja

> El sistema deberá permitir programar el enrutamiento de un Caso de mantenimiento
> para una fecha futura acordada.
