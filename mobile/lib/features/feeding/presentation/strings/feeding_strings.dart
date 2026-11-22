/// Textos del registro de alimentación.
abstract final class FeedingStrings {
  /// Título de la pantalla.
  static const pageTitle = 'Registrar alimentación';

  /// Explica cómo sumar animales.
  static const readHint = 'Leé con el bastón o escribí la caravana de cada animal que recibió el alimento.';

  /// Campo de caravana.
  static const tagFieldHint = 'Caravana o RFID';

  /// Botón para sumar la caravana.
  static const addTag = 'Agregar animal';

  /// Quitar un animal de la lista.
  static const removeAnimal = 'Quitar';

  /// Título de la lista de animales.
  static String animalsTitle(int count) => count == 1 ? '1 animal' : '$count animales';

  /// Potrero actual del animal.
  static String inLot(String lotName) => lotName.isEmpty ? 'Sin potrero' : 'En $lotName';

  /// Sección del tipo.
  static const typeTitle = '¿Qué le diste?';

  /// Opción suplemento.
  static const supplement = 'Suplemento';

  /// Opción dieta.
  static const diet = 'Dieta';

  /// Aclara la diferencia.
  static const typeHelper =
      'Suplemento: un agregado (grano en sequía, sales). Dieta: un régimen que define lo que come.';

  /// Campo de alimento.
  static const foodTitle = 'Alimento';

  /// Ejemplo del campo.
  static const foodHint = 'Elegí un alimento';

  /// Acción para crear uno.
  static const newFoodCta = 'Nuevo alimento';

  /// Catálogo vacío.
  static const noFoods = 'Todavía no hay alimentos cargados. Creá el primero.';

  /// Título del diálogo.
  static const newFoodTitle = 'Nuevo alimento';

  /// Campo de nombre.
  static const foodNameLabel = 'Nombre';

  /// Ejemplo de nombre.
  static const foodNameHint = 'Ej. Maíz partido';

  /// Coincidencias mientras se escribe.
  static const similarFoods = 'Ya cargaste:';

  /// Campo de categoría.
  static const categoryLabel = 'Categoría';

  /// Campo de unidad.
  static const unitLabel = 'Unidad';

  /// Cancelar el diálogo.
  static const cancel = 'Cancelar';

  /// Confirmar el diálogo.
  static const useFood = 'Usar este alimento';

  /// Alimento nuevo, todavía sin guardar.
  static String newFoodSelected(String name) => '$name (nuevo)';

  /// Sección del lugar.
  static const lotTitle = '¿Dónde?';

  /// Sin potrero: corral o manga.
  static const noLot = 'Corral o manga';

  /// Subtítulo del corral.
  static const noLotHelper = 'Fuera de un potrero';

  /// Subtítulo de un potrero.
  static const lotHelper = 'Potrero';

  /// Sección de cantidad.
  static const quantityTitle = 'Cantidad';

  /// Ejemplo de cantidad.
  static const quantityHint = 'Ej. 2,5';

  /// Cantidad por animal.
  static const perAnimalDay = 'Por animal/día';

  /// Cantidad del grupo.
  static const groupDay = 'Grupo/día';

  /// Sección de duración.
  static const durationTitle = 'Duración';

  /// Un solo día.
  static const oneDay = 'Un día';

  /// Con fecha de fin.
  static const period = 'Período';

  /// Sigue vigente.
  static const ongoing = 'En curso';

  /// Fecha de inicio.
  static const startLabel = 'Desde';

  /// Fecha única.
  static const dayLabel = 'Fecha';

  /// Fecha de fin.
  static const endLabel = 'Hasta';

  /// Ejemplo de fecha.
  static const dateHint = 'dd/mm/aaaa';

  /// Motivo.
  static const reasonLabel = 'Motivo (opcional)';

  /// Ejemplo de motivo.
  static const reasonHint = 'Ej. Sequía, recría, engorde';

  /// Botón principal.
  static String submit(int count) => count == 1 ? 'Guardar para 1 animal' : 'Guardar para $count animales';

  /// Confirmación al volver.
  static const savedOffline = 'Alimentación guardada en el celular. Se sincroniza cuando haya señal.';
}
