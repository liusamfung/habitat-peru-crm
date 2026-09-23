# BRD — Proyecto Service Cloud · Corporación Habitat Perú

Documento de Requerimientos de Negocio dividido en archivos navegables.
Fuente original: `BRD Service Cloud — Corporación Habitat Perú.md`.

## Cómo está organizado

```
docs/
├── 00-contexto.md          Contexto del negocio, alcance, stakeholders
├── 01-convenciones.md      Tipos de implementación + requisitos no funcionales
├── req/                    Los 43 requerimientos funcionales
│   ├── README.md           Tabla resumen + tablero de progreso
│   ├── 01-gestion-casos.md         .. 12-ia-agentforce.md
└── devops/                 Flujo de desarrollo end-to-end
    ├── 01-flujo-git-y-orgs.md
    ├── 02-ci-cd.md
    ├── 03-autenticacion-jwt.md
    └── 04-calidad-de-codigo.md   Compuertas pre-commit / pre-push / CI
```

## Por dónde empezar

1. Lee [00-contexto.md](00-contexto.md) para entender el negocio.
2. Lee [01-convenciones.md](01-convenciones.md) para entender la clasificación
   DEC / FLOW / APEX / LWC / INT / IA. **Este criterio — saber qué se configura y
   qué se programa — es exactamente lo que evalúan en una entrevista.**
3. Revisa el [tablero de requerimientos](req/README.md) y elige el primero.
4. Sigue el [flujo de trabajo por feature](devops/01-flujo-git-y-orgs.md).

## Nota sobre la Sección 6 del BRD original

El BRD original incluía una Sección 6 con "prompts para pegar en Claude Code" que
pedían generar código completo. **Esa sección está derogada**: Samuel escribe todo el
código a mano. El contenido útil de esa sección (el apartado _"Qué debe explicarte"_
de cada prompt) se conservó dentro de cada requerimiento, reconvertido en
**Objetivos de aprendizaje** y **Pistas**. Ver [CLAUDE.md](../CLAUDE.md) para el modo
de trabajo completo.
