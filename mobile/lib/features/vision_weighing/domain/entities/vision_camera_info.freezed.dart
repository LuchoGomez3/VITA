// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vision_camera_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VisionCameraInfo {

 double get aspectRatio;
/// Create a copy of VisionCameraInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionCameraInfoCopyWith<VisionCameraInfo> get copyWith => _$VisionCameraInfoCopyWithImpl<VisionCameraInfo>(this as VisionCameraInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionCameraInfo&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}


@override
int get hashCode => Object.hash(runtimeType,aspectRatio);

@override
String toString() {
  return 'VisionCameraInfo(aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class $VisionCameraInfoCopyWith<$Res>  {
  factory $VisionCameraInfoCopyWith(VisionCameraInfo value, $Res Function(VisionCameraInfo) _then) = _$VisionCameraInfoCopyWithImpl;
@useResult
$Res call({
 double aspectRatio
});




}
/// @nodoc
class _$VisionCameraInfoCopyWithImpl<$Res>
    implements $VisionCameraInfoCopyWith<$Res> {
  _$VisionCameraInfoCopyWithImpl(this._self, this._then);

  final VisionCameraInfo _self;
  final $Res Function(VisionCameraInfo) _then;

/// Create a copy of VisionCameraInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aspectRatio = null,}) {
  return _then(_self.copyWith(
aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionCameraInfo].
extension VisionCameraInfoPatterns on VisionCameraInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionCameraInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionCameraInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionCameraInfo value)  $default,){
final _that = this;
switch (_that) {
case _VisionCameraInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionCameraInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VisionCameraInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double aspectRatio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionCameraInfo() when $default != null:
return $default(_that.aspectRatio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double aspectRatio)  $default,) {final _that = this;
switch (_that) {
case _VisionCameraInfo():
return $default(_that.aspectRatio);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double aspectRatio)?  $default,) {final _that = this;
switch (_that) {
case _VisionCameraInfo() when $default != null:
return $default(_that.aspectRatio);case _:
  return null;

}
}

}

/// @nodoc


class _VisionCameraInfo implements VisionCameraInfo {
  const _VisionCameraInfo({required this.aspectRatio});
  

@override final  double aspectRatio;

/// Create a copy of VisionCameraInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionCameraInfoCopyWith<_VisionCameraInfo> get copyWith => __$VisionCameraInfoCopyWithImpl<_VisionCameraInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionCameraInfo&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}


@override
int get hashCode => Object.hash(runtimeType,aspectRatio);

@override
String toString() {
  return 'VisionCameraInfo(aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class _$VisionCameraInfoCopyWith<$Res> implements $VisionCameraInfoCopyWith<$Res> {
  factory _$VisionCameraInfoCopyWith(_VisionCameraInfo value, $Res Function(_VisionCameraInfo) _then) = __$VisionCameraInfoCopyWithImpl;
@override @useResult
$Res call({
 double aspectRatio
});




}
/// @nodoc
class __$VisionCameraInfoCopyWithImpl<$Res>
    implements _$VisionCameraInfoCopyWith<$Res> {
  __$VisionCameraInfoCopyWithImpl(this._self, this._then);

  final _VisionCameraInfo _self;
  final $Res Function(_VisionCameraInfo) _then;

/// Create a copy of VisionCameraInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aspectRatio = null,}) {
  return _then(_VisionCameraInfo(
aspectRatio: null == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
