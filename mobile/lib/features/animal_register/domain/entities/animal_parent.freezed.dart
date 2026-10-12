// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_parent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalParent {

 String get id; String get visualTag; String get rfid; String get breed; AnimalSex get sex;
/// Create a copy of AnimalParent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalParentCopyWith<AnimalParent> get copyWith => _$AnimalParentCopyWithImpl<AnimalParent>(this as AnimalParent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalParent&&(identical(other.id, id) || other.id == id)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfid, rfid) || other.rfid == rfid)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.sex, sex) || other.sex == sex));
}


@override
int get hashCode => Object.hash(runtimeType,id,visualTag,rfid,breed,sex);

@override
String toString() {
  return 'AnimalParent(id: $id, visualTag: $visualTag, rfid: $rfid, breed: $breed, sex: $sex)';
}


}

/// @nodoc
abstract mixin class $AnimalParentCopyWith<$Res>  {
  factory $AnimalParentCopyWith(AnimalParent value, $Res Function(AnimalParent) _then) = _$AnimalParentCopyWithImpl;
@useResult
$Res call({
 String id, String visualTag, String rfid, String breed, AnimalSex sex
});




}
/// @nodoc
class _$AnimalParentCopyWithImpl<$Res>
    implements $AnimalParentCopyWith<$Res> {
  _$AnimalParentCopyWithImpl(this._self, this._then);

  final AnimalParent _self;
  final $Res Function(AnimalParent) _then;

/// Create a copy of AnimalParent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? visualTag = null,Object? rfid = null,Object? breed = null,Object? sex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalParent].
extension AnimalParentPatterns on AnimalParent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalParent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalParent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalParent value)  $default,){
final _that = this;
switch (_that) {
case _AnimalParent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalParent value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalParent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String visualTag,  String rfid,  String breed,  AnimalSex sex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalParent() when $default != null:
return $default(_that.id,_that.visualTag,_that.rfid,_that.breed,_that.sex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String visualTag,  String rfid,  String breed,  AnimalSex sex)  $default,) {final _that = this;
switch (_that) {
case _AnimalParent():
return $default(_that.id,_that.visualTag,_that.rfid,_that.breed,_that.sex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String visualTag,  String rfid,  String breed,  AnimalSex sex)?  $default,) {final _that = this;
switch (_that) {
case _AnimalParent() when $default != null:
return $default(_that.id,_that.visualTag,_that.rfid,_that.breed,_that.sex);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalParent implements AnimalParent {
  const _AnimalParent({required this.id, required this.visualTag, required this.rfid, required this.breed, required this.sex});
  

@override final  String id;
@override final  String visualTag;
@override final  String rfid;
@override final  String breed;
@override final  AnimalSex sex;

/// Create a copy of AnimalParent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalParentCopyWith<_AnimalParent> get copyWith => __$AnimalParentCopyWithImpl<_AnimalParent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalParent&&(identical(other.id, id) || other.id == id)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfid, rfid) || other.rfid == rfid)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.sex, sex) || other.sex == sex));
}


@override
int get hashCode => Object.hash(runtimeType,id,visualTag,rfid,breed,sex);

@override
String toString() {
  return 'AnimalParent(id: $id, visualTag: $visualTag, rfid: $rfid, breed: $breed, sex: $sex)';
}


}

/// @nodoc
abstract mixin class _$AnimalParentCopyWith<$Res> implements $AnimalParentCopyWith<$Res> {
  factory _$AnimalParentCopyWith(_AnimalParent value, $Res Function(_AnimalParent) _then) = __$AnimalParentCopyWithImpl;
@override @useResult
$Res call({
 String id, String visualTag, String rfid, String breed, AnimalSex sex
});




}
/// @nodoc
class __$AnimalParentCopyWithImpl<$Res>
    implements _$AnimalParentCopyWith<$Res> {
  __$AnimalParentCopyWithImpl(this._self, this._then);

  final _AnimalParent _self;
  final $Res Function(_AnimalParent) _then;

/// Create a copy of AnimalParent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? visualTag = null,Object? rfid = null,Object? breed = null,Object? sex = null,}) {
  return _then(_AnimalParent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,rfid: null == rfid ? _self.rfid : rfid // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,
  ));
}


}

// dart format on
