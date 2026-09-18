# 4.6 Habitat Inmobiliaria (específico)

Lotes, vivienda de interés social y departamentos, con posventa y garantías de
construcción sujetas a plazos legales peruanos.

| ID        | Tipo             | Prioridad | Estado |
| --------- | ---------------- | --------- | ------ |
| REQ-RE-01 | DEC              | Alta      | ⬜     |
| REQ-RE-02 | DEC              | Alta      | ⬜     |
| REQ-RE-03 | DEC + LWC        | Baja      | ⬜     |
| REQ-RE-04 | APEX (Scheduled) | Media     | ⬜     |

---

## REQ-RE-01 — Vincular Caso a Unidad Inmobiliaria

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá vincular cada Caso a una "Unidad Inmobiliaria" (custom, tipo
> Asset) con etapa de proyecto y fecha de entrega.

Objeto base de esta unidad de negocio. [REQ-RE-04](#req-re-04--seguimiento-post-venta-automático-3090180-días)
depende de la fecha de entrega que definas aquí.

**Preguntas que debes poder responder:**

- ¿Usas el objeto estándar `Asset` o creas un objeto custom? ¿Qué ganas y qué pierdes
  con cada opción?
- ¿Lookup o Master-Detail hacia Case? ¿Qué implica cada uno para sharing y para el
  borrado en cascada?

---

## REQ-RE-02 — Garantía de Vivienda con Entitlement Process propio

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá gestionar la "Garantía de Vivienda" con un Entitlement Process
> propio y plazos legales peruanos.

Los plazos legales peruanos de garantía de construcción son parte del ejercicio de
consultoría: investígalos y documenta la fuente en el Entitlement Process.
Relacionado con [REQ-CASE-06](01-gestion-casos.md) (bloqueo de cierre sin evidencia).

---

## REQ-RE-03 — Partner Community para corredores externos

**Tipo:** DEC + LWC · **Prioridad:** Baja

> El sistema deberá permitir a corredores externos crear/seguir Casos de sus clientes
> referidos desde un Partner Community.

Requiere Experience Cloud, igual que [REQ-KM-03](04-conocimiento.md). Ojo con el
modelo de sharing para usuarios externos — interactúa con
[REQ-SEC-01](10-seguridad.md).

---

## REQ-RE-04 — Seguimiento post-venta automático (30/90/180 días) 🔨

**Tipo:** APEX (Scheduled) · **Prioridad:** Media

> El sistema deberá generar automáticamente un Caso de seguimiento post-venta a los
> 30, 90 y 180 días de la entrega.

**Diseño esperado:** una ejecución diaria que cree un Caso de tipo "Seguimiento
Post-Venta" para toda Unidad Inmobiliaria cuya fecha de entrega tenga exactamente 30,
90 o 180 días de antigüedad.

> 🎯 **Este requerimiento es el mejor ejercicio de criterio del BRD.** Se puede
> resolver igual de bien con un **Scheduled Flow** o con una clase **Schedulable en
> Apex**. Diseña las dos versiones y escribe el trade-off. Ese razonamiento
> —"¿por qué código aquí y no clicks?"— es justo lo que evalúan en entrevista, y el
> requisito no funcional de _sostenibilidad por un admin_ empuja hacia el Flow.

**Preguntas que debes poder responder:**

- ¿Cuál es el trade-off concreto entre Scheduled Flow y Schedulable Apex aquí?
  (mantenibilidad, límites, testabilidad, control de versiones)
- ¿Cómo evitas crear el Caso dos veces si el job corre dos veces el mismo día?
- ¿Qué pasa con las unidades entregadas mientras el job estuvo caído?
