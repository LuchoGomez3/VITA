import 'dart:convert';

import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';

const _unchangedLivestockSaleSyncErrorCode = Object();

/// Estado local de sincronizacion de una venta de hacienda.
enum BrickLivestockSaleSyncStatus {
  /// Guardada en SQLite y pendiente de envio o reintento.
  pending,

  /// Confirmada por el backend.
  synchronized,

  /// Rechazada por una validacion funcional del backend.
  rejected,
}

/// Configura el alta REST de ventas de hacienda.
class BrickLivestockSaleRequestTransformer extends RestRequestTransformer {
  /// Crea el transformer requerido por Brick.
  const BrickLivestockSaleRequestTransformer(super.query, super.instance);

  /// Endpoint atomico que registra venta, detalle, cobro y baja de stock.
  static const salesPath = '/api/v1/ventas';

  @override
  RestRequest get get => const RestRequest(
    url: salesPath,
    topLevelKey: 'data',
  );

  @override
  RestRequest get upsert => const RestRequest(
    method: 'POST',
    url: salesPath,
  );
}

/// Venta guardada primero en SQLite y enviada al backend como un solo agregado.
///
/// Los valores decimales se conservan como texto canonico. Esto evita que un
/// `double` cambie el precio pactado por kilo o introduzca centavos espurios.
@ConnectOfflineFirstWithRest(
  restConfig: RestSerializable(
    requestTransformer: BrickLivestockSaleRequestTransformer.new,
  ),
)
class BrickLivestockSaleModel extends OfflineFirstWithRestModel {
  /// Crea una venta persistible y sincronizable.
  BrickLivestockSaleModel({
    required this.localId,
    required this.establishmentId,
    required this.operationDate,
    required this.buyerType,
    required this.buyerName,
    required this.isCompany,
    required this.dteNumber,
    required this.saleType,
    required this.totalAmount,
    required this.animalIdsJson,
    required this.paymentCondition,
    required this.createdAt,
    required this.updatedAt,
    this.buyerLastName,
    this.totalWeightKg,
    this.pricePerKg,
    this.observations,
    this.initialPaymentJson,
    this.deletedAt,
    this.syncStatus = BrickLivestockSaleSyncStatus.pending,
    this.syncErrorCode,
  });

  /// UUID generado por mobile para que los reintentos sean idempotentes.
  @Rest(name: 'id')
  final String localId;

  /// Tenant propietario de la operacion.
  @Rest(name: 'establecimiento_id')
  final String establishmentId;

  /// Fecha comercial elegida por el usuario, sin hora ni zona en REST.
  @Rest(
    name: 'fecha_operacion',
    toGenerator: 'brickLivestockSaleDateToBackend(%INSTANCE_PROPERTY%)',
  )
  final DateTime operationDate;

  /// Canal comercial: frigorifico, remate o particular.
  @Rest(name: 'tipo_comprador')
  final String buyerType;

  /// Nombre de persona o razon social.
  @Rest(name: 'nombre_comprador')
  final String buyerName;

  /// Distingue una razon social de una persona fisica.
  @Rest(name: 'es_empresa')
  final bool isCompany;

  /// Apellido de persona fisica; una empresa no lo envia.
  @Rest(name: 'apellido_comprador')
  final String? buyerLastName;

  /// Numero de Documento de Transito Electronico.
  @Rest(name: 'nro_dte')
  final String dteNumber;

  /// Modalidad comercial: al_bulto o por_kilo.
  @Rest(name: 'tipo_venta')
  final String saleType;

  /// Peso comercial de la tropa con hasta tres decimales.
  @Rest(name: 'peso_total_kg')
  final String? totalWeightKg;

  /// Precio pactado por kilo con hasta seis decimales, sin redondearlo.
  @Rest(name: 'precio_por_kg')
  final String? pricePerKg;

  /// Total final expresado en pesos y centavos.
  @Rest(name: 'monto_total')
  final String totalAmount;

  /// Nota opcional de la operacion.
  @Rest(name: 'observaciones')
  final String? observations;

  /// UUID de animales como JSON estable en SQLite y lista en REST.
  @Rest(
    name: 'animal_ids',
    toGenerator: 'brickLivestockSaleJsonToBackend(%INSTANCE_PROPERTY%)',
    fromGenerator: 'brickLivestockSaleJsonFromBackend(%DATA_PROPERTY%)',
  )
  final String animalIdsJson;

  /// Situacion inicial elegida: total, parcial o pendiente.
  @Rest(name: 'condicion_cobro')
  final String paymentCondition;

  /// Cobro inicial completo, o null para una venta pendiente.
  ///
  /// Se guarda anidado porque el endpoint crea toda la operacion de forma
  /// atomica; encolarlo como otra entidad permitiria ventas sin su cobro.
  @Rest(
    name: 'cobro_inicial',
    toGenerator: 'brickLivestockSaleNullableJsonToBackend(%INSTANCE_PROPERTY%)',
    fromGenerator: 'brickLivestockSaleNullableJsonFromBackend(%DATA_PROPERTY%)',
  )
  final String? initialPaymentJson;

  /// Auditoria generada en el dispositivo para last-write-wins.
  @Rest(name: 'created_at')
  final DateTime createdAt;

  /// Ultima version local de la operacion.
  @Rest(name: 'updated_at')
  final DateTime updatedAt;

  /// Tombstone sincronizable.
  @Rest(name: 'deleted_at')
  final DateTime? deletedAt;

  /// Estado de la cola exclusivo de SQLite.
  @Rest(ignore: true)
  final BrickLivestockSaleSyncStatus syncStatus;

  /// Codigo funcional del ultimo rechazo permanente.
  @Rest(ignore: true)
  final String? syncErrorCode;

  /// Crea una copia reconciliada conservando la fila SQLite existente.
  BrickLivestockSaleModel copyWith({
    BrickLivestockSaleSyncStatus? syncStatus,
    Object? syncErrorCode = _unchangedLivestockSaleSyncErrorCode,
  }) {
    final nextSyncErrorCode =
        identical(
          syncErrorCode,
          _unchangedLivestockSaleSyncErrorCode,
        )
        ? this.syncErrorCode
        : syncErrorCode as String?;

    return BrickLivestockSaleModel(
      localId: localId,
      establishmentId: establishmentId,
      operationDate: operationDate,
      buyerType: buyerType,
      buyerName: buyerName,
      isCompany: isCompany,
      buyerLastName: buyerLastName,
      dteNumber: dteNumber,
      saleType: saleType,
      totalWeightKg: totalWeightKg,
      pricePerKg: pricePerKg,
      totalAmount: totalAmount,
      observations: observations,
      animalIdsJson: animalIdsJson,
      paymentCondition: paymentCondition,
      initialPaymentJson: initialPaymentJson,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncErrorCode: nextSyncErrorCode,
    )..primaryKey = primaryKey;
  }
}

/// Serializa una fecha comercial sin hora ni conversion de zona.
String brickLivestockSaleDateToBackend(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Convierte JSON persistido como texto al objeto esperado por FastAPI.
Object brickLivestockSaleJsonToBackend(String encoded) => jsonDecode(encoded) as Object;

/// Convierte una lista u objeto REST a texto estable para SQLite.
String brickLivestockSaleJsonFromBackend(Object? value) => jsonEncode(value);

/// Convierte el cobro anidado sin transformar una ausencia en texto `null`.
Object? brickLivestockSaleNullableJsonToBackend(String? encoded) {
  return encoded == null ? null : jsonDecode(encoded);
}

/// Conserva como ausencia un cobro que no existe en el backend.
String? brickLivestockSaleNullableJsonFromBackend(Object? value) {
  return value == null ? null : jsonEncode(value);
}
