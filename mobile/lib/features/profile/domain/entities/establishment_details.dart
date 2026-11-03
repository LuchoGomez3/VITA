import 'package:frontend_mayoral/core/authentication/user_role.dart';

/// Datos de un establecimiento disponibles offline para Perfil.
typedef EstablishmentDetails = ({
  String id,
  String ownerId,
  String name,
  UserRole role,
  String? renspaNumber,
  String? cuit,
  double? areaHectares,
  String? province,
  String? department,
  String? locality,
  double? latitude,
  double? longitude,
  List<({double latitude, double longitude})> boundary,
  DateTime createdAt,
  DateTime updatedAt,
});
