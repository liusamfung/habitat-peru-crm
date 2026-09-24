# 4.10 Seguridad y cumplimiento

> ⚠️ **Ataca REQ-SEC-01 temprano.** Cambiar el modelo de sharing cuando ya hay datos,
> automatizaciones y usuarios configurados es mucho más caro que definirlo al inicio.

| ID         | Tipo | Prioridad | Estado |
| ---------- | ---- | --------- | ------ |
| REQ-SEC-01 | DEC  | Alta      | ⬜     |
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
