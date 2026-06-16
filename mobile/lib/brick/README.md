# Brick

Esta carpeta concentra la infraestructura offline-first del proyecto.

Acá viven:

- modelos persistibles y sincronizables con Brick
- configuración del repository offline-first
- adapters y schema generados
- migraciones locales

Las features no deben depender directamente de esta carpeta desde `presentation`
ni desde `domain`. La integración se hace desde `data/repositories`.
