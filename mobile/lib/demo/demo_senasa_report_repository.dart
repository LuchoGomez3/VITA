import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/core/authentication/establishment_catalog.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/entities/senasa_report_models.dart';
import 'package:frontend_mayoral/features/senasa_report/domain/repositories/senasa_report_repository.dart';

/// Exportación SENASA representativa construida exclusivamente con SQLite.
class DemoSenasaReportRepository implements SenasaReportRepository {
  DemoSenasaReportRepository({required AnimalBrickStore animalStore, required EstablishmentCatalog catalog})
    : _animalStore = animalStore,
      _catalog = catalog;

  final AnimalBrickStore _animalStore;
  final EstablishmentCatalog _catalog;
  static final Map<String, GeneratedSenasaReport> _files = {};
  static final List<SenasaExportHistoryItem> _history = [];

  @override
  Future<List<SenasaEstablishment>> getEstablishments() async => [
    for (final membership in await _catalog.getMemberships())
      SenasaEstablishment(id: membership.id, name: membership.name, renspa: '04.001.0.00001/00'),
  ];

  @override
  Future<SenasaValidationResult> validateRecords(SenasaReportValidationRequest request) async {
    final animals = await _animalsFor(request.establishmentId);
    final issues = <SenasaRecordIssue>[
      for (final animal in animals)
        if (animal.rfidTagNumber.isEmpty || animal.visualTag.isEmpty)
          SenasaRecordIssue(
            animalId: animal.localId,
            tag: animal.visualTag,
            missingFields: [
              if (animal.rfidTagNumber.isEmpty) 'nro_caravana_rfid',
              if (animal.visualTag.isEmpty) 'caravana_visual',
            ],
          ),
    ];
    return SenasaValidationResult(exportableAnimals: animals.length - issues.length, issues: issues);
  }

  @override
  Future<GeneratedSenasaReport> generateReport(SenasaReportRequest request) async {
    final animals = await _animalsFor(request.establishmentId);
    final rows = <String>['RFID;CARAVANA_VISUAL;SEXO;RAZA;FECHA_NACIMIENTO'];
    for (final animal in animals) {
      rows.add([
        animal.rfidTagNumber,
        animal.visualTag,
        brickAnimalSexToBackend(animal.sex),
        animal.breed,
        animal.birthDate.toIso8601String().split('T').first,
      ].join(';'));
    }
    final generatedAt = DateTime.now();
    final report = GeneratedSenasaReport(
      bytes: Uint8List.fromList(utf8.encode(rows.join('\r\n'))),
      filename: request.fileName.endsWith('.csv') ? request.fileName : '${request.fileName}.csv',
      mediaType: 'text/csv',
      generatedAt: generatedAt,
      animalCount: animals.length,
    );
    final id = 'demo-${generatedAt.microsecondsSinceEpoch}';
    _files[id] = report;
    _history.insert(
      0,
      SenasaExportHistoryItem(
        id: id,
        establishmentId: request.establishmentId,
        filename: report.filename,
        mediaType: report.mediaType,
        animalCount: report.animalCount,
        generatedAt: generatedAt,
        from: request.from,
        to: request.to,
      ),
    );
    return report;
  }

  @override
  Future<List<SenasaExportHistoryItem>> getGeneratedReports(String establishmentId) async =>
      _history.where((item) => item.establishmentId == establishmentId).toList(growable: false);

  @override
  Future<GeneratedSenasaReport> downloadGeneratedReport(String exportId) async => _files[exportId]!;

  Future<List<BrickAnimalModel>> _animalsFor(String establishmentId) async =>
      (await _animalStore.getLocalAnimals())
          .where((animal) => animal.establishmentId == establishmentId && animal.deletedAt == null)
          .toList(growable: false);
}
