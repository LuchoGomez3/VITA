// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registrar_animal_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegistrarAnimalState {

 RegistrarAnimalStatus get status; DomainException? get error;
/// Create a copy of RegistrarAnimalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrarAnimalStateCopyWith<RegistrarAnimalState> get copyWith => _$RegistrarAnimalStateCopyWithImpl<RegistrarAnimalState>(this as RegistrarAnimalState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrarAnimalState&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,error);

@override
String toString() {
  return 'RegistrarAnimalState(status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class $RegistrarAnimalStateCopyWith<$Res>  {
  factory $RegistrarAnimalStateCopyWith(RegistrarAnimalState value, $Res Function(RegistrarAnimalState) _then) = _$RegistrarAnimalStateCopyWithImpl;
@useResult
$Res call({
 RegistrarAnimalStatus status, DomainException? error
});


$DomainExceptionCopyWith<$Res>? get error;

}
/// @nodoc
class _$RegistrarAnimalStateCopyWithImpl<$Res>
    implements $RegistrarAnimalStateCopyWith<$Res> {
  _$RegistrarAnimalStateCopyWithImpl(this._self, this._then);

  final RegistrarAnimalState _self;
  final $Res Function(RegistrarAnimalState) _then;

/// Create a copy of RegistrarAnimalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RegistrarAnimalStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}
/// Create a copy of RegistrarAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegistrarAnimalState].
extension RegistrarAnimalStatePatterns on RegistrarAnimalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrarAnimalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrarAnimalState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrarAnimalState value)  $default,){
final _that = this;
switch (_that) {
case _RegistrarAnimalState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrarAnimalState value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrarAnimalState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegistrarAnimalStatus status,  DomainException? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrarAnimalState() when $default != null:
return $default(_that.status,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegistrarAnimalStatus status,  DomainException? error)  $default,) {final _that = this;
switch (_that) {
case _RegistrarAnimalState():
return $default(_that.status,_that.error);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegistrarAnimalStatus status,  DomainException? error)?  $default,) {final _that = this;
switch (_that) {
case _RegistrarAnimalState() when $default != null:
return $default(_that.status,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _RegistrarAnimalState implements RegistrarAnimalState {
  const _RegistrarAnimalState({this.status = RegistrarAnimalStatus.initial, this.error});
  

@override@JsonKey() final  RegistrarAnimalStatus status;
@override final  DomainException? error;

/// Create a copy of RegistrarAnimalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrarAnimalStateCopyWith<_RegistrarAnimalState> get copyWith => __$RegistrarAnimalStateCopyWithImpl<_RegistrarAnimalState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrarAnimalState&&(identical(other.status, status) || other.status == status)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,error);

@override
String toString() {
  return 'RegistrarAnimalState(status: $status, error: $error)';
}


}

/// @nodoc
abstract mixin class _$RegistrarAnimalStateCopyWith<$Res> implements $RegistrarAnimalStateCopyWith<$Res> {
  factory _$RegistrarAnimalStateCopyWith(_RegistrarAnimalState value, $Res Function(_RegistrarAnimalState) _then) = __$RegistrarAnimalStateCopyWithImpl;
@override @useResult
$Res call({
 RegistrarAnimalStatus status, DomainException? error
});


@override $DomainExceptionCopyWith<$Res>? get error;

}
/// @nodoc
class __$RegistrarAnimalStateCopyWithImpl<$Res>
    implements _$RegistrarAnimalStateCopyWith<$Res> {
  __$RegistrarAnimalStateCopyWithImpl(this._self, this._then);

  final _RegistrarAnimalState _self;
  final $Res Function(_RegistrarAnimalState) _then;

/// Create a copy of RegistrarAnimalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? error = freezed,}) {
  return _then(_RegistrarAnimalState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RegistrarAnimalStatus,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}

/// Create a copy of RegistrarAnimalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
