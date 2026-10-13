# 4.10 Seguridad y cumplimiento

> ⚠️ **Ataca REQ-SEC-01 temprano.** Cambiar el modelo de sharing cuando ya hay datos,
> automatizaciones y usuarios configurados es mucho más caro que definirlo al inicio.

| ID         | Tipo | Prioridad | Estado |
| ---------- | ---- | --------- | ------ |
| REQ-SEC-01 | DEC  | Alta      | ✅     |
| REQ-SEC-02 | DEC  | Alta      | ⬜     |
| REQ-SEC-03 | DEC  | Media     | ⬜     |

---

## REQ-SEC-01 — OWD de Case Privado

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá configurar el OWD de Case como Privado, con visibilidad vía Case
> Team y jerarquía acotada por unidad.

**Pasos de Setup:** configura el OWD de Case en Privado (Setup → Sharing Settings) y
crea los Case Team Roles. La visibilidad por jerarquía de roles se acota con la forma
de la jerarquía, no con una casilla (ver la corrección de abajo).

> ⚠️ **Corrección al BRD.** El BRD indica usar **"Grant Access Using Hierarchies"** para
> limitar cuánto sube la visibilidad. En Case esa casilla **no se puede desmarcar**:
> Samuel lo comprobó en su org el 2026-09-23 (queda marcada y bloqueada aunque el OWD
> sea Private). La jerarquía de roles siempre da acceso hacia arriba, así que lo de
> "jerarquía acotada por unidad" se logra con la **forma de la jerarquía**: cada unidad
> de negocio en su propia rama, sin que el rol de un gerente sea ancestro de los roles
> de otra unidad, y solo el holding en la cima.

### Decisiones de diseño (2026-10-12)

Tomadas con Samuel. Nota: un texto sobre "las 7 capas" de visibilidad llegó pegado desde
otro chat; **no es un diseño vigente** y se descartó. Lo que sigue es lo decidido aquí.

| Decisión                                      | Valor                                           |
| --------------------------------------------- | ----------------------------------------------- |
| OWD de `Case`                                 | `Private` (interno y externo)                   |
| ¿Los agentes ven Casos de pares de su unidad? | Sí, **solo lectura**                            |
| ¿Quién ve los Casos de todas las unidades?    | Solo el rol superior del holding, por jerarquía |
| Niveles de rol dentro de cada unidad          | 2: gerente y agente                             |

**Jerarquía de roles.** API name en inglés, label en español:

```
Holding                              (Holding)
├── Real_Estate_Manager              (Gerente Inmobiliaria)
│   └── Real_Estate_Agent            (Agente Inmobiliaria)
├── Parking_Manager                  (Gerente Estacionamientos)
│   └── Parking_Agent                (Agente Estacionamientos)
└── Hospitality_Manager              (Gerente Hotelería)
    └── Hospitality_Agent            (Agente Hotelería)
```

**Qué ve cada rol:**

| Rol     | Casos propios        | Casos de pares de su unidad | Casos de otras unidades |
| ------- | -------------------- | --------------------------- | ----------------------- |
| Agente  | Lectura y edición    | Solo lectura                | No                      |
| Gerente | Lectura y edición    | Todos los de su unidad      | No                      |
| Holding | Todos, por jerarquía | Todos                       | Todos                   |

**Mecanismos que lo implementan:**

1. **OWD Privado.** Sin otro mecanismo, solo el propietario ve un Caso.
2. **Jerarquía de roles.** Siempre activa en `Case` (la casilla está bloqueada). Da al
   gerente la visibilidad de sus agentes y al holding la de todos.
3. **Una sharing rule por unidad**, por criterio de Record Type, que da lectura al rol
   `*_Agent` de esa unidad. Es lo que permite ver a los pares sin poder editarlos.
4. **Case Team.** Para dar acceso puntual a un Caso concreto. El único uso confirmado es
   REQ-PK-03 (Legal y Seguros); los roles de equipo se crean cuando un requerimiento los
   pida.

**Permission sets por unidad** (alcance heredado de [REQ-CASE-01](01-gestion-casos.md)).
`Case_All_Record_Types` sigue siendo para el administrador y el desarrollo. Para los
agentes, un permission set por unidad que solo hace disponibles los Record Types de la
suya. Los permisos CRUD sobre `Case` siguen viniendo del perfil.

| Permission set     | Label                     | Record Type que habilita |
| ------------------ | ------------------------- | ------------------------ |
| `Case_Real_Estate` | Casos de Inmobiliaria     | `Real_Estate`            |
| `Case_Parking`     | Casos de Estacionamientos | `Parking`                |
| `Case_Hospitality` | Casos de Hotelería        | `Hospitality`            |

Disponibilidad de un Record Type (permission set) y visibilidad de un registro (sharing
rule, rol) son ejes independientes.

**Cómo se verificará.** El administrador tiene `View All Data` y ve todo, así que no sirve
para probar. Se usa **un usuario de prueba**, al que se le cambia el rol entre pruebas:

1. Como agente de Parking: ve sus Casos y los de Parking en solo lectura; no ve
   Inmobiliaria ni Hotelería.
2. Como gerente de Parking: ve toda su unidad y no las otras.
3. Como holding: ve todo.

**Resultado de la verificación (2026-10-13).** Usuario de prueba `Agente Prueba`, licencia
`Salesforce`, con tres Casos de prueba (uno por Record Type) propiedad del administrador:

| Rol del usuario                  | Casos de su unidad                               | Casos de otras unidades |
| -------------------------------- | ------------------------------------------------ | ----------------------- |
| `Parking_Agent`                  | Lectura; editar falla al guardar                 | No los encuentra        |
| `Parking_Manager`                | Ve los de su unidad                              | No                      |
| `Holding`                        | Ve los de todas las unidades                     | Sí                      |
| `Parking_Agent` + `Case_Parking` | El diálogo de Nuevo solo ofrece Estacionamientos | —                       |

Qué se aprendió, y qué dejó de ser una duda:

- **Los Case Team Roles son datos, no metadata.** No existe tipo de metadata para ellos
  (`CaseTeamRole` es un objeto con filas). Hay que crearlos en cada org o cargarlos con un
  archivo de datos; se hará en REQ-PK-03 cuando se necesiten Legal y Seguros.
- **Case Teams ya viene habilitado** en esta versión de la org: no hay ajuste que activar
  ni versionar.
- **Los roles y las sharing rules sí se recuperan con `retrieve`** (por tipo y nombre,
  nunca `Profile`). Las tres reglas llegan juntas en `sharingRules/Case.sharingRules-meta.xml`.
- **El botón Edit aparece aunque no se pueda editar:** sigue el permiso sobre el objeto.
  El bloqueo real es por registro y se aplica al guardar.
- **Una vista de lista no concede acceso**, solo filtra lo que el usuario ya ve. La org
  no trae vistas de `Case`, así que se creó `All_Cases` (visible para todos).
- **El criterio de la sharing rule guarda la etiqueta del Record Type** (`Estacionamientos`),
  no su `DeveloperName`. Funciona porque la etiqueta también viaja en el despliegue, pero
  renombrar un Record Type rompería la regla sin avisar.

**Sin verificar todavía:**

- Que la licencia `Salesforce Platform` no da acceso a Casos. Hay **una** licencia
  `Salesforce` libre en cada org, suficiente para un usuario de prueba.
- Que las sharing rules se desplieguen bien en una org limpia (lo cubre el CI del PR).
- Los 18 roles que trae la scratch org son de la plantilla de ventas de Salesforce y no
  se usan: se ignoran, no se borran.

**Preguntas que debes poder responder:**

- ¿Orden de evaluación completo: OWD → Role Hierarchy → Sharing Rules → Manual/Apex
  Sharing → Team?
- ¿Por qué la forma de la jerarquía de roles importa en un holding? (pista: si
  Inmobiliaria y Hotelería comparten rama, el gerente de una termina viendo los Casos
  de la otra)
- ¿Qué implica el OWD Privado para el código Apex? (`with sharing` /
  `without sharing` / `inherited sharing`)

---

## REQ-SEC-02 — Ley N.º 29733 y campos sensibles

**Tipo:** DEC · **Prioridad:** Alta

> El sistema deberá cumplir la Ley N.º 29733 de Protección de Datos Personales del
> Perú restringiendo campos sensibles vía FLS.

Identifica primero _qué_ campos son datos personales sensibles bajo esa ley (DNI,
datos de salud, datos financieros), luego aplica FLS por Permission Set.

**Preguntas que debes poder responder:**

- ¿Diferencia entre FLS, Page Layout y Permission Set en cuanto a qué protegen
  realmente? (pista: ocultar en el layout no protege contra la API)
- ¿Cómo respeta FLS tu código Apex? (`Security.stripInaccessible`,
  `WITH USER_MODE`, `Schema.sObjectType...isAccessible()`)

---

## REQ-SEC-03 — Field History Tracking

**Tipo:** DEC · **Prioridad:** Media

> El sistema deberá auditar (Field History Tracking) los campos críticos de Casos con
> implicancia legal.

Conecta con el requisito no funcional de trazabilidad: todo cambio de **Prioridad,
Estado o Propietario** debe quedar auditado. Ojo con el límite de 20 campos por objeto
y con el periodo de retención del historial.
