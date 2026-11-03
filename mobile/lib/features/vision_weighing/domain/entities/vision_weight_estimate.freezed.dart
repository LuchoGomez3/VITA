// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vision_weight_estimate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VisionWeightEstimate {

 double get weightKg; double get lowerKg; double get upperKg; double get targetCoverage;
/// Create a copy of VisionWeightEstimate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionWeightEstimateCopyWith<VisionWeightEstimate> get copyWith => _$VisionWeightEstimateCopyWithImpl<VisionWeightEstimate>(this as VisionWeightEstimate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionWeightEstimate&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.lowerKg, lowerKg) || other.lowerKg == lowerKg)&&(identical(other.upperKg, upperKg) || other.upperKg == upperKg)&&(identical(other.targetCoverage, targetCoverage) || other.targetCoverage == targetCoverage));
}


@override
int get hashCode => Object.hash(runtimeType,weightKg,lowerKg,upperKg,targetCoverage);

@override
String toString() {
  return 'VisionWeightEstimate(weightKg: $weightKg, lowerKg: $lowerKg, upperKg: $upperKg, targetCoverage: $targetCoverage)';
}


}

/// @nodoc
abstract mixin class $VisionWeightEstimateCopyWith<$Res>  {
  factory $VisionWeightEstimateCopyWith(VisionWeightEstimate value, $Res Function(VisionWeightEstimate) _then) = _$VisionWeightEstimateCopyWithImpl;
@useResult
$Res call({
 double weightKg, double lowerKg, double upperKg, double targetCoverage
});




}
/// @nodoc
class _$VisionWeightEstimateCopyWithImpl<$Res>
    implements $VisionWeightEstimateCopyWith<$Res> {
  _$VisionWeightEstimateCopyWithImpl(this._self, this._then);

  final VisionWeightEstimate _self;
  final $Res Function(VisionWeightEstimate) _then;

/// Create a copy of VisionWeightEstimate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weightKg = null,Object? lowerKg = null,Object? upperKg = null,Object? targetCoverage = null,}) {
  return _then(_self.copyWith(
weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,lowerKg: null == lowerKg ? _self.lowerKg : lowerKg // ignore: cast_nullable_to_non_nullable
as double,upperKg: null == upperKg ? _self.upperKg : upperKg // ignore: cast_nullable_to_non_nullable
as double,targetCoverage: null == targetCoverage ? _self.targetCoverage : targetCoverage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VisionWeightEstimate].
extension VisionWeightEstimatePatterns on VisionWeightEstimate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionWeightEstimate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionWeightEstimate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionWeightEstimate value)  $default,){
final _that = this;
switch (_that) {
case _VisionWeightEstimate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionWeightEstimate value)?  $default,){
final _that = this;
switch (_that) {
case _VisionWeightEstimate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weightKg,  double lowerKg,  double upperKg,  double targetCoverage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionWeightEstimate() when $default != null:
return $default(_that.weightKg,_that.lowerKg,_that.upperKg,_that.targetCoverage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weightKg,  double lowerKg,  double upperKg,  double targetCoverage)  $default,) {final _that = this;
switch (_that) {
case _VisionWeightEstimate():
return $default(_that.weightKg,_that.lowerKg,_that.upperKg,_that.targetCoverage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weightKg,  double lowerKg,  double upperKg,  double targetCoverage)?  $default,) {final _that = this;
switch (_that) {
case _VisionWeightEstimate() when $default != null:
return $default(_that.weightKg,_that.lowerKg,_that.upperKg,_that.targetCoverage);case _:
  return null;

}
}

}

/// @nodoc


class _VisionWeightEstimate implements VisionWeightEstimate {
  const _VisionWeightEstimate({required this.weightKg, required this.lowerKg, required this.upperKg, required this.targetCoverage});
  

@override final  double weightKg;
@override final  double lowerKg;
@override final  double upperKg;
@override final  double targetCoverage;

/// Create a copy of VisionWeightEstimate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionWeightEstimateCopyWith<_VisionWeightEstimate> get copyWith => __$VisionWeightEstimateCopyWithImpl<_VisionWeightEstimate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionWeightEstimate&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.lowerKg, lowerKg) || other.lowerKg == lowerKg)&&(identical(other.upperKg, upperKg) || other.upperKg == upperKg)&&(identical(other.targetCoverage, targetCoverage) || other.targetCoverage == targetCoverage));
}


@override
int get hashCode => Object.hash(runtimeType,weightKg,lowerKg,upperKg,targetCoverage);

@override
String toString() {
  return 'VisionWeightEstimate(weightKg: $weightKg, lowerKg: $lowerKg, upperKg: $upperKg, targetCoverage: $targetCoverage)';
}


}

/// @nodoc
abstract mixin class _$VisionWeightEstimateCopyWith<$Res> implements $VisionWeightEstimateCopyWith<$Res> {
  factory _$VisionWeightEstimateCopyWith(_VisionWeightEstimate value, $Res Function(_VisionWeightEstimate) _then) = __$VisionWeightEstimateCopyWithImpl;
@override @useResult
$Res call({
 double weightKg, double lowerKg, double upperKg, double targetCoverage
});




}
/// @nodoc
class __$VisionWeightEstimateCopyWithImpl<$Res>
    implements _$VisionWeightEstimateCopyWith<$Res> {
  __$VisionWeightEstimateCopyWithImpl(this._self, this._then);

  final _VisionWeightEstimate _self;
  final $Res Function(_VisionWeightEstimate) _then;

/// Create a copy of VisionWeightEstimate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weightKg = null,Object? lowerKg = null,Object? upperKg = null,Object? targetCoverage = null,}) {
  return _then(_VisionWeightEstimate(
weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,lowerKg: null == lowerKg ? _self.lowerKg : lowerKg // ignore: cast_nullable_to_non_nullable
as double,upperKg: null == upperKg ? _self.upperKg : upperKg // ignore: cast_nullable_to_non_nullable
as double,targetCoverage: null == targetCoverage ? _self.targetCoverage : targetCoverage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
