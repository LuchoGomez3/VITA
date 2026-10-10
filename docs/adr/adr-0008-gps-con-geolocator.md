# ADR-0008 — Lectura de GPS en mobile con `geolocator`

- **Estado:** propuesto
- **Fecha:** 2026-10-10
- **Contexto:** alta de establecimiento, paso 3 ("Usar mi ubicación actual")

## Contexto

El botón "Usar mi ubicación actual" del paso 3 del alta cargaba coordenadas fijas, y el
BLoC rechazaba a propósito cualquier envío con esos valores. El resultado: desde la app
no se podía crear ningún establecimiento. El proyecto no tenía ningún paquete de
geolocalización.

La lectura tiene que funcionar en el campo, sin datos móviles (offline-first). Además,
cada falla esperable (GPS apagado, permiso negado, sin señal) tiene que terminar en un
mensaje que el productor entienda, porque en la manga no puede depurar nada.

## Decisión

- Se usa **`geolocator`**, fijado en `14.1.1`. Es el paquete de geolocalización más
  usado de Flutter, tiene mantenimiento activo y soporta Android e iOS con una sola API.
  - En Android usa el proveedor fusionado de Google Play Services cuando está disponible
    y, si no, el `LocationManager` del sistema.
  - La posición sale del receptor GPS del dispositivo y **no requiere internet**. Con
    datos móviles el primer fix puede ser más rápido (A-GPS), pero no es una condición.
- El paquete queda detrás de una interfaz de dominio:
  - `CurrentLocationRepository` (dominio) → `GeolocatorCurrentLocationRepository` (datos)
    → `GetCurrentLocationUseCase`.
  - El BLoC y la UI no importan `geolocator`. Si hay que cambiar de paquete, se cambia
    solo la implementación del repositorio.
  - El repositorio recibe `GeolocatorPlatform` inyectado, así los tests cubren cada rama
    sin un dispositivo real.
- **Permisos mínimos:** ubicación precisa y aproximada, y solo **mientras la app está en
  uso**.
  - Android: `ACCESS_FINE_LOCATION` y `ACCESS_COARSE_LOCATION`.
  - iOS: `NSLocationWhenInUseUsageDescription`.
  - No se pide ubicación en segundo plano: ninguna funcionalidad la necesita.
- **Fallas como resultado, no como excepción.** El repositorio devuelve
  `Result.failure` con un `CurrentLocationFailure` en `reason`:
  - `serviceDisabled`: el GPS del dispositivo está apagado.
  - `permissionDenied`: el usuario negó el permiso, y se puede volver a pedir.
  - `permissionDeniedForever`: el permiso quedó bloqueado y hay que habilitarlo desde
    Ajustes.
  - `timeout`: no hubo fix en **30 s**.

  Cada falla se registra en el log y la UI la explica con un snackbar. Si la lectura
  falla, el borrador del alta no cambia.

## Alternativas descartadas

- **`location`:** API similar, pero con menos mantenimiento y un manejo de permisos
  menos explícito, que es justo lo que hay que explicar bien al productor.
- **Canal nativo propio:** control total, pero obliga a escribir y mantener código
  Kotlin y Swift por una lectura puntual de posición.

## Consecuencias

- Se puede crear un establecimiento desde la app con una posición real, también sin
  conexión.
- La leyenda del paso 3 muestra la precisión informada por el GPS, en lugar de un valor
  fijo.
- Es la primera vez que la app pide un permiso de ubicación. Cualquier funcionalidad
  futura que necesite la posición debe reutilizar `CurrentLocationRepository` en lugar
  de llamar al paquete directamente.
- Si una funcionalidad llegara a necesitar seguimiento continuo o en segundo plano, hace
  falta un ADR nuevo: cambia los permisos y el consumo de batería.
