// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestock_establishment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivestockEstablishment {

 String get id; String get name; UserRole get role;
/// Create a copy of LivestockEstablishment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockEstablishmentCopyWith<LivestockEstablishment> get copyWith => _$LivestockEstablishmentCopyWithImpl<LivestockEstablishment>(this as LivestockEstablishment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role);

@override
String toString() {
  return 'LivestockEstablishment(id: $id, name: $name, role: $role)';
}


}

/// @nodoc
abstract mixin class $LivestockEstablishmentCopyWith<$Res>  {
  factory $LivestockEstablishmentCopyWith(LivestockEstablishment value, $Res Function(LivestockEstablishment) _then) = _$LivestockEstablishmentCopyWithImpl;
@useResult
$Res call({
 String id, String name, UserRole role
});




}
/// @nodoc
class _$LivestockEstablishmentCopyWithImpl<$Res>
    implements $LivestockEstablishmentCopyWith<$Res> {
  _$LivestockEstablishmentCopyWithImpl(this._self, this._then);

  final LivestockEstablishment _self;
  final $Res Function(LivestockEstablishment) _then;

/// Create a copy of LivestockEstablishment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockEstablishment].
extension LivestockEstablishmentPatterns on LivestockEstablishment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockEstablishment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockEstablishment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockEstablishment value)  $default,){
final _that = this;
switch (_that) {
case _LivestockEstablishment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockEstablishment value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockEstablishment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockEstablishment() when $default != null:
return $default(_that.id,_that.name,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  UserRole role)  $default,) {final _that = this;
switch (_that) {
case _LivestockEstablishment():
return $default(_that.id,_that.name,_that.role);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  UserRole role)?  $default,) {final _that = this;
switch (_that) {
case _LivestockEstablishment() when $default != null:
return $default(_that.id,_that.name,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockEstablishment extends LivestockEstablishment {
  const _LivestockEstablishment({required this.id, required this.name, required this.role}): super._();


@override final  String id;
@override final  String name;
@override final  UserRole role;

/// Create a copy of LivestockEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockEstablishmentCopyWith<_LivestockEstablishment> get copyWith => __$LivestockEstablishmentCopyWithImpl<_LivestockEstablishment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,role);

@override
String toString() {
  return 'LivestockEstablishment(id: $id, name: $name, role: $role)';
}


}

/// @nodoc
abstract mixin class _$LivestockEstablishmentCopyWith<$Res> implements $LivestockEstablishmentCopyWith<$Res> {
  factory _$LivestockEstablishmentCopyWith(_LivestockEstablishment value, $Res Function(_LivestockEstablishment) _then) = __$LivestockEstablishmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, UserRole role
});




}
/// @nodoc
class __$LivestockEstablishmentCopyWithImpl<$Res>
    implements _$LivestockEstablishmentCopyWith<$Res> {
  __$LivestockEstablishmentCopyWithImpl(this._self, this._then);

  final _LivestockEstablishment _self;
  final $Res Function(_LivestockEstablishment) _then;

/// Create a copy of LivestockEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,}) {
  return _then(_LivestockEstablishment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}


}

// dart format on
