# Sanidad animal

## Mobile

La ficha, el lote y el lector rápido abren el mismo formulario. Cada
confirmación aplica una práctica a una selección de UUID y guarda un evento por
animal. El historial lee SQLite por establecimiento y animal. Un estudio se
registra con resultado pendiente y permite completar el primero desde la ficha.
La referencia de muestra es opcional y pertenece al animal.

El catálogo se guarda por establecimiento. Con el último catálogo descargado
se puede registrar sin señal. Una instalación nueva necesita descargar el
catálogo antes de elegir prácticas o productos. Los eventos conservan el nombre
del producto aplicado aunque se retire del catálogo.
La sincronización actualiza catálogo e historial por separado. Una falla
parcial conserva el último dato local del recurso afectado y permite aplicar
los cambios del recurso disponible.
Un envío nuevo conserva el reintento de catálogo e historial, tanto si la
descarga sigue en curso como si el reintento ya está programado.
Si el operario cambia de campo mientras se descarga el catálogo, el formulario
relee el catálogo del campo activo al terminar y conserva los animales de esa
selección. Una lectura RFID pendiente pertenece a la selección que la inició y
se descarta si el operario cambia de campo, incluso si después regresa al mismo.
El botón del formulario pide el catálogo del campo seleccionado. Si Sync ya
está descargando ese catálogo para la misma sesión, ambos usan la misma descarga.

La tabla de operaciones de Sanidad en SQLite conserva el cuerpo y el UUID
original durante los reintentos del mismo envío. Un lote usa una sola operación.
La operación se guarda en la transacción de los eventos en la base principal.
El transporte autenticado es el de Brick y entrega el envelope completo para
reconciliar listas y cursores. El coordinador sanitario administra los
reintentos de esa operación, ya que la cola REST general usa otra base SQLite.
El resultado tiene su propia operación sobre el evento existente. Una dependencia
de alta animal mantiene el envío pendiente mientras el UUID pueda confirmarse.
La integración de altas de Brick comprueba ese UUID y recupera el respaldo de
animales cuando corresponde. El adaptador sanitario solo llama a sus endpoints.
Si el alta es rechazada, el grupo pasa a rechazado y se puede corregir desde
la ficha de un integrante. La corrección crea una operación nueva y conserva
los UUID y los resultados de los integrantes retenidos. Si un integrante excluido
ya tiene un resultado local, conserva su registro rechazado para que se pueda
recuperar por separado.
Cada operación se envía con la cuenta que la guardó. La pantalla de
sincronización muestra los pendientes y rechazos de esa cuenta.
Al pedir sincronización manual, el indicador espera tanto la preparación de
datos como el ciclo sanitario. Una falla de transporte se informa en Sync y
conserva los registros en el dispositivo. Los rechazos funcionales se muestran
en su sección de rechazados.

Los resultados locales se leen desde la operación de la cuenta que los guardó.
Dos cuentas habilitadas que comparten un dispositivo pueden guardar sus propios
borradores para el mismo estudio. El resultado confirmado se comparte entre
las cuentas autorizadas y cierra los borradores de ese evento.
Si el alta del estudio requiere una corrección manual, su resultado queda
guardado y se muestra desde el registro rechazado. La cola cuenta ese resultado
como pendiente cuando se guarda la corrección del alta y lo envía después de
que el servidor confirme el estudio.

El historial incremental aplica el evento y el cursor en la misma transacción.
Una actualización sin resultado conserva cualquier carga local en curso. Un
resultado confirmado o una baja lógica de la versión vigente cierra las cargas
locales del estudio y retira sus operaciones, aunque fueran de otra cuenta del
dispositivo.

## Contrato para backend

El repositorio contiene los modelos `EventoSanitario` y `ProductoSanitario`.
Los endpoints siguientes y el aislamiento en Supabase se deben verificar
cuando esté disponible la implementación de FastAPI en staging.

Todos los endpoints usan `StandardResponse`. Los IDs son UUID, salvo el
identificador estable de práctica, que también puede ser un código. Aplicar
membresía activa y aislamiento por establecimiento en las cuatro operaciones.
Los roles operativos `owner`, `admin`, `employee` y `veterinarian` pueden
consultar, registrar y completar un resultado. Obtener los autores desde la
sesión autenticada y conservar el responsable informado como dato separado.

| Petición | Datos |
| --- | --- |
| `GET /api/v1/eventos_sanitarios/catalogo?establecimiento_id=...` | `data.practicas` con `id`, `nombre`, `modelo` y `producto_ids`, y `data.productos` con `id` y `nombre`. Los modelos admitidos son `aplicacion`, `muestreo` y `lesion`. |
| `POST /api/v1/eventos_sanitarios` | `id` de operación, `establecimiento_id`, `practica_id`, `fecha_aplicacion`, `responsable`, `observaciones`, `datos` y `animales`. Cada elemento de `animales` trae `id` de evento, `animal_id`, `caravana`, `lote_id`, `referencia_muestra`, `created_at` y `updated_at`. Devolver la lista de eventos confirmados en `data`. |
| `PUT /api/v1/eventos_sanitarios/{evento_id}/resultado` | `id` de operación, `resultado` como texto y `fecha`. Devolver el evento completo en `data`. |
| `GET /api/v1/eventos_sanitarios?establecimiento_id=...&cursor=...` | Lista de eventos en `data` y `meta.next_cursor` más `meta.has_more`. La primera consulta omite el cursor. Incluir bajas lógicas. El cursor representa cambios del servidor de forma independiente a la fecha de aplicación del evento. |

En `datos`, una aplicación envía `producto_id`, `producto_nombre`, `dosis`
decimal como texto, `unidad`, `via`, `serie` y `vencimiento` como fecha
`YYYY-MM-DD`. Muestreo y lesión envían `descripcion` y `tipo_muestra`
(nulo en lesión). Backend valida compatibilidad de producto y práctica,
pertenencia de todos los animales y campos específicos de cada tipo.

La representación canónica de un evento contiene los campos comunes, los
campos del animal en el mismo nivel, `registrado_por_id`, `deleted_at`,
`practica` con la forma del catálogo, y `resultado` nulo o como
`{valor, fecha, registrado_por_id}`. Las fechas con hora usan ISO 8601 UTC.

- Registrar el grupo y su clave de idempotencia en una sola transacción. Un
  reenvío idéntico devuelve los eventos originales. Cada animal recibe a lo
  sumo un evento de esa operación.
- Completar únicamente un estudio pendiente. Resolver la concurrencia en
  la misma transacción que registra la operación. Si el mismo envío ya fue
  aceptado, devolver éxito. Si ganó otro envío, devolver HTTP `409` con
  `errors[0].code = resultado_ya_completado` y el evento vigente en
  `errors[0].details.evento`.
- Al completar un resultado o dar de baja un evento, actualizar su
  `updated_at` en backend e incluir la versión canónica en el historial
  incremental.
- Para un rechazo funcional devolver un código estable. En `errors[0].details`,
  `animal_id` identifica al animal afectado y `campo` indica el nombre del campo
  del cuerpo, por ejemplo `datos.dosis` o `referencia_muestra`. Ambos son
  opcionales. Mobile los guarda en SQLite y muestra la caravana y la etiqueta
  del campo al corregir el registro. Si el evento ya no existe, usar
  `evento_sanitario_no_encontrado` como código de `404`.
- Entregar las migraciones, el SQL espejo y las pruebas de aislamiento,
  atomicidad, concurrencia, idempotencia y cursor. Las confirmaciones en la
  app se deben verificar en staging con dos cuentas y dos dispositivos.

## Linear

VITA-20 cubre registro desde ficha, lote y manga. VITA-143 corresponde al
catálogo, VITA-145 a manga y VITA-147 a persistencia y sincronización móvil.
VITA-39 aporta el historial individual. Para backend, ampliar VITA-142 y
VITA-146 con el esquema y la operación de registro, y contemplar tareas de
lectura y carga de resultado. VITA-144 corresponde al futuro flujo de
jornadas con múltiples prácticas.

## Verificación

Desde `mobile`, correr
`fvm flutter test --no-pub test/features/health test/brick/stores/health_persistence_test.dart`.

| Recorrido | Verificación automatizada mobile |
| --- | --- |
| Ficha | Formulario individual, estudio y carga de resultado sobre el UUID existente. |
| Lote o grupo | Una sola operación en SQLite, reenvío con el mismo cuerpo y reanudación del resultado tras corregir un alta rechazada. |
| Manga | Lecturas HID simuladas y entrada manual sin repetir un animal. |
| Historial incremental | Conserva un resultado local ante cambios de metadatos y lo concilia ante un resultado confirmado o una baja lógica. |
| Rechazos | El `422` simulado conserva el animal y el campo en SQLite y la corrección muestra una indicación localizada. |
| Sesión | Cambio de cuenta durante un pedido, borradores privados en el mismo dispositivo y reversión de una escritura interrumpida. |

En staging, usar dos cuentas de un establecimiento y una cuenta sin acceso
a ese establecimiento. Registrar por ficha, lote y manga en modo avión y
reiniciar la app para verificar la persistencia. Probar el bastón físico y
repetir con un animal dado de alta sin señal. Al recuperar la conexión,
comprobar los UUID en ambos dispositivos, el reenvío sin duplicados y la
sincronización al volver desde segundo plano. Completar el resultado desde
dos dispositivos y verificar el mismo historial en ambos. Con la cuenta sin
membresía, comprobar que el catálogo, el historial y las mutaciones queden
restringidos. Validar un rechazo real con el animal o campo afectado.
