# Compuertas de calidad de código

El proyecto tiene **tres compuertas**, cada una más lenta y más estricta que la
anterior. La idea es que un error te lo diga la compuerta más barata posible: cuanto
más tarde lo descubres, más caro sale.

| Compuerta      | Cuándo                | Qué corre                                                                | Duración | Se puede saltar    |
| -------------- | --------------------- | ------------------------------------------------------------------------ | -------- | ------------------ |
| **pre-commit** | `git commit`          | Prettier + ESLint + Jest, **solo sobre archivos staged** (`lint-staged`) | segundos | Sí (`--no-verify`) |
| **pre-push**   | `git push`            | **Salesforce Code Analyzer** sobre todo `force-app`                      | ~10 s    | Sí (`--no-verify`) |
| **CI**         | Pull Request a `main` | Todo lo anterior + scratch org, deploy y tests Apex                      | minutos  | **No**             |

## Por qué Code Analyzer va en pre-push y no en pre-commit

Prettier y ESLint tardan milisegundos sobre un par de archivos. Code Analyzer levanta
una JVM, compila el workspace y construye un grafo de código: ~10 segundos hoy, y crece
con el proyecto.

En cada `git commit` te llevaría a hacer menos commits, y commits grandes y espaciados
son peores que el problema que se quiere evitar. En `git push` corre **una sola vez sin
importar cuántos commits lleves**, y sigue estando antes de CI.

## Las reglas de seguridad no vienen activadas por defecto

Code Analyzer tiene varios engines. Los de Apex son **PMD** (mira un archivo a la vez)
y **SFGE**, el _Salesforce Graph Engine_ (sigue el flujo de datos por todos los
caminos de ejecución). En una frase: **PMD ve un archivo, SFGE ve un camino.**

Las reglas de SFGE están etiquetadas `DevPreview`, no `Recommended`, y el selector por
defecto es `Recommended`. Medido con la versión instalada: `Recommended` son 72 reglas
(6 regex, 65 PMD, 1 CPD) y **ninguna** es de SFGE. Sin pedirlo explícitamente, no
corren estas:

| Regla                                  | Severidad    | Qué detecta                                  | Requerimiento relacionado            |
| -------------------------------------- | ------------ | -------------------------------------------- | ------------------------------------ |
| `ApexFlsViolation`                     | 2 (High)     | Lectura/escritura sin verificar CRUD/FLS     | [REQ-SEC-02](../req/10-seguridad.md) |
| `DatabaseOperationsMustUseWithSharing` | 2 (High)     | DML en clases sin `with sharing`             | [REQ-SEC-01](../req/10-seguridad.md) |
| `AvoidDatabaseOperationInLoop`         | 2 (High)     | SOQL o DML dentro de un loop                 | Bulkificación, transversal           |
| `AvoidMultipleMassSchemaLookups`       | 2 (High)     | `Schema.describe` repetido (caro)            | Transversal                          |
| `ApexNullPointerException`             | 3 (Moderate) | NPE alcanzable por algún camino              | Transversal                          |
| `MissingNullCheckOnSoqlVariable`       | 3 (Moderate) | Usar el resultado de una query sin validarlo | Transversal                          |
| `UnimplementedType`                    | 4 (Low)      | Interfaz declarada y no implementada         | Transversal                          |

**Cuánto se pierde sin ellas:** al correr el análisis sobre el Apex de
[dreamhouse-lwc](https://github.com/trailheadapps/dreamhouse-lwc) (9 clases), el
selector por defecto encuentra 13 violaciones que bloquean; con SFGE encuentra 25. Las
12 que se escapaban eran 9 `ApexFlsViolation`, 2 `MissingNullCheckOnSoqlVariable` y 1
`ApexNullPointerException`.

Por eso el comando lleva dos selectores. Vive en `package.json`, de modo que el hook y
CI ejecutan exactamente lo mismo:

```bash
sf code-analyzer run --workspace force-app \
  --rule-selector Recommended --rule-selector sfge \
  --severity-threshold 3
```

## El umbral de severidad

`--severity-threshold 3` hace que el comando salga con un código distinto de cero
cuando la peor violación es de severidad **3 (Moderate), 2 (High) o 1 (Critical)**. El
código de salida es el número de la severidad más grave encontrada (2 en el ejemplo de
dreamhouse), y Git aborta el push ante cualquier valor distinto de cero.

Las severidades **4 (Low) y 5 (Info) se reportan pero no bloquean**: cosas como "falta
ApexDoc" o "`@isTest` debería ser `@IsTest`".

## Comandos

```bash
npm run scan          # lo que corre el hook de pre-push
npm run scan:detail   # igual, con la explicación completa de cada violación
```

`scan:detail` sirve para entender _por qué_ se queja una regla: incluye el
razonamiento y, en SFGE, el camino de ejecución que disparó la violación.

## Configuración (`code-analyzer.yml`)

Solo contiene lo que difiere de los valores por defecto:

- `auto_discover_eslint_config: true` — el engine ESLint reutiliza el `eslint.config.js`
  del proyecto, así que `npm run lint` y el análisis no pueden discrepar sobre un mismo
  archivo.
- `disable_lwc_base_config: true` — `eslint.config.js` ya aplica las reglas
  recomendadas de LWC; dejar la base integrada activa reportaría cada violación LWC
  dos veces.

## Cuándo saltarse una compuerta

`git push --no-verify` salta el hook. Es legítimo para respaldar una rama en progreso,
o ante un falso positivo que ya estás gestionando. **No lo es para "ya lo arreglo
después"**: CI corre el mismo comando y te frena igual, solo que más tarde.

Ante un falso positivo real, lo correcto es suprimirlo explícitamente (sección
`suppressions` de `code-analyzer.yml`, o un comentario de supresión en línea) dejando
constancia del porqué. Una supresión documentada se puede defender en una revisión; un
`--no-verify` no deja rastro.

## Estado actual y pendientes

- Las 4 violaciones Low que se reportan hoy son de `CicdPipelineCheck`, la clase smoke
  test descartable. Desaparecen al borrarla.
- **La versión de Code Analyzer no está fijada**, ni en local ni en CI (igual que el
  Salesforce CLI). Una versión nueva puede añadir reglas y hacer fallar CI sin que el
  código haya cambiado. Si eso se vuelve un problema, se fija en el workflow con
  `sf plugins install code-analyzer@<versión>`.
- Cuando aparezcan Flows, el engine `flow` necesitará Python; el analizador lo
  autodetecta como `python3`.
