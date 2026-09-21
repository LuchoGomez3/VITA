// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reviewed_vision_capture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewedVisionCapture {

 VisionCapture get capture; double? get calibrationWeightKg;
/// Create a copy of ReviewedVisionCapture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewedVisionCaptureCopyWith<ReviewedVisionCapture> get copyWith => _$ReviewedVisionCaptureCopyWithImpl<ReviewedVisionCapture>(this as ReviewedVisionCapture, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewedVisionCapture&&(identical(other.capture, capture) || other.capture == capture)&&(identical(other.calibrationWeightKg, calibrationWeightKg) || other.calibrationWeightKg == calibrationWeightKg));
}


@override
int get hashCode => Object.hash(runtimeType,capture,calibrationWeightKg);

@override
String toString() {
  return 'ReviewedVisionCapture(capture: $capture, calibrationWeightKg: $calibrationWeightKg)';
}


}

/// @nodoc
abstract mixin class $ReviewedVisionCaptureCopyWith<$Res>  {
  factory $ReviewedVisionCaptureCopyWith(ReviewedVisionCapture value, $Res Function(ReviewedVisionCapture) _then) = _$ReviewedVisionCaptureCopyWithImpl;
@useResult
$Res call({
 VisionCapture capture, double? calibrationWeightKg
});


$VisionCaptureCopyWith<$Res> get capture;

}
/// @nodoc
class _$ReviewedVisionCaptureCopyWithImpl<$Res>
    implements $ReviewedVisionCaptureCopyWith<$Res> {
  _$ReviewedVisionCaptureCopyWithImpl(this._self, this._then);

  final ReviewedVisionCapture _self;
  final $Res Function(ReviewedVisionCapture) _then;

/// Create a copy of ReviewedVisionCapture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capture = null,Object? calibrationWeightKg = freezed,}) {
  return _then(_self.copyWith(
capture: null == capture ? _self.capture : capture // ignore: cast_nullable_to_non_nullable
as VisionCapture,calibrationWeightKg: freezed == calibrationWeightKg ? _self.calibrationWeightKg : calibrationWeightKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of ReviewedVisionCapture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VisionCaptureCopyWith<$Res> get capture {
  
  return $VisionCaptureCopyWith<$Res>(_self.capture, (value) {
    return _then(_self.copyWith(capture: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReviewedVisionCapture].
extension ReviewedVisionCapturePatterns on ReviewedVisionCapture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewedVisionCapture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewedVisionCapture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewedVisionCapture value)  $default,){
final _that = this;
switch (_that) {
case _ReviewedVisionCapture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewedVisionCapture value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewedVisionCapture() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VisionCapture capture,  double? calibrationWeightKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewedVisionCapture() when $default != null:
return $default(_that.capture,_that.calibrationWeightKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VisionCapture capture,  double? calibrationWeightKg)  $default,) {final _that = this;
switch (_that) {
case _ReviewedVisionCapture():
return $default(_that.capture,_that.calibrationWeightKg);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VisionCapture capture,  double? calibrationWeightKg)?  $default,) {final _that = this;
switch (_that) {
case _ReviewedVisionCapture() when $default != null:
return $default(_that.capture,_that.calibrationWeightKg);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewedVisionCapture implements ReviewedVisionCapture {
  const _ReviewedVisionCapture({required this.capture, this.calibrationWeightKg});
  

@override final  VisionCapture capture;
@override final  double? calibrationWeightKg;

/// Create a copy of ReviewedVisionCapture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewedVisionCaptureCopyWith<_ReviewedVisionCapture> get copyWith => __$ReviewedVisionCaptureCopyWithImpl<_ReviewedVisionCapture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewedVisionCapture&&(identical(other.capture, capture) || other.capture == capture)&&(identical(other.calibrationWeightKg, calibrationWeightKg) || other.calibrationWeightKg == calibrationWeightKg));
}


@override
int get hashCode => Object.hash(runtimeType,capture,calibrationWeightKg);

@override
String toString() {
  return 'ReviewedVisionCapture(capture: $capture, calibrationWeightKg: $calibrationWeightKg)';
}


}

/// @nodoc
abstract mixin class _$ReviewedVisionCaptureCopyWith<$Res> implements $ReviewedVisionCaptureCopyWith<$Res> {
  factory _$ReviewedVisionCaptureCopyWith(_ReviewedVisionCapture value, $Res Function(_ReviewedVisionCapture) _then) = __$ReviewedVisionCaptureCopyWithImpl;
@override @useResult
$Res call({
 VisionCapture capture, double? calibrationWeightKg
});


@override $VisionCaptureCopyWith<$Res> get capture;

}
/// @nodoc
class __$ReviewedVisionCaptureCopyWithImpl<$Res>
    implements _$ReviewedVisionCaptureCopyWith<$Res> {
  __$ReviewedVisionCaptureCopyWithImpl(this._self, this._then);

  final _ReviewedVisionCapture _self;
  final $Res Function(_ReviewedVisionCapture) _then;

/// Create a copy of ReviewedVisionCapture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capture = null,Object? calibrationWeightKg = freezed,}) {
  return _then(_ReviewedVisionCapture(
capture: null == capture ? _self.capture : capture // ignore: cast_nullable_to_non_nullable
as VisionCapture,calibrationWeightKg: freezed == calibrationWeightKg ? _self.calibrationWeightKg : calibrationWeightKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of ReviewedVisionCapture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VisionCaptureCopyWith<$Res> get capture {
  
  return $VisionCaptureCopyWith<$Res>(_self.capture, (value) {
    return _then(_self.copyWith(capture: value));
  });
}
}

// dart format on
