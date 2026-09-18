# Autenticación sin navegador: JWT Bearer Flow

> Material conceptual. **Es tema de entrevista de alto valor** — cuando una postulación
> pide "OAuth 2.0", saber explicar JWT Bearer es una respuesta más específica y
> profunda dentro de ese mismo tema.

## El problema

GitHub Actions no puede abrir un navegador para el `sf org login web` normal. Se
necesita un flujo de autenticación _headless_. El estándar de la industria es **JWT
Bearer Flow**.

## JWT no compite con OAuth 2.0 — vive adentro

Es la confusión más común:

- **OAuth 2.0** es el marco general de autorización: define roles (cliente, servidor
  de autorización, servidor de recursos) y varios **grant types** (formas de obtener
  un access token).
- **JWT** (JSON Web Token, RFC 7519) es solo un **formato de token firmado**.
- El **"JWT Bearer Flow"** es el nombre de uno de esos grant types de OAuth 2.0
  (RFC 7523), donde en vez de un usuario aprobando un login o un client secret
  compartido, usas un JWT firmado con tu llave privada como credencial.

### Grant types de OAuth 2.0

| Grant type                | Cuándo se usa                                                                              | ¿Requiere humano? |
| ------------------------- | ------------------------------------------------------------------------------------------ | ----------------- |
| Authorization Code        | Login interactivo con aprobación del usuario (ej. "Login with Salesforce")                 | Sí                |
| Authorization Code + PKCE | Igual, para apps móviles/SPA sin backend seguro donde guardar un secret                    | Sí                |
| Client Credentials        | Server-to-server, usando un `client_secret` compartido                                     | No                |
| **JWT Bearer**            | Server-to-server, usando una llave privada que firma un JWT en vez de un secret compartido | No                |
| Refresh Token             | Renovar un access token vencido sin repetir el login completo                              | No                |

### ¿Por qué JWT Bearer y no Client Credentials?

Client Credentials es una alternativa válida y **más simple** de configurar (solo un
`client_secret`, sin certificado). La razón para preferir JWT Bearer es de seguridad:

- Un `client_secret` es un string estático que viaja y se guarda tal cual.
- Con JWT Bearer **nunca compartes ninguna llave con Salesforce** — solo le diste tu
  llave **pública** (el `.crt`) al registrar la app, y la llave privada nunca sale de
  tu GitHub Secret.

## Spring '26: External Client Apps, no Connected Apps

Salesforce **deshabilitó el botón "New Connected App"** en todas las orgs a partir de
Spring '26. Las Connected Apps existentes siguen funcionando, pero no se puede crear
una nueva sin pasar por soporte.

El reemplazo son las **External Client Apps (ECA)**. El JWT Bearer Flow funciona
exactamente igual dentro de ellas: **el CLI (`sf org login jwt`) no cambia en
absoluto**, porque para el CLI solo importan el Consumer Key y el certificado, sin
que le interese de dónde vinieron. Lo único que cambia son las pantallas de Setup.

## Implementación con ECA

1. **Genera el par de llaves** (una sola vez, local):

   ```bash
   openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 3650 -nodes
   ```

2. **En cada org** que necesite autenticación headless (Dev Hub para CI, Portafolio
   para CD): Setup → "External Client Apps" → **External Client App Manager** →
   **New External Client App**. Nombre y correo de contacto, Distribution State =
   **Local**. En **API (Enable OAuth Settings)** marca "Enable OAuth", pon un Callback
   URL cualquiera (`http://localhost:1717/OauthRedirect` — no se usa realmente en este
   flujo), y en **Flow Enablement** marca **"Enable JWT Bearer Flow"** y sube tu
   `server.crt`. Guarda.

3. **Policies** → Edit → en **OAuth Policies** selecciona **"Admin approved users are
   pre-authorized"** y asigna el perfil o Permission Set de tu usuario. Guarda.

4. **Settings → OAuth Settings** → copia el **Consumer Key**. (No necesitas el
   Consumer Secret — JWT Bearer no lo usa.)

5. **GitHub Secrets** (Settings → Secrets and variables → Actions): el contenido de
   `server.key`, el Consumer Key de cada app, y el username de cada org.
   **Nunca commitees `server.key`.**

### Por qué en _cada_ org y no solo en Portafolio

Salesforce registra cada External Client App **dentro de una org específica** — su
Consumer Key solo significa algo en esa org; no existe una app "global" válida en
cualquier org. Por eso necesitas registrar una en el Dev Hub y otra en Portafolio.

**Sí puedes reutilizar el mismo par de llaves** (`server.key` / `server.crt`) para
ambas. Lo único distinto entre las dos es a qué org le subiste el certificado y qué
Consumer Key te devolvió.

## ⚠️ Cómo aplica esto realmente en este repo

**Solo CD usa JWT.** CI autentica el Dev Hub con un **SFDX auth URL**, por el bug
C-1016 del CLI (`sf org create scratch` falla con un Dev Hub autenticado vía ECA+JWT).
Ver [02-ci-cd.md](02-ci-cd.md) para el detalle.

Es decir: el conocimiento de esta página sigue siendo válido y es el que se explica en
una entrevista, pero la implementación real tuvo que desviarse en un punto por un bug
del CLI — lo cual, contado bien, es una mejor anécdota de entrevista que si todo
hubiera funcionado a la primera.
