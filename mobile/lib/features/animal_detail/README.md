# Detalle animal

## Foto local del animal

La foto es un detalle visual exclusivo de mobile. Se guarda en el directorio
privado de soporte de la app, funciona sin conexión y se elimina junto con los
datos locales al desinstalar la app o borrar sus datos. No se sube al backend,
no se sincroniza con Brick y no se consulta `foto_url` de los pesajes.

`AnimalPhotoStore`, en `lib/core/storage/animal_photo_store.dart`, conserva una
foto por animal y establecimiento. Una captura nueva reemplaza la anterior;
un pesaje sin captura no necesita llamar al store y conserva la foto existente.
El detalle consulta ese store desde data y entrega `AnimalDetail.localPhotoPath`
a presentation, que muestra la foto arriba de los datos, a todo el ancho de
la pantalla y con proporción 4:3.

Si no hay foto, mientras carga o si falla la decodificación, se conserva el
círculo original y la disposición anterior de la ficha, sin un bloque vacío.
El círculo solo se oculta cuando la foto grande se decodificó correctamente.
Se usa `BoxFit.cover` para llenar el fondo y puede recortar los bordes según
la proporción original. No se muestra un título debajo de la foto; su etiqueta
se conserva únicamente para lectores de pantalla. Las superficies son blancas
y el verde destaca solo la fuente de pesaje «Estimación por IA».

## Integración con la rama de pesaje después del merge

Después de confirmar el pesaje, copiar la captura al almacenamiento privado
antes de eliminar el archivo temporal de cámara:

```dart
await const AnimalPhotoStore().savePhoto(
  establishmentId: establishmentId,
  animalId: animalId,
  sourcePath: capturedPhotoPath,
);
```

Importar el store compartido desde la capa data de pesaje; no importar internos
de la feature de detalle. La copia debe completarse antes de abrir nuevamente
la ficha. Si falla, el flujo de pesaje debe informar el error de guardado de foto
sin confundirlo con el resultado del pesaje.

La ruta se resuelve en cada lectura desde `getApplicationSupportDirectory()`.
No guardar la ruta temporal de cámara ni una ruta local en `photoUrl`/`foto_url`:
esos campos pertenecen al contrato remoto y no intervienen en esta funcionalidad.
No se agregan endpoints, migraciones ni dependencias nuevas.

Esta rama prepara la lectura y el almacenamiento; la llamada desde la captura
se integra en la rama de pesaje cuando esté disponible. Hasta entonces, o en
animales sin foto local ni foto de ejemplo, se conserva el avatar actual.

## Fotos de ejemplo por caravana

Se pueden agregar fotos en `assets/images/animal_photos/` usando la caravana
visual sin espacios como nombre: `003 1295` busca `0031295.jpg`. Se conservan
los ceros iniciales y se admiten las extensiones minúsculas `jpg`, `jpeg`, `png`
y `webp`, en ese orden de prioridad. Reiniciar la ejecución de la app después
de agregar un archivo para que Flutter lo incluya en el bundle.

La captura local del pesaje tiene prioridad. Cuando no existe, data consulta
el manifiesto de assets y entrega `photoAssetPath` al encabezado. Sin coincidencia
se mantiene el círculo. No se consulta internet ni se copia el asset al disco.

Las fotos de esta carpeta se incluyen en la app compilada y volverán a estar
disponibles al reinstalar esa compilación; las capturas reales son datos privados
que se borran con la instalación. La búsqueda de ejemplos usa solo la caravana,
por lo que un mismo número en dos establecimientos comparte la foto de ejemplo.

## Espaciado

Las tarjetas usan 12 px de margen lateral, como el home, y 16 px de separación
entre ficha, observaciones, evolución de peso e historial. Se conserva el padding
interno. La foto superior ocupa todo el ancho de la pantalla y la ficha blanca
se superpone 40 px sobre su borde inferior. Sin foto no se aplica superposición.

El encabezado superior usa `AppHeader`, compartido con las demás secciones.
El regreso conserva el fallback al home cuando no hay una ruta previa.

La foto comienza detrás de los últimos 20 px del header para cubrir sus esquinas
redondeadas. El contenido contempla la altura del header y la barra de estado;
sin foto, la ficha permanece debajo del encabezado. Las tarjetas de datos,
observaciones, gráfico e historial tienen elevación 4 y sombra uniforme.

## Acciones visuales pendientes de integrar

La ficha ofrece ingresar peso, cambiar categoría y baja por muerte. Cambiar
preñez aparece únicamente para hembras; no se inventa un estado reproductivo.
Observaciones incluye «Nueva entrada» con un lápiz. Estos accesos son maquetas:
no invocan casos de uso, no navegan a otras features y no escriben en disco,
Brick ni backend.

La baja muestra únicamente una confirmación y, al confirmar, un snackbar de
vista previa con «Deshacer». Ninguno modifica datos. Al integrar la rama de
edición, reemplazar los callbacks de maqueta por casos de uso y conectar tanto
la baja como su reversión, además de sustituir los textos de vista previa.
