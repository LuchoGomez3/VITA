// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_boundary_validation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotBoundaryValidation {

 List<LotBoundaryValidationIssue> get issues; double get estimatedAreaSquareUnits;
/// Create a copy of LotBoundaryValidation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotBoundaryValidationCopyWith<LotBoundaryValidation> get copyWith => _$LotBoundaryValidationCopyWithImpl<LotBoundaryValidation>(this as LotBoundaryValidation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotBoundaryValidation&&const DeepCollectionEquality().equals(other.issues, issues)&&(identical(other.estimatedAreaSquareUnits, estimatedAreaSquareUnits) || other.estimatedAreaSquareUnits == estimatedAreaSquareUnits));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(issues),estimatedAreaSquareUnits);

@override
String toString() {
  return 'LotBoundaryValidation(issues: $issues, estimatedAreaSquareUnits: $estimatedAreaSquareUnits)';
}


}

/// @nodoc
abstract mixin class $LotBoundaryValidationCopyWith<$Res>  {
  factory $LotBoundaryValidationCopyWith(LotBoundaryValidation value, $Res Function(LotBoundaryValidation) _then) = _$LotBoundaryValidationCopyWithImpl;
@useResult
$Res call({
 List<LotBoundaryValidationIssue> issues, double estimatedAreaSquareUnits
});




}
/// @nodoc
class _$LotBoundaryValidationCopyWithImpl<$Res>
    implements $LotBoundaryValidationCopyWith<$Res> {
  _$LotBoundaryValidationCopyWithImpl(this._self, this._then);

  final LotBoundaryValidation _self;
  final $Res Function(LotBoundaryValidation) _then;

/// Create a copy of LotBoundaryValidation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? issues = null,Object? estimatedAreaSquareUnits = null,}) {
  return _then(_self.copyWith(
issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<LotBoundaryValidationIssue>,estimatedAreaSquareUnits: null == estimatedAreaSquareUnits ? _self.estimatedAreaSquareUnits : estimatedAreaSquareUnits // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LotBoundaryValidation].
extension LotBoundaryValidationPatterns on LotBoundaryValidation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotBoundaryValidation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotBoundaryValidation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotBoundaryValidation value)  $default,){
final _that = this;
switch (_that) {
case _LotBoundaryValidation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotBoundaryValidation value)?  $default,){
final _that = this;
switch (_that) {
case _LotBoundaryValidation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LotBoundaryValidationIssue> issues,  double estimatedAreaSquareUnits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotBoundaryValidation() when $default != null:
return $default(_that.issues,_that.estimatedAreaSquareUnits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LotBoundaryValidationIssue> issues,  double estimatedAreaSquareUnits)  $default,) {final _that = this;
switch (_that) {
case _LotBoundaryValidation():
return $default(_that.issues,_that.estimatedAreaSquareUnits);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LotBoundaryValidationIssue> issues,  double estimatedAreaSquareUnits)?  $default,) {final _that = this;
switch (_that) {
case _LotBoundaryValidation() when $default != null:
return $default(_that.issues,_that.estimatedAreaSquareUnits);case _:
  return null;

}
}

}

/// @nodoc


class _LotBoundaryValidation extends LotBoundaryValidation {
  const _LotBoundaryValidation({required final  List<LotBoundaryValidationIssue> issues, required this.estimatedAreaSquareUnits}): _issues = issues,super._();
  

 final  List<LotBoundaryValidationIssue> _issues;
@override List<LotBoundaryValidationIssue> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}

@override final  double estimatedAreaSquareUnits;

/// Create a copy of LotBoundaryValidation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotBoundaryValidationCopyWith<_LotBoundaryValidation> get copyWith => __$LotBoundaryValidationCopyWithImpl<_LotBoundaryValidation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotBoundaryValidation&&const DeepCollectionEquality().equals(other._issues, _issues)&&(identical(other.estimatedAreaSquareUnits, estimatedAreaSquareUnits) || other.estimatedAreaSquareUnits == estimatedAreaSquareUnits));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_issues),estimatedAreaSquareUnits);

@override
String toString() {
  return 'LotBoundaryValidation(issues: $issues, estimatedAreaSquareUnits: $estimatedAreaSquareUnits)';
}


}

/// @nodoc
abstract mixin class _$LotBoundaryValidationCopyWith<$Res> implements $LotBoundaryValidationCopyWith<$Res> {
  factory _$LotBoundaryValidationCopyWith(_LotBoundaryValidation value, $Res Function(_LotBoundaryValidation) _then) = __$LotBoundaryValidationCopyWithImpl;
@override @useResult
$Res call({
 List<LotBoundaryValidationIssue> issues, double estimatedAreaSquareUnits
});




}
/// @nodoc
class __$LotBoundaryValidationCopyWithImpl<$Res>
    implements _$LotBoundaryValidationCopyWith<$Res> {
  __$LotBoundaryValidationCopyWithImpl(this._self, this._then);

  final _LotBoundaryValidation _self;
  final $Res Function(_LotBoundaryValidation) _then;

/// Create a copy of LotBoundaryValidation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? issues = null,Object? estimatedAreaSquareUnits = null,}) {
  return _then(_LotBoundaryValidation(
issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<LotBoundaryValidationIssue>,estimatedAreaSquareUnits: null == estimatedAreaSquareUnits ? _self.estimatedAreaSquareUnits : estimatedAreaSquareUnits // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
