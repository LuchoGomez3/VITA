# Plan backend para integrar Sanidad

**Para Lucho** · 21 de noviembre de 2026 · Propuesta de contrato para revisar con Mobile

## Alcance de esta entrega

Un operario registra **una práctica sanitaria sobre uno o varios animales de un establecimiento**. La ficha individual, la selección desde el lote y la captura sucesiva en manga con RFID o caravana manual usan la misma operación. Cada animal seleccionado recibe un evento individual. En un estudio, el primer resultado se informa después sobre el UUID del evento. Por ejemplo, una vacunación usa `aplicacion`, un sangrado usa `muestreo` y una lesión usa `lesion`.

Mobile guarda cada operación y sus eventos en SQLite antes del envío. Reutiliza el transporte autenticado de Brick. Al reconectar conserva el UUID y el cuerpo del envío, concilia la respuesta y descarga cambios del historial por establecimiento. El catálogo descargado queda disponible sin señal.

La agenda sanitaria, las jornadas con varias prácticas, la administración de productos y los recordatorios quedan para otra entrega. Esta integración cubre los datos que ya captura el formulario y el primer resultado. [VITA-20](https://linear.app/utn-frc-proyecto-final/issue/VITA-20/registrar-eventos-sanitarios-desde-ficha-lote-o-manga) · [Ficha individual](https://linear.app/utn-frc-proyecto-final/issue/VITA-39/visualizar-detalles-e-historial-del-animal) · [Manga](https://linear.app/utn-frc-proyecto-final/issue/VITA-145/mobile-registrar-una-practica-desde-manga-con-rfid-o-caravana-manual) · [Jornada por establecimiento](https://linear.app/utn-frc-proyecto-final/issue/VITA-144/3-feature-configurar-una-jornada-sanitaria-por-establecimiento)

## Base que ya existe

| En el repo | Trabajo para integrar |
| --- | --- |
| `EventoSanitario` tiene animal, establecimiento, tipo, producto opcional, fecha, dosis, resultado de texto y campos de carencia. | Agregar identidad de la práctica, datos específicos, responsable informado y autores, contexto histórico del animal y metadatos del primer resultado. Conservar los registros previos. |
| `ProductoSanitario` puede ser global o pertenecer a un establecimiento. Tiene tipo, nombre y carencia. | Definir las prácticas y los productos vigentes que resultan elegibles por campo. Los nombres aplicados deben poder seguir mostrándose tras un cambio del catálogo. |
| El router de FastAPI registra animales, movimientos y otros módulos. | Registrar Sanidad en `backend/core/router.py`. Faltan las cuatro rutas sanitarias y verificar el esquema y el aislamiento en Supabase. |

[Modelo de eventos](../backend/api/modules/eventos_sanitarios/models.py) · [Modelo de productos](../backend/api/modules/productos_sanitarios/models.py) · [Router](../backend/core/router.py) · [Contrato en Mobile](../mobile/lib/features/health/data/datasources/health_remote_data_source.dart)

## Fase 1 · Esquema, permisos y catálogo

1. Extender los modelos y preparar una migración Alembic incremental con SQL espejo en `backend/scripts/`. Probar instalación y actualización desde datos existentes, incluidos eventos que solo guardan el resultado como texto. Acordar cómo completar sus datos históricos para que produzcan el formato canónico.
2. Agregar índices para historial por establecimiento y animal, y una forma durable de identificar la operación de alta o resultado. Separar UUID de operación y UUID de evento.
3. Crear `router.py`, `schemas.py`, `service.py` y `repository.py` en `backend/api/modules/eventos_sanitarios/`. El router usa `get_current_user`, el servicio valida permisos y reglas y el repositorio ejecuta escrituras y consultas.
4. Restringir lecturas y escrituras a miembros activos del establecimiento. Los roles actuales son `owner`, `admin`, `employee` y `veterinarian`. Verificar el filtro en el servicio y las políticas RLS en Supabase. Resolver autoría a partir del JWT. El texto `responsable` queda como dato operativo separado.
5. Implementar el catálogo. Publicar identificadores de práctica estables y devolver las prácticas y los productos aplicables al establecimiento autorizado. Probar catálogo vacío, producto retirado, producto global y producto privado de otro campo.

Una práctica del catálogo incluye `id`, `nombre`, `modelo` y `producto_ids`. Un producto incluye `id` y `nombre`. La lista `producto_ids` indica las combinaciones permitidas para `aplicacion`. El identificador de práctica puede ser UUID o un código estable. Los tres valores de `modelo` que interpreta Mobile son `aplicacion`, `muestreo` y `lesion`. El modelo del formulario y el tipo sanitario del catálogo son conceptos separados.

[Esquema y migraciones · VITA-142](https://linear.app/utn-frc-proyecto-final/issue/VITA-142/db-extender-el-esquema-de-eventos-sanitarios-y-el-aislamiento-por) · [Catálogo · VITA-143](https://linear.app/utn-frc-proyecto-final/issue/VITA-143/integracion-consultar-el-catalogo-sanitario-por-establecimiento-sin)

## Fase 2 · Alta y resultado

Las rutas van bajo `/api/v1/eventos_sanitarios` y responden con `StandardResponse`.

| Método y ruta | Entrada | Salida |
| --- | --- | --- |
| `GET /api/v1/eventos_sanitarios/catalogo` | Query `establecimiento_id` | `data.practicas` y `data.productos`. |
| `POST /api/v1/eventos_sanitarios` | `id` de operación, `establecimiento_id`, `practica_id`, `fecha_aplicacion`, `responsable`, `observaciones`, `datos` y `animales`. | `data` con el array de eventos canónicos de la operación. |
| `PUT /api/v1/eventos_sanitarios/{evento_id}/resultado` | `id` de operación, `resultado` en texto y `fecha`. El establecimiento se resuelve desde el evento. | `data` con el evento canónico completo. |
| `GET /api/v1/eventos_sanitarios` | Query `establecimiento_id` y `cursor` opcional. | `data` con eventos canónicos y `meta.next_cursor` de texto y `meta.has_more` booleano. |

Cada elemento de `animales` en el alta lleva `id` del evento, `animal_id`, `caravana`, `lote_id` opcional, `referencia_muestra` opcional, `created_at` y `updated_at`. Validar que los UUID y relaciones pertenezcan al mismo establecimiento. El lote es contexto histórico del animal y puede ser distinto entre integrantes. Acordar cómo conservar ese contexto cuando el animal se mueve antes de que Mobile recupere señal.

| Modelo | Contenido de `datos` |
| --- | --- |
| `aplicacion` | `producto_id`, `producto_nombre`, `dosis` como decimal en texto, `unidad`, `via`, `serie` opcional y `vencimiento` opcional en `YYYY-MM-DD`. |
| `muestreo` | `descripcion` como motivo y `tipo_muestra`. La referencia opcional pertenece a cada animal. |
| `lesion` | `descripcion` y `tipo_muestra: null`. |

### Ejemplo de alta de un muestreo

```json
{
  "id": "00000001-0000-4000-8000-000000000000",
  "establecimiento_id": "00000002-0000-4000-8000-000000000000",
  "practica_id": "sangrado",
  "fecha_aplicacion": "2026-11-21T13:00:00Z",
  "responsable": "Operario de prueba",
  "observaciones": null,
  "datos": {"descripcion": "Control de rutina", "tipo_muestra": "Sangre"},
  "animales": [
    {
      "id": "00000003-0000-4000-8000-000000000000",
      "animal_id": "00000004-0000-4000-8000-000000000000",
      "caravana": "A-101",
      "lote_id": null,
      "referencia_muestra": "M-101",
      "created_at": "2026-11-21T13:05:00Z",
      "updated_at": "2026-11-21T13:05:00Z"
    }
  ]
}
```

### Alta atómica e idempotencia

- Validar práctica, producto, pertenencia y estado de los animales, ausencia de destinatarios repetidos y campos obligatorios del modelo. Una selección inválida revierte el grupo completo.
- Persistir la aceptación y sus eventos en una sola transacción. Proteger también dos POST concurrentes con el mismo UUID. Un reenvío idéntico devuelve los mismos UUID de evento y conserva los cambios posteriores ya confirmados en el servidor. Definir un conflicto estable si se reutiliza el UUID con un cuerpo diferente.
- Resolver el reenvío autorizado de una operación aceptada antes de revalidar datos que cambian con el tiempo, como vigencia de producto o estado del animal. Si una operación se rechazó de forma definitiva, la corrección usa un UUID de operación nuevo y puede conservar los UUID de los eventos de los animales retenidos.
- Conservar en la representación histórica la práctica y el producto aplicado. Validar o derivar los datos de referencia desde el servidor. Acordar el límite de animales por operación en función del uso en manga. Mobile conserva el grupo como unidad de guardado y envío.

### Resultado y errores

- Permitir el primer resultado de un estudio vigente. Guardarlo junto con la autoría y la fecha de informe y publicar el cambio al historial. Aplicar el control de concurrencia en la misma transacción. El reenvío de la misma operación resulta exitoso. Si ganó una operación distinta, responder `409` con `errors[0].code = resultado_ya_completado` y la versión vigente en `errors[0].details.evento`.
- Para un rechazo que el operario pueda corregir, devolver el envelope de dominio. `errors[0].details.animal_id` y `errors[0].details.campo` son opcionales. Ejemplos de campo `datos.dosis` y `animales.1.referencia_muestra`. Un estudio inexistente se comunica con `404` y código `evento_sanitario_no_encontrado`.
- Verificar el cuerpo de los `422` del esquema y de las reglas de negocio. El envelope genérico de validación de FastAPI necesita traducción cuando haya que señalar un campo o un animal. Conservar la clasificación de fallas transitorias, por ejemplo `429` y `5xx`, para que Mobile pueda reintentar.

[Alta · VITA-146](https://linear.app/utn-frc-proyecto-final/issue/VITA-146/backend-confirmar-el-registro-de-una-practica-sanitaria-por-grupo) · [Resultado · VITA-207](https://linear.app/utn-frc-proyecto-final/issue/VITA-207/backend-registrar-el-primer-resultado-de-un-estudio-sanitario) · [Envelope y errores de dominio](../backend/core/middlewares.py)

## Fase 3 · Historial incremental

La representación canónica es la misma para POST, PUT, GET y el evento de conflicto del PUT. Para el consumo de Mobile incluye:

- `id`, `establecimiento_id`, `animal_id`, `caravana`, `lote_id` y `referencia_muestra`.
- `practica` con forma de catálogo, `datos` según el modelo, `fecha_aplicacion`, `responsable`, `registrado_por_id` y `observaciones`.
- `created_at`, `updated_at` y `deleted_at`. Fecha y hora en ISO 8601 UTC, con `deleted_at: null` para un evento vigente.
- `resultado: null` o un objeto `{valor, fecha, registrado_por_id}`.

El cursor debe representar cambios confirmados y visibles en el servidor. La primera consulta omite el parámetro `cursor`. La última página también devuelve un `next_cursor` válido. Con `has_more: true`, el cursor debe avanzar. Incluir resultados y bajas lógicas en la descarga incremental. Verificar que las escrituras concurrentes y la paginación mantengan todos los cambios accesibles. La versión `updated_at` de un evento tiene que avanzar con cada cambio confirmado, incluso si llegó un alta con reloj del dispositivo adelantado. El orden del feed se define en el servidor, separado de la fecha de aplicación.

Mobile ya conserva una versión más nueva descargada aunque después reciba una respuesta idempotente anterior. El cursor se guarda junto con la página aplicada y el envío conserva su UUID hasta la confirmación del grupo.

[Historial incremental · VITA-206](https://linear.app/utn-frc-proyecto-final/issue/VITA-206/backend-servir-el-historial-sanitario-incremental-por-establecimiento) · [Persistencia y sync · VITA-147](https://linear.app/utn-frc-proyecto-final/issue/VITA-147/mobile-guardar-y-sincronizar-eventos-sanitarios-sin-conexion) · [Mapper de Mobile](../mobile/lib/features/health/data/mappers/health_codec.dart)

## Fase 4 · Criterios de integración

| Caso | Resultado esperado |
| --- | --- |
| Un integrante inválido en un grupo válido | Rechazo con campo o animal y cero eventos persistidos. La corrección conserva las selecciones válidas. |
| Mismo cuerpo tras una respuesta perdida, y dos envíos simultáneos | Un evento por animal, los mismos UUID en la respuesta y acumulación sin duplicados. |
| Resultado concurrente de dos cuentas habilitadas | Gana una escritura. La otra recibe el conflicto con el evento vigente y ambos dispositivos convergen. |
| Cambio sanitario entre páginas, baja lógica y respuesta de alta anterior al resultado | El cursor mantiene todos los cambios accesibles, las bajas se propagan y el resultado posterior queda visible. |
| Cuenta sin membresía, productos privados, animal o lote de otro campo | Acceso restringido en las cuatro rutas y aislamiento comprobado en Supabase. |
| Ficha, lote y manga en modo avión, con reinicio y vuelta de señal | Los datos sobreviven al reinicio. Al volver la red se sincronizan el alta animal pendiente y el evento sanitario. Se verifica con dos dispositivos y un bastón físico. |

Backend entrega pruebas de API y persistencia, migración y SQL espejo, y comprobación de RLS en staging. Mobile verifica el mismo payload contra staging, el reinicio offline y la captura física.

VITA-20 agrupa la entrega de **una práctica por confirmación**. VITA-145 y VITA-147 siguen el trabajo de Mobile en revisión. VITA-143 sigue la integración del catálogo. VITA-142, VITA-146, VITA-206 y VITA-207 siguen el trabajo de Backend. VITA-144 conserva la configuración de jornadas como trabajo posterior relacionado.
