# Contexto, alcance y stakeholders

## 1. Contexto y objetivo del proyecto

Corporación Habitat Perú es una empresa ficticia con estructura de holding, con tres
unidades de negocio operando bajo una misma marca corporativa pero con procesos de
atención al cliente muy distintos entre sí:

- **Habitat Inmobiliaria** — habilitación urbana (lotes), vivienda de interés social
  y departamentos, con posventa y garantías de construcción.
- **Habitat Parking** — operación de playas de estacionamiento en zonas de alta
  demanda y centros comerciales.
- **Habitat Hospitality** — hoteles orientados a distintos segmentos de viaje
  (corporativo, vacacional).

**Objetivo:** implementar un piloto de Salesforce Service Cloud que centralice la
atención al cliente de las tres unidades de negocio en una sola plataforma,
respetando que cada una tiene canales, SLAs y procesos distintos, pero compartiendo
un modelo de datos, seguridad y reportería consolidada a nivel holding.

El proyecto es, a la vez, un BRD realista para practicar el rol de developer/consultor
y la fuente de trabajo para el portafolio.

### La decisión de diseño central

Las tres unidades comparten el objeto **`Case`**, diferenciadas por **Record Type**.
Todo lo demás (Queues, Assignment Rules, Entitlement Processes, Knowledge, layouts)
se deriva de esa separación. Entender por qué se eligió _un objeto con Record Types_
en lugar de _tres objetos custom_ es una de las preguntas de diseño más importantes
del proyecto.

## 2. Alcance

**Dentro de alcance:**

- Gestión de casos multi-canal.
- Omni-Channel con enrutamiento por unidad de negocio.
- Entitlements / SLA diferenciados.
- Base de conocimiento segmentada.
- Reportería consolidada y por unidad.
- Integraciones simuladas con sistemas externos (PMS de hotel, control de acceso de parking).
- Un componente de IA / Agentforce como valor agregado.

**Fuera de alcance:**

- Field Service Lightning (despacho de técnicos físicos).
- Integración ERP completa.
- Telefonía CTI de producción.
- Marketing Cloud.
- Facturación electrónica SUNAT.

## 3. Stakeholders

| Rol                                          | Responsabilidad                                                                  |
| -------------------------------------------- | -------------------------------------------------------------------------------- |
| Sponsor (Gerencia de Experiencia al Cliente) | Define prioridades de negocio y aprueba alcance                                  |
| Product Owner                                | Traduce necesidades de negocio en requerimientos (rol de Samuel en el ejercicio) |
| Salesforce Admin                             | Configura Setup: Queues, Assignment Rules, Entitlements, Reports                 |
| Salesforce Developer                         | Construye Apex, LWC e integraciones (el otro rol de Samuel)                      |
| Agentes de servicio por unidad de negocio    | Usuarios finales de la Consola de Servicio                                       |
| Clientes finales                             | Compradores de vivienda, arrendatarios de parking, huéspedes de hotel            |
