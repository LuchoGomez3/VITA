# ADR-0009 — Delimitación geográfica del establecimiento

- **Estado:** propuesto
- **Fecha:** 2026-10-10
- **Contexto:** alta de establecimiento, paso 4 ("Delimitar superficie")
- **Requiere validación del Product Owner:** sí. Reemplaza la réplica visual estática
  que se había decidido para el paso 4.

## Contexto

El paso 4 del alta mostraba un mapa decorativo con un polígono fijo de 847 ha y 7
vértices. El productor no podía dibujar su campo ni cargar la superficie real.

El backend ya aceptaba `poligono: [{orden, latitud, longitud}]` en WGS84, pero no lo
validaba y mobile nunca lo enviaba.

El ADR-0002 dejó la geometría de los **lotes** esquemática y local (un lienzo de
1000×1000 sin relación con el mundo real), y anticipó que la geometría geográfica real
llegaría aparte. Este ADR es ese paso, pero para el **contorno del establecimiento**, no
para los lotes.

## Decisión

### 1. El contorno del campo es geográfico (WGS84)

- Los vértices son latitud y longitud reales.
- El mapa se centra en el punto que el GPS leyó en el paso 3.
- Se reutiliza `flutter_map` (ya era dependencia por los lotes), con la proyección
  geográfica por defecto en lugar del `CrsSimple` del lienzo esquemático.
- No se suma ningún paquete nuevo.

### 2. La imagen satelital es una mejora, nunca una condición (offline-first)

- **Fondo:** imagen satelital de **Esri World Imagery**, con la atribución visible que
  exigen sus términos. Es lo que permite ver alambrados y caminos al dibujar.
- **Caché:** `flutter_map` 8 guarda los tiles por defecto en el directorio de caché del
  sistema, hasta 1 GB. Una zona que se vio con conexión se puede volver a ver sin ella,
  aunque el sistema operativo puede limpiar esa caché.
- **Sin señal:**
  - El mapa queda con fondo neutro y aparece un aviso.
  - Siguen funcionando el dibujo, el GPS, el cálculo de superficie y las validaciones.
  - El botón **"Marcar vértice acá"** usa el GPS (ADR-0008) para delimitar el campo
    recorriendo el perímetro, sin datos móviles ni imagen.
- **Botón "Capa":** alterna entre imagen satelital y fondo neutro.

**Términos de uso:** el uso de los tiles de Esri sin cuenta es adecuado para el MVP
académico. Antes de un despliegue comercial hay que revisar los términos de Esri o
migrar a un proveedor con clave. Ese cambio queda acotado a la URL del `TileLayer` en
`establishment_register_surface_step.dart`.

### 3. El polígono es opcional

- Si el productor no puede dibujar el campo (no conoce bien los límites, está apurado),
  carga la superficie total a mano y la delimita más adelante.
- Si dibuja un polígono, la superficie se calcula de su área y el valor cargado a mano
  se ignora.

### 4. La superficie se calcula en el dispositivo

- **Área:** `FieldBoundaryGeometry.areaHectares` calcula el área sobre la esfera
  (Chamberlain y Duquette, la misma fórmula y el mismo radio medio de Turf `area()`). Un
  test la compara contra Turf.
- **Cruces:** `FieldBoundaryGeometry.selfIntersects` detecta lados que se cruzan,
  incluido el lado de cierre.
- Son funciones puras de dominio, sin dependencias de mapas.

### 5. Validación en los dos extremos

| Regla | Mobile (gatea "Siguiente") | Backend (`poligono_invalido`, 422) |
|---|---|---|
| Al menos 3 vértices | ✓ | ✓ |
| Sin lados que se crucen | ✓ | ✓ (`shapely`, `is_valid`) |
| Encierra superficie (no colineal) | ✓ | ✓ |
| `orden` único | (lo asigna mobile) | ✓ |
| Coordenadas en rango | (salen del mapa o del GPS) | ✓ |
| Superficie > 0 sin polígono | ✓ | ✓ (`superficie_invalida`, ya existía) |

- El backend ordena los vértices por `orden` antes de validar.
- Mobile envía `orden` desde 1, igual que la numeración que ve el productor, y redondea
  `superficie_ha` a los 2 decimales de la columna.

## Alternativas descartadas

- **Mantener el lienzo esquemático también para el campo:** no da superficie real en
  hectáreas ni sirve para SENASA o para geolocalizar lotes más adelante.
- **Google Maps o Mapbox:** requieren clave y facturación, y suman un SDK nativo. La
  imagen de Esri alcanza para dibujar un contorno.
- **OpenStreetMap callejero:** en zona rural de Córdoba casi no muestra nada útil para
  delimitar un campo.
- **Polígono obligatorio:** frena el alta en el campo cuando no se puede dibujar.

## Consecuencias

- `establecimientos.poligono` empieza a llenarse con coordenadas reales, validadas en el
  backend.
- La creación del establecimiento sigue siendo online-only (ver la spec). El dibujo y la
  superficie se resuelven sin conexión; solo el envío final la necesita.
- Los lotes siguen siendo esquemáticos (ADR-0002). Ubicarlos dentro de este contorno
  geográfico queda para un ADR futuro.
