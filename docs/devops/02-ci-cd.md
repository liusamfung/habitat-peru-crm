# CI/CD — estado real del repo

> ⚠️ **Los YAML de la Sección 7.3 y 7.4 del BRD original NO son lo que está
> implementado.** El BRD fue escrito antes de encontrar dos bugs del Salesforce CLI.
> Este archivo documenta lo que realmente corre. Ante cualquier duda, la fuente de
> verdad son [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) y
> [`cd.yml`](../../.github/workflows/cd.yml).

## CI — en cada Pull Request hacia `main`

**Objetivo:** que ningún código roto llegue a `main`. Son **dos jobs encadenados**
([`ci.yml`](../../.github/workflows/ci.yml)): el segundo declara `needs` sobre el
primero, así que solo corre si el primero pasa. Un error de formato o una violación de
seguridad falla en segundos y **nunca gasta una de las 6 creaciones diarias de scratch
org**.

### Job 1 — `format-lint-lwc-tests` (sin org)

1. Checkout del código.
2. `actions/setup-node` instala Node leyendo `.node-version` y cachea las descargas de npm.
3. `npm ci` (con `HUSKY=0`, porque los git hooks no sirven en un runner).
4. Prettier (`prettier:verify`), ESLint (`lint`) y Jest (`test:unit:coverage`).
5. Instalar el Salesforce CLI y el plugin `code-analyzer`.
6. **Análisis estático de Apex** (`npm run scan`). Ver
   [04-calidad-de-codigo.md](04-calidad-de-codigo.md).

### Job 2 — `scratch-org-test` (con org)

1. Instalar el Salesforce CLI y hacer checkout.
2. Escribir el auth URL del Dev Hub a un archivo, validando que el secret no esté vacío.
3. `sf org login sfdx-url` → alias `devhub`, marcado como default Dev Hub.
4. `sf org create scratch` → alias `scratch-org`, 1 día de duración.
5. `sf project deploy start`.
6. `sf org assign permset -n Case_All_Record_Types`: da acceso a los Record Types de
   `Case`. Es un dato y no metadata, por eso no viaja en el despliegue.
7. `sf apex run test -c -r human -w 20`.
8. `sf org delete scratch` (`if: always()`).

### Por qué `if: always()` en el borrado

Sin él, un fallo de tests dejaría la scratch org viva. Con **3 scratch orgs activas**
de límite, dos o tres PRs con tests rojos bastan para bloquear todo el desarrollo con
orgs huérfanas. `if: always()` garantiza la limpieza pase lo que pase.

## CD — en cada push a `main`

**Objetivo:** que la org de Portafolio siempre refleje exactamente lo último en `main`,
sin desplegar a mano.

Pasos de [`cd.yml`](../../.github/workflows/cd.yml):

1. Checkout + instalar CLI.
2. Escribir `server.key` desde el secret `SF_PORTFOLIO_JWT_KEY`.
3. `sf org login jwt` con Consumer Key + username → alias `portfolio`.
4. `sf project deploy start --source-dir force-app`.
5. `sf apex run test --test-level RunLocalTests --code-coverage --synchronous`.
6. Borrar `server.key` (`if: always()`).

### CI vs. CD — la diferencia conceptual

|               | CI                                   | CD                            |
| ------------- | ------------------------------------ | ----------------------------- |
| Disparo       | Pull Request hacia `main`            | Push a `main` (merge)         |
| Org           | Scratch temporal, creada y destruida | Portafolio, permanente        |
| Autenticación | Dev Hub (para _crear_ la scratch)    | Portafolio (para _desplegar_) |
| Persiste algo | **No.** Valida y descarta.           | **Sí.** Acumula features.     |

## Portafolio: lo que el CD no hace, y por qué

El CD despliega **metadata**. Hay cuatro cosas en Portafolio que no lo son, o que no se
lograron fijar como tal, y se hacen a mano **una sola vez**:

| Paso                                                   | Cómo                                                                                           | Por qué no está en el CD                                                        |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Asignar el permission set a quien use los Record Types | `sf org assign permset -n Case_All_Record_Types -o habitat-porfolio`                           | Ver abajo                                                                       |
| Activar Translation Workbench                          | Setup → Translation Language Settings → **Enable**                                             | No se logró fijar de forma fiable como metadata                                 |
| Añadir el español como idioma activo                   | El mismo sitio → **Add** → Spanish → **Active**                                                | Igual que el anterior                                                           |
| Volver a desplegar para activar las traducciones       | `gh run rerun $(gh run list --workflow CD --limit 1 --json databaseId --jq '.[0].databaseId')` | Las traducciones desplegadas con Translation Workbench apagado quedan inactivas |

El último paso solo hace falta si las traducciones se desplegaron **antes** de activar
Translation Workbench. Con la org ya configurada, cada CD las aplica directamente.

### Por qué el CD no asigna el permission set

- **Es un dato, no metadata**, y apunta a un usuario concreto. En el CD solo existe el
  usuario de la integración (el del JWT), que no tiene por qué ser quien use la org.
- **No es idempotente.** Asignarlo dos veces falla con `Duplicate PermissionSetAssignment`
  (código de salida 1), y el CD corre en cada push a `main` sobre la misma org. Habría que
  tolerar ese error a mano para algo que se hace una sola vez.
- **No es lo habitual en orgs persistentes.** Las asignaciones las gestionan los
  administradores o el aprovisionamiento de usuarios. En pipelines se asigna en scratch
  orgs efímeras, como hace el CI, porque ahí se parte de cero cada vez.

## Dos workarounds de bugs del CLI

Ambos están comentados en el propio YAML. Vale la pena entenderlos: son exactamente
el tipo de problema real que se cuenta en una entrevista.

### 1. `SF_USE_GENERIC_UNIX_KEYCHAIN: "true"` (en ambos workflows)

Los runners Linux de GitHub no tienen keychain/keyring de sistema operativo. Sin esta
variable, la búsqueda nativa de keychain del CLI falla **silenciosamente** después de
un intercambio OAuth exitoso, y se manifiesta como un `RefreshTokenAuthError`
engañoso — aunque el LoginHistory de Salesforce muestre el login como _Success_.

Ref: [forcedotcom/cli#2922](https://github.com/forcedotcom/cli/issues/2922)

### 2. Dev Hub autenticado por SFDX auth URL, no por JWT (solo en CI)

**Esta es la divergencia con el BRD.** El BRD §7.3 muestra `sf org login jwt` para el
Dev Hub; el repo usa `sf org login sfdx-url`.

Motivo: el bug **C-1016** del CLI — `sf org create scratch` falla cuando el Dev Hub
está autenticado vía **External Client App con JWT Bearer Flow**, porque el signup de
la scratch org no puede replicar ese tipo de app en la org nueva. Y como la creación
de Connected Apps clásicas está deshabilitada desde Spring '26, el JWT simplemente no
está disponible en este Dev Hub. La alternativa es un **SFDX auth URL** (refresh
token) guardado como secret.

Ref: [forcedotcom/cli#3515](https://github.com/forcedotcom/cli/issues/3515)

**CD sí usa JWT** — el bug solo afecta la creación de scratch orgs, y CD solo despliega.

## GitHub Secrets en uso

| Secret                      | Workflow | Para qué                                             |
| --------------------------- | -------- | ---------------------------------------------------- |
| `SF_DEVHUB_SFDX_AUTH_URL`   | CI       | Autenticar el Dev Hub y crear la scratch org         |
| `SF_PORTFOLIO_JWT_KEY`      | CD       | Llave privada del certificado JWT                    |
| `SF_PORTFOLIO_CONSUMER_KEY` | CD       | Consumer Key de la External Client App de Portafolio |
| `SF_PORTFOLIO_USERNAME`     | CD       | Usuario de la org de Portafolio                      |

> Los secrets `SF_CONSUMER_KEY`, `SF_JWT_KEY` y `SF_DEVHUB_USERNAME` que menciona el
> BRD §7.7 quedaron **sin usar** al cambiar CI a SFDX auth URL.

## Deuda técnica conocida

- **`CicdPipelineCheck`** — clase Apex smoke test (`ping()` → `'pong'`) con su test.
  No es parte del BRD. Borrar cuando exista el primer componente real.
- **Los tests corren dos veces** (CI en scratch, CD en Portafolio). Es intencional:
  la scratch org se crea desde cero y Portafolio tiene estado acumulado, así que
  detectan cosas distintas.
