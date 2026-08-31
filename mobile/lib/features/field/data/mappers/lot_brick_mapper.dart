import 'package:frontend_mayoral/brick/models/lot.model.dart';
import 'package:frontend_mayoral/features/field/data/mappers/lot_boundary_local_json_mapper.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_status.dart';

/// Traduce entre dominio y el modelo técnico de Brick.
class LotBrickMapper {
  const LotBrickMapper._();

  /// Convierte un lote de dominio para persistirlo.
  static BrickLotModel toBrick(Lot lot) => BrickLotModel(
    localId: lot.id,
    establishmentId: lot.establishmentId,
    name: lot.name,
    boundaryJson: LotBoundaryLocalJsonMapper.encode(lot.boundary),
    surfaceTenths: lot.surfaceTenths,
    forageResourceCode: lot.forageResourceCode,
    hasWater: lot.hasWater,
    statusCode: lot.status.code,
    createdAt: lot.createdAt,
    updatedAt: lot.updatedAt,
    deletedAt: lot.deletedAt,
  );

  /// Recupera un lote de dominio desde SQLite.
  static Lot fromBrick(BrickLotModel model) => Lot(
    id: model.localId,
    establishmentId: model.establishmentId,
    name: model.name,
    boundary: LotBoundaryLocalJsonMapper.decode(model.boundaryJson),
    surfaceTenths: model.surfaceTenths,
    forageResourceCode: model.forageResourceCode,
    hasWater: model.hasWater,
    status: LotStatus.fromCode(model.statusCode),
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
    deletedAt: model.deletedAt,
  );
}
