// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vision_capture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VisionCapture {

 Uint8List get jpegBytes; CaptureQuality get quality; double get sharpness; double? get estimatedWeightKg;/// Límites del intervalo empírico; no son confianza de una foto individual.
 double? get estimatedWeightLowerKg; double? get estimatedWeightUpperKg; double? get intervalTargetCoverage;
/// Create a copy of VisionCapture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionCaptureCopyWith<VisionCapture> get copyWith => _$VisionCaptureCopyWithImpl<VisionCapture>(this as VisionCapture, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionCapture&&const DeepCollectionEquality().equals(other.jpegBytes, jpegBytes)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.sharpness, sharpness) || other.sharpness == sharpness)&&(identical(other.estimatedWeightKg, estimatedWeightKg) || other.estimatedWeightKg == estimatedWeightKg)&&(identical(other.estimatedWeightLowerKg, estimatedWeightLowerKg) || other.estimatedWeightLowerKg == estimatedWeightLowerKg)&&(identical(other.estimatedWeightUpperKg, estimatedWeightUpperKg) || other.estimatedWeightUpperKg == estimatedWeightUpperKg)&&(identical(other.intervalTargetCoverage, intervalTargetCoverage) || other.intervalTargetCoverage == intervalTargetCoverage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(jpegBytes),quality,sharpness,estimatedWeightKg,estimatedWeightLowerKg,estimatedWeightUpperKg,intervalTargetCoverage);

@override
String toString() {
  return 'VisionCapture(jpegBytes: $jpegBytes, quality: $quality, sharpness: $sharpness, estimatedWeightKg: $estimatedWeightKg, estimatedWeightLowerKg: $estimatedWeightLowerKg, estimatedWeightUpperKg: $estimatedWeightUpperKg, intervalTargetCoverage: $intervalTargetCoverage)';
}


}

/// @nodoc
abstract mixin class $VisionCaptureCopyWith<$Res>  {
  factory $VisionCaptureCopyWith(VisionCapture value, $Res Function(VisionCapture) _then) = _$VisionCaptureCopyWithImpl;
@useResult
$Res call({
 Uint8List jpegBytes, CaptureQuality quality, double sharpness, double? estimatedWeightKg, double? estimatedWeightLowerKg, double? estimatedWeightUpperKg, double? intervalTargetCoverage
});




}
/// @nodoc
class _$VisionCaptureCopyWithImpl<$Res>
    implements $VisionCaptureCopyWith<$Res> {
  _$VisionCaptureCopyWithImpl(this._self, this._then);

  final VisionCapture _self;
  final $Res Function(VisionCapture) _then;

/// Create a copy of VisionCapture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jpegBytes = null,Object? quality = null,Object? sharpness = null,Object? estimatedWeightKg = freezed,Object? estimatedWeightLowerKg = freezed,Object? estimatedWeightUpperKg = freezed,Object? intervalTargetCoverage = freezed,}) {
  return _then(_self.copyWith(
jpegBytes: null == jpegBytes ? _self.jpegBytes : jpegBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as CaptureQuality,sharpness: null == sharpness ? _self.sharpness : sharpness // ignore: cast_nullable_to_non_nullable
as double,estimatedWeightKg: freezed == estimatedWeightKg ? _self.estimatedWeightKg : estimatedWeightKg // ignore: cast_nullable_to_non_nullable
as double?,estimatedWeightLowerKg: freezed == estimatedWeightLowerKg ? _self.estimatedWeightLowerKg : estimatedWeightLowerKg // ignore: cast_nullable_to_non_nullable
as double?,estimatedWeightUpperKg: freezed == estimatedWeightUpperKg ? _self.estimatedWeightUpperKg : estimatedWeightUpperKg // ignore: cast_nullable_to_non_nullable
as double?,intervalTargetCoverage: freezed == intervalTargetCoverage ? _self.intervalTargetCoverage : intervalTargetCoverage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionCapture].
extension VisionCapturePatterns on VisionCapture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionCapture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionCapture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionCapture value)  $default,){
final _that = this;
switch (_that) {
case _VisionCapture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionCapture value)?  $default,){
final _that = this;
switch (_that) {
case _VisionCapture() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List jpegBytes,  CaptureQuality quality,  double sharpness,  double? estimatedWeightKg,  double? estimatedWeightLowerKg,  double? estimatedWeightUpperKg,  double? intervalTargetCoverage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionCapture() when $default != null:
return $default(_that.jpegBytes,_that.quality,_that.sharpness,_that.estimatedWeightKg,_that.estimatedWeightLowerKg,_that.estimatedWeightUpperKg,_that.intervalTargetCoverage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List jpegBytes,  CaptureQuality quality,  double sharpness,  double? estimatedWeightKg,  double? estimatedWeightLowerKg,  double? estimatedWeightUpperKg,  double? intervalTargetCoverage)  $default,) {final _that = this;
switch (_that) {
case _VisionCapture():
return $default(_that.jpegBytes,_that.quality,_that.sharpness,_that.estimatedWeightKg,_that.estimatedWeightLowerKg,_that.estimatedWeightUpperKg,_that.intervalTargetCoverage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List jpegBytes,  CaptureQuality quality,  double sharpness,  double? estimatedWeightKg,  double? estimatedWeightLowerKg,  double? estimatedWeightUpperKg,  double? intervalTargetCoverage)?  $default,) {final _that = this;
switch (_that) {
case _VisionCapture() when $default != null:
return $default(_that.jpegBytes,_that.quality,_that.sharpness,_that.estimatedWeightKg,_that.estimatedWeightLowerKg,_that.estimatedWeightUpperKg,_that.intervalTargetCoverage);case _:
  return null;

}
}

}

/// @nodoc


class _VisionCapture implements VisionCapture {
  const _VisionCapture({required this.jpegBytes, required this.quality, required this.sharpness, this.estimatedWeightKg, this.estimatedWeightLowerKg, this.estimatedWeightUpperKg, this.intervalTargetCoverage});
  

@override final  Uint8List jpegBytes;
@override final  CaptureQuality quality;
@override final  double sharpness;
@override final  double? estimatedWeightKg;
/// Límites del intervalo empírico; no son confianza de una foto individual.
@override final  double? estimatedWeightLowerKg;
@override final  double? estimatedWeightUpperKg;
@override final  double? intervalTargetCoverage;

/// Create a copy of VisionCapture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionCaptureCopyWith<_VisionCapture> get copyWith => __$VisionCaptureCopyWithImpl<_VisionCapture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionCapture&&const DeepCollectionEquality().equals(other.jpegBytes, jpegBytes)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.sharpness, sharpness) || other.sharpness == sharpness)&&(identical(other.estimatedWeightKg, estimatedWeightKg) || other.estimatedWeightKg == estimatedWeightKg)&&(identical(other.estimatedWeightLowerKg, estimatedWeightLowerKg) || other.estimatedWeightLowerKg == estimatedWeightLowerKg)&&(identical(other.estimatedWeightUpperKg, estimatedWeightUpperKg) || other.estimatedWeightUpperKg == estimatedWeightUpperKg)&&(identical(other.intervalTargetCoverage, intervalTargetCoverage) || other.intervalTargetCoverage == intervalTargetCoverage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(jpegBytes),quality,sharpness,estimatedWeightKg,estimatedWeightLowerKg,estimatedWeightUpperKg,intervalTargetCoverage);

@override
String toString() {
  return 'VisionCapture(jpegBytes: $jpegBytes, quality: $quality, sharpness: $sharpness, estimatedWeightKg: $estimatedWeightKg, estimatedWeightLowerKg: $estimatedWeightLowerKg, estimatedWeightUpperKg: $estimatedWeightUpperKg, intervalTargetCoverage: $intervalTargetCoverage)';
}


}

/// @nodoc
abstract mixin class _$VisionCaptureCopyWith<$Res> implements $VisionCaptureCopyWith<$Res> {
  factory _$VisionCaptureCopyWith(_VisionCapture value, $Res Function(_VisionCapture) _then) = __$VisionCaptureCopyWithImpl;
@override @useResult
$Res call({
 Uint8List jpegBytes, CaptureQuality quality, double sharpness, double? estimatedWeightKg, double? estimatedWeightLowerKg, double? estimatedWeightUpperKg, double? intervalTargetCoverage
});




}
/// @nodoc
class __$VisionCaptureCopyWithImpl<$Res>
    implements _$VisionCaptureCopyWith<$Res> {
  __$VisionCaptureCopyWithImpl(this._self, this._then);

  final _VisionCapture _self;
  final $Res Function(_VisionCapture) _then;

/// Create a copy of VisionCapture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jpegBytes = null,Object? quality = null,Object? sharpness = null,Object? estimatedWeightKg = freezed,Object? estimatedWeightLowerKg = freezed,Object? estimatedWeightUpperKg = freezed,Object? intervalTargetCoverage = freezed,}) {
  return _then(_VisionCapture(
jpegBytes: null == jpegBytes ? _self.jpegBytes : jpegBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as CaptureQuality,sharpness: null == sharpness ? _self.sharpness : sharpness // ignore: cast_nullable_to_non_nullable
as double,estimatedWeightKg: freezed == estimatedWeightKg ? _self.estimatedWeightKg : estimatedWeightKg // ignore: cast_nullable_to_non_nullable
as double?,estimatedWeightLowerKg: freezed == estimatedWeightLowerKg ? _self.estimatedWeightLowerKg : estimatedWeightLowerKg // ignore: cast_nullable_to_non_nullable
as double?,estimatedWeightUpperKg: freezed == estimatedWeightUpperKg ? _self.estimatedWeightUpperKg : estimatedWeightUpperKg // ignore: cast_nullable_to_non_nullable
as double?,intervalTargetCoverage: freezed == intervalTargetCoverage ? _self.intervalTargetCoverage : intervalTargetCoverage // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
