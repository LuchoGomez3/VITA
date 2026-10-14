// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_list_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalListEntry {

/// UUID del animal, para abrir su ficha.
 String get id;/// Establecimiento al que pertenece, para filtrar la lista.
 String get establishmentId;/// Número de caravana visual.
 String get visualTag;/// Número RFID oficial (15 dígitos).
 String get rfidTagNumber;/// Raza declarada.
 String get breed;/// Nombre de la categoría productiva, o vacío si no se conoce.
 String get categoryName;/// Nombre del potrero actual, o vacío si no tiene.
 String get lotName;/// Último peso conocido en kg, si hay alguno.
 double? get lastWeightKg;/// Fecha del último peso conocido.
 DateTime? get lastWeighingDate;
/// Create a copy of AnimalListEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalListEntryCopyWith<AnimalListEntry> get copyWith => _$AnimalListEntryCopyWithImpl<AnimalListEntry>(this as AnimalListEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalListEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.lastWeightKg, lastWeightKg) || other.lastWeightKg == lastWeightKg)&&(identical(other.lastWeighingDate, lastWeighingDate) || other.lastWeighingDate == lastWeighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,visualTag,rfidTagNumber,breed,categoryName,lotName,lastWeightKg,lastWeighingDate);

@override
String toString() {
  return 'AnimalListEntry(id: $id, establishmentId: $establishmentId, visualTag: $visualTag, rfidTagNumber: $rfidTagNumber, breed: $breed, categoryName: $categoryName, lotName: $lotName, lastWeightKg: $lastWeightKg, lastWeighingDate: $lastWeighingDate)';
}


}

/// @nodoc
abstract mixin class $AnimalListEntryCopyWith<$Res>  {
  factory $AnimalListEntryCopyWith(AnimalListEntry value, $Res Function(AnimalListEntry) _then) = _$AnimalListEntryCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String visualTag, String rfidTagNumber, String breed, String categoryName, String lotName, double? lastWeightKg, DateTime? lastWeighingDate
});




}
/// @nodoc
class _$AnimalListEntryCopyWithImpl<$Res>
    implements $AnimalListEntryCopyWith<$Res> {
  _$AnimalListEntryCopyWithImpl(this._self, this._then);

  final AnimalListEntry _self;
  final $Res Function(AnimalListEntry) _then;

/// Create a copy of AnimalListEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? visualTag = null,Object? rfidTagNumber = null,Object? breed = null,Object? categoryName = null,Object? lotName = null,Object? lastWeightKg = freezed,Object? lastWeighingDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,lastWeightKg: freezed == lastWeightKg ? _self.lastWeightKg : lastWeightKg // ignore: cast_nullable_to_non_nullable
as double?,lastWeighingDate: freezed == lastWeighingDate ? _self.lastWeighingDate : lastWeighingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalListEntry].
extension AnimalListEntryPatterns on AnimalListEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalListEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalListEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalListEntry value)  $default,){
final _that = this;
switch (_that) {
case _AnimalListEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalListEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalListEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String visualTag,  String rfidTagNumber,  String breed,  String categoryName,  String lotName,  double? lastWeightKg,  DateTime? lastWeighingDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalListEntry() when $default != null:
return $default(_that.id,_that.establishmentId,_that.visualTag,_that.rfidTagNumber,_that.breed,_that.categoryName,_that.lotName,_that.lastWeightKg,_that.lastWeighingDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String visualTag,  String rfidTagNumber,  String breed,  String categoryName,  String lotName,  double? lastWeightKg,  DateTime? lastWeighingDate)  $default,) {final _that = this;
switch (_that) {
case _AnimalListEntry():
return $default(_that.id,_that.establishmentId,_that.visualTag,_that.rfidTagNumber,_that.breed,_that.categoryName,_that.lotName,_that.lastWeightKg,_that.lastWeighingDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String visualTag,  String rfidTagNumber,  String breed,  String categoryName,  String lotName,  double? lastWeightKg,  DateTime? lastWeighingDate)?  $default,) {final _that = this;
switch (_that) {
case _AnimalListEntry() when $default != null:
return $default(_that.id,_that.establishmentId,_that.visualTag,_that.rfidTagNumber,_that.breed,_that.categoryName,_that.lotName,_that.lastWeightKg,_that.lastWeighingDate);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalListEntry implements AnimalListEntry {
  const _AnimalListEntry({required this.id, required this.establishmentId, required this.visualTag, required this.rfidTagNumber, required this.breed, required this.categoryName, required this.lotName, this.lastWeightKg, this.lastWeighingDate});
  

/// UUID del animal, para abrir su ficha.
@override final  String id;
/// Establecimiento al que pertenece, para filtrar la lista.
@override final  String establishmentId;
/// Número de caravana visual.
@override final  String visualTag;
/// Número RFID oficial (15 dígitos).
@override final  String rfidTagNumber;
/// Raza declarada.
@override final  String breed;
/// Nombre de la categoría productiva, o vacío si no se conoce.
@override final  String categoryName;
/// Nombre del potrero actual, o vacío si no tiene.
@override final  String lotName;
/// Último peso conocido en kg, si hay alguno.
@override final  double? lastWeightKg;
/// Fecha del último peso conocido.
@override final  DateTime? lastWeighingDate;

/// Create a copy of AnimalListEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalListEntryCopyWith<_AnimalListEntry> get copyWith => __$AnimalListEntryCopyWithImpl<_AnimalListEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalListEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.lastWeightKg, lastWeightKg) || other.lastWeightKg == lastWeightKg)&&(identical(other.lastWeighingDate, lastWeighingDate) || other.lastWeighingDate == lastWeighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,visualTag,rfidTagNumber,breed,categoryName,lotName,lastWeightKg,lastWeighingDate);

@override
String toString() {
  return 'AnimalListEntry(id: $id, establishmentId: $establishmentId, visualTag: $visualTag, rfidTagNumber: $rfidTagNumber, breed: $breed, categoryName: $categoryName, lotName: $lotName, lastWeightKg: $lastWeightKg, lastWeighingDate: $lastWeighingDate)';
}


}

/// @nodoc
abstract mixin class _$AnimalListEntryCopyWith<$Res> implements $AnimalListEntryCopyWith<$Res> {
  factory _$AnimalListEntryCopyWith(_AnimalListEntry value, $Res Function(_AnimalListEntry) _then) = __$AnimalListEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String visualTag, String rfidTagNumber, String breed, String categoryName, String lotName, double? lastWeightKg, DateTime? lastWeighingDate
});




}
/// @nodoc
class __$AnimalListEntryCopyWithImpl<$Res>
    implements _$AnimalListEntryCopyWith<$Res> {
  __$AnimalListEntryCopyWithImpl(this._self, this._then);

  final _AnimalListEntry _self;
  final $Res Function(_AnimalListEntry) _then;

/// Create a copy of AnimalListEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? visualTag = null,Object? rfidTagNumber = null,Object? breed = null,Object? categoryName = null,Object? lotName = null,Object? lastWeightKg = freezed,Object? lastWeighingDate = freezed,}) {
  return _then(_AnimalListEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,lastWeightKg: freezed == lastWeightKg ? _self.lastWeightKg : lastWeightKg // ignore: cast_nullable_to_non_nullable
as double?,lastWeighingDate: freezed == lastWeighingDate ? _self.lastWeighingDate : lastWeighingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
