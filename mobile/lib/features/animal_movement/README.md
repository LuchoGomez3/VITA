# Movimientos de animales

`GroupMovementPage` permite preparar una selección por caravana visual o RFID
y trasladarla a un potrero. La lectura y escritura mantienen el flujo local
existente mediante los stores compartidos de Brick.

## Límites y composición

- Domain define entidades Freezed, el contrato de lectura y los casos de uso.
- Data implementa el contrato sobre los stores de animales, lotes y movimientos.
- Presentation invoca casos de uso y renderiza sus resultados.
- `lib/app/composition/animal_movement_composition.dart` conecta estos módulos
  con la operación de traslado de `field`. Ninguna feature construye los
  repositorios internos de la otra.

El comando de dominio `MoveLotAnimalsUseCase` de campo se reutiliza para
conservar las validaciones y la transacción de cada origen. La pestaña de
historial pertenece a `animal_detail`, que consume el contrato de dominio
`AnimalMovementRepository`, sin importar implementaciones de esta feature.

## Estado y errores

`GroupMovementState` es Freezed y conserva por separado tres operaciones:

- `preparation`: animal inicial y destinos (`ResultState<GroupMovementPreparation>`).
- `tagResolution`: última lectura (`ResultState<MovementAnimal>`).
- `submission`: guardado (`ResultState<GroupMovementSummary>`).

Así, una lectura fallida no reemplaza la selección preparada y un error de
guardado conserva los datos editables. Las colecciones expuestas por las
entidades y el estado no se pueden modificar desde sus consumidores.

Las lecturas se resuelven en orden para que cada validación reciba la selección
vigente. El guardado espera a que terminen y bloquea un segundo envío o cambios
de selección mientras la operación está en curso. La búsqueda siempre incluye
el establecimiento antes de elegir una coincidencia de caravana.

La captura se separa del campo editable antes de consultar: una respuesta
tardía no borra la siguiente lectura. Si falla, solo se restaura el texto si no
hubo nuevas ediciones o capturas. El selector explícito determina si se consulta
por RFID o por caravana visual; una visual no se reinterpreta como RFID aunque
contenga quince dígitos. El modo RFID solo admite números, hasta quince durante
la edición y exactamente quince al confirmar. No se quitan letras ni se recortan
pegados largos para fabricar un identificador válido.
Si varios animales válidos coinciden por visual o RFID, se informa ambigüedad
y no se agrega ninguno; hay que leer un RFID único o revisar los datos.
La identidad RFID se resuelve antes de filtrar la elegibilidad: si corresponde
a un animal vendido, borrado o sin potrero, se informa que no puede moverse,
sin reinterpretar el número como la visual de otro animal activo.

`RfidValidator` es la regla compartida con el alta y la identificación manual/HID.
Los campos electrónicos usan `RfidInputFormatter`, y los casos de uso rechazan
RFID incompletos o inválidos antes de consultar o persistir. El selector cambia
solo mobile: el backend conserva sus campos de RFID y visual, y el traslado
sigue enviando UUID de animales.

Los casos de uso y data entregan `DomainException` con un motivo Freezed
`MovementFailure` en `reason`. Su `message` es un identificador técnico;
`AnimalMovementStrings.errorMessage` traduce el motivo y sus parámetros en
presentación. No se usan esos identificadores ni excepciones técnicas como
texto visible. Los errores heredados del comando de campo se traducen por
código, conservando la causa en el resultado parcial.

Cuando un origen se guarda y el siguiente falla, el motivo parcial conserva
los UUID ya trasladados. El Cubit los quita de la selección pendiente y acumula
el resultado durable en `savedSummary`. Un reintento procesa solo lo restante;
volver atrás devuelve los cambios ya guardados para refrescar ficha e historial.
La pantalla bloquea la salida durante la escritura local en curso.

`GroupMovementSummary` conserva los destinos por UUID y nombre, incluso si se
quita al animal inicial o un reintento utiliza otro destino. La confirmación
no deduce el destino desde la ubicación del animal cuya ficha abrió el flujo.

Los textos del formulario y sus errores viven en `AnimalMovementStrings`.
El nombre del acceso, compartido con la ficha, está en `FeatureStrings`.
Los textos del historial y la confirmación pertenecen a `AnimalDetailStrings`.

## Validación

Las pruebas cubren transiciones initial/loading/data/error, preservación de
la selección, cierre durante una carga, inmutabilidad, motivos de dominio y
su traducción a mensajes. El widget test del traslado y el de la ficha cubren
el recorrido exitoso y la convivencia con genealogía.

Las regresiones de QA cubren caravanas compartidas entre establecimientos,
lecturas concurrentes y cierre con trabajo en cola, doble submit, rechazo remoto,
reintento y retorno tras un resultado parcial, y exclusión del animal inicial.
Las pruebas del historial también cubren fechas retroactivas, visitas repetidas
y nombres de lotes borrados. Los tests de stores ejercitan SQLite real con
deduplicación, tombstones y aislamiento entre establecimientos.

La atomicidad se conserva por origen; el contrato backend registra un origen
por movimiento. Estas correcciones no convierten el conjunto de orígenes en
una única transacción remota. La prueba con bastón físico, reinicio en modo
avión y reconciliación concurrente entre dispositivos sigue siendo manual.
