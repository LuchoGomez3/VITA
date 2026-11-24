# Registro de animales

## Peso inicial

En **Datos básicos**, se puede escribir el **Peso** o tocar **+** para abrir el selector de pesaje. Confirmar una carga manual o una estimación por foto completa el campo. Al volver sin confirmar, el formulario conserva el valor anterior. La opción Bluetooth ofrece carga manual mientras la app no pueda leer una balanza.

El alta guarda el peso junto con el animal. Si se edita a mano una estimación devuelta por la cámara, el método pasa a ser manual.

## Categorías según el sexo

En **Datos básicos**, al elegir el sexo aparecen las categorías compatibles del catálogo global.

| Sexo | Categorías del catálogo vigente |
| --- | --- |
| Hembra | Ternera, Vaca, Vaquillona |
| Macho | Novillo, Ternero, Toro |

Si se cambia el sexo y la categoría elegida deja de ser válida, el formulario limpia su identificador y su nombre. Las categorías que el backend marca como `ambos` se muestran para los dos sexos y conservan la selección al cambiar entre ellos. **Engorde Rápido** se excluye del alta aunque siga en una caché anterior.

Brick guarda `sexo_permitido` de `GET /api/v1/categorias` en SQLite. Las instalaciones que aún tienen filas sin ese campo aplican las reglas vigentes a los UUID globales conocidos. Las demás filas requieren una regla válida del catálogo remoto para aparecer. El BLoC filtra las opciones de la lectura local, así que cambiar el sexo funciona sin conexión.

Al arrancar, Brick conserva la columna `allowed_sex` si ya existía por una rama anterior o un arranque interrumpido. La migración registra su versión y conserva las categorías guardadas.

## Razas

El selector incluye las 32 opciones distintas que reconoce el exportador SENASA del backend, incluidas **Ganado Cruza**, **Otra raza** y **Sin especificar**. **Aberdeen Angus** cubre también el alias **Angus**. Se usa la denominación **Bosmara** del exportador para mantener la compatibilidad con el código `BO`.

Fuentes del monorepo

- [Catálogo global y reglas por sexo](../../../../backend/alembic/versions/20261001_02_reglas_reproductivas_categorias.py)
- [Unificación del catálogo global](../../../../backend/alembic/versions/20261014_01_catalogo_global_categorias.py)
- [Códigos de raza del exportador SENASA](../../../../backend/api/reportes/service.py)
