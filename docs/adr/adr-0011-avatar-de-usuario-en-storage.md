# ADR-0011 — Foto de perfil en Supabase Storage y color de la cabecera

- **Estado:** propuesto
- **Fecha:** 2026-10-17
- **Contexto:** personalización de la cabecera de Perfil (rama `feature/pantalla-ajustes`, PR #43)
- **Relacionado:** PR #52 (`core/storage.py`, imágenes de calibración ML)

## Contexto

La cabecera de Perfil muestra un avatar con las iniciales sobre un degradado verde. Se
pidió que cada usuario pueda poner una foto (cámara o galería) y cambiar el color de
fondo, y que la foto ocupe lo mínimo: **una sola por usuario**.

Restricciones:

- Supabase está en plan free: 1 GB de Storage y 5 GB de egress por mes. Una foto de
  celular pesa ~4,5 MB.
- El bucket `avatars` es **privado**. Se limitó a `image/jpeg` y 1 MB
  (`file_size_limit`) como segunda barrera.
- La cola offline de Brick no encola requests multipart: la foto no puede viajar por
  la cola (ver PR #52).

## Decisión

1. **Bucket privado servido por el backend.** El backend entra con la service-role key
   (`core/storage.py`, el mismo adaptador del PR #52) y expone
   `GET /api/v1/usuarios/me/avatar`. No se emiten URLs públicas ni firmadas: una URL
   firmada vence, y la app la tendría que renovar para mostrar algo que ya tiene
   guardado en el celular.
2. **Clave fija por usuario con upsert**, `avatars/{usuario_id}.jpg`, en lugar de
   buscar la foto anterior y borrarla. Subir otra foto pisa la anterior en una sola
   operación: nunca hay dos fotos del mismo usuario, y si algo falla a la mitad no
   queda una huérfana ocupando espacio (con buscar-y-borrar, un borrado fallido
   después de subir la nueva deja la vieja para siempre). `DELETE` borra el objeto.
3. **Normalización en el backend a 512 px.** Se acepta JPEG, PNG o WebP de hasta 8 MB
   y se guarda siempre un JPEG cuadrado de hasta 512 px (recorte al centro), calidad
   85, en RGB (la transparencia se aplana sobre blanco) y **sin metadatos** (la foto
   puede traer el GPS de dónde se sacó). Pesa ~40 KB: entran ~25.000 en el bucket.
   La app también la achica antes de subir, pero la que manda es esta.
4. **En `usuarios`, dos columnas nullable** (migración `20261017_01`):
   - `color_cabecera varchar(7)`: `#RRGGBB` en mayúsculas (check
     `ck_usuarios_color_cabecera`); `null` es el verde por defecto. Se guarda en la
     cuenta para que se vea igual en cualquier celular.
   - `avatar_actualizado_en timestamptz`: cuándo se subió la foto. Viaja en la sesión
     (`/auth/login`, `/auth/refresh`, `/auth/me`) y le dice a otro dispositivo que hay
     una foto nueva para bajar. No se guarda la clave: se deriva del id.
5. **El `GET` de la foto no usa `StandardResponse`.** Devuelve los bytes con
   `image/jpeg` y `Cache-Control: private`: envolverla en JSON obligaría a pasarla a
   base64 (+33 % de egress). Los errores sí salen como `StandardResponse`
   (404 `avatar_no_encontrado`, 502 `almacenamiento_de_avatar_fallido`).

## Offline

Cambiar el color o la foto es personalización, no una operación de campo. La app los
aplica al instante en el celular y los envía cuando hay conexión, reintentando por su
cuenta (la foto con su propio uploader, porque la cola de Brick no lleva multipart). Si
Storage falla, el backend responde 502 y **no** actualiza la fecha, así el perfil sigue
apuntando a la foto que sí existe.

## Consecuencias

- Cuando entre el PR #52 va a haber conflicto en `core/storage.py`, `core/config.py` y
  `pyproject.toml`: son las mismas piezas con un getter más cada una.
- Las rutas trabajan siempre sobre el usuario del JWT (`/me`): no reciben un id, así que
  no hay forma de leer ni cambiar la foto de otro usuario.
- La foto no tiene historial: reemplazarla o quitarla es definitivo.
