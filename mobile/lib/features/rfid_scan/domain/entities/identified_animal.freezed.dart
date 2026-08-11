// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identified_animal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IdentifiedAnimal {

/// UUID local y remoto del animal.
 String get id;/// Numero oficial de la caravana electronica.
 String get rfidTagNumber;/// Numero de caravana visual mostrado en campo.
 String get visualTag;/// Sexo declarado del animal.
 IdentifiedAnimalSex get sex;/// Raza declarada del animal.
 String get breed;/// Nombre visible de la categoria productiva.
 String get categoryName;/// Nombre visible del lote actual.
 String get lotName;/// Ultima actualizacion conocida en la base local.
 DateTime get updatedAt;
/// Create a copy of IdentifiedAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentifiedAnimalCopyWith<IdentifiedAnimal> get copyWith => _$IdentifiedAnimalCopyWithImpl<IdentifiedAnimal>(this as IdentifiedAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentifiedAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,rfidTagNumber,visualTag,sex,breed,categoryName,lotName,updatedAt);

@override
String toString() {
  return 'IdentifiedAnimal(id: $id, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, categoryName: $categoryName, lotName: $lotName, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $IdentifiedAnimalCopyWith<$Res>  {
  factory $IdentifiedAnimalCopyWith(IdentifiedAnimal value, $Res Function(IdentifiedAnimal) _then) = _$IdentifiedAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String rfidTagNumber, String visualTag, IdentifiedAnimalSex sex, String breed, String categoryName, String lotName, DateTime updatedAt
});




}
/// @nodoc
class _$IdentifiedAnimalCopyWithImpl<$Res>
    implements $IdentifiedAnimalCopyWith<$Res> {
  _$IdentifiedAnimalCopyWithImpl(this._self, this._then);

  final IdentifiedAnimal _self;
  final $Res Function(IdentifiedAnimal) _then;

/// Create a copy of IdentifiedAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? categoryName = null,Object? lotName = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as IdentifiedAnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [IdentifiedAnimal].
extension IdentifiedAnimalPatterns on IdentifiedAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdentifiedAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdentifiedAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdentifiedAnimal value)  $default,){
final _that = this;
switch (_that) {
case _IdentifiedAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdentifiedAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _IdentifiedAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rfidTagNumber,  String visualTag,  IdentifiedAnimalSex sex,  String breed,  String categoryName,  String lotName,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdentifiedAnimal() when $default != null:
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.categoryName,_that.lotName,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rfidTagNumber,  String visualTag,  IdentifiedAnimalSex sex,  String breed,  String categoryName,  String lotName,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _IdentifiedAnimal():
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.categoryName,_that.lotName,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rfidTagNumber,  String visualTag,  IdentifiedAnimalSex sex,  String breed,  String categoryName,  String lotName,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _IdentifiedAnimal() when $default != null:
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.categoryName,_that.lotName,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _IdentifiedAnimal implements IdentifiedAnimal {
  const _IdentifiedAnimal({required this.id, required this.rfidTagNumber, required this.visualTag, required this.sex, required this.breed, required this.categoryName, required this.lotName, required this.updatedAt});
  

/// UUID local y remoto del animal.
@override final  String id;
/// Numero oficial de la caravana electronica.
@override final  String rfidTagNumber;
/// Numero de caravana visual mostrado en campo.
@override final  String visualTag;
/// Sexo declarado del animal.
@override final  IdentifiedAnimalSex sex;
/// Raza declarada del animal.
@override final  String breed;
/// Nombre visible de la categoria productiva.
@override final  String categoryName;
/// Nombre visible del lote actual.
@override final  String lotName;
/// Ultima actualizacion conocida en la base local.
@override final  DateTime updatedAt;

/// Create a copy of IdentifiedAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentifiedAnimalCopyWith<_IdentifiedAnimal> get copyWith => __$IdentifiedAnimalCopyWithImpl<_IdentifiedAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentifiedAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,rfidTagNumber,visualTag,sex,breed,categoryName,lotName,updatedAt);

@override
String toString() {
  return 'IdentifiedAnimal(id: $id, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, categoryName: $categoryName, lotName: $lotName, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$IdentifiedAnimalCopyWith<$Res> implements $IdentifiedAnimalCopyWith<$Res> {
  factory _$IdentifiedAnimalCopyWith(_IdentifiedAnimal value, $Res Function(_IdentifiedAnimal) _then) = __$IdentifiedAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String rfidTagNumber, String visualTag, IdentifiedAnimalSex sex, String breed, String categoryName, String lotName, DateTime updatedAt
});




}
/// @nodoc
class __$IdentifiedAnimalCopyWithImpl<$Res>
    implements _$IdentifiedAnimalCopyWith<$Res> {
  __$IdentifiedAnimalCopyWithImpl(this._self, this._then);

  final _IdentifiedAnimal _self;
  final $Res Function(_IdentifiedAnimal) _then;

/// Create a copy of IdentifiedAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? categoryName = null,Object? lotName = null,Object? updatedAt = null,}) {
  return _then(_IdentifiedAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as IdentifiedAnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
