// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotDraft {

 String get name; LotBoundary get boundary; int get surfaceTenths; String? get forageResourceCode; bool? get hasWater; LotStatus get status;
/// Create a copy of LotDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotDraftCopyWith<LotDraft> get copyWith => _$LotDraftCopyWithImpl<LotDraft>(this as LotDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.boundary, boundary) || other.boundary == boundary)&&(identical(other.surfaceTenths, surfaceTenths) || other.surfaceTenths == surfaceTenths)&&(identical(other.forageResourceCode, forageResourceCode) || other.forageResourceCode == forageResourceCode)&&(identical(other.hasWater, hasWater) || other.hasWater == hasWater)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,boundary,surfaceTenths,forageResourceCode,hasWater,status);

@override
String toString() {
  return 'LotDraft(name: $name, boundary: $boundary, surfaceTenths: $surfaceTenths, forageResourceCode: $forageResourceCode, hasWater: $hasWater, status: $status)';
}


}

/// @nodoc
abstract mixin class $LotDraftCopyWith<$Res>  {
  factory $LotDraftCopyWith(LotDraft value, $Res Function(LotDraft) _then) = _$LotDraftCopyWithImpl;
@useResult
$Res call({
 String name, LotBoundary boundary, int surfaceTenths, String? forageResourceCode, bool? hasWater, LotStatus status
});


$LotBoundaryCopyWith<$Res> get boundary;

}
/// @nodoc
class _$LotDraftCopyWithImpl<$Res>
    implements $LotDraftCopyWith<$Res> {
  _$LotDraftCopyWithImpl(this._self, this._then);

  final LotDraft _self;
  final $Res Function(LotDraft) _then;

/// Create a copy of LotDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? boundary = null,Object? surfaceTenths = null,Object? forageResourceCode = freezed,Object? hasWater = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,boundary: null == boundary ? _self.boundary : boundary // ignore: cast_nullable_to_non_nullable
as LotBoundary,surfaceTenths: null == surfaceTenths ? _self.surfaceTenths : surfaceTenths // ignore: cast_nullable_to_non_nullable
as int,forageResourceCode: freezed == forageResourceCode ? _self.forageResourceCode : forageResourceCode // ignore: cast_nullable_to_non_nullable
as String?,hasWater: freezed == hasWater ? _self.hasWater : hasWater // ignore: cast_nullable_to_non_nullable
as bool?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LotStatus,
  ));
}
/// Create a copy of LotDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotBoundaryCopyWith<$Res> get boundary {
  
  return $LotBoundaryCopyWith<$Res>(_self.boundary, (value) {
    return _then(_self.copyWith(boundary: value));
  });
}
}


/// Adds pattern-matching-related methods to [LotDraft].
extension LotDraftPatterns on LotDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotDraft value)  $default,){
final _that = this;
switch (_that) {
case _LotDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotDraft value)?  $default,){
final _that = this;
switch (_that) {
case _LotDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  LotBoundary boundary,  int surfaceTenths,  String? forageResourceCode,  bool? hasWater,  LotStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotDraft() when $default != null:
return $default(_that.name,_that.boundary,_that.surfaceTenths,_that.forageResourceCode,_that.hasWater,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  LotBoundary boundary,  int surfaceTenths,  String? forageResourceCode,  bool? hasWater,  LotStatus status)  $default,) {final _that = this;
switch (_that) {
case _LotDraft():
return $default(_that.name,_that.boundary,_that.surfaceTenths,_that.forageResourceCode,_that.hasWater,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  LotBoundary boundary,  int surfaceTenths,  String? forageResourceCode,  bool? hasWater,  LotStatus status)?  $default,) {final _that = this;
switch (_that) {
case _LotDraft() when $default != null:
return $default(_that.name,_that.boundary,_that.surfaceTenths,_that.forageResourceCode,_that.hasWater,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _LotDraft implements LotDraft {
  const _LotDraft({required this.name, required this.boundary, this.surfaceTenths = 0, this.forageResourceCode, this.hasWater, this.status = LotStatus.active});
  

@override final  String name;
@override final  LotBoundary boundary;
@override@JsonKey() final  int surfaceTenths;
@override final  String? forageResourceCode;
@override final  bool? hasWater;
@override@JsonKey() final  LotStatus status;

/// Create a copy of LotDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotDraftCopyWith<_LotDraft> get copyWith => __$LotDraftCopyWithImpl<_LotDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.boundary, boundary) || other.boundary == boundary)&&(identical(other.surfaceTenths, surfaceTenths) || other.surfaceTenths == surfaceTenths)&&(identical(other.forageResourceCode, forageResourceCode) || other.forageResourceCode == forageResourceCode)&&(identical(other.hasWater, hasWater) || other.hasWater == hasWater)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,name,boundary,surfaceTenths,forageResourceCode,hasWater,status);

@override
String toString() {
  return 'LotDraft(name: $name, boundary: $boundary, surfaceTenths: $surfaceTenths, forageResourceCode: $forageResourceCode, hasWater: $hasWater, status: $status)';
}


}

/// @nodoc
abstract mixin class _$LotDraftCopyWith<$Res> implements $LotDraftCopyWith<$Res> {
  factory _$LotDraftCopyWith(_LotDraft value, $Res Function(_LotDraft) _then) = __$LotDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, LotBoundary boundary, int surfaceTenths, String? forageResourceCode, bool? hasWater, LotStatus status
});


@override $LotBoundaryCopyWith<$Res> get boundary;

}
/// @nodoc
class __$LotDraftCopyWithImpl<$Res>
    implements _$LotDraftCopyWith<$Res> {
  __$LotDraftCopyWithImpl(this._self, this._then);

  final _LotDraft _self;
  final $Res Function(_LotDraft) _then;

/// Create a copy of LotDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? boundary = null,Object? surfaceTenths = null,Object? forageResourceCode = freezed,Object? hasWater = freezed,Object? status = null,}) {
  return _then(_LotDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,boundary: null == boundary ? _self.boundary : boundary // ignore: cast_nullable_to_non_nullable
as LotBoundary,surfaceTenths: null == surfaceTenths ? _self.surfaceTenths : surfaceTenths // ignore: cast_nullable_to_non_nullable
as int,forageResourceCode: freezed == forageResourceCode ? _self.forageResourceCode : forageResourceCode // ignore: cast_nullable_to_non_nullable
as String?,hasWater: freezed == hasWater ? _self.hasWater : hasWater // ignore: cast_nullable_to_non_nullable
as bool?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LotStatus,
  ));
}

/// Create a copy of LotDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotBoundaryCopyWith<$Res> get boundary {
  
  return $LotBoundaryCopyWith<$Res>(_self.boundary, (value) {
    return _then(_self.copyWith(boundary: value));
  });
}
}

// dart format on
