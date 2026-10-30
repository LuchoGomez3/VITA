# Detalle animal

## Foto local del animal

La foto es un dato privado de la instalación mobile. Se guarda en el directorio
de soporte de la app, funciona sin conexión y se elimina al desinstalar la app
o borrar sus datos. No se sube al backend, no se sincroniza con Brick y no usa
el campo remoto `foto_url` de los pesajes.

`AnimalPhotoStore`, en `lib/core/storage/animal_photo_store.dart`, conserva
una foto por animal y establecimiento. Una captura nueva reemplaza la anterior;
un pesaje sin captura conserva la foto existente. El repositorio local de fotos
lee el store desde data y entrega un `AnimalPhoto` con bytes al dominio. La ruta
fisica queda encapsulada dentro del store y presentation usa `Image.memory`.
El reemplazo escribe primero un temporal y conserva un respaldo hasta completar
el cambio, por lo que una escritura fallida o interrumpida no deja un archivo
parcial ni pierde la foto anterior.

La ficha y la foto tienen estados de carga independientes. Si el proveedor del
directorio o el filesystem fallan, data registra el incidente sin IDs ni rutas
y responde foto ausente; el detalle del animal permanece disponible.

Si no hay foto, mientras carga o si falla la decodificación, se conserva el
placeholder del rediseño. Cuando la foto se decodifica, se muestra en la parte
superior de la pestaña General con proporción 4:3 y `BoxFit.cover`.
La decodificación se limita al ancho físico de la pantalla para evitar mantener
en memoria el bitmap completo de una captura de alta resolución.

## Integración con pesaje

Después de confirmar el pesaje, el flujo debe copiar la captura antes de borrar
el archivo temporal:

```dart
await const AnimalPhotoStore().savePhoto(
  establishmentId: establishmentId,
  animalId: animalId,
  sourcePath: capturedPhotoPath,
);
```

La integración se hace desde la capa data de pesaje, usando el store compartido
y sin importar internos de la feature de detalle. La copia debe completarse
antes de volver a abrir la ficha. Si falla, pesaje debe informar el error sin
confundirlo con el resultado del pesaje.

Cuando el flujo conserva la captura en memoria, como pesaje por visión, debe
usar `savePhotoBytes` con el JPEG revisado en lugar de crear un archivo
temporal sólo para copiarlo.

No se debe guardar una ruta local en `photoUrl`/`foto_url`: esos campos
pertenecen al contrato remoto. Esta funcionalidad no agrega endpoints,
migraciones ni dependencias de red.

## Presentación

La ficha conserva la cabecera y las pestañas del rediseño. General muestra la
foto local o el placeholder, identificación, estado productivo, observaciones y
sincronización. Pesajes conserva el gráfico y el historial; las otras pestañas
mantienen el contenido del rediseño. La carga opcional de la foto no bloquea los
datos del animal ni la navegación entre pestañas.

## Genealogía

La genealogía se consulta sin red y tiene un estado independiente de la ficha y
de su foto:

```text
AnimalGenealogyTab
  -> AnimalGenealogyCubit (ResultState<AnimalGenealogy>)
  -> GetAnimalGenealogyUseCase
  -> AnimalGenealogyRepository
  -> AnimalGenealogyRepositoryImpl / AnimalGenealogyMapper
  -> stores locales de animales y categorías -> SQLite
```

El repository resuelve el establecimiento del sujeto y devuelve únicamente
animales locales sin baja lógica de ese establecimiento. El mapper conserva
identidad, fecha y referencias a los progenitores. No se consultan endpoints ni
se modifica la cola de sincronización.

El caso de uso construye padres y abuelos, evita repetir al sujeto o al
progenitor en su propia línea y ordena las crías por nacimiento descendente.
Un ancestro compartido entre ambas líneas sigue siendo válido.

La cabecera y los ancestros tienen tamaño acotado; las crías se renderizan bajo
demanda con `SliverList.builder` dentro del mismo desplazamiento. La cantidad de
descendientes no obliga a construir todos sus widgets al abrir la pestaña.

Las entidades usan Freezed y la lista de crías no se puede modificar desde sus
consumidores. Los parientes ausentes del caché se muestran como datos faltantes;
los registros con soft delete no participan del árbol.

Composition construye las dependencias y el provider de la pestaña es dueño del
Cubit. Al cambiar los datos del animal se crea una lectura nueva y se cierra la
anterior. El Cubit descarta respuestas anteriores y no emite después del cierre.
Los errores técnicos se registran en data; el Cubit los traduce al mensaje
centralizado en `AnimalDetailStrings`.

Las pruebas de data verifican mapeo, aislamiento, ausencia de red y errores; las
de dominio cubren relaciones, ciclos, orden e inmutabilidad; las de Cubit y
widgets cubren estados, navegación, respuestas tardías y lifecycle.
