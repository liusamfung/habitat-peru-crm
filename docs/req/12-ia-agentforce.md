# 4.12 IA / Agentforce (valor agregado)

Ambos de prioridad Baja y mayormente configuración. Son el "extra" que diferencia el
portafolio, no el núcleo del proyecto — déjalos para el final.

| ID        | Tipo | Prioridad | Estado |
| --------- | ---- | --------- | ------ |
| REQ-AI-01 | IA   | Baja      | ⬜     |
| REQ-AI-02 | IA   | Baja      | ⬜     |

---

## REQ-AI-01 — Agente Agentforce de autoservicio

**Tipo:** IA · **Prioridad:** Baja

> El sistema deberá evaluar un Agente Agentforce para autoservicio de preguntas
> frecuentes antes de derivar a un humano.

**Pasos de Setup:** configúralo en **Agent Builder** (Setup → Agentforce), definiendo
el propósito, las acciones disponibles (ej. consultar Knowledge) y las condiciones de
derivación a un agente humano. No requiere Apex salvo que quieras darle una **Acción
custom** (ahí sí es una clase con `@InvocableMethod`).

Depende de [REQ-KM-01](04-conocimiento.md): sin Knowledge cargado y segmentado, el
agente no tiene de dónde responder.

---

## REQ-AI-02 — Clasificación predictiva de Tipo y Motivo

**Tipo:** IA · **Prioridad:** Baja

> El sistema deberá sugerir Tipo y Motivo del Caso al agente mediante clasificación
> predictiva.

Es el camino "IA" de [REQ-CASE-02](01-gestion-casos.md) (Einstein Case
Classification), frente al camino "Flow con reglas explícitas".

> ⚠️ Einstein Case Classification necesita **volumen histórico de Casos** para
> entrenar el modelo. En una org de portafolio recién creada probablemente no haya
> suficientes datos reales. Considéralo al planificar: quizá necesites generar datos
> de prueba, o limitarte a documentar el diseño sin activarlo.

**Preguntas que debes poder responder:**

- ¿Cuándo conviene la clasificación predictiva frente a reglas explícitas en un Flow?
- ¿Qué volumen de datos históricos requiere y qué pasa si no lo tienes?
