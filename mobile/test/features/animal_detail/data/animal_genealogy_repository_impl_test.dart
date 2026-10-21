import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/brick/models/animal.model.dart';
import 'package:frontend_mayoral/brick/models/categoria.model.dart';
import 'package:frontend_mayoral/brick/stores/animal_brick_store.dart';
import 'package:frontend_mayoral/brick/stores/categoria_brick_store.dart';
import 'package:frontend_mayoral/core/result/result.dart';
import 'package:frontend_mayoral/features/animal_detail/data/repositories/animal_genealogy_repository_impl.dart';
import 'package:frontend_mayoral/features/animal_detail/domain/entities/animal_genealogy.dart';

void main() {
  Future<AnimalGenealogy> genealogyOf(String id, List<BrickAnimalModel> animals) async {
    final repository = AnimalGenealogyRepositoryImpl(
      animalStore: _FakeAnimalStore(animals),
      categoryStore: _FakeCategoryStore(),
    );
    final result = await repository.getGenealogy(id);
    return (result as Success<AnimalGenealogy>).data;
  }

  test('arma padres y abuelos paternos y maternos', () async {
    final genealogy = await genealogyOf('ternero', [
      _animal('ternero', tag: '005 0001', mother: 'vaca', father: 'toro'),
      _animal('vaca', tag: '003 0421', mother: 'abuela-m', father: 'abuelo-m'),
      _animal('toro', tag: '003 0820', mother: 'abuela-p', father: 'abuelo-p'),
      _animal('abuela-m', tag: '002 0001'),
      _animal('abuelo-m', tag: '002 0002'),
      _animal('abuela-p', tag: '002 0003'),
      _animal('abuelo-p', tag: '002 0004'),
    ]);

    expect(genealogy.mother?.visualTag, '003 0421');
    expect(genealogy.father?.visualTag, '003 0820');
    expect(genealogy.maternalGrandmother?.id, 'abuela-m');
    expect(genealogy.maternalGrandfather?.id, 'abuelo-m');
    expect(genealogy.paternalGrandmother?.id, 'abuela-p');
    expect(genealogy.paternalGrandfather?.id, 'abuelo-p');
    expect(genealogy.mother?.categoryName, 'Vaca');
  });

  test('un progenitor sin cargar queda como dato faltante', () async {
    final genealogy = await genealogyOf('ternero', [
      _animal('ternero', mother: 'vaca'),
      _animal('vaca'),
    ]);

    expect(genealogy.mother?.id, 'vaca');
    expect(genealogy.father, isNull);
    expect(genealogy.maternalGrandmother, isNull);
    expect(genealogy.paternalGrandfather, isNull);
  });

  test('no muestra progenitores borrados ni de otro establecimiento', () async {
    final genealogy = await genealogyOf('ternero', [
      _animal('ternero', mother: 'vaca', father: 'toro'),
      _animal('vaca', deletedAt: DateTime.utc(2026, 9)),
      _animal('toro', establishmentId: 'otro-campo'),
    ]);

    expect(genealogy.mother, isNull);
    expect(genealogy.father, isNull);
  });

  test('corta los ciclos: un animal no aparece como su propio ancestro', () async {
    final genealogy = await genealogyOf('vaca', [
      // Datos mal cargados: la madre de la vaca es su propia hija.
      _animal('vaca', mother: 'hija'),
      _animal('hija', mother: 'vaca'),
    ]);

    expect(genealogy.mother?.id, 'hija');
    expect(genealogy.maternalGrandmother, isNull);
  });

  test('un animal que es su propia madre no se dibuja', () async {
    final genealogy = await genealogyOf('vaca', [_animal('vaca', mother: 'vaca')]);

    expect(genealogy.mother, isNull);
  });

  test('lista las crías vigentes del mismo establecimiento, la más nueva primero', () async {
    final genealogy = await genealogyOf('vaca', [
      _animal('vaca'),
      _animal('cria-vieja', mother: 'vaca', birthDate: DateTime.utc(2024)),
      _animal('cria-nueva', mother: 'vaca', birthDate: DateTime.utc(2026)),
      _animal('cria-borrada', mother: 'vaca', deletedAt: DateTime.utc(2026, 9)),
      _animal('cria-ajena', mother: 'vaca', establishmentId: 'otro-campo'),
    ]);

    expect(genealogy.offspring.map((child) => child.id), ['cria-nueva', 'cria-vieja']);
  });

  test('si falla la lectura local devuelve un error entendible', () async {
    final repository = AnimalGenealogyRepositoryImpl(
      animalStore: _FakeAnimalStore(const [], fail: true),
      categoryStore: _FakeCategoryStore(),
    );

    final result = await repository.getGenealogy('vaca');

    expect(result, isA<Failure<AnimalGenealogy>>());
  });
}

BrickAnimalModel _animal(
  String id, {
  String? tag,
  String? mother,
  String? father,
  String establishmentId = 'campo-1',
  DateTime? deletedAt,
  DateTime? birthDate,
}) {
  return BrickAnimalModel(
    localId: id,
    rfidTagNumber: '982000412884${id.hashCode.abs() % 1000}',
    visualTag: tag ?? id,
    sex: BrickAnimalSex.female,
    breed: 'Aberdeen Angus',
    birthDate: birthDate ?? DateTime.utc(2022),
    categoryId: 'cat-vaca',
    lotId: 'lote-1',
    establishmentId: establishmentId,
    initialWeight: 300,
    weighingMethod: BrickAnimalWeighingMethod.manual,
    weighingDate: DateTime.utc(2026),
    motherId: mother,
    fatherId: father,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    deletedAt: deletedAt,
  );
}

class _FakeAnimalStore implements AnimalBrickStore {
  _FakeAnimalStore(this.animals, {this.fail = false});

  final List<BrickAnimalModel> animals;
  final bool fail;

  @override
  Future<List<BrickAnimalModel>> getLocalAnimals() async {
    if (fail) {
      throw StateError('SQLite no disponible');
    }
    return animals;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class _FakeCategoryStore implements CategoriaBrickStore {
  @override
  Future<List<BrickCategoriaModel>> getLocalCategorias() async => [
    BrickCategoriaModel(
      localId: 'cat-vaca',
      name: 'Vaca',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}
