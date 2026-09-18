# CI/CD — estado real del repo

> ⚠️ **Los YAML de la Sección 7.3 y 7.4 del BRD original NO son lo que está
> implementado.** El BRD fue escrito antes de encontrar dos bugs del Salesforce CLI.
> Este archivo documenta lo que realmente corre. Ante cualquier duda, la fuente de
> verdad son [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) y
> [`cd.yml`](../../.github/workflows/cd.yml).

## CI — en cada Pull Request hacia `main`

**Objetivo:** que ningún código roto llegue a `main`. Crea una scratch org temporal
_solo para validar_, corre los tests, y la borra sin importar el resultado.

Pasos de [`ci.yml`](../../.github/workflows/ci.yml):

1. Checkout del código.
2. Instalar el Salesforce CLI.
3. Escribir el auth URL del Dev Hub a un archivo temporal desde el secret.
4. `sf org login sfdx-url` → alias `devhub`, marcado como default Dev Hub.
5. Borrar el archivo del auth URL (`if: always()`).
6. `sf org create scratch` → alias `ci-scratch`, 1 día de duración.
7. `sf project deploy start --source-dir force-app`.
8. `sf apex run test --test-level RunLocalTests --code-coverage --synchronous`.
9. `sf org delete scratch` (`if: always()`).

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
