// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vision_animal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VisionAnimal {

 String get id; String get establishmentId; String get rfidTagNumber; String get visualTag; DateTime get updatedAt;
/// Create a copy of VisionAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionAnimalCopyWith<VisionAnimal> get copyWith => _$VisionAnimalCopyWithImpl<VisionAnimal>(this as VisionAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,rfidTagNumber,visualTag,updatedAt);

@override
String toString() {
  return 'VisionAnimal(id: $id, establishmentId: $establishmentId, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $VisionAnimalCopyWith<$Res>  {
  factory $VisionAnimalCopyWith(VisionAnimal value, $Res Function(VisionAnimal) _then) = _$VisionAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String rfidTagNumber, String visualTag, DateTime updatedAt
});




}
/// @nodoc
class _$VisionAnimalCopyWithImpl<$Res>
    implements $VisionAnimalCopyWith<$Res> {
  _$VisionAnimalCopyWithImpl(this._self, this._then);

  final VisionAnimal _self;
  final $Res Function(VisionAnimal) _then;

/// Create a copy of VisionAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionAnimal].
extension VisionAnimalPatterns on VisionAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionAnimal value)  $default,){
final _that = this;
switch (_that) {
case _VisionAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _VisionAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String rfidTagNumber,  String visualTag,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionAnimal() when $default != null:
return $default(_that.id,_that.establishmentId,_that.rfidTagNumber,_that.visualTag,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String rfidTagNumber,  String visualTag,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _VisionAnimal():
return $default(_that.id,_that.establishmentId,_that.rfidTagNumber,_that.visualTag,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String rfidTagNumber,  String visualTag,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _VisionAnimal() when $default != null:
return $default(_that.id,_that.establishmentId,_that.rfidTagNumber,_that.visualTag,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _VisionAnimal implements VisionAnimal {
  const _VisionAnimal({required this.id, required this.establishmentId, required this.rfidTagNumber, required this.visualTag, required this.updatedAt});
  

@override final  String id;
@override final  String establishmentId;
@override final  String rfidTagNumber;
@override final  String visualTag;
@override final  DateTime updatedAt;

/// Create a copy of VisionAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionAnimalCopyWith<_VisionAnimal> get copyWith => __$VisionAnimalCopyWithImpl<_VisionAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,rfidTagNumber,visualTag,updatedAt);

@override
String toString() {
  return 'VisionAnimal(id: $id, establishmentId: $establishmentId, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VisionAnimalCopyWith<$Res> implements $VisionAnimalCopyWith<$Res> {
  factory _$VisionAnimalCopyWith(_VisionAnimal value, $Res Function(_VisionAnimal) _then) = __$VisionAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String rfidTagNumber, String visualTag, DateTime updatedAt
});




}
/// @nodoc
class __$VisionAnimalCopyWithImpl<$Res>
    implements _$VisionAnimalCopyWith<$Res> {
  __$VisionAnimalCopyWithImpl(this._self, this._then);

  final _VisionAnimal _self;
  final $Res Function(_VisionAnimal) _then;

/// Create a copy of VisionAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? updatedAt = null,}) {
  return _then(_VisionAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$VisionEstablishment {

 String get id; String get name;
/// Create a copy of VisionEstablishment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionEstablishmentCopyWith<VisionEstablishment> get copyWith => _$VisionEstablishmentCopyWithImpl<VisionEstablishment>(this as VisionEstablishment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'VisionEstablishment(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $VisionEstablishmentCopyWith<$Res>  {
  factory $VisionEstablishmentCopyWith(VisionEstablishment value, $Res Function(VisionEstablishment) _then) = _$VisionEstablishmentCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$VisionEstablishmentCopyWithImpl<$Res>
    implements $VisionEstablishmentCopyWith<$Res> {
  _$VisionEstablishmentCopyWithImpl(this._self, this._then);

  final VisionEstablishment _self;
  final $Res Function(VisionEstablishment) _then;

/// Create a copy of VisionEstablishment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionEstablishment].
extension VisionEstablishmentPatterns on VisionEstablishment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionEstablishment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionEstablishment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionEstablishment value)  $default,){
final _that = this;
switch (_that) {
case _VisionEstablishment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionEstablishment value)?  $default,){
final _that = this;
switch (_that) {
case _VisionEstablishment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionEstablishment() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _VisionEstablishment():
return $default(_that.id,_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _VisionEstablishment() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _VisionEstablishment implements VisionEstablishment {
  const _VisionEstablishment({required this.id, required this.name});
  

@override final  String id;
@override final  String name;

/// Create a copy of VisionEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionEstablishmentCopyWith<_VisionEstablishment> get copyWith => __$VisionEstablishmentCopyWithImpl<_VisionEstablishment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'VisionEstablishment(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$VisionEstablishmentCopyWith<$Res> implements $VisionEstablishmentCopyWith<$Res> {
  factory _$VisionEstablishmentCopyWith(_VisionEstablishment value, $Res Function(_VisionEstablishment) _then) = __$VisionEstablishmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$VisionEstablishmentCopyWithImpl<$Res>
    implements _$VisionEstablishmentCopyWith<$Res> {
  __$VisionEstablishmentCopyWithImpl(this._self, this._then);

  final _VisionEstablishment _self;
  final $Res Function(_VisionEstablishment) _then;

/// Create a copy of VisionEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_VisionEstablishment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$VisionAnimalOptions {

 List<VisionAnimal> get animals; List<VisionEstablishment> get establishments;
/// Create a copy of VisionAnimalOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionAnimalOptionsCopyWith<VisionAnimalOptions> get copyWith => _$VisionAnimalOptionsCopyWithImpl<VisionAnimalOptions>(this as VisionAnimalOptions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionAnimalOptions&&const DeepCollectionEquality().equals(other.animals, animals)&&const DeepCollectionEquality().equals(other.establishments, establishments));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(animals),const DeepCollectionEquality().hash(establishments));

@override
String toString() {
  return 'VisionAnimalOptions(animals: $animals, establishments: $establishments)';
}


}

/// @nodoc
abstract mixin class $VisionAnimalOptionsCopyWith<$Res>  {
  factory $VisionAnimalOptionsCopyWith(VisionAnimalOptions value, $Res Function(VisionAnimalOptions) _then) = _$VisionAnimalOptionsCopyWithImpl;
@useResult
$Res call({
 List<VisionAnimal> animals, List<VisionEstablishment> establishments
});




}
/// @nodoc
class _$VisionAnimalOptionsCopyWithImpl<$Res>
    implements $VisionAnimalOptionsCopyWith<$Res> {
  _$VisionAnimalOptionsCopyWithImpl(this._self, this._then);

  final VisionAnimalOptions _self;
  final $Res Function(VisionAnimalOptions) _then;

/// Create a copy of VisionAnimalOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animals = null,Object? establishments = null,}) {
  return _then(_self.copyWith(
animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<VisionAnimal>,establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as List<VisionEstablishment>,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionAnimalOptions].
extension VisionAnimalOptionsPatterns on VisionAnimalOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionAnimalOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionAnimalOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionAnimalOptions value)  $default,){
final _that = this;
switch (_that) {
case _VisionAnimalOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionAnimalOptions value)?  $default,){
final _that = this;
switch (_that) {
case _VisionAnimalOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VisionAnimal> animals,  List<VisionEstablishment> establishments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionAnimalOptions() when $default != null:
return $default(_that.animals,_that.establishments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VisionAnimal> animals,  List<VisionEstablishment> establishments)  $default,) {final _that = this;
switch (_that) {
case _VisionAnimalOptions():
return $default(_that.animals,_that.establishments);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VisionAnimal> animals,  List<VisionEstablishment> establishments)?  $default,) {final _that = this;
switch (_that) {
case _VisionAnimalOptions() when $default != null:
return $default(_that.animals,_that.establishments);case _:
  return null;

}
}

}

/// @nodoc


class _VisionAnimalOptions implements VisionAnimalOptions {
  const _VisionAnimalOptions({required final  List<VisionAnimal> animals, required final  List<VisionEstablishment> establishments}): _animals = animals,_establishments = establishments;
  

 final  List<VisionAnimal> _animals;
@override List<VisionAnimal> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}

 final  List<VisionEstablishment> _establishments;
@override List<VisionEstablishment> get establishments {
  if (_establishments is EqualUnmodifiableListView) return _establishments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_establishments);
}


/// Create a copy of VisionAnimalOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionAnimalOptionsCopyWith<_VisionAnimalOptions> get copyWith => __$VisionAnimalOptionsCopyWithImpl<_VisionAnimalOptions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionAnimalOptions&&const DeepCollectionEquality().equals(other._animals, _animals)&&const DeepCollectionEquality().equals(other._establishments, _establishments));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_animals),const DeepCollectionEquality().hash(_establishments));

@override
String toString() {
  return 'VisionAnimalOptions(animals: $animals, establishments: $establishments)';
}


}

/// @nodoc
abstract mixin class _$VisionAnimalOptionsCopyWith<$Res> implements $VisionAnimalOptionsCopyWith<$Res> {
  factory _$VisionAnimalOptionsCopyWith(_VisionAnimalOptions value, $Res Function(_VisionAnimalOptions) _then) = __$VisionAnimalOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<VisionAnimal> animals, List<VisionEstablishment> establishments
});




}
/// @nodoc
class __$VisionAnimalOptionsCopyWithImpl<$Res>
    implements _$VisionAnimalOptionsCopyWith<$Res> {
  __$VisionAnimalOptionsCopyWithImpl(this._self, this._then);

  final _VisionAnimalOptions _self;
  final $Res Function(_VisionAnimalOptions) _then;

/// Create a copy of VisionAnimalOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animals = null,Object? establishments = null,}) {
  return _then(_VisionAnimalOptions(
animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<VisionAnimal>,establishments: null == establishments ? _self._establishments : establishments // ignore: cast_nullable_to_non_nullable
as List<VisionEstablishment>,
  ));
}


}

// dart format on
