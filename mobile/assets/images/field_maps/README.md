# Fondo offline del campo

`campo.png` es la imagen exportada desde QGIS. `campo.pgw` contiene la
transformación afín del centro de sus píxeles a coordenadas del proyecto:
escala, rotación y origen. El world file no identifica el CRS; falta registrar
el EPSG para transformar esas coordenadas a ubicaciones GPS reales.

La app lee el ancho y alto de la cabecera PNG y las seis líneas del PGW. Usa
la misma escala en ambos ejes y dibuja las esquinas con `RotatedOverlayImage`:
respeta la proporción y la rotación sin deformar el raster. Traslada y normaliza
las coordenadas del proyecto al lienzo local de `flutter_map`. Estos valores
siguen siendo técnicos, no latitud/longitud.

La geometría se carga una sola vez desde los assets, sin red, antes de
inicializar cada cámara. El encuadre inicial utiliza un rectángulo interior del
raster rotado y `CameraFit.insideBounds`, para que la imagen cubra todo el visor.
Se recorta parte de la imagen según la proporción de la pantalla; se puede
explorar el resto desplazándose y haciendo zoom.

En modo demo se habilita en el visor, el editor y la ficha de cada lote de
La Esperanza. Fuera de la demo conserva la selección temporal por el nombre
exacto San Nicolás, ignorando mayúsculas, espacios externos y la tilde.
La navegación transmite esa elección desde el visor a la ficha del lote.
Para una configuración permanente conviene asociar los assets al UUID del
establecimiento, en lugar de seleccionarlos por nombre.

Los lotes existentes conservan sus coordenadas cartesianas `0..1000`: esta
capa no los transforma ni los alinea automáticamente con límites reales.
Tampoco calcula superficies geográficas ni habilita navegación GPS. Para
reemplazar el fondo deben conservarse juntos PNG, PGW y su EPSG de origen;
las dimensiones de una imagen nueva se leen automáticamente.
