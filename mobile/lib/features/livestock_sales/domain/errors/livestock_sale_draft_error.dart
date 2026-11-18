/// Motivos estables por los que puede fallar el borrador local de una venta.
enum LivestockSaleDraftError {
  /// El contenido almacenado no corresponde al formato vigente.
  invalidData,

  /// No se pudo leer el progreso desde el dispositivo.
  localRead,

  /// No se pudo actualizar el progreso en el dispositivo.
  localWrite,

  /// No se pudo eliminar el progreso del dispositivo.
  localDelete,
}
