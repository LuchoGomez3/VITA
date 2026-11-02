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

Los casos de uso y data entregan `DomainException` con un motivo Freezed
`MovementFailure` en `reason`. Su `message` es un identificador técnico;
`AnimalMovementStrings.errorMessage` traduce el motivo y sus parámetros en
presentación. No se usan esos identificadores ni excepciones técnicas como
texto visible. Los errores heredados del comando de campo se traducen por
código, conservando la causa en el resultado parcial.

Los textos del formulario y sus errores viven en `AnimalMovementStrings`.
El nombre del acceso, compartido con la ficha, está en `FeatureStrings`.
Los textos del historial y la confirmación pertenecen a `AnimalDetailStrings`.

## Validación

Las pruebas cubren transiciones initial/loading/data/error, preservación de
la selección, cierre durante una carga, inmutabilidad, motivos de dominio y
su traducción a mensajes. El widget test del traslado y el de la ficha cubren
el recorrido exitoso y la convivencia con genealogía.

Esta reorganización arquitectónica conserva la agrupación por origen y su
comportamiento ante fallos parciales. No resuelve los hallazgos funcionales
de QA sobre identificación, concurrencia, retry parcial o representación del
historial, que requieren sus respectivas correcciones y regresiones.
