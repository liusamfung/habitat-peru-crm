# Flujo de desarrollo: Git, orgs y trabajo por feature

## Los tres tipos de org y su rol

| Org                                                | Rol                                                                                                                | Vida                |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------- |
| **Dev Hub** (Developer Edition actual)             | Solo autoriza y da seguimiento a la creación de Scratch Orgs. **Nunca recibe deploys.**                            | Permanente          |
| **Scratch Orgs**                                   | Una por feature/rama, para desarrollar y probar. Se descartan al terminar.                                         | Efímera (7–30 días) |
| **Org de Portafolio** (Developer Edition separada) | Acumula todo lo que ya pasó por Pull Request y se mergeó a `main`. Es la pantalla que le muestras a un reclutador. | Permanente          |

### Qué vive en cada una

| Configuración                                                    | Dev Hub                               | Portafolio                     |
| ---------------------------------------------------------------- | ------------------------------------- | ------------------------------ |
| Enable Dev Hub                                                   | Sí                                    | No aplica                      |
| External Client App + certificado JWT                            | Sí — para CI                          | Sí — para CD                   |
| Record Types de Case, objetos custom, Apex, LWC                  | **No** — nunca vive nada del BRD aquí | Sí — todo lo mergeado a `main` |
| Entitlement Management, Omni-Channel, Knowledge, Service Console | No                                    | Sí                             |

> **Por qué el Dev Hub también necesita autenticación headless** — es el punto que más
> confunde la primera vez. Mezcla dos cosas distintas: _desplegar código_ vs.
> _autenticarse para poder hacer algo_. El workflow de CI nunca toca Portafolio; su
> login al Dev Hub no es para desplegar, es para tener permiso de ejecutar
> `sf org create scratch`. Sin ese login, GitHub Actions no puede pedirle al Dev Hub
> una scratch org nueva.

## Flujo por feature (local)

```bash
git checkout -b feature/req-case-05
sf org create scratch -f config/project-scratch-def.json -a scratch-case-05 -d -y 7
# ...desarrollas...
sf project deploy start -o scratch-case-05
sf apex run test -o scratch-case-05 -l RunLocalTests -r human
# si tocaste algo a mano en el navegador de la scratch org:
sf project retrieve start -o scratch-case-05
git add . && git commit -m "REQ-CASE-05: encuesta de satisfacción al cerrar Caso"
git push origin feature/req-case-05
# abres el Pull Request en GitHub
```

La scratch org del feature se borra sola (o con `sf org delete scratch`) una vez
mergeado el PR — no se "sube" a ningún lado, es descartable por diseño.

## ⚠️ Cuota de scratch orgs

Un Dev Hub de Developer Edition da:

- **3 scratch orgs activas** a la vez
- **6 creaciones exitosas por día** (ventana móvil de 24 h)

**Cada corrida de CI consume una creación.** Con 6 al día, entre tus scratch orgs
locales y los pushes a un PR abierto, se agota antes de lo que parece.

```bash
sf org list --all                      # ver las activas
sf org delete scratch -o <alias> -p    # borrar una
```

## Checklist de configuración inicial

| #   | Paso                                                                                                                                       | Estado           |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------ | ---------------- |
| 1   | Certificado JWT (`openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 3650 -nodes`), fuera del repo o gitignoreado | ✅               |
| 2   | External Client App en el Dev Hub → Consumer Key                                                                                           | ✅               |
| 3   | External Client App en Portafolio (mismo certificado) → su propio Consumer Key                                                             | ✅               |
| 4   | GitHub Secrets configurados                                                                                                                | ✅               |
| 5   | Workflows `ci.yml` y `cd.yml` commiteados y corriendo al menos una vez                                                                     | ✅               |
| 6   | **Branch protection en `main`**                                                                                                            | ⬜ **Pendiente** |
| 7   | Vigilar la cuota de scratch orgs                                                                                                           | 🔁 Continuo      |

### Paso 6 — Branch protection (pendiente)

GitHub → Settings → Branches → Add rule, sobre `main`:

- **"Require a pull request before merging"** — se puede activar desde ya.
- **"Require status checks to pass"** — solo aparece seleccionable **después de que
  `ci.yml` haya corrido al menos una vez** contra el repo; GitHub necesita haber
  "visto" el check antes de poder exigirlo. Como el workflow ya corrió, este paso ya
  se puede completar.

Con esto, el botón de "Merge" literalmente no se habilita si los tests Apex fallan.
