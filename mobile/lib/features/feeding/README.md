# Alimentación

Qué comió cada animal, dónde y cuándo. Decisiones de fondo en
`docs/adr/adr-0015-alimentacion-pastoreo-derivado-y-registros.md`.

## Dos fuentes

- **Pastoreo (derivado).** No se carga a mano: `GrazingHistoryBuilder` cruza los
  movimientos del animal (`BrickAnimalLotMovementModel`) con el historial de
  recursos de cada potrero (`BrickLotForagePeriodModel`, se carga desde el
  detalle del potrero en `field`). Funciona sin conexión.
- **Suplementos y dietas (registrados).** `RegisterFeedingPage` guarda un
  `BrickFeedingRecordModel` para uno o varios animales, con alimento, potrero o
  corral, cantidad, unidad y fechas (`fecha_hasta` null = en curso). Un alimento
  nuevo se da de alta en el mismo formulario y se guarda en la misma
  transacción local; se encola antes que el registro que lo usa.

## Tramos estimados

El historial de movimientos tiene huecos conocidos (dar de alta un animal o
editar su potrero desde la ficha no genera un movimiento). Esos tramos se
infieren y llevan un `GrazingEstimateReason`:

| Motivo | Cuándo |
|---|---|
| `noMovements` | El animal no tiene movimientos: se asume su potrero actual desde el alta |
| `beforeFirstMovement` | Antes del primer movimiento: se asume el origen desde el alta |
| `brokenChain` | Un movimiento sale de un potrero distinto al que llegó el anterior |
| `lotEditedWithoutMovement` | El potrero actual no coincide con el último destino |

Un tramo estimado nunca se une con uno respaldado por un movimiento. Las fechas
son días locales: los períodos y registros viajan como `yyyy-MM-dd` para no
correrse por UTC-3.

## Dónde se ve

- Pestaña **Alimentación** de la ficha (`animal_detail/.../animal_feeding_tab.dart`),
  con su `AnimalFeedingCubit`, que relee ante cambios locales.
- Sección **Forraje y servicios** del potrero (`field/.../lot_forage_section.dart`).

Las etiquetas de recursos, categorías y unidades están en `core/catalogs/`
porque las comparten `field`, `feeding` y `animal_detail`.
