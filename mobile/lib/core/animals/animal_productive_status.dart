/// Estado productivo del animal independiente de la persistencia local.
///
/// Es compartido por las features que necesitan decidir si un animal integra
/// el stock, puede participar de una operacion o debe mostrarse como historico.
enum AnimalProductiveStatus {
  /// El estado recibido no forma parte del contrato conocido por esta version.
  unknown,

  /// El animal integra el stock productivo y admite operaciones de campo.
  active,

  /// El animal salio del stock mediante una venta.
  sold,

  /// El animal fue registrado como muerto.
  dead,

  /// El animal fue dado de baja por otro motivo.
  removed;

  /// Indica si el animal integra el stock productivo disponible.
  bool get isInProductiveStock => this == active;

  /// Indica si el estado representa una salida productiva del stock.
  bool get isProductiveRemoval => switch (this) {
    sold || dead || removed => true,
    unknown || active => false,
  };
}
