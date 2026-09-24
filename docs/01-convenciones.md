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
  inglés para huéspedes extranjeros de Hotelería. Cómo se cumple en la org: ver
  [Idioma — regla estricta](#idioma--regla-estricta).
- **Trazabilidad** — todo cambio de Prioridad, Estado o Propietario en un Caso debe
  quedar auditado.
- **Capacitación** — el diseño de automatización debe ser sostenible por un equipo de
  administración sin dependencia permanente de un developer. _De ahí que la mayoría
  de requerimientos sean DEC:_ elegir Apex cuando un Flow bastaba es un error de
  criterio, no una virtud técnica.

## Convenciones de código y repo

| Tema        | Convención                                                                                          |
| ----------- | --------------------------------------------------------------------------------------------------- |
| Rama        | `feature/req-case-05` — tipo/kebab, en inglés                                                       |
| Commit      | En inglés, imperativo, con el ID como prefijo: `REQ-CASE-05: add satisfaction survey on case close` |
| API version | 67.0 (`sfdx-project.json`)                                                                          |
| Formato     | Prettier + ESLint vía Husky pre-commit                                                              |

## Idioma — regla estricta

| Ámbito                                                              | Idioma                                                                                   |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Ramas, commits, Pull Requests                                       | **Inglés**                                                                               |
| Código: clases, métodos, variables, comentarios                     | **Inglés**                                                                               |
| **API names** de objetos y campos custom                            | **Inglés** — `SLA_Risk__c`, `Hotel_Reservation__c`                                       |
| **Labels** de objetos, campos y Record Types                        | **Español**, tecleados directo — "Riesgo SLA", "Reserva de Hotel"                        |
| **Valores de picklist** (`Status`, `Type`, `Reason`, campos custom) | **Inglés**, con traducción al español vía Translation Workbench (pendiente de verificar) |
| Plantillas de email y textos de Flow                                | **Pendiente de decidir**                                                                 |
| Documentación (`docs/`, `README.md`)                                | **Español**                                                                              |

**El porqué de la separación:** la documentación es la cara visible del portafolio
ante un reclutador hispanohablante, así que va en español. El código va en inglés
porque es el estándar profesional y es lo que esperaría cualquier equipo. El
requisito no funcional de _"interfaz y comunicaciones en español"_ se cumple con dos
piezas: los **labels** de objetos, campos y Record Types, tecleados directamente en
español, y las **traducciones al español de los valores de picklist**. Los API names,
que el usuario final nunca ve, quedan en inglés.

**Por qué los valores de picklist no se teclean en español:** el código los compara
como string (`Status = 'Closed'`). Si el valor guardado fuera `Cerrado`, esa
comparación dejaría de coincidir. Por eso el valor se guarda siempre en inglés y el
español se agrega solo como traducción, que cambia lo que ve el usuario sin cambiar lo
que compara el código. Un label, en cambio, es texto libre que el código nunca
referencia (usa API names o `DeveloperName`), así que no necesita traducción.

### Idioma de la org

La org está en **inglés** (`en_US`). Verificado en la org de Portafolio con
`SELECT LanguageLocaleKey FROM Organization`. Las scratch orgs usan el idioma por
defecto, porque `config/project-scratch-def.json` no define la clave `language`; eso
se confirmará con la primera scratch org real. La idea es que CI, CD y el desarrollo
local compartan idioma.

### Translation Workbench (pendiente de verificar)

Translation Workbench es la herramienta de Setup que permite ofrecer traducciones de
elementos de metadata, entre ellos los valores de picklist, según el idioma del
usuario. En este proyecto se usa **solo para los valores de picklist** (`Status`,
`Type`, `Reason` y los de campos custom); los labels se teclean directo en español y
no la necesitan.

> ⚠️ **Pendiente de verificar.** Aún no se ha comprobado que funcione como se espera.
> Prueba mínima antes de aplicarlo a todo: crear UN valor de prueba en `Type`,
> confirmar que se guarda en inglés, y confirmar que la traducción aparece al cambiar
> el idioma del usuario a español. En la misma prueba, comprobar si el valor de
> picklist tiene **API name propio** además de su label: de eso depende si el guion
> bajo de valores como `Waiting_on_Customer` va solo en el API name o en todo el
> valor. Si la prueba falla, esta sección y la regla de idioma se revisan.

> ⚠️ **Dos convenciones del BRD original quedaron derogadas:** proponía commits en
> español (ahora inglés, por consistencia con el historial del repo) y nombraba campos
> en español — `Riesgo_SLA__c`, `Reserva_Hotel__c`. Cuando un requerimiento mencione
> un campo con nombre en español, créalo con **API name en inglés y Label en español**.
