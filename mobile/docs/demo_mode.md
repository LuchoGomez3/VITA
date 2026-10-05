# Modo demo offline (rama `jornada-poster`)

Esta rama inicia en modo demo por defecto. El arranque crea una sesión local y
siembra datos sintéticos en la misma SQLite de Brick que consumen las features.
El transporte REST queda bloqueado antes de llegar a un socket; las altas de la
demo persisten localmente con estado pendiente.

```powershell
# Demo offline (valor por defecto de esta rama)
fvm flutter run

# Restaurar el conjunto inicial y descartar cambios locales de la demo
fvm flutter run --dart-define=DEMO_RESET=true

# Ejecutar la composición productiva existente
fvm flutter run --dart-define=DEMO_MODE=false
```

La pantalla inicial es Login. Las credenciales sintéticas son:

- Usuario: `epetrich9@gmail.com`
- Contraseña: `test1234`

El flujo alternativo de crear una cuenta también finaliza correctamente y crea
una sesión local con los datos ingresados. El alta de establecimiento agrega una
membresía `owner` al catálogo local, sin invocar al backend.

El reset elimina únicamente las tablas Brick usadas por los fixtures y vuelve a
sembrarlas. No consulta ni modifica Supabase. Todos los UUID, personas, RENSPA,
caravanas y movimientos incluidos son ficticios.

Deuda temporal: `DEMO_MODE` tiene `true` como valor predeterminado solo para la
presentación. Antes de integrar cambios a `develop`, debe volver a `false` o
eliminarse junto con `lib/demo/` y las ramas demo de los composition roots.
