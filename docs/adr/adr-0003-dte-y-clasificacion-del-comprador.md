# ADR-0003 — DTe obligatorio y clasificación del comprador en ventas

- **Estado:** aceptado
- **Fecha:** 2026-09-10
- **Contexto:** VITA-43 / VITA-127
- **Reemplaza parcialmente:** ADR-0001, decisiones 3 y 4

## Contexto

El ADR-0001 permitió registrar `nro_dte` y `apellido_comprador` como nulos. La revisión
posterior de la historia confirmó que trabajar offline no impide ingresar un DTe ya
emitido: el número puede capturarse manualmente y persistirse localmente. También se
definió que el formulario distinguirá expresamente empresas de personas físicas.

## Decisión

- `nro_dte` es obligatorio y no puede estar vacío. Se almacena como texto para conservar
  su formato.
- `nombre_comprador` siempre es obligatorio y representa la razón social de una empresa
  o el nombre de pila de una persona física.
- `es_empresa` es un booleano obligatorio que persiste la selección del formulario.
- `tipo_comprador` y `es_empresa` son conceptos ortogonales. El primero describe la
  clase o canal comercial (`frigorifico`, `remate` o `particular`) y el segundo la
  naturaleza del comprador consignado. Todas sus combinaciones son válidas: por
  ejemplo, una empresa puede comprar directamente como `particular`, y el responsable
  consignado para un frigorífico o remate puede ser una persona física.
- `apellido_comprador` es obligatorio y no vacío cuando `es_empresa` es falso. Cuando es
  verdadero, el apellido no corresponde y debe ser nulo; mobile bloquea y limpia el campo.

La aplicación puede registrar todos estos datos en SQLite sin conectividad y
sincronizarlos después. VITA no necesita consultar a SENASA para aceptar el número que
el usuario ya posee.

## Consecuencias

- Las ventas confirmadas siempre conservan un DTe.
- El backend y mobile deben exponer y validar `es_empresa` con la misma regla condicional.
- Ninguna capa debe inferir `es_empresa` a partir de `tipo_comprador`.
- La migración falla ante cualquier venta preexistente sin una clasificación explícita,
  evitando alterar silenciosamente el significado de los datos históricos.
- Una futura necesidad de registrar un trato todavía sin DTe deberá modelarse como
  borrador o preoperación y no como venta confirmada.
- La migración falla de forma explícita si encuentra ventas preexistentes sin DTe válido,
  evitando completar información legal con valores inventados.
