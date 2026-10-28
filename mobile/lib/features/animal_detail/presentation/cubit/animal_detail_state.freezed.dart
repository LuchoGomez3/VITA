// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalDetailState {

 ResultState<AnimalDetail> get detail; ResultState<AnimalPhoto?> get photo;
/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalDetailStateCopyWith<AnimalDetailState> get copyWith => _$AnimalDetailStateCopyWithImpl<AnimalDetailState>(this as AnimalDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDetailState&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.photo, photo) || other.photo == photo));
}


@override
int get hashCode => Object.hash(runtimeType,detail,photo);

@override
String toString() {
  return 'AnimalDetailState(detail: $detail, photo: $photo)';
}


}

/// @nodoc
abstract mixin class $AnimalDetailStateCopyWith<$Res>  {
  factory $AnimalDetailStateCopyWith(AnimalDetailState value, $Res Function(AnimalDetailState) _then) = _$AnimalDetailStateCopyWithImpl;
@useResult
$Res call({
 ResultState<AnimalDetail> detail, ResultState<AnimalPhoto?> photo
});


$ResultStateCopyWith<AnimalDetail, $Res> get detail;$ResultStateCopyWith<AnimalPhoto?, $Res> get photo;

}
/// @nodoc
class _$AnimalDetailStateCopyWithImpl<$Res>
    implements $AnimalDetailStateCopyWith<$Res> {
  _$AnimalDetailStateCopyWithImpl(this._self, this._then);

  final AnimalDetailState _self;
  final $Res Function(AnimalDetailState) _then;

/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? detail = null,Object? photo = null,}) {
  return _then(_self.copyWith(
detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as ResultState<AnimalDetail>,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as ResultState<AnimalPhoto?>,
  ));
}
/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<AnimalDetail, $Res> get detail {

  return $ResultStateCopyWith<AnimalDetail, $Res>(_self.detail, (value) {
    return _then(_self.copyWith(detail: value));
  });
}/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<AnimalPhoto?, $Res> get photo {

  return $ResultStateCopyWith<AnimalPhoto?, $Res>(_self.photo, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnimalDetailState].
extension AnimalDetailStatePatterns on AnimalDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalDetailState value)  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<AnimalDetail> detail,  ResultState<AnimalPhoto?> photo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
return $default(_that.detail,_that.photo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<AnimalDetail> detail,  ResultState<AnimalPhoto?> photo)  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailState():
return $default(_that.detail,_that.photo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<AnimalDetail> detail,  ResultState<AnimalPhoto?> photo)?  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
return $default(_that.detail,_that.photo);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalDetailState implements AnimalDetailState {
  const _AnimalDetailState({required this.detail, required this.photo});


@override final  ResultState<AnimalDetail> detail;
@override final  ResultState<AnimalPhoto?> photo;

/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalDetailStateCopyWith<_AnimalDetailState> get copyWith => __$AnimalDetailStateCopyWithImpl<_AnimalDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalDetailState&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.photo, photo) || other.photo == photo));
}


@override
int get hashCode => Object.hash(runtimeType,detail,photo);

@override
String toString() {
  return 'AnimalDetailState(detail: $detail, photo: $photo)';
}


}

/// @nodoc
abstract mixin class _$AnimalDetailStateCopyWith<$Res> implements $AnimalDetailStateCopyWith<$Res> {
  factory _$AnimalDetailStateCopyWith(_AnimalDetailState value, $Res Function(_AnimalDetailState) _then) = __$AnimalDetailStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<AnimalDetail> detail, ResultState<AnimalPhoto?> photo
});


@override $ResultStateCopyWith<AnimalDetail, $Res> get detail;@override $ResultStateCopyWith<AnimalPhoto?, $Res> get photo;

}
/// @nodoc
class __$AnimalDetailStateCopyWithImpl<$Res>
    implements _$AnimalDetailStateCopyWith<$Res> {
  __$AnimalDetailStateCopyWithImpl(this._self, this._then);

  final _AnimalDetailState _self;
  final $Res Function(_AnimalDetailState) _then;

/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? detail = null,Object? photo = null,}) {
  return _then(_AnimalDetailState(
detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as ResultState<AnimalDetail>,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as ResultState<AnimalPhoto?>,
  ));
}

/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<AnimalDetail, $Res> get detail {

  return $ResultStateCopyWith<AnimalDetail, $Res>(_self.detail, (value) {
    return _then(_self.copyWith(detail: value));
  });
}/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<AnimalPhoto?, $Res> get photo {

  return $ResultStateCopyWith<AnimalPhoto?, $Res>(_self.photo, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}

// dart format on
