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

## Integración con pesaje IA

Al confirmar y guardar el pesaje, su repositorio de data entrega el JPEG
revisado a `AnimalPhotoStore.savePhotoBytes`. La escritura usa un archivo
auxiliar y reemplaza la foto privada anterior una vez completada. También
invalida la caché de `FileImage` para mostrar la captura nueva al volver a la
ficha. Si el guardado falla, el flujo conserva la revisión para reintentar.

El detalle consulta ese mismo store por establecimiento y animal. La ruta se
resuelve desde `getApplicationSupportDirectory()` en cada lectura; no se guarda
en `photoUrl` ni en `foto_url`. La imagen no entra en Brick ni en la cola REST.
No se agregan endpoints, migraciones ni dependencias nuevas.

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

## Acciones conectadas al backend

Los botones recogen la intención en un formulario y ejecutan
`SaveAnimalDetailChangeUseCase`. El dominio valida peso positivo, texto no vacío,
sexo permitido por categoría y condición reproductiva. Preñada y vacía solo se
ofrecen para hembras cuya categoría las admite; sin determinar está disponible
para las demás hembras. No se borra una preñez conocida al cambiar de categoría.

| Acción | Contrato |
| --- | --- |
| Ingresar peso | `POST /api/v1/pesajes`: UUID, establecimiento, animal, peso_kg, fecha, metodo manual y timestamps |
| Cambiar categoría | `PUT /api/v1/animales/{id}` con categoria_id |
| Condición reproductiva | El mismo PUT con estado_reproductivo; null explícito elimina la condición |
| Baja por muerte | El mismo PUT con estado muerto; conserva la ficha y su historial |
| Deshacer baja | El mismo PUT con el estado anterior y updated_at posterior |
| Nueva observación | `POST /api/v1/observaciones_animales`: UUID, establecimiento, animal, texto, fecha y timestamps; autor resuelto por backend |

El PUT lleva una instantánea acotada de categoría, estado y condición reproductiva
junto con id y updated_at. No reenvía raza, nacimiento, lote ni peso inicial.
Cada escritura guarda primero en SQLite y luego encola su request HTTP mediante
Brick. La UI confirma el guardado local; el footer y las notas indican la
sincronización. Un rechazo funcional se conserva como rechazado, sin anunciar
que backend lo aceptó. Deslizar hacia abajo refresca pesajes, catálogo y notas
con sus GET filtrados por establecimiento y animal; sin conexión usa la caché.

La confirmación de muerte ofrece Deshacer durante diez segundos. Solo revierte
la versión que se confirmó en esta ficha, evitando pisar cambios posteriores.
Los resultados HTTP contienen la versión enviada: una respuesta anterior al
deshacer no cambia su estado local de sincronización. Los animales muertos,
vendidos o dados de baja dejan de integrar el stock activo del home y los lotes.
Se pueden seguir leyendo y agregando observaciones; las acciones productivas
quedan deshabilitadas. Las observaciones legacy se mantienen visibles junto
con las entradas nuevas, sin sobrescribirlas.

La foto sigue siendo privada y local; estos requests no suben imágenes.

## Movimientos en la ficha

**Cambiar de lote** abre el flujo compartido por rutas y queda junto a
**Baja por muerte**. El texto del estado productivo sigue siendo **Muerto**.
Al volver se lee la ubicación local; el Historial de Eventos incluye asignaciones
y traslados con fecha, origen, destino, motivo y estado de sincronización.
Los rechazos conservan el código del backend y no se muestran como confirmados.
Ver [asignación y traslado entre lotes](../lot_movement/README.md) para el contrato,
la persistencia offline, los reintentos y los límites de reconciliación.
