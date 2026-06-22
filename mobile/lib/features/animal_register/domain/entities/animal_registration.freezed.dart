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

 String get rfidTagNumber; AnimalSex get sex; String get breed; DateTime get birthDate; String get lotId; String get establishmentId; double get initialWeight; String? get visualTag; String? get motherId; String? get fatherId; String? get categoryId; String? get coat; String? get observations; AnimalWeighingMethod get weighingMethod; DateTime? get weighingDate;
/// Create a copy of AnimalRegistration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalRegistrationCopyWith<AnimalRegistration> get copyWith => _$AnimalRegistrationCopyWithImpl<AnimalRegistration>(this as AnimalRegistration, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalRegistration&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.initialWeight, initialWeight) || other.initialWeight == initialWeight)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,rfidTagNumber,sex,breed,birthDate,lotId,establishmentId,initialWeight,visualTag,motherId,fatherId,categoryId,coat,observations,weighingMethod,weighingDate);

@override
String toString() {
  return 'AnimalRegistration(rfidTagNumber: $rfidTagNumber, sex: $sex, breed: $breed, birthDate: $birthDate, lotId: $lotId, establishmentId: $establishmentId, initialWeight: $initialWeight, visualTag: $visualTag, motherId: $motherId, fatherId: $fatherId, categoryId: $categoryId, coat: $coat, observations: $observations, weighingMethod: $weighingMethod, weighingDate: $weighingDate)';
}


}

/// @nodoc
abstract mixin class $AnimalRegistrationCopyWith<$Res>  {
  factory $AnimalRegistrationCopyWith(AnimalRegistration value, $Res Function(AnimalRegistration) _then) = _$AnimalRegistrationCopyWithImpl;
@useResult
$Res call({
 String rfidTagNumber, AnimalSex sex, String breed, DateTime birthDate, String lotId, String establishmentId, double initialWeight, String? visualTag, String? motherId, String? fatherId, String? categoryId, String? coat, String? observations, AnimalWeighingMethod weighingMethod, DateTime? weighingDate
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
@pragma('vm:prefer-inline') @override $Res call({Object? rfidTagNumber = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? lotId = null,Object? establishmentId = null,Object? initialWeight = null,Object? visualTag = freezed,Object? motherId = freezed,Object? fatherId = freezed,Object? categoryId = freezed,Object? coat = freezed,Object? observations = freezed,Object? weighingMethod = null,Object? weighingDate = freezed,}) {
  return _then(_self.copyWith(
rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,initialWeight: null == initialWeight ? _self.initialWeight : initialWeight // ignore: cast_nullable_to_non_nullable
as double,visualTag: freezed == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String?,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rfidTagNumber,  AnimalSex sex,  String breed,  DateTime birthDate,  String lotId,  String establishmentId,  double initialWeight,  String? visualTag,  String? motherId,  String? fatherId,  String? categoryId,  String? coat,  String? observations,  AnimalWeighingMethod weighingMethod,  DateTime? weighingDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalRegistration() when $default != null:
return $default(_that.rfidTagNumber,_that.sex,_that.breed,_that.birthDate,_that.lotId,_that.establishmentId,_that.initialWeight,_that.visualTag,_that.motherId,_that.fatherId,_that.categoryId,_that.coat,_that.observations,_that.weighingMethod,_that.weighingDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rfidTagNumber,  AnimalSex sex,  String breed,  DateTime birthDate,  String lotId,  String establishmentId,  double initialWeight,  String? visualTag,  String? motherId,  String? fatherId,  String? categoryId,  String? coat,  String? observations,  AnimalWeighingMethod weighingMethod,  DateTime? weighingDate)  $default,) {final _that = this;
switch (_that) {
case _AnimalRegistration():
return $default(_that.rfidTagNumber,_that.sex,_that.breed,_that.birthDate,_that.lotId,_that.establishmentId,_that.initialWeight,_that.visualTag,_that.motherId,_that.fatherId,_that.categoryId,_that.coat,_that.observations,_that.weighingMethod,_that.weighingDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rfidTagNumber,  AnimalSex sex,  String breed,  DateTime birthDate,  String lotId,  String establishmentId,  double initialWeight,  String? visualTag,  String? motherId,  String? fatherId,  String? categoryId,  String? coat,  String? observations,  AnimalWeighingMethod weighingMethod,  DateTime? weighingDate)?  $default,) {final _that = this;
switch (_that) {
case _AnimalRegistration() when $default != null:
return $default(_that.rfidTagNumber,_that.sex,_that.breed,_that.birthDate,_that.lotId,_that.establishmentId,_that.initialWeight,_that.visualTag,_that.motherId,_that.fatherId,_that.categoryId,_that.coat,_that.observations,_that.weighingMethod,_that.weighingDate);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalRegistration implements AnimalRegistration {
  const _AnimalRegistration({required this.rfidTagNumber, required this.sex, required this.breed, required this.birthDate, required this.lotId, required this.establishmentId, required this.initialWeight, this.visualTag, this.motherId, this.fatherId, this.categoryId, this.coat, this.observations, this.weighingMethod = AnimalWeighingMethod.manual, this.weighingDate});
  

@override final  String rfidTagNumber;
@override final  AnimalSex sex;
@override final  String breed;
@override final  DateTime birthDate;
@override final  String lotId;
@override final  String establishmentId;
@override final  double initialWeight;
@override final  String? visualTag;
@override final  String? motherId;
@override final  String? fatherId;
@override final  String? categoryId;
@override final  String? coat;
@override final  String? observations;
@override@JsonKey() final  AnimalWeighingMethod weighingMethod;
@override final  DateTime? weighingDate;

/// Create a copy of AnimalRegistration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalRegistrationCopyWith<_AnimalRegistration> get copyWith => __$AnimalRegistrationCopyWithImpl<_AnimalRegistration>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalRegistration&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.initialWeight, initialWeight) || other.initialWeight == initialWeight)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,rfidTagNumber,sex,breed,birthDate,lotId,establishmentId,initialWeight,visualTag,motherId,fatherId,categoryId,coat,observations,weighingMethod,weighingDate);

@override
String toString() {
  return 'AnimalRegistration(rfidTagNumber: $rfidTagNumber, sex: $sex, breed: $breed, birthDate: $birthDate, lotId: $lotId, establishmentId: $establishmentId, initialWeight: $initialWeight, visualTag: $visualTag, motherId: $motherId, fatherId: $fatherId, categoryId: $categoryId, coat: $coat, observations: $observations, weighingMethod: $weighingMethod, weighingDate: $weighingDate)';
}


}

/// @nodoc
abstract mixin class _$AnimalRegistrationCopyWith<$Res> implements $AnimalRegistrationCopyWith<$Res> {
  factory _$AnimalRegistrationCopyWith(_AnimalRegistration value, $Res Function(_AnimalRegistration) _then) = __$AnimalRegistrationCopyWithImpl;
@override @useResult
$Res call({
 String rfidTagNumber, AnimalSex sex, String breed, DateTime birthDate, String lotId, String establishmentId, double initialWeight, String? visualTag, String? motherId, String? fatherId, String? categoryId, String? coat, String? observations, AnimalWeighingMethod weighingMethod, DateTime? weighingDate
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
@override @pragma('vm:prefer-inline') $Res call({Object? rfidTagNumber = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? lotId = null,Object? establishmentId = null,Object? initialWeight = null,Object? visualTag = freezed,Object? motherId = freezed,Object? fatherId = freezed,Object? categoryId = freezed,Object? coat = freezed,Object? observations = freezed,Object? weighingMethod = null,Object? weighingDate = freezed,}) {
  return _then(_AnimalRegistration(
rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,initialWeight: null == initialWeight ? _self.initialWeight : initialWeight // ignore: cast_nullable_to_non_nullable
as double,visualTag: freezed == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String?,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
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

 String get id; AnimalRegistration get registration; AnimalSyncStatus get syncStatus; String? get syncErrorCode;
/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisteredAnimalCopyWith<RegisteredAnimal> get copyWith => _$RegisteredAnimalCopyWithImpl<RegisteredAnimal>(this as RegisteredAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisteredAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,registration,syncStatus,syncErrorCode);

@override
String toString() {
  return 'RegisteredAnimal(id: $id, registration: $registration, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $RegisteredAnimalCopyWith<$Res>  {
  factory $RegisteredAnimalCopyWith(RegisteredAnimal value, $Res Function(RegisteredAnimal) _then) = _$RegisteredAnimalCopyWithImpl;
@useResult
$Res call({
 String id, AnimalRegistration registration, AnimalSyncStatus syncStatus, String? syncErrorCode
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? registration = null,Object? syncStatus = null,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,registration: null == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as AnimalRegistration,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AnimalRegistration registration,  AnimalSyncStatus syncStatus,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisteredAnimal() when $default != null:
return $default(_that.id,_that.registration,_that.syncStatus,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AnimalRegistration registration,  AnimalSyncStatus syncStatus,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _RegisteredAnimal():
return $default(_that.id,_that.registration,_that.syncStatus,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AnimalRegistration registration,  AnimalSyncStatus syncStatus,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _RegisteredAnimal() when $default != null:
return $default(_that.id,_that.registration,_that.syncStatus,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _RegisteredAnimal implements RegisteredAnimal {
  const _RegisteredAnimal({required this.id, required this.registration, required this.syncStatus, this.syncErrorCode});
  

@override final  String id;
@override final  AnimalRegistration registration;
@override final  AnimalSyncStatus syncStatus;
@override final  String? syncErrorCode;

/// Create a copy of RegisteredAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisteredAnimalCopyWith<_RegisteredAnimal> get copyWith => __$RegisteredAnimalCopyWithImpl<_RegisteredAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisteredAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,registration,syncStatus,syncErrorCode);

@override
String toString() {
  return 'RegisteredAnimal(id: $id, registration: $registration, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$RegisteredAnimalCopyWith<$Res> implements $RegisteredAnimalCopyWith<$Res> {
  factory _$RegisteredAnimalCopyWith(_RegisteredAnimal value, $Res Function(_RegisteredAnimal) _then) = __$RegisteredAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, AnimalRegistration registration, AnimalSyncStatus syncStatus, String? syncErrorCode
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? registration = null,Object? syncStatus = null,Object? syncErrorCode = freezed,}) {
  return _then(_RegisteredAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,registration: null == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as AnimalRegistration,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
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
