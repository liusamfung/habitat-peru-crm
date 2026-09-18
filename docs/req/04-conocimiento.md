# 4.4 Conocimiento / autoservicio

| ID        | Tipo      | Prioridad | Estado |
| --------- | --------- | --------- | ------ |
| REQ-KM-01 | DEC       | Media     | ⬜     |
| REQ-KM-02 | DEC       | Media     | ⬜     |
| REQ-KM-03 | DEC + LWC | Baja      | ⬜     |

---

## REQ-KM-01 — Knowledge segmentado por Data Category

**Tipo:** DEC · **Prioridad:** Media

> El sistema deberá segmentar Salesforce Knowledge por Data Category según Unidad
> de Negocio.

**Preguntas que debes poder responder:**

- ¿Qué es un Data Category Group y cómo se relaciona con la visibilidad por
  Profile/Role?
- ¿Diferencia entre segmentar por Data Category y segmentar por Record Type?

---

## REQ-KM-02 — Sugerir artículos relevantes al agente

**Tipo:** DEC · **Prioridad:** Media

> El sistema deberá sugerir artículos relevantes al agente según Tipo y Motivo del Caso.

Knowledge Component en la Service Console + reglas de sugerencia. Depende de REQ-KM-01.

---

## REQ-KM-03 — Portal de autoservicio en Experience Cloud

**Tipo:** DEC + LWC · **Prioridad:** Baja

> El sistema deberá publicar artículos de autoservicio en un portal Experience Cloud.

Prioridad baja y alcance grande (levantar un site completo). Relacionado con
[REQ-RE-03](06-inmobiliaria.md), que también necesita Experience Cloud — si atacas
uno, considera hacer ambos en la misma iteración.
