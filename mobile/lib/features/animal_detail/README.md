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
avatar original y no se reserva un bloque vacío. Cuando la foto se decodifica,
se muestra arriba de la ficha con proporción 4:3 y `BoxFit.cover`.
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

La foto comienza detrás del borde inferior de `AppHeader` y la tarjeta
principal se superpone sobre ella. Sin foto, la ficha mantiene el avatar y el
espaciado normal. Las secciones de datos, observaciones, evolución de peso e
historial conservan separación uniforme y el pie de sincronización permite
reintentar rechazos.
