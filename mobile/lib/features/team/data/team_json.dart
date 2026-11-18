/// Lecturas del contrato; un tipo incorrecto es una respuesta/cache inválida.
String teamString(Map<String, dynamic> json, String key) => switch (json[key]) {
  final String value => value,
  _ => throw FormatException('Invalid team field: $key'),
};

/// Campo opcional: ausencia y tipos desconocidos no conceden permisos.
String? teamOptionalString(Map<String, dynamic> json, String key) => switch (json[key]) {
  null => null,
  final String value => value,
  _ => throw FormatException('Invalid optional team field: $key'),
};

/// Lista de objetos que no descarta silenciosamente filas inválidas.
List<Map<String, dynamic>> teamObjects(Object? value) {
  if (value is! List) throw const FormatException('Invalid team list');
  return [
    for (final entry in value)
      switch (entry) {
        final Map<String, dynamic> entry => entry,
        _ => throw const FormatException('Invalid team entry'),
      },
  ];
}
