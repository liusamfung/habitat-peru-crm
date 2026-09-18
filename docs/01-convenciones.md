# Convenciones y requisitos no funcionales

## Tipos de implementación

Cada requerimiento lleva un **Tipo**. Este criterio — distinguir qué se configura y
qué se programa — es el que un entrevistador espera que sepas aplicar de entrada.

| Código   | Significa                            | Qué implica                                                                                                                                                  |
| -------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **DEC**  | Declarativo                          | Se configura 100% en Setup (clicks): Flow, Assignment Rules, Entitlement Processes, Reports, Sharing. No necesitas escribir código — necesitas el navegador. |
| **FLOW** | Flow Builder avanzado                | Declarativo, pero con lógica condicional/orquestación no trivial. Tampoco requiere Apex, pero vale la pena documentar el diseño del Flow.                    |
| **APEX** | Apex (Trigger/Clase/Batch/Queueable) | Requiere código.                                                                                                                                             |
| **LWC**  | Lightning Web Component              | Requiere código (HTML/JS + Apex de soporte).                                                                                                                 |
| **INT**  | Integración                          | REST/SOAP/Platform Events — normalmente Apex + configuración (Named Credentials).                                                                            |
| **IA**   | Agentforce / Einstein                | Mayormente configuración (Agent Builder, Einstein Setup); no suele requerir Apex salvo acciones custom.                                                      |

### Regla general para requerimientos sin detalle propio

- Si el Tipo dice **DEC** → es Setup, sin código. Los pasos de configuración los
  puedo dar completos, porque configurar no es el objetivo de aprendizaje de código.
- Si dice **APEX / FLOW+APEX / INT / LWC** → lo escribe Samuel. La estructura de
  trabajo se mantiene igual en todos: **entender el requerimiento → diseñar →
  escribir código → escribir test → explicar en voz alta qué hace y por qué**.

### El estándar de "terminado"

Un requerimiento de código no está listo hasta que:

1. El código funciona desplegado en una scratch org.
2. Existe su clase de test con **>75% de cobertura**, incluyendo un **escenario bulk
   de 200 registros**.
3. Samuel puede explicar en español y en lenguaje sencillo: qué hace cada parte, qué
   patrón de diseño usó (handler pattern, bulkificación, etc.) y **qué pasaría si no
   lo hubiera aplicado**.

El punto 3 es el que realmente importa. Si no puede explicarlo, no está terminado.

## Requisitos no funcionales

- **Disponibilidad y rendimiento** — la Consola de Servicio debe cargar en menos de
  3 segundos; el sistema debe soportar picos de demanda en temporada alta de Hotelería.
- **Cumplimiento legal** — adherencia a la **Ley N.º 29733** (Protección de Datos
  Personales, Perú) para todo dato de cliente almacenado.
- **Idioma** — interfaz y comunicaciones en español, con soporte de plantillas en
  inglés para huéspedes extranjeros de Hotelería.
- **Trazabilidad** — todo cambio de Prioridad, Estado o Propietario en un Caso debe
  quedar auditado.
- **Capacitación** — el diseño de automatización debe ser sostenible por un equipo de
  administración sin dependencia permanente de un developer. _De ahí que la mayoría
  de requerimientos sean DEC:_ elegir Apex cuando un Flow bastaba es un error de
  criterio, no una virtud técnica.

## Convenciones de código y repo

| Tema        | Convención                                                                                                                                                            |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Rama        | `feature/req-case-05` — tipo/kebab, ID del requerimiento en minúsculas                                                                                                |
| Commit      | **En inglés**, imperativo, con el ID como prefijo: `REQ-CASE-05: add satisfaction survey on case close`                                                               |
| API version | 67.0 (`sfdx-project.json`)                                                                                                                                            |
| Idioma      | **Git en inglés** (ramas y commits). **Español** en documentación, comentarios de código y nombres de campos/objetos de negocio (`Riesgo_SLA__c`, `Reserva_Hotel__c`) |

> El BRD original proponía commits en español. Se optó por inglés para mantener la
> consistencia con el historial ya existente del repo.
> | Formato | Prettier + ESLint vía Husky pre-commit |
