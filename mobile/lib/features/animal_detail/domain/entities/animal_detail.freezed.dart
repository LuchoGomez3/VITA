// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalDetail {

/// UUID generado por mobile y usado tambien por backend.
 String get id;/// Numero RFID oficial del animal.
 String get rfidTagNumber;/// Numero visual de caravana mostrado en UI.
 String get visualTag;/// Sexo del animal.
 AnimalSex get sex;/// Raza declarada del animal.
 String get breed;/// Fecha de nacimiento.
 DateTime get birthDate;/// ID backend de la categoria productiva.
 String get categoryId;/// Nombre visible de la categoria si existe en cache local.
 String get categoryName;/// ID backend del lote/potrero actual.
 String get lotId;/// Nombre visible del lote si existe en cache local.
 String get lotName;/// ID backend del establecimiento.
 String get establishmentId;/// Ultimo peso conocido por la app.
 double get currentWeight;/// Metodo asociado al ultimo peso conocido.
 AnimalWeighingMethod get weighingMethod;/// Fecha del ultimo pesaje conocido.
 DateTime get weighingDate;/// Estado local de sincronizacion con backend.
 AnimalSyncStatus get syncStatus;/// Ultima actualizacion conocida.
 DateTime get updatedAt;/// ID backend de la madre, si existe.
 String? get motherId;/// ID backend del padre, si existe.
 String? get fatherId;/// Pelaje declarado.
 String? get coat;/// Observaciones libres.
 String? get observations;/// Codigo de rechazo de sync guardado localmente.
 String? get syncErrorCode;
/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalDetailCopyWith<AnimalDetail> get copyWith => _$AnimalDetailCopyWithImpl<AnimalDetail>(this as AnimalDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,rfidTagNumber,visualTag,sex,breed,birthDate,categoryId,categoryName,lotId,lotName,establishmentId,currentWeight,weighingMethod,weighingDate,syncStatus,updatedAt,motherId,fatherId,coat,observations,syncErrorCode]);

@override
String toString() {
  return 'AnimalDetail(id: $id, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, birthDate: $birthDate, categoryId: $categoryId, categoryName: $categoryName, lotId: $lotId, lotName: $lotName, establishmentId: $establishmentId, currentWeight: $currentWeight, weighingMethod: $weighingMethod, weighingDate: $weighingDate, syncStatus: $syncStatus, updatedAt: $updatedAt, motherId: $motherId, fatherId: $fatherId, coat: $coat, observations: $observations, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $AnimalDetailCopyWith<$Res>  {
  factory $AnimalDetailCopyWith(AnimalDetail value, $Res Function(AnimalDetail) _then) = _$AnimalDetailCopyWithImpl;
@useResult
$Res call({
 String id, String rfidTagNumber, String visualTag, AnimalSex sex, String breed, DateTime birthDate, String categoryId, String categoryName, String lotId, String lotName, String establishmentId, double currentWeight, AnimalWeighingMethod weighingMethod, DateTime weighingDate, AnimalSyncStatus syncStatus, DateTime updatedAt, String? motherId, String? fatherId, String? coat, String? observations, String? syncErrorCode
});




}
/// @nodoc
class _$AnimalDetailCopyWithImpl<$Res>
    implements $AnimalDetailCopyWith<$Res> {
  _$AnimalDetailCopyWithImpl(this._self, this._then);

  final AnimalDetail _self;
  final $Res Function(AnimalDetail) _then;

/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? categoryId = null,Object? categoryName = null,Object? lotId = null,Object? lotName = null,Object? establishmentId = null,Object? currentWeight = null,Object? weighingMethod = null,Object? weighingDate = null,Object? syncStatus = null,Object? updatedAt = null,Object? motherId = freezed,Object? fatherId = freezed,Object? coat = freezed,Object? observations = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,weighingMethod: null == weighingMethod ? _self.weighingMethod : weighingMethod // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,weighingDate: null == weighingDate ? _self.weighingDate : weighingDate // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,coat: freezed == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalDetail].
extension AnimalDetailPatterns on AnimalDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalDetail value)  $default,){
final _that = this;
switch (_that) {
case _AnimalDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String categoryId,  String categoryName,  String lotId,  String lotName,  String establishmentId,  double currentWeight,  AnimalWeighingMethod weighingMethod,  DateTime weighingDate,  AnimalSyncStatus syncStatus,  DateTime updatedAt,  String? motherId,  String? fatherId,  String? coat,  String? observations,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.categoryId,_that.categoryName,_that.lotId,_that.lotName,_that.establishmentId,_that.currentWeight,_that.weighingMethod,_that.weighingDate,_that.syncStatus,_that.updatedAt,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String categoryId,  String categoryName,  String lotId,  String lotName,  String establishmentId,  double currentWeight,  AnimalWeighingMethod weighingMethod,  DateTime weighingDate,  AnimalSyncStatus syncStatus,  DateTime updatedAt,  String? motherId,  String? fatherId,  String? coat,  String? observations,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _AnimalDetail():
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.categoryId,_that.categoryName,_that.lotId,_that.lotName,_that.establishmentId,_that.currentWeight,_that.weighingMethod,_that.weighingDate,_that.syncStatus,_that.updatedAt,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String categoryId,  String categoryName,  String lotId,  String lotName,  String establishmentId,  double currentWeight,  AnimalWeighingMethod weighingMethod,  DateTime weighingDate,  AnimalSyncStatus syncStatus,  DateTime updatedAt,  String? motherId,  String? fatherId,  String? coat,  String? observations,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.categoryId,_that.categoryName,_that.lotId,_that.lotName,_that.establishmentId,_that.currentWeight,_that.weighingMethod,_that.weighingDate,_that.syncStatus,_that.updatedAt,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalDetail implements AnimalDetail {
  const _AnimalDetail({required this.id, required this.rfidTagNumber, required this.visualTag, required this.sex, required this.breed, required this.birthDate, required this.categoryId, required this.categoryName, required this.lotId, required this.lotName, required this.establishmentId, required this.currentWeight, required this.weighingMethod, required this.weighingDate, required this.syncStatus, required this.updatedAt, this.motherId, this.fatherId, this.coat, this.observations, this.syncErrorCode});
  

/// UUID generado por mobile y usado tambien por backend.
@override final  String id;
/// Numero RFID oficial del animal.
@override final  String rfidTagNumber;
/// Numero visual de caravana mostrado en UI.
@override final  String visualTag;
/// Sexo del animal.
@override final  AnimalSex sex;
/// Raza declarada del animal.
@override final  String breed;
/// Fecha de nacimiento.
@override final  DateTime birthDate;
/// ID backend de la categoria productiva.
@override final  String categoryId;
/// Nombre visible de la categoria si existe en cache local.
@override final  String categoryName;
/// ID backend del lote/potrero actual.
@override final  String lotId;
/// Nombre visible del lote si existe en cache local.
@override final  String lotName;
/// ID backend del establecimiento.
@override final  String establishmentId;
/// Ultimo peso conocido por la app.
@override final  double currentWeight;
/// Metodo asociado al ultimo peso conocido.
@override final  AnimalWeighingMethod weighingMethod;
/// Fecha del ultimo pesaje conocido.
@override final  DateTime weighingDate;
/// Estado local de sincronizacion con backend.
@override final  AnimalSyncStatus syncStatus;
/// Ultima actualizacion conocida.
@override final  DateTime updatedAt;
/// ID backend de la madre, si existe.
@override final  String? motherId;
/// ID backend del padre, si existe.
@override final  String? fatherId;
/// Pelaje declarado.
@override final  String? coat;
/// Observaciones libres.
@override final  String? observations;
/// Codigo de rechazo de sync guardado localmente.
@override final  String? syncErrorCode;

/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalDetailCopyWith<_AnimalDetail> get copyWith => __$AnimalDetailCopyWithImpl<_AnimalDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,rfidTagNumber,visualTag,sex,breed,birthDate,categoryId,categoryName,lotId,lotName,establishmentId,currentWeight,weighingMethod,weighingDate,syncStatus,updatedAt,motherId,fatherId,coat,observations,syncErrorCode]);

@override
String toString() {
  return 'AnimalDetail(id: $id, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, birthDate: $birthDate, categoryId: $categoryId, categoryName: $categoryName, lotId: $lotId, lotName: $lotName, establishmentId: $establishmentId, currentWeight: $currentWeight, weighingMethod: $weighingMethod, weighingDate: $weighingDate, syncStatus: $syncStatus, updatedAt: $updatedAt, motherId: $motherId, fatherId: $fatherId, coat: $coat, observations: $observations, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$AnimalDetailCopyWith<$Res> implements $AnimalDetailCopyWith<$Res> {
  factory _$AnimalDetailCopyWith(_AnimalDetail value, $Res Function(_AnimalDetail) _then) = __$AnimalDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String rfidTagNumber, String visualTag, AnimalSex sex, String breed, DateTime birthDate, String categoryId, String categoryName, String lotId, String lotName, String establishmentId, double currentWeight, AnimalWeighingMethod weighingMethod, DateTime weighingDate, AnimalSyncStatus syncStatus, DateTime updatedAt, String? motherId, String? fatherId, String? coat, String? observations, String? syncErrorCode
});




}
/// @nodoc
class __$AnimalDetailCopyWithImpl<$Res>
    implements _$AnimalDetailCopyWith<$Res> {
  __$AnimalDetailCopyWithImpl(this._self, this._then);

  final _AnimalDetail _self;
  final $Res Function(_AnimalDetail) _then;

/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? categoryId = null,Object? categoryName = null,Object? lotId = null,Object? lotName = null,Object? establishmentId = null,Object? currentWeight = null,Object? weighingMethod = null,Object? weighingDate = null,Object? syncStatus = null,Object? updatedAt = null,Object? motherId = freezed,Object? fatherId = freezed,Object? coat = freezed,Object? observations = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_AnimalDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,weighingMethod: null == weighingMethod ? _self.weighingMethod : weighingMethod // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,weighingDate: null == weighingDate ? _self.weighingDate : weighingDate // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,coat: freezed == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
