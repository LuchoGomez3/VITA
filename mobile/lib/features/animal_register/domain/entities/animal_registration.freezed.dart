// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_registration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalRegistration {

/// Numero de caravana RFID individual.
 String get rfidTagNumber;/// Numero visual de caravana mostrado al usuario.
 String get visualTag;/// Sexo del animal.
 AnimalSex get sex;/// Raza declarada al momento del alta.
 String get breed;/// Fecha de nacimiento del animal.
 DateTime get birthDate;/// ID del lote/potrero donde queda ubicado el animal.
 String get lotId;/// Nombre visible del lote usado para resumenes de UI.
 String get lotName;/// ID del establecimiento al que pertenece el animal.
 String get establishmentId;/// ID de la categoria productiva del animal.
 String get categoryId;/// Nombre visible de la categoria usado para resumenes de UI.
 String get categoryName;/// Peso inicial registrado junto con el alta.
 double get initialWeight;/// ID de la madre, cuando se selecciona genealogia.
 String? get motherId;/// ID del padre, cuando se selecciona genealogia.
 String? get fatherId;/// Pelaje declarado, si el formulario lo captura.
 String? get coat;/// Observaciones libres del registro.
 String? get observations;/// Metodo con el que se obtuvo el peso inicial.
 AnimalWeighingMethod get weighingMethod;/// Fecha/hora del pesaje inicial. Si no viene, data puede completar una.
 DateTime? get weighingDate;
/// Create a copy of AnimalRegistration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalRegistrationCopyWith<AnimalRegistration> get copyWith => _$AnimalRegistrationCopyWithImpl<AnimalRegistration>(this as AnimalRegistration, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalRegistration&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.initialWeight, initialWeight) || other.initialWeight == initialWeight)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,rfidTagNumber,visualTag,sex,breed,birthDate,lotId,lotName,establishmentId,categoryId,categoryName,initialWeight,motherId,fatherId,coat,observations,weighingMethod,weighingDate);

@override
String toString() {
  return 'AnimalRegistration(rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, birthDate: $birthDate, lotId: $lotId, lotName: $lotName, establishmentId: $establishmentId, categoryId: $categoryId, categoryName: $categoryName, initialWeight: $initialWeight, motherId: $motherId, fatherId: $fatherId, coat: $coat, observations: $observations, weighingMethod: $weighingMethod, weighingDate: $weighingDate)';
}


}

/// @nodoc
abstract mixin class $AnimalRegistrationCopyWith<$Res>  {
  factory $AnimalRegistrationCopyWith(AnimalRegistration value, $Res Function(AnimalRegistration) _then) = _$AnimalRegistrationCopyWithImpl;
@useResult
$Res call({
 String rfidTagNumber, String visualTag, AnimalSex sex, String breed, DateTime birthDate, String lotId, String lotName, String establishmentId, String categoryId, String categoryName, double initialWeight, String? motherId, String? fatherId, String? coat, String? observations, AnimalWeighingMethod weighingMethod, DateTime? weighingDate
});




}
/// @nodoc
class _$AnimalRegistrationCopyWithImpl<$Res>
    implements $AnimalRegistrationCopyWith<$Res> {
  _$AnimalRegistrationCopyWithImpl(this._self, this._then);

  final AnimalRegistration _self;
  final $Res Function(AnimalRegistration) _then;

/// Create a copy of AnimalRegistration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? lotId = null,Object? lotName = null,Object? establishmentId = null,Object? categoryId = null,Object? categoryName = null,Object? initialWeight = null,Object? motherId = freezed,Object? fatherId = freezed,Object? coat = freezed,Object? observations = freezed,Object? weighingMethod = null,Object? weighingDate = freezed,}) {
  return _then(_self.copyWith(
rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,initialWeight: null == initialWeight ? _self.initialWeight : initialWeight // ignore: cast_nullable_to_non_nullable
as double,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,coat: freezed == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,weighingMethod: null == weighingMethod ? _self.weighingMethod : weighingMethod // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,weighingDate: freezed == weighingDate ? _self.weighingDate : weighingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalRegistration].
extension AnimalRegistrationPatterns on AnimalRegistration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalRegistration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalRegistration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalRegistration value)  $default,){
final _that = this;
switch (_that) {
case _AnimalRegistration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalRegistration value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalRegistration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String lotId,  String lotName,  String establishmentId,  String categoryId,  String categoryName,  double initialWeight,  String? motherId,  String? fatherId,  String? coat,  String? observations,  AnimalWeighingMethod weighingMethod,  DateTime? weighingDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalRegistration() when $default != null:
return $default(_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.lotId,_that.lotName,_that.establishmentId,_that.categoryId,_that.categoryName,_that.initialWeight,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.weighingMethod,_that.weighingDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String lotId,  String lotName,  String establishmentId,  String categoryId,  String categoryName,  double initialWeight,  String? motherId,  String? fatherId,  String? coat,  String? observations,  AnimalWeighingMethod weighingMethod,  DateTime? weighingDate)  $default,) {final _that = this;
switch (_that) {
case _AnimalRegistration():
return $default(_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.lotId,_that.lotName,_that.establishmentId,_that.categoryId,_that.categoryName,_that.initialWeight,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.weighingMethod,_that.weighingDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String lotId,  String lotName,  String establishmentId,  String categoryId,  String categoryName,  double initialWeight,  String? motherId,  String? fatherId,  String? coat,  String? observations,  AnimalWeighingMethod weighingMethod,  DateTime? weighingDate)?  $default,) {final _that = this;
switch (_that) {
case _AnimalRegistration() when $default != null:
return $default(_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.lotId,_that.lotName,_that.establishmentId,_that.categoryId,_that.categoryName,_that.initialWeight,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.weighingMethod,_that.weighingDate);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalRegistration implements AnimalRegistration {
  const _AnimalRegistration({required this.rfidTagNumber, required this.visualTag, required this.sex, required this.breed, required this.birthDate, required this.lotId, required this.lotName, required this.establishmentId, required this.categoryId, required this.categoryName, required this.initialWeight, this.motherId, this.fatherId, this.coat, this.observations, this.weighingMethod = AnimalWeighingMethod.manual, this.weighingDate});
  

/// Numero de caravana RFID individual.
@override final  String rfidTagNumber;
/// Numero visual de caravana mostrado al usuario.
@override final  String visualTag;
/// Sexo del animal.
@override final  AnimalSex sex;
/// Raza declarada al momento del alta.
@override final  String breed;
/// Fecha de nacimiento del animal.
@override final  DateTime birthDate;
/// ID del lote/potrero donde queda ubicado el animal.
@override final  String lotId;
/// Nombre visible del lote usado para resumenes de UI.
@override final  String lotName;
/// ID del establecimiento al que pertenece el animal.
@override final  String establishmentId;
/// ID de la categoria productiva del animal.
@override final  String categoryId;
/// Nombre visible de la categoria usado para resumenes de UI.
@override final  String categoryName;
/// Peso inicial registrado junto con el alta.
@override final  double initialWeight;
/// ID de la madre, cuando se selecciona genealogia.
@override final  String? motherId;
/// ID del padre, cuando se selecciona genealogia.
@override final  String? fatherId;
/// Pelaje declarado, si el formulario lo captura.
@override final  String? coat;
/// Observaciones libres del registro.
@override final  String? observations;
/// Metodo con el que se obtuvo el peso inicial.
@override@JsonKey() final  AnimalWeighingMethod weighingMethod;
/// Fecha/hora del pesaje inicial. Si no viene, data puede completar una.
@override final  DateTime? weighingDate;

/// Create a copy of AnimalRegistration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalRegistrationCopyWith<_AnimalRegistration> get copyWith => __$AnimalRegistrationCopyWithImpl<_AnimalRegistration>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalRegistration&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.initialWeight, initialWeight) || other.initialWeight == initialWeight)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,rfidTagNumber,visualTag,sex,breed,birthDate,lotId,lotName,establishmentId,categoryId,categoryName,initialWeight,motherId,fatherId,coat,observations,weighingMethod,weighingDate);

@override
String toString() {
  return 'AnimalRegistration(rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, birthDate: $birthDate, lotId: $lotId, lotName: $lotName, establishmentId: $establishmentId, categoryId: $categoryId, categoryName: $categoryName, initialWeight: $initialWeight, motherId: $motherId, fatherId: $fatherId, coat: $coat, observations: $observations, weighingMethod: $weighingMethod, weighingDate: $weighingDate)';
}


}

/// @nodoc
abstract mixin class _$AnimalRegistrationCopyWith<$Res> implements $AnimalRegistrationCopyWith<$Res> {
  factory _$AnimalRegistrationCopyWith(_AnimalRegistration value, $Res Function(_AnimalRegistration) _then) = __$AnimalRegistrationCopyWithImpl;
@override @useResult
$Res call({
 String rfidTagNumber, String visualTag, AnimalSex sex, String breed, DateTime birthDate, String lotId, String lotName, String establishmentId, String categoryId, String categoryName, double initialWeight, String? motherId, String? fatherId, String? coat, String? observations, AnimalWeighingMethod weighingMethod, DateTime? weighingDate
});




}
/// @nodoc
class __$AnimalRegistrationCopyWithImpl<$Res>
    implements _$AnimalRegistrationCopyWith<$Res> {
  __$AnimalRegistrationCopyWithImpl(this._self, this._then);

  final _AnimalRegistration _self;
  final $Res Function(_AnimalRegistration) _then;

/// Create a copy of AnimalRegistration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? lotId = null,Object? lotName = null,Object? establishmentId = null,Object? categoryId = null,Object? categoryName = null,Object? initialWeight = null,Object? motherId = freezed,Object? fatherId = freezed,Object? coat = freezed,Object? observations = freezed,Object? weighingMethod = null,Object? weighingDate = freezed,}) {
  return _then(_AnimalRegistration(
rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,initialWeight: null == initialWeight ? _self.initialWeight : initialWeight // ignore: cast_nullable_to_non_nullable
as double,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,coat: freezed == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,weighingMethod: null == weighingMethod ? _self.weighingMethod : weighingMethod // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,weighingDate: freezed == weighingDate ? _self.weighingDate : weighingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$RegisteredAnimal {

/// UUID generado en mobile y usado tambien como ID de backend.
 String get id;/// Datos de negocio registrados.
 AnimalRegistration get registration;/// Estado local de sincronizacion con backend.
 AnimalSyncStatus get syncStatus;/// Fecha/hora de creacion local del registro.
 DateTime get createdAt;/// Fecha/hora de ultima modificacion de negocio.
 DateTime get updatedAt;/// Destino visible para pantallas de exito o resumen.
 String get displayDestination;/// Categoria visible para pantallas de exito o resumen.
 String get displayCategory;/// Codigo de error devuelto por backend cuando el sync queda rechazado.
 String? get syncErrorCode;
/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisteredAnimalCopyWith<RegisteredAnimal> get copyWith => _$RegisteredAnimalCopyWithImpl<RegisteredAnimal>(this as RegisteredAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisteredAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.displayDestination, displayDestination) || other.displayDestination == displayDestination)&&(identical(other.displayCategory, displayCategory) || other.displayCategory == displayCategory)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,registration,syncStatus,createdAt,updatedAt,displayDestination,displayCategory,syncErrorCode);

@override
String toString() {
  return 'RegisteredAnimal(id: $id, registration: $registration, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt, displayDestination: $displayDestination, displayCategory: $displayCategory, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $RegisteredAnimalCopyWith<$Res>  {
  factory $RegisteredAnimalCopyWith(RegisteredAnimal value, $Res Function(RegisteredAnimal) _then) = _$RegisteredAnimalCopyWithImpl;
@useResult
$Res call({
 String id, AnimalRegistration registration, AnimalSyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, String displayDestination, String displayCategory, String? syncErrorCode
});


$AnimalRegistrationCopyWith<$Res> get registration;

}
/// @nodoc
class _$RegisteredAnimalCopyWithImpl<$Res>
    implements $RegisteredAnimalCopyWith<$Res> {
  _$RegisteredAnimalCopyWithImpl(this._self, this._then);

  final RegisteredAnimal _self;
  final $Res Function(RegisteredAnimal) _then;

/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? registration = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? displayDestination = null,Object? displayCategory = null,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,registration: null == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as AnimalRegistration,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,displayDestination: null == displayDestination ? _self.displayDestination : displayDestination // ignore: cast_nullable_to_non_nullable
as String,displayCategory: null == displayCategory ? _self.displayCategory : displayCategory // ignore: cast_nullable_to_non_nullable
as String,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalRegistrationCopyWith<$Res> get registration {
  
  return $AnimalRegistrationCopyWith<$Res>(_self.registration, (value) {
    return _then(_self.copyWith(registration: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegisteredAnimal].
extension RegisteredAnimalPatterns on RegisteredAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisteredAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisteredAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisteredAnimal value)  $default,){
final _that = this;
switch (_that) {
case _RegisteredAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisteredAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _RegisteredAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AnimalRegistration registration,  AnimalSyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  String displayDestination,  String displayCategory,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisteredAnimal() when $default != null:
return $default(_that.id,_that.registration,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.displayDestination,_that.displayCategory,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AnimalRegistration registration,  AnimalSyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  String displayDestination,  String displayCategory,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _RegisteredAnimal():
return $default(_that.id,_that.registration,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.displayDestination,_that.displayCategory,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AnimalRegistration registration,  AnimalSyncStatus syncStatus,  DateTime createdAt,  DateTime updatedAt,  String displayDestination,  String displayCategory,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _RegisteredAnimal() when $default != null:
return $default(_that.id,_that.registration,_that.syncStatus,_that.createdAt,_that.updatedAt,_that.displayDestination,_that.displayCategory,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _RegisteredAnimal implements RegisteredAnimal {
  const _RegisteredAnimal({required this.id, required this.registration, required this.syncStatus, required this.createdAt, required this.updatedAt, required this.displayDestination, required this.displayCategory, this.syncErrorCode});
  

/// UUID generado en mobile y usado tambien como ID de backend.
@override final  String id;
/// Datos de negocio registrados.
@override final  AnimalRegistration registration;
/// Estado local de sincronizacion con backend.
@override final  AnimalSyncStatus syncStatus;
/// Fecha/hora de creacion local del registro.
@override final  DateTime createdAt;
/// Fecha/hora de ultima modificacion de negocio.
@override final  DateTime updatedAt;
/// Destino visible para pantallas de exito o resumen.
@override final  String displayDestination;
/// Categoria visible para pantallas de exito o resumen.
@override final  String displayCategory;
/// Codigo de error devuelto por backend cuando el sync queda rechazado.
@override final  String? syncErrorCode;

/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisteredAnimalCopyWith<_RegisteredAnimal> get copyWith => __$RegisteredAnimalCopyWithImpl<_RegisteredAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisteredAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.displayDestination, displayDestination) || other.displayDestination == displayDestination)&&(identical(other.displayCategory, displayCategory) || other.displayCategory == displayCategory)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,registration,syncStatus,createdAt,updatedAt,displayDestination,displayCategory,syncErrorCode);

@override
String toString() {
  return 'RegisteredAnimal(id: $id, registration: $registration, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt, displayDestination: $displayDestination, displayCategory: $displayCategory, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$RegisteredAnimalCopyWith<$Res> implements $RegisteredAnimalCopyWith<$Res> {
  factory _$RegisteredAnimalCopyWith(_RegisteredAnimal value, $Res Function(_RegisteredAnimal) _then) = __$RegisteredAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, AnimalRegistration registration, AnimalSyncStatus syncStatus, DateTime createdAt, DateTime updatedAt, String displayDestination, String displayCategory, String? syncErrorCode
});


@override $AnimalRegistrationCopyWith<$Res> get registration;

}
/// @nodoc
class __$RegisteredAnimalCopyWithImpl<$Res>
    implements _$RegisteredAnimalCopyWith<$Res> {
  __$RegisteredAnimalCopyWithImpl(this._self, this._then);

  final _RegisteredAnimal _self;
  final $Res Function(_RegisteredAnimal) _then;

/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? registration = null,Object? syncStatus = null,Object? createdAt = null,Object? updatedAt = null,Object? displayDestination = null,Object? displayCategory = null,Object? syncErrorCode = freezed,}) {
  return _then(_RegisteredAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,registration: null == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as AnimalRegistration,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,displayDestination: null == displayDestination ? _self.displayDestination : displayDestination // ignore: cast_nullable_to_non_nullable
as String,displayCategory: null == displayCategory ? _self.displayCategory : displayCategory // ignore: cast_nullable_to_non_nullable
as String,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalRegistrationCopyWith<$Res> get registration {
  
  return $AnimalRegistrationCopyWith<$Res>(_self.registration, (value) {
    return _then(_self.copyWith(registration: value));
  });
}
}

// dart format on
