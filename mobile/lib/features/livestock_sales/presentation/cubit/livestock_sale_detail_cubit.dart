import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/core/result/result_state.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/entities/livestock_sale_selection.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_detail_animals_use_case.dart';
import 'package:frontend_mayoral/features/livestock_sales/domain/use_cases/get_livestock_sale_detail_use_case.dart';

/// Datos locales necesarios para presentar una venta y sus animales.
class LivestockSaleDetailData {
  /// Crea una vista inmutable del agregado disponible en SQLite.
  LivestockSaleDetailData({
    required this.sale,
    required List<LivestockSaleAnimal> animals,
    this.animalsReadFailed = false,
  }) : animals = List.unmodifiable(animals);

  /// Operacion comercial seleccionada.
  final LivestockSale sale;

  /// Animales que pudieron resolverse individualmente en el dispositivo.
  final List<LivestockSaleAnimal> animals;

  /// Indica que SQLite no pudo resolver el inventario asociado.
  final bool animalsReadFailed;

  /// UUID asociados que no estan disponibles en el inventario local.
  int get unavailableAnimalCount => sale.animalIds.length - animals.length;
}

/// Estado asincronico del detalle local de una venta.
typedef LivestockSaleDetailState = ResultState<LivestockSaleDetailData>;

/// Carga una venta por UUID y establecimiento desde SQLite.
class LivestockSaleDetailCubit extends Cubit<LivestockSaleDetailState> {
  /// Crea el Cubit sin permitir que presentacion conozca persistencia.
  LivestockSaleDetailCubit({
    required String establishmentId,
    required String saleId,
    required GetLivestockSaleDetailUseCase getDetail,
    required GetLivestockSaleDetailAnimalsUseCase getAnimals,
  }) : _establishmentId = establishmentId,
       _saleId = saleId,
       _getDetail = getDetail,
       _getAnimals = getAnimals,
       super(const ResultState.initial()) {
    // La misma venta puede cambiar de pendiente a sincronizada mientras el
    // detalle esta abierto. Se relee SQLite sin depender de navegacion manual.
    _saleChanges = _getDetail.changes.listen((_) => unawaited(_refresh()));
  }

  final String _establishmentId;
  final String _saleId;
  final GetLivestockSaleDetailUseCase _getDetail;
  final GetLivestockSaleDetailAnimalsUseCase _getAnimals;
  late final StreamSubscription<void> _saleChanges;
  int _requestVersion = 0;

  /// Lee el detalle local y expone carga, dato o error.
  Future<void> load() => _load(showLoading: true);

  Future<void> _refresh() => _load(showLoading: false);

  Future<void> _load({required bool showLoading}) async {
    final requestVersion = ++_requestVersion;
    if (showLoading) emit(const ResultState.loading());
    final result = await _getDetail(
      establishmentId: _establishmentId,
      saleId: _saleId,
    );
    if (isClosed || requestVersion != _requestVersion) return;
    await result.when(
      success: (sale) => _loadAnimals(sale, requestVersion),
      failure: (error) async => emit(ResultState.error(error)),
    );
  }

  Future<void> _loadAnimals(LivestockSale sale, int requestVersion) async {
    final result = await _getAnimals(sale.animalIds);
    if (isClosed || requestVersion != _requestVersion) return;
    result.when(
      success: (animals) => emit(
        ResultState.data(
          LivestockSaleDetailData(sale: sale, animals: animals),
        ),
      ),
      // La operacion sigue siendo consultable si falla el inventario; el estado
      // permite informar la degradacion sin ocultar los datos comerciales.
      failure: (_) => emit(
        ResultState.data(
          LivestockSaleDetailData(
            sale: sale,
            animals: const [],
            animalsReadFailed: true,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _saleChanges.cancel();
    return super.close();
  }
}
