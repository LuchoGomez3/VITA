# Fondo de San Nicolás

`campo.png` es la imagen exportada por el usuario desde QGIS (5052 × 2846).
`campo.pgw` conserva su transformación de píxeles a coordenadas del proyecto,
incluida la rotación. Falta registrar el EPSG de origen para usarla como mapa
geográfico; un world file no identifica por sí mismo el sistema de referencia.

La app muestra el PNG offline debajo de los lotes en el visor y al crear un lote
desde San Nicolás. La selección usa el nombre exacto del establecimiento,
ignorando mayúsculas, espacios externos y la tilde de Nicolás. Otros nombres
mantienen el fondo esquemático. Si el establecimiento cambia de nombre, deja
de seleccionarse esta imagen. Para una configuración permanente conviene
asociar este asset al UUID confirmado del establecimiento.

La imagen conserva su proporción y se mueve con el zoom del lienzo local.
No se interpreta el PGW ni se cambian las coordenadas existentes de los lotes:
los polígonos previos no se alinean automáticamente con límites reales.
La captura sirve como referencia visual para dibujar. No calcula superficies
geográficas ni habilita navegación GPS. La resolución original limita el detalle
al acercarse, aunque el visor permita más zoom.

Al reemplazar la imagen por otra de diferente tamaño hay que actualizar su
proporción en `FieldSatelliteMap` y conservar juntos PNG, world file y EPSG.
