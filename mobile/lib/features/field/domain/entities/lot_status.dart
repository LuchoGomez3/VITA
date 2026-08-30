/// Estado operativo de un lote.
enum LotStatus {
  /// Disponible para recibir animales.
  active('active'),

  /// Reservado para recuperación de la pastura.
  resting('resting'),

  /// Temporalmente afectado por tareas de mantenimiento.
  maintenance('maintenance'),

  /// Conserva su espacio físico, pero no admite animales.
  inactive('inactive'),

  /// Valor recibido de una versión futura del contrato.
  unknown('unknown');

  const LotStatus(this.code);

  /// Código estable persistido localmente y enviado al backend.
  final String code;

  /// Recupera un estado sin impedir la lectura de códigos futuros.
  static LotStatus fromCode(String code) => LotStatus.values.firstWhere(
    (status) => status.code == code,
    orElse: () => LotStatus.unknown,
  );

  /// Indica si el lote puede recibir animales.
  bool get acceptsAnimals => this == LotStatus.active;
}
