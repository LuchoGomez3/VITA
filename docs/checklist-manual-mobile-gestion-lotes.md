# Checklist manual — Gestión mobile de lotes

Ejecutar preferentemente en emulador y luego en un dispositivo físico, con los
flags `VITA_ENABLE_LOT_REMOTE_SYNC` y
`VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC` apagados.

## Alta y persistencia

- [ ] Crear un lote sin conexión siguiendo delimitación → datos.
- [ ] Confirmar que superficie admite coma o punto y se muestra con un decimal.
- [ ] Volver al módulo y verificarlo en vista gráfica y listado.
- [ ] Cerrar completamente la app, abrirla sin conexión y verificar que continúa.
- [ ] Crear un segundo lote compartiendo vértice y luego compartiendo borde.
- [ ] Verificar que cruce, contención, coincidencia y solapamiento parcial se rechazan.
- [ ] Verificar que un nombre duplicado en el establecimiento se rechaza.

## Consulta y ciclo de vida

- [ ] Abrir el mismo detalle desde la vista gráfica y desde el listado.
- [ ] Editar nombre, superficie, forraje, agua y estado; comprobar que el perímetro no cambia.
- [ ] Verificar que un lote inactivo sigue ocupando espacio para superposición.
- [ ] Eliminar un lote vacío y confirmar que desaparece y libera su espacio.
- [ ] Intentar inactivar y eliminar un lote con animales; ambas acciones deben rechazarse.

## Animales y movimientos

- [ ] Registrar un animal y comprobar que el selector ofrece lotes activos reales de SQLite.
- [ ] Abrir el lote y verificar conteo y animal individual.
- [ ] Mover uno o varios animales indicando destino, fecha y motivo.
- [ ] Confirmar que desaparecen del origen y aparecen en el destino con conteos actualizados.
- [ ] Confirmar que descanso, mantenimiento e inactivo no aparecen como destinos.

## Sincronización deshabilitada

- [ ] Trabajar varios minutos offline y online sin observar errores/reintentos de lotes.
- [ ] Comprobar que no se ejecutan requests a `/api/v1/lotes` ni
  `/api/v1/movimientos_lotes` en esta versión.
