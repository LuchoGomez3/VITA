// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forage_resource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ForageResource {

 String get code; String get displayName; bool get active;
/// Create a copy of ForageResource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForageResourceCopyWith<ForageResource> get copyWith => _$ForageResourceCopyWithImpl<ForageResource>(this as ForageResource, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForageResource&&(identical(other.code, code) || other.code == code)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,code,displayName,active);

@override
String toString() {
  return 'ForageResource(code: $code, displayName: $displayName, active: $active)';
}


}

/// @nodoc
abstract mixin class $ForageResourceCopyWith<$Res>  {
  factory $ForageResourceCopyWith(ForageResource value, $Res Function(ForageResource) _then) = _$ForageResourceCopyWithImpl;
@useResult
$Res call({
 String code, String displayName, bool active
});




}
/// @nodoc
class _$ForageResourceCopyWithImpl<$Res>
    implements $ForageResourceCopyWith<$Res> {
  _$ForageResourceCopyWithImpl(this._self, this._then);

  final ForageResource _self;
  final $Res Function(ForageResource) _then;

/// Create a copy of ForageResource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? displayName = null,Object? active = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ForageResource].
extension ForageResourcePatterns on ForageResource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForageResource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForageResource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForageResource value)  $default,){
final _that = this;
switch (_that) {
case _ForageResource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForageResource value)?  $default,){
final _that = this;
switch (_that) {
case _ForageResource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String displayName,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForageResource() when $default != null:
return $default(_that.code,_that.displayName,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String displayName,  bool active)  $default,) {final _that = this;
switch (_that) {
case _ForageResource():
return $default(_that.code,_that.displayName,_that.active);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String displayName,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _ForageResource() when $default != null:
return $default(_that.code,_that.displayName,_that.active);case _:
  return null;

}
}

}

/// @nodoc


class _ForageResource implements ForageResource {
  const _ForageResource({required this.code, required this.displayName, this.active = true});
  

@override final  String code;
@override final  String displayName;
@override@JsonKey() final  bool active;

/// Create a copy of ForageResource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForageResourceCopyWith<_ForageResource> get copyWith => __$ForageResourceCopyWithImpl<_ForageResource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForageResource&&(identical(other.code, code) || other.code == code)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,code,displayName,active);

@override
String toString() {
  return 'ForageResource(code: $code, displayName: $displayName, active: $active)';
}


}

/// @nodoc
abstract mixin class _$ForageResourceCopyWith<$Res> implements $ForageResourceCopyWith<$Res> {
  factory _$ForageResourceCopyWith(_ForageResource value, $Res Function(_ForageResource) _then) = __$ForageResourceCopyWithImpl;
@override @useResult
$Res call({
 String code, String displayName, bool active
});




}
/// @nodoc
class __$ForageResourceCopyWithImpl<$Res>
    implements _$ForageResourceCopyWith<$Res> {
  __$ForageResourceCopyWithImpl(this._self, this._then);

  final _ForageResource _self;
  final $Res Function(_ForageResource) _then;

/// Create a copy of ForageResource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? displayName = null,Object? active = null,}) {
  return _then(_ForageResource(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
