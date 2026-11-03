// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operating_expense_remote_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OperatingExpenseRemoteDto _$OperatingExpenseRemoteDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_OperatingExpenseRemoteDto',
  json,
  ($checkedConvert) {
    final val = _OperatingExpenseRemoteDto(
      id: $checkedConvert('id', (v) => v as String),
      establishmentId: $checkedConvert(
        'establecimiento_id',
        (v) => v as String,
      ),
      amount: $checkedConvert('monto', (v) => v as String),
      type: $checkedConvert('tipo', (v) => v as String),
      category: $checkedConvert('categoria', (v) => v as String),
      supply: $checkedConvert('insumo', (v) => v as String),
      date: $checkedConvert('fecha', (v) => DateTime.parse(v as String)),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
      description: $checkedConvert('descripcion', (v) => v as String?),
      receiptNumber: $checkedConvert('numero_comprobante', (v) => v as String?),
      loadedById: $checkedConvert('cargado_por_id', (v) => v as String?),
      loadedBy: $checkedConvert(
        'cargado_por',
        (v) => v == null ? null : OperatingExpenseRemoteUserDto.fromJson(v as Map<String, dynamic>),
      ),
      deletedAt: $checkedConvert(
        'deleted_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'establishmentId': 'establecimiento_id',
    'amount': 'monto',
    'type': 'tipo',
    'category': 'categoria',
    'supply': 'insumo',
    'date': 'fecha',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'description': 'descripcion',
    'receiptNumber': 'numero_comprobante',
    'loadedById': 'cargado_por_id',
    'loadedBy': 'cargado_por',
    'deletedAt': 'deleted_at',
  },
);

Map<String, dynamic> _$OperatingExpenseRemoteDtoToJson(
  _OperatingExpenseRemoteDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'establecimiento_id': instance.establishmentId,
  'monto': instance.amount,
  'tipo': instance.type,
  'categoria': instance.category,
  'insumo': instance.supply,
  'fecha': instance.date.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'descripcion': instance.description,
  'numero_comprobante': instance.receiptNumber,
  'cargado_por_id': instance.loadedById,
  'cargado_por': instance.loadedBy,
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_OperatingExpenseRemoteUserDto _$OperatingExpenseRemoteUserDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_OperatingExpenseRemoteUserDto',
  json,
  ($checkedConvert) {
    final val = _OperatingExpenseRemoteUserDto(
      firstName: $checkedConvert('nombre', (v) => v as String?),
      lastName: $checkedConvert('apellido', (v) => v as String?),
      email: $checkedConvert('email', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'firstName': 'nombre', 'lastName': 'apellido'},
);

Map<String, dynamic> _$OperatingExpenseRemoteUserDtoToJson(
  _OperatingExpenseRemoteUserDto instance,
) => <String, dynamic>{
  'nombre': instance.firstName,
  'apellido': instance.lastName,
  'email': instance.email,
};

_OperatingExpenseRemoteCatalogType _$OperatingExpenseRemoteCatalogTypeFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_OperatingExpenseRemoteCatalogType',
  json,
  ($checkedConvert) {
    final val = _OperatingExpenseRemoteCatalogType(
      type: $checkedConvert('valor', (v) => v as String),
      categories: $checkedConvert(
        'categorias',
        (v) => (v as List<dynamic>)
            .map(
              (e) => OperatingExpenseRemoteCategory.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'type': 'valor', 'categories': 'categorias'},
);

Map<String, dynamic> _$OperatingExpenseRemoteCatalogTypeToJson(
  _OperatingExpenseRemoteCatalogType instance,
) => <String, dynamic>{
  'valor': instance.type,
  'categorias': instance.categories,
};

_OperatingExpenseRemoteCategory _$OperatingExpenseRemoteCategoryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_OperatingExpenseRemoteCategory',
  json,
  ($checkedConvert) {
    final val = _OperatingExpenseRemoteCategory(
      value: $checkedConvert('valor', (v) => v as String),
      label: $checkedConvert('etiqueta', (v) => v as String),
      custom: $checkedConvert('personalizada', (v) => v as bool),
      id: $checkedConvert('id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'value': 'valor',
    'label': 'etiqueta',
    'custom': 'personalizada',
  },
);

Map<String, dynamic> _$OperatingExpenseRemoteCategoryToJson(
  _OperatingExpenseRemoteCategory instance,
) => <String, dynamic>{
  'valor': instance.value,
  'etiqueta': instance.label,
  'personalizada': instance.custom,
  'id': instance.id,
};
