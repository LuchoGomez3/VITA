import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mayoral/features/field/data/mappers/lot_boundary_local_json_mapper.dart';
import 'package:frontend_mayoral/features/field/domain/entities/local_point.dart';
import 'package:frontend_mayoral/features/field/domain/entities/lot_boundary.dart';

void main() {
  test('conserva exactamente los vértices en el round trip local', () {
    const boundary = LotBoundary(
      vertices: [
        LocalPoint(x: 100.25, y: 200.5),
        LocalPoint(x: 400, y: 220),
        LocalPoint(x: 320, y: 600),
      ],
    );

    final encoded = LotBoundaryLocalJsonMapper.encode(boundary);
    final decoded = LotBoundaryLocalJsonMapper.decode(encoded);

    expect(decoded, boundary);
    expect(encoded, contains('establishment_canvas_v1'));
    expect(encoded, isNot(contains('latitude')));
  });

  test('rechaza un espacio de coordenadas desconocido', () {
    expect(
      () => LotBoundaryLocalJsonMapper.decode(
        '{"type":"LocalPolygon","coordinateSpace":"other","vertices":[]}',
      ),
      throwsFormatException,
    );
  });

  test('rechaza una version de geometria no soportada', () {
    expect(
      () => LotBoundaryLocalJsonMapper.decode(
        '{"type":"LocalPolygon","coordinate_space":"establishment_canvas_v1","version":2,"extent":{"width":1000,"height":1000},"vertices":[]}',
      ),
      throwsFormatException,
    );
  });

  test('rechaza dimensiones distintas al lienzo actual', () {
    expect(
      () => LotBoundaryLocalJsonMapper.decode(
        '{"type":"LocalPolygon","coordinate_space":"establishment_canvas_v1","version":1,"extent":{"width":1,"height":1},"vertices":[]}',
      ),
      throwsFormatException,
    );
  });
}
