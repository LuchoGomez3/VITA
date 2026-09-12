// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operating_expense_remote_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperatingExpenseRemotePage {

 List<OperatingExpenseRemoteDto> get expenses; int get totalCents;
/// Create a copy of OperatingExpenseRemotePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseRemotePageCopyWith<OperatingExpenseRemotePage> get copyWith => _$OperatingExpenseRemotePageCopyWithImpl<OperatingExpenseRemotePage>(this as OperatingExpenseRemotePage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseRemotePage&&const DeepCollectionEquality().equals(other.expenses, expenses)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(expenses),totalCents);

@override
String toString() {
  return 'OperatingExpenseRemotePage(expenses: $expenses, totalCents: $totalCents)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseRemotePageCopyWith<$Res>  {
  factory $OperatingExpenseRemotePageCopyWith(OperatingExpenseRemotePage value, $Res Function(OperatingExpenseRemotePage) _then) = _$OperatingExpenseRemotePageCopyWithImpl;
@useResult
$Res call({
 List<OperatingExpenseRemoteDto> expenses, int totalCents
});




}
/// @nodoc
class _$OperatingExpenseRemotePageCopyWithImpl<$Res>
    implements $OperatingExpenseRemotePageCopyWith<$Res> {
  _$OperatingExpenseRemotePageCopyWithImpl(this._self, this._then);

  final OperatingExpenseRemotePage _self;
  final $Res Function(OperatingExpenseRemotePage) _then;

/// Create a copy of OperatingExpenseRemotePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expenses = null,Object? totalCents = null,}) {
  return _then(_self.copyWith(
expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseRemoteDto>,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseRemotePage].
extension OperatingExpenseRemotePagePatterns on OperatingExpenseRemotePage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseRemotePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseRemotePage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseRemotePage value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemotePage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseRemotePage value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemotePage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OperatingExpenseRemoteDto> expenses,  int totalCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseRemotePage() when $default != null:
return $default(_that.expenses,_that.totalCents);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OperatingExpenseRemoteDto> expenses,  int totalCents)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemotePage():
return $default(_that.expenses,_that.totalCents);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OperatingExpenseRemoteDto> expenses,  int totalCents)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemotePage() when $default != null:
return $default(_that.expenses,_that.totalCents);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingExpenseRemotePage implements OperatingExpenseRemotePage {
  const _OperatingExpenseRemotePage({required final  List<OperatingExpenseRemoteDto> expenses, required this.totalCents}): _expenses = expenses;
  

 final  List<OperatingExpenseRemoteDto> _expenses;
@override List<OperatingExpenseRemoteDto> get expenses {
  if (_expenses is EqualUnmodifiableListView) return _expenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenses);
}

@override final  int totalCents;

/// Create a copy of OperatingExpenseRemotePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseRemotePageCopyWith<_OperatingExpenseRemotePage> get copyWith => __$OperatingExpenseRemotePageCopyWithImpl<_OperatingExpenseRemotePage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseRemotePage&&const DeepCollectionEquality().equals(other._expenses, _expenses)&&(identical(other.totalCents, totalCents) || other.totalCents == totalCents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_expenses),totalCents);

@override
String toString() {
  return 'OperatingExpenseRemotePage(expenses: $expenses, totalCents: $totalCents)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseRemotePageCopyWith<$Res> implements $OperatingExpenseRemotePageCopyWith<$Res> {
  factory _$OperatingExpenseRemotePageCopyWith(_OperatingExpenseRemotePage value, $Res Function(_OperatingExpenseRemotePage) _then) = __$OperatingExpenseRemotePageCopyWithImpl;
@override @useResult
$Res call({
 List<OperatingExpenseRemoteDto> expenses, int totalCents
});




}
/// @nodoc
class __$OperatingExpenseRemotePageCopyWithImpl<$Res>
    implements _$OperatingExpenseRemotePageCopyWith<$Res> {
  __$OperatingExpenseRemotePageCopyWithImpl(this._self, this._then);

  final _OperatingExpenseRemotePage _self;
  final $Res Function(_OperatingExpenseRemotePage) _then;

/// Create a copy of OperatingExpenseRemotePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expenses = null,Object? totalCents = null,}) {
  return _then(_OperatingExpenseRemotePage(
expenses: null == expenses ? _self._expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseRemoteDto>,totalCents: null == totalCents ? _self.totalCents : totalCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OperatingExpenseRemoteDto {

 String get id;@JsonKey(name: 'establecimiento_id') String get establishmentId;@JsonKey(name: 'monto') String get amount;@JsonKey(name: 'tipo') String get type;@JsonKey(name: 'categoria') String get category;@JsonKey(name: 'insumo') String get supply;@JsonKey(name: 'fecha') DateTime get date;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'descripcion') String? get description;@JsonKey(name: 'numero_comprobante') String? get receiptNumber;@JsonKey(name: 'cargado_por_id') String? get loadedById;@JsonKey(name: 'cargado_por') OperatingExpenseRemoteUserDto? get loadedBy;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;
/// Create a copy of OperatingExpenseRemoteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseRemoteDtoCopyWith<OperatingExpenseRemoteDto> get copyWith => _$OperatingExpenseRemoteDtoCopyWithImpl<OperatingExpenseRemoteDto>(this as OperatingExpenseRemoteDto, _$identity);

  /// Serializes this OperatingExpenseRemoteDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseRemoteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.supply, supply) || other.supply == supply)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.loadedById, loadedById) || other.loadedById == loadedById)&&(identical(other.loadedBy, loadedBy) || other.loadedBy == loadedBy)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,amount,type,category,supply,date,createdAt,updatedAt,description,receiptNumber,loadedById,loadedBy,deletedAt);

@override
String toString() {
  return 'OperatingExpenseRemoteDto(id: $id, establishmentId: $establishmentId, amount: $amount, type: $type, category: $category, supply: $supply, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, receiptNumber: $receiptNumber, loadedById: $loadedById, loadedBy: $loadedBy, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseRemoteDtoCopyWith<$Res>  {
  factory $OperatingExpenseRemoteDtoCopyWith(OperatingExpenseRemoteDto value, $Res Function(OperatingExpenseRemoteDto) _then) = _$OperatingExpenseRemoteDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'establecimiento_id') String establishmentId,@JsonKey(name: 'monto') String amount,@JsonKey(name: 'tipo') String type,@JsonKey(name: 'categoria') String category,@JsonKey(name: 'insumo') String supply,@JsonKey(name: 'fecha') DateTime date,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'descripcion') String? description,@JsonKey(name: 'numero_comprobante') String? receiptNumber,@JsonKey(name: 'cargado_por_id') String? loadedById,@JsonKey(name: 'cargado_por') OperatingExpenseRemoteUserDto? loadedBy,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});


$OperatingExpenseRemoteUserDtoCopyWith<$Res>? get loadedBy;

}
/// @nodoc
class _$OperatingExpenseRemoteDtoCopyWithImpl<$Res>
    implements $OperatingExpenseRemoteDtoCopyWith<$Res> {
  _$OperatingExpenseRemoteDtoCopyWithImpl(this._self, this._then);

  final OperatingExpenseRemoteDto _self;
  final $Res Function(OperatingExpenseRemoteDto) _then;

/// Create a copy of OperatingExpenseRemoteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? amount = null,Object? type = null,Object? category = null,Object? supply = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? receiptNumber = freezed,Object? loadedById = freezed,Object? loadedBy = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,supply: null == supply ? _self.supply : supply // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,loadedById: freezed == loadedById ? _self.loadedById : loadedById // ignore: cast_nullable_to_non_nullable
as String?,loadedBy: freezed == loadedBy ? _self.loadedBy : loadedBy // ignore: cast_nullable_to_non_nullable
as OperatingExpenseRemoteUserDto?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of OperatingExpenseRemoteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingExpenseRemoteUserDtoCopyWith<$Res>? get loadedBy {
    if (_self.loadedBy == null) {
    return null;
  }

  return $OperatingExpenseRemoteUserDtoCopyWith<$Res>(_self.loadedBy!, (value) {
    return _then(_self.copyWith(loadedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [OperatingExpenseRemoteDto].
extension OperatingExpenseRemoteDtoPatterns on OperatingExpenseRemoteDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteDto value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteDto():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseRemoteDto value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'establecimiento_id')  String establishmentId, @JsonKey(name: 'monto')  String amount, @JsonKey(name: 'tipo')  String type, @JsonKey(name: 'categoria')  String category, @JsonKey(name: 'insumo')  String supply, @JsonKey(name: 'fecha')  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'descripcion')  String? description, @JsonKey(name: 'numero_comprobante')  String? receiptNumber, @JsonKey(name: 'cargado_por_id')  String? loadedById, @JsonKey(name: 'cargado_por')  OperatingExpenseRemoteUserDto? loadedBy, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteDto() when $default != null:
return $default(_that.id,_that.establishmentId,_that.amount,_that.type,_that.category,_that.supply,_that.date,_that.createdAt,_that.updatedAt,_that.description,_that.receiptNumber,_that.loadedById,_that.loadedBy,_that.deletedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'establecimiento_id')  String establishmentId, @JsonKey(name: 'monto')  String amount, @JsonKey(name: 'tipo')  String type, @JsonKey(name: 'categoria')  String category, @JsonKey(name: 'insumo')  String supply, @JsonKey(name: 'fecha')  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'descripcion')  String? description, @JsonKey(name: 'numero_comprobante')  String? receiptNumber, @JsonKey(name: 'cargado_por_id')  String? loadedById, @JsonKey(name: 'cargado_por')  OperatingExpenseRemoteUserDto? loadedBy, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteDto():
return $default(_that.id,_that.establishmentId,_that.amount,_that.type,_that.category,_that.supply,_that.date,_that.createdAt,_that.updatedAt,_that.description,_that.receiptNumber,_that.loadedById,_that.loadedBy,_that.deletedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'establecimiento_id')  String establishmentId, @JsonKey(name: 'monto')  String amount, @JsonKey(name: 'tipo')  String type, @JsonKey(name: 'categoria')  String category, @JsonKey(name: 'insumo')  String supply, @JsonKey(name: 'fecha')  DateTime date, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'descripcion')  String? description, @JsonKey(name: 'numero_comprobante')  String? receiptNumber, @JsonKey(name: 'cargado_por_id')  String? loadedById, @JsonKey(name: 'cargado_por')  OperatingExpenseRemoteUserDto? loadedBy, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteDto() when $default != null:
return $default(_that.id,_that.establishmentId,_that.amount,_that.type,_that.category,_that.supply,_that.date,_that.createdAt,_that.updatedAt,_that.description,_that.receiptNumber,_that.loadedById,_that.loadedBy,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _OperatingExpenseRemoteDto implements OperatingExpenseRemoteDto {
  const _OperatingExpenseRemoteDto({required this.id, @JsonKey(name: 'establecimiento_id') required this.establishmentId, @JsonKey(name: 'monto') required this.amount, @JsonKey(name: 'tipo') required this.type, @JsonKey(name: 'categoria') required this.category, @JsonKey(name: 'insumo') required this.supply, @JsonKey(name: 'fecha') required this.date, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'descripcion') this.description, @JsonKey(name: 'numero_comprobante') this.receiptNumber, @JsonKey(name: 'cargado_por_id') this.loadedById, @JsonKey(name: 'cargado_por') this.loadedBy, @JsonKey(name: 'deleted_at') this.deletedAt});
  factory _OperatingExpenseRemoteDto.fromJson(Map<String, dynamic> json) => _$OperatingExpenseRemoteDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'establecimiento_id') final  String establishmentId;
@override@JsonKey(name: 'monto') final  String amount;
@override@JsonKey(name: 'tipo') final  String type;
@override@JsonKey(name: 'categoria') final  String category;
@override@JsonKey(name: 'insumo') final  String supply;
@override@JsonKey(name: 'fecha') final  DateTime date;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'descripcion') final  String? description;
@override@JsonKey(name: 'numero_comprobante') final  String? receiptNumber;
@override@JsonKey(name: 'cargado_por_id') final  String? loadedById;
@override@JsonKey(name: 'cargado_por') final  OperatingExpenseRemoteUserDto? loadedBy;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;

/// Create a copy of OperatingExpenseRemoteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseRemoteDtoCopyWith<_OperatingExpenseRemoteDto> get copyWith => __$OperatingExpenseRemoteDtoCopyWithImpl<_OperatingExpenseRemoteDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OperatingExpenseRemoteDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseRemoteDto&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.supply, supply) || other.supply == supply)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.loadedById, loadedById) || other.loadedById == loadedById)&&(identical(other.loadedBy, loadedBy) || other.loadedBy == loadedBy)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,amount,type,category,supply,date,createdAt,updatedAt,description,receiptNumber,loadedById,loadedBy,deletedAt);

@override
String toString() {
  return 'OperatingExpenseRemoteDto(id: $id, establishmentId: $establishmentId, amount: $amount, type: $type, category: $category, supply: $supply, date: $date, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, receiptNumber: $receiptNumber, loadedById: $loadedById, loadedBy: $loadedBy, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseRemoteDtoCopyWith<$Res> implements $OperatingExpenseRemoteDtoCopyWith<$Res> {
  factory _$OperatingExpenseRemoteDtoCopyWith(_OperatingExpenseRemoteDto value, $Res Function(_OperatingExpenseRemoteDto) _then) = __$OperatingExpenseRemoteDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'establecimiento_id') String establishmentId,@JsonKey(name: 'monto') String amount,@JsonKey(name: 'tipo') String type,@JsonKey(name: 'categoria') String category,@JsonKey(name: 'insumo') String supply,@JsonKey(name: 'fecha') DateTime date,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'descripcion') String? description,@JsonKey(name: 'numero_comprobante') String? receiptNumber,@JsonKey(name: 'cargado_por_id') String? loadedById,@JsonKey(name: 'cargado_por') OperatingExpenseRemoteUserDto? loadedBy,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});


@override $OperatingExpenseRemoteUserDtoCopyWith<$Res>? get loadedBy;

}
/// @nodoc
class __$OperatingExpenseRemoteDtoCopyWithImpl<$Res>
    implements _$OperatingExpenseRemoteDtoCopyWith<$Res> {
  __$OperatingExpenseRemoteDtoCopyWithImpl(this._self, this._then);

  final _OperatingExpenseRemoteDto _self;
  final $Res Function(_OperatingExpenseRemoteDto) _then;

/// Create a copy of OperatingExpenseRemoteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? amount = null,Object? type = null,Object? category = null,Object? supply = null,Object? date = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? receiptNumber = freezed,Object? loadedById = freezed,Object? loadedBy = freezed,Object? deletedAt = freezed,}) {
  return _then(_OperatingExpenseRemoteDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,supply: null == supply ? _self.supply : supply // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,loadedById: freezed == loadedById ? _self.loadedById : loadedById // ignore: cast_nullable_to_non_nullable
as String?,loadedBy: freezed == loadedBy ? _self.loadedBy : loadedBy // ignore: cast_nullable_to_non_nullable
as OperatingExpenseRemoteUserDto?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of OperatingExpenseRemoteDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OperatingExpenseRemoteUserDtoCopyWith<$Res>? get loadedBy {
    if (_self.loadedBy == null) {
    return null;
  }

  return $OperatingExpenseRemoteUserDtoCopyWith<$Res>(_self.loadedBy!, (value) {
    return _then(_self.copyWith(loadedBy: value));
  });
}
}


/// @nodoc
mixin _$OperatingExpenseRemoteUserDto {

@JsonKey(name: 'nombre') String? get firstName;@JsonKey(name: 'apellido') String? get lastName; String? get email;
/// Create a copy of OperatingExpenseRemoteUserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseRemoteUserDtoCopyWith<OperatingExpenseRemoteUserDto> get copyWith => _$OperatingExpenseRemoteUserDtoCopyWithImpl<OperatingExpenseRemoteUserDto>(this as OperatingExpenseRemoteUserDto, _$identity);

  /// Serializes this OperatingExpenseRemoteUserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseRemoteUserDto&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,email);

@override
String toString() {
  return 'OperatingExpenseRemoteUserDto(firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseRemoteUserDtoCopyWith<$Res>  {
  factory $OperatingExpenseRemoteUserDtoCopyWith(OperatingExpenseRemoteUserDto value, $Res Function(OperatingExpenseRemoteUserDto) _then) = _$OperatingExpenseRemoteUserDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'nombre') String? firstName,@JsonKey(name: 'apellido') String? lastName, String? email
});




}
/// @nodoc
class _$OperatingExpenseRemoteUserDtoCopyWithImpl<$Res>
    implements $OperatingExpenseRemoteUserDtoCopyWith<$Res> {
  _$OperatingExpenseRemoteUserDtoCopyWithImpl(this._self, this._then);

  final OperatingExpenseRemoteUserDto _self;
  final $Res Function(OperatingExpenseRemoteUserDto) _then;

/// Create a copy of OperatingExpenseRemoteUserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseRemoteUserDto].
extension OperatingExpenseRemoteUserDtoPatterns on OperatingExpenseRemoteUserDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteUserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteUserDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteUserDto value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteUserDto():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseRemoteUserDto value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteUserDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'nombre')  String? firstName, @JsonKey(name: 'apellido')  String? lastName,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteUserDto() when $default != null:
return $default(_that.firstName,_that.lastName,_that.email);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'nombre')  String? firstName, @JsonKey(name: 'apellido')  String? lastName,  String? email)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteUserDto():
return $default(_that.firstName,_that.lastName,_that.email);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'nombre')  String? firstName, @JsonKey(name: 'apellido')  String? lastName,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteUserDto() when $default != null:
return $default(_that.firstName,_that.lastName,_that.email);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _OperatingExpenseRemoteUserDto implements OperatingExpenseRemoteUserDto {
  const _OperatingExpenseRemoteUserDto({@JsonKey(name: 'nombre') this.firstName, @JsonKey(name: 'apellido') this.lastName, this.email});
  factory _OperatingExpenseRemoteUserDto.fromJson(Map<String, dynamic> json) => _$OperatingExpenseRemoteUserDtoFromJson(json);

@override@JsonKey(name: 'nombre') final  String? firstName;
@override@JsonKey(name: 'apellido') final  String? lastName;
@override final  String? email;

/// Create a copy of OperatingExpenseRemoteUserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseRemoteUserDtoCopyWith<_OperatingExpenseRemoteUserDto> get copyWith => __$OperatingExpenseRemoteUserDtoCopyWithImpl<_OperatingExpenseRemoteUserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OperatingExpenseRemoteUserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseRemoteUserDto&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,email);

@override
String toString() {
  return 'OperatingExpenseRemoteUserDto(firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseRemoteUserDtoCopyWith<$Res> implements $OperatingExpenseRemoteUserDtoCopyWith<$Res> {
  factory _$OperatingExpenseRemoteUserDtoCopyWith(_OperatingExpenseRemoteUserDto value, $Res Function(_OperatingExpenseRemoteUserDto) _then) = __$OperatingExpenseRemoteUserDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'nombre') String? firstName,@JsonKey(name: 'apellido') String? lastName, String? email
});




}
/// @nodoc
class __$OperatingExpenseRemoteUserDtoCopyWithImpl<$Res>
    implements _$OperatingExpenseRemoteUserDtoCopyWith<$Res> {
  __$OperatingExpenseRemoteUserDtoCopyWithImpl(this._self, this._then);

  final _OperatingExpenseRemoteUserDto _self;
  final $Res Function(_OperatingExpenseRemoteUserDto) _then;

/// Create a copy of OperatingExpenseRemoteUserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,}) {
  return _then(_OperatingExpenseRemoteUserDto(
firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OperatingExpenseRemoteCatalogType {

@JsonKey(name: 'valor') String get type;@JsonKey(name: 'categorias') List<OperatingExpenseRemoteCategory> get categories;
/// Create a copy of OperatingExpenseRemoteCatalogType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseRemoteCatalogTypeCopyWith<OperatingExpenseRemoteCatalogType> get copyWith => _$OperatingExpenseRemoteCatalogTypeCopyWithImpl<OperatingExpenseRemoteCatalogType>(this as OperatingExpenseRemoteCatalogType, _$identity);

  /// Serializes this OperatingExpenseRemoteCatalogType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseRemoteCatalogType&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'OperatingExpenseRemoteCatalogType(type: $type, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseRemoteCatalogTypeCopyWith<$Res>  {
  factory $OperatingExpenseRemoteCatalogTypeCopyWith(OperatingExpenseRemoteCatalogType value, $Res Function(OperatingExpenseRemoteCatalogType) _then) = _$OperatingExpenseRemoteCatalogTypeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'valor') String type,@JsonKey(name: 'categorias') List<OperatingExpenseRemoteCategory> categories
});




}
/// @nodoc
class _$OperatingExpenseRemoteCatalogTypeCopyWithImpl<$Res>
    implements $OperatingExpenseRemoteCatalogTypeCopyWith<$Res> {
  _$OperatingExpenseRemoteCatalogTypeCopyWithImpl(this._self, this._then);

  final OperatingExpenseRemoteCatalogType _self;
  final $Res Function(OperatingExpenseRemoteCatalogType) _then;

/// Create a copy of OperatingExpenseRemoteCatalogType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? categories = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseRemoteCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseRemoteCatalogType].
extension OperatingExpenseRemoteCatalogTypePatterns on OperatingExpenseRemoteCatalogType {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteCatalogType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCatalogType() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteCatalogType value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCatalogType():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseRemoteCatalogType value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCatalogType() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'valor')  String type, @JsonKey(name: 'categorias')  List<OperatingExpenseRemoteCategory> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCatalogType() when $default != null:
return $default(_that.type,_that.categories);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'valor')  String type, @JsonKey(name: 'categorias')  List<OperatingExpenseRemoteCategory> categories)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCatalogType():
return $default(_that.type,_that.categories);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'valor')  String type, @JsonKey(name: 'categorias')  List<OperatingExpenseRemoteCategory> categories)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCatalogType() when $default != null:
return $default(_that.type,_that.categories);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _OperatingExpenseRemoteCatalogType implements OperatingExpenseRemoteCatalogType {
  const _OperatingExpenseRemoteCatalogType({@JsonKey(name: 'valor') required this.type, @JsonKey(name: 'categorias') required final  List<OperatingExpenseRemoteCategory> categories}): _categories = categories;
  factory _OperatingExpenseRemoteCatalogType.fromJson(Map<String, dynamic> json) => _$OperatingExpenseRemoteCatalogTypeFromJson(json);

@override@JsonKey(name: 'valor') final  String type;
 final  List<OperatingExpenseRemoteCategory> _categories;
@override@JsonKey(name: 'categorias') List<OperatingExpenseRemoteCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of OperatingExpenseRemoteCatalogType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseRemoteCatalogTypeCopyWith<_OperatingExpenseRemoteCatalogType> get copyWith => __$OperatingExpenseRemoteCatalogTypeCopyWithImpl<_OperatingExpenseRemoteCatalogType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OperatingExpenseRemoteCatalogTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseRemoteCatalogType&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'OperatingExpenseRemoteCatalogType(type: $type, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseRemoteCatalogTypeCopyWith<$Res> implements $OperatingExpenseRemoteCatalogTypeCopyWith<$Res> {
  factory _$OperatingExpenseRemoteCatalogTypeCopyWith(_OperatingExpenseRemoteCatalogType value, $Res Function(_OperatingExpenseRemoteCatalogType) _then) = __$OperatingExpenseRemoteCatalogTypeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'valor') String type,@JsonKey(name: 'categorias') List<OperatingExpenseRemoteCategory> categories
});




}
/// @nodoc
class __$OperatingExpenseRemoteCatalogTypeCopyWithImpl<$Res>
    implements _$OperatingExpenseRemoteCatalogTypeCopyWith<$Res> {
  __$OperatingExpenseRemoteCatalogTypeCopyWithImpl(this._self, this._then);

  final _OperatingExpenseRemoteCatalogType _self;
  final $Res Function(_OperatingExpenseRemoteCatalogType) _then;

/// Create a copy of OperatingExpenseRemoteCatalogType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? categories = null,}) {
  return _then(_OperatingExpenseRemoteCatalogType(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<OperatingExpenseRemoteCategory>,
  ));
}


}


/// @nodoc
mixin _$OperatingExpenseRemoteCategory {

@JsonKey(name: 'valor') String get value;@JsonKey(name: 'etiqueta') String get label;@JsonKey(name: 'personalizada') bool get custom; String? get id;
/// Create a copy of OperatingExpenseRemoteCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingExpenseRemoteCategoryCopyWith<OperatingExpenseRemoteCategory> get copyWith => _$OperatingExpenseRemoteCategoryCopyWithImpl<OperatingExpenseRemoteCategory>(this as OperatingExpenseRemoteCategory, _$identity);

  /// Serializes this OperatingExpenseRemoteCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingExpenseRemoteCategory&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.custom, custom) || other.custom == custom)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,label,custom,id);

@override
String toString() {
  return 'OperatingExpenseRemoteCategory(value: $value, label: $label, custom: $custom, id: $id)';
}


}

/// @nodoc
abstract mixin class $OperatingExpenseRemoteCategoryCopyWith<$Res>  {
  factory $OperatingExpenseRemoteCategoryCopyWith(OperatingExpenseRemoteCategory value, $Res Function(OperatingExpenseRemoteCategory) _then) = _$OperatingExpenseRemoteCategoryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'valor') String value,@JsonKey(name: 'etiqueta') String label,@JsonKey(name: 'personalizada') bool custom, String? id
});




}
/// @nodoc
class _$OperatingExpenseRemoteCategoryCopyWithImpl<$Res>
    implements $OperatingExpenseRemoteCategoryCopyWith<$Res> {
  _$OperatingExpenseRemoteCategoryCopyWithImpl(this._self, this._then);

  final OperatingExpenseRemoteCategory _self;
  final $Res Function(OperatingExpenseRemoteCategory) _then;

/// Create a copy of OperatingExpenseRemoteCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,Object? custom = null,Object? id = freezed,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingExpenseRemoteCategory].
extension OperatingExpenseRemoteCategoryPatterns on OperatingExpenseRemoteCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCategory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingExpenseRemoteCategory value)  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCategory():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingExpenseRemoteCategory value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCategory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'valor')  String value, @JsonKey(name: 'etiqueta')  String label, @JsonKey(name: 'personalizada')  bool custom,  String? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCategory() when $default != null:
return $default(_that.value,_that.label,_that.custom,_that.id);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'valor')  String value, @JsonKey(name: 'etiqueta')  String label, @JsonKey(name: 'personalizada')  bool custom,  String? id)  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCategory():
return $default(_that.value,_that.label,_that.custom,_that.id);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'valor')  String value, @JsonKey(name: 'etiqueta')  String label, @JsonKey(name: 'personalizada')  bool custom,  String? id)?  $default,) {final _that = this;
switch (_that) {
case _OperatingExpenseRemoteCategory() when $default != null:
return $default(_that.value,_that.label,_that.custom,_that.id);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _OperatingExpenseRemoteCategory implements OperatingExpenseRemoteCategory {
  const _OperatingExpenseRemoteCategory({@JsonKey(name: 'valor') required this.value, @JsonKey(name: 'etiqueta') required this.label, @JsonKey(name: 'personalizada') required this.custom, this.id});
  factory _OperatingExpenseRemoteCategory.fromJson(Map<String, dynamic> json) => _$OperatingExpenseRemoteCategoryFromJson(json);

@override@JsonKey(name: 'valor') final  String value;
@override@JsonKey(name: 'etiqueta') final  String label;
@override@JsonKey(name: 'personalizada') final  bool custom;
@override final  String? id;

/// Create a copy of OperatingExpenseRemoteCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingExpenseRemoteCategoryCopyWith<_OperatingExpenseRemoteCategory> get copyWith => __$OperatingExpenseRemoteCategoryCopyWithImpl<_OperatingExpenseRemoteCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OperatingExpenseRemoteCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingExpenseRemoteCategory&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.custom, custom) || other.custom == custom)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,label,custom,id);

@override
String toString() {
  return 'OperatingExpenseRemoteCategory(value: $value, label: $label, custom: $custom, id: $id)';
}


}

/// @nodoc
abstract mixin class _$OperatingExpenseRemoteCategoryCopyWith<$Res> implements $OperatingExpenseRemoteCategoryCopyWith<$Res> {
  factory _$OperatingExpenseRemoteCategoryCopyWith(_OperatingExpenseRemoteCategory value, $Res Function(_OperatingExpenseRemoteCategory) _then) = __$OperatingExpenseRemoteCategoryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'valor') String value,@JsonKey(name: 'etiqueta') String label,@JsonKey(name: 'personalizada') bool custom, String? id
});




}
/// @nodoc
class __$OperatingExpenseRemoteCategoryCopyWithImpl<$Res>
    implements _$OperatingExpenseRemoteCategoryCopyWith<$Res> {
  __$OperatingExpenseRemoteCategoryCopyWithImpl(this._self, this._then);

  final _OperatingExpenseRemoteCategory _self;
  final $Res Function(_OperatingExpenseRemoteCategory) _then;

/// Create a copy of OperatingExpenseRemoteCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,Object? custom = null,Object? id = freezed,}) {
  return _then(_OperatingExpenseRemoteCategory(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,custom: null == custom ? _self.custom : custom // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
