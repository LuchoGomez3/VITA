// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vision_capture_view_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VisionCaptureViewData {

 VisionCapture get capture; int get inferenceMilliseconds; ReviewedVisionCapture? get reviewedCapture; bool get saved;
/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisionCaptureViewDataCopyWith<VisionCaptureViewData> get copyWith => _$VisionCaptureViewDataCopyWithImpl<VisionCaptureViewData>(this as VisionCaptureViewData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisionCaptureViewData&&(identical(other.capture, capture) || other.capture == capture)&&(identical(other.inferenceMilliseconds, inferenceMilliseconds) || other.inferenceMilliseconds == inferenceMilliseconds)&&(identical(other.reviewedCapture, reviewedCapture) || other.reviewedCapture == reviewedCapture)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,capture,inferenceMilliseconds,reviewedCapture,saved);

@override
String toString() {
  return 'VisionCaptureViewData(capture: $capture, inferenceMilliseconds: $inferenceMilliseconds, reviewedCapture: $reviewedCapture, saved: $saved)';
}


}

/// @nodoc
abstract mixin class $VisionCaptureViewDataCopyWith<$Res>  {
  factory $VisionCaptureViewDataCopyWith(VisionCaptureViewData value, $Res Function(VisionCaptureViewData) _then) = _$VisionCaptureViewDataCopyWithImpl;
@useResult
$Res call({
 VisionCapture capture, int inferenceMilliseconds, ReviewedVisionCapture? reviewedCapture, bool saved
});


$VisionCaptureCopyWith<$Res> get capture;$ReviewedVisionCaptureCopyWith<$Res>? get reviewedCapture;

}
/// @nodoc
class _$VisionCaptureViewDataCopyWithImpl<$Res>
    implements $VisionCaptureViewDataCopyWith<$Res> {
  _$VisionCaptureViewDataCopyWithImpl(this._self, this._then);

  final VisionCaptureViewData _self;
  final $Res Function(VisionCaptureViewData) _then;

/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capture = null,Object? inferenceMilliseconds = null,Object? reviewedCapture = freezed,Object? saved = null,}) {
  return _then(_self.copyWith(
capture: null == capture ? _self.capture : capture // ignore: cast_nullable_to_non_nullable
as VisionCapture,inferenceMilliseconds: null == inferenceMilliseconds ? _self.inferenceMilliseconds : inferenceMilliseconds // ignore: cast_nullable_to_non_nullable
as int,reviewedCapture: freezed == reviewedCapture ? _self.reviewedCapture : reviewedCapture // ignore: cast_nullable_to_non_nullable
as ReviewedVisionCapture?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VisionCaptureCopyWith<$Res> get capture {
  
  return $VisionCaptureCopyWith<$Res>(_self.capture, (value) {
    return _then(_self.copyWith(capture: value));
  });
}/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewedVisionCaptureCopyWith<$Res>? get reviewedCapture {
    if (_self.reviewedCapture == null) {
    return null;
  }

  return $ReviewedVisionCaptureCopyWith<$Res>(_self.reviewedCapture!, (value) {
    return _then(_self.copyWith(reviewedCapture: value));
  });
}
}


/// Adds pattern-matching-related methods to [VisionCaptureViewData].
extension VisionCaptureViewDataPatterns on VisionCaptureViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisionCaptureViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisionCaptureViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisionCaptureViewData value)  $default,){
final _that = this;
switch (_that) {
case _VisionCaptureViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisionCaptureViewData value)?  $default,){
final _that = this;
switch (_that) {
case _VisionCaptureViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VisionCapture capture,  int inferenceMilliseconds,  ReviewedVisionCapture? reviewedCapture,  bool saved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisionCaptureViewData() when $default != null:
return $default(_that.capture,_that.inferenceMilliseconds,_that.reviewedCapture,_that.saved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VisionCapture capture,  int inferenceMilliseconds,  ReviewedVisionCapture? reviewedCapture,  bool saved)  $default,) {final _that = this;
switch (_that) {
case _VisionCaptureViewData():
return $default(_that.capture,_that.inferenceMilliseconds,_that.reviewedCapture,_that.saved);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VisionCapture capture,  int inferenceMilliseconds,  ReviewedVisionCapture? reviewedCapture,  bool saved)?  $default,) {final _that = this;
switch (_that) {
case _VisionCaptureViewData() when $default != null:
return $default(_that.capture,_that.inferenceMilliseconds,_that.reviewedCapture,_that.saved);case _:
  return null;

}
}

}

/// @nodoc


class _VisionCaptureViewData extends VisionCaptureViewData {
  const _VisionCaptureViewData({required this.capture, required this.inferenceMilliseconds, this.reviewedCapture, this.saved = false}): super._();
  

@override final  VisionCapture capture;
@override final  int inferenceMilliseconds;
@override final  ReviewedVisionCapture? reviewedCapture;
@override@JsonKey() final  bool saved;

/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisionCaptureViewDataCopyWith<_VisionCaptureViewData> get copyWith => __$VisionCaptureViewDataCopyWithImpl<_VisionCaptureViewData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisionCaptureViewData&&(identical(other.capture, capture) || other.capture == capture)&&(identical(other.inferenceMilliseconds, inferenceMilliseconds) || other.inferenceMilliseconds == inferenceMilliseconds)&&(identical(other.reviewedCapture, reviewedCapture) || other.reviewedCapture == reviewedCapture)&&(identical(other.saved, saved) || other.saved == saved));
}


@override
int get hashCode => Object.hash(runtimeType,capture,inferenceMilliseconds,reviewedCapture,saved);

@override
String toString() {
  return 'VisionCaptureViewData(capture: $capture, inferenceMilliseconds: $inferenceMilliseconds, reviewedCapture: $reviewedCapture, saved: $saved)';
}


}

/// @nodoc
abstract mixin class _$VisionCaptureViewDataCopyWith<$Res> implements $VisionCaptureViewDataCopyWith<$Res> {
  factory _$VisionCaptureViewDataCopyWith(_VisionCaptureViewData value, $Res Function(_VisionCaptureViewData) _then) = __$VisionCaptureViewDataCopyWithImpl;
@override @useResult
$Res call({
 VisionCapture capture, int inferenceMilliseconds, ReviewedVisionCapture? reviewedCapture, bool saved
});


@override $VisionCaptureCopyWith<$Res> get capture;@override $ReviewedVisionCaptureCopyWith<$Res>? get reviewedCapture;

}
/// @nodoc
class __$VisionCaptureViewDataCopyWithImpl<$Res>
    implements _$VisionCaptureViewDataCopyWith<$Res> {
  __$VisionCaptureViewDataCopyWithImpl(this._self, this._then);

  final _VisionCaptureViewData _self;
  final $Res Function(_VisionCaptureViewData) _then;

/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capture = null,Object? inferenceMilliseconds = null,Object? reviewedCapture = freezed,Object? saved = null,}) {
  return _then(_VisionCaptureViewData(
capture: null == capture ? _self.capture : capture // ignore: cast_nullable_to_non_nullable
as VisionCapture,inferenceMilliseconds: null == inferenceMilliseconds ? _self.inferenceMilliseconds : inferenceMilliseconds // ignore: cast_nullable_to_non_nullable
as int,reviewedCapture: freezed == reviewedCapture ? _self.reviewedCapture : reviewedCapture // ignore: cast_nullable_to_non_nullable
as ReviewedVisionCapture?,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VisionCaptureCopyWith<$Res> get capture {
  
  return $VisionCaptureCopyWith<$Res>(_self.capture, (value) {
    return _then(_self.copyWith(capture: value));
  });
}/// Create a copy of VisionCaptureViewData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewedVisionCaptureCopyWith<$Res>? get reviewedCapture {
    if (_self.reviewedCapture == null) {
    return null;
  }

  return $ReviewedVisionCaptureCopyWith<$Res>(_self.reviewedCapture!, (value) {
    return _then(_self.copyWith(reviewedCapture: value));
  });
}
}

// dart format on
