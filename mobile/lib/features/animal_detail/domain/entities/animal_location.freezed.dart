// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalLocation {

 String get animalId; String get establishmentId; String get lotId; String get lotName; DateTime get updatedAt;
/// Create a copy of AnimalLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalLocationCopyWith<AnimalLocation> get copyWith => _$AnimalLocationCopyWithImpl<AnimalLocation>(this as AnimalLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalLocation&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,establishmentId,lotId,lotName,updatedAt);

@override
String toString() {
  return 'AnimalLocation(animalId: $animalId, establishmentId: $establishmentId, lotId: $lotId, lotName: $lotName, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AnimalLocationCopyWith<$Res>  {
  factory $AnimalLocationCopyWith(AnimalLocation value, $Res Function(AnimalLocation) _then) = _$AnimalLocationCopyWithImpl;
@useResult
$Res call({
 String animalId, String establishmentId, String lotId, String lotName, DateTime updatedAt
});




}
/// @nodoc
class _$AnimalLocationCopyWithImpl<$Res>
    implements $AnimalLocationCopyWith<$Res> {
  _$AnimalLocationCopyWithImpl(this._self, this._then);

  final AnimalLocation _self;
  final $Res Function(AnimalLocation) _then;

/// Create a copy of AnimalLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animalId = null,Object? establishmentId = null,Object? lotId = null,Object? lotName = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalLocation].
extension AnimalLocationPatterns on AnimalLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalLocation value)  $default,){
final _that = this;
switch (_that) {
case _AnimalLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalLocation value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String animalId,  String establishmentId,  String lotId,  String lotName,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalLocation() when $default != null:
return $default(_that.animalId,_that.establishmentId,_that.lotId,_that.lotName,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String animalId,  String establishmentId,  String lotId,  String lotName,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AnimalLocation():
return $default(_that.animalId,_that.establishmentId,_that.lotId,_that.lotName,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String animalId,  String establishmentId,  String lotId,  String lotName,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AnimalLocation() when $default != null:
return $default(_that.animalId,_that.establishmentId,_that.lotId,_that.lotName,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalLocation implements AnimalLocation {
  const _AnimalLocation({required this.animalId, required this.establishmentId, required this.lotId, required this.lotName, required this.updatedAt});
  

@override final  String animalId;
@override final  String establishmentId;
@override final  String lotId;
@override final  String lotName;
@override final  DateTime updatedAt;

/// Create a copy of AnimalLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalLocationCopyWith<_AnimalLocation> get copyWith => __$AnimalLocationCopyWithImpl<_AnimalLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalLocation&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,establishmentId,lotId,lotName,updatedAt);

@override
String toString() {
  return 'AnimalLocation(animalId: $animalId, establishmentId: $establishmentId, lotId: $lotId, lotName: $lotName, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AnimalLocationCopyWith<$Res> implements $AnimalLocationCopyWith<$Res> {
  factory _$AnimalLocationCopyWith(_AnimalLocation value, $Res Function(_AnimalLocation) _then) = __$AnimalLocationCopyWithImpl;
@override @useResult
$Res call({
 String animalId, String establishmentId, String lotId, String lotName, DateTime updatedAt
});




}
/// @nodoc
class __$AnimalLocationCopyWithImpl<$Res>
    implements _$AnimalLocationCopyWith<$Res> {
  __$AnimalLocationCopyWithImpl(this._self, this._then);

  final _AnimalLocation _self;
  final $Res Function(_AnimalLocation) _then;

/// Create a copy of AnimalLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = null,Object? establishmentId = null,Object? lotId = null,Object? lotName = null,Object? updatedAt = null,}) {
  return _then(_AnimalLocation(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
