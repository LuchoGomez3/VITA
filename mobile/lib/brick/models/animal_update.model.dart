import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';

/// Dirige el comando de edición al UUID existente en lugar del endpoint de alta.
class BrickAnimalUpdateRequestTransformer extends RestRequestTransformer {
  /// Recibe la instantánea que la cola serializa antes de intentar enviarla.
  const BrickAnimalUpdateRequestTransformer(super.query, super.instance);

  @override
  RestRequest get upsert => BrickAnimalRequestTransformer.updateRequest(
    (instance! as BrickAnimalUpdateModel).localId,
  );
}

/// Payload acotado de edición para la cola HTTP de Brick.
///
/// No se inserta en SQLite: la ficha se guarda como BrickAnimalModel y la cola
/// conserva este cuerpo HTTP. Así editar el estado no reenvía raza, nacimiento,
/// lote ni campos del alta que podrían estar incompletos en la caché antigua.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(requestTransformer: BrickAnimalUpdateRequestTransformer.new),
)
class BrickAnimalUpdateModel extends OfflineFirstWithRestModel {
  /// Captura los campos editables sin mantener referencias a la ficha mutable.
  BrickAnimalUpdateModel({
    required this.localId,
    required this.categoryId,
    required this.status,
    required this.reproductiveStatus,
    required this.updatedAt,
  });

  /// UUID usado también para asociar el resultado HTTP con la ficha local.
  @Rest(name: 'id')
  final String localId;

  /// Una categoría ausente se envía como null, nunca como UUID vacío.
  @Rest(name: 'categoria_id')
  final String? categoryId;

  /// Estado productivo completo de esta versión de la ficha.
  @Rest(name: 'estado')
  final String status;

  /// Se incluye null explícito cuando el usuario elimina la condición.
  @Rest(name: 'estado_reproductivo')
  final String? reproductiveStatus;

  /// Versión creciente que permite al backend ordenar cambios y deshacer.
  final DateTime updatedAt;
}
