// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpState {

/// Etapa que la interfaz debe comunicar al usuario.
 SignUpStage get stage;/// Sesion persistida luego del auto-login exitoso.
 AuthSession? get session;/// Error bloqueante de registro o auto-login.
 DomainException? get error;/// Indica que el alta termino aunque un paso posterior haya fallado.
 bool get accountCreated;
/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpStateCopyWith<SignUpState> get copyWith => _$SignUpStateCopyWithImpl<SignUpState>(this as SignUpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpState&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.session, session) || other.session == session)&&(identical(other.error, error) || other.error == error)&&(identical(other.accountCreated, accountCreated) || other.accountCreated == accountCreated));
}


@override
int get hashCode => Object.hash(runtimeType,stage,session,error,accountCreated);

@override
String toString() {
  return 'SignUpState(stage: $stage, session: $session, error: $error, accountCreated: $accountCreated)';
}


}

/// @nodoc
abstract mixin class $SignUpStateCopyWith<$Res>  {
  factory $SignUpStateCopyWith(SignUpState value, $Res Function(SignUpState) _then) = _$SignUpStateCopyWithImpl;
@useResult
$Res call({
 SignUpStage stage, AuthSession? session, DomainException? error, bool accountCreated
});


$AuthSessionCopyWith<$Res>? get session;$DomainExceptionCopyWith<$Res>? get error;

}
/// @nodoc
class _$SignUpStateCopyWithImpl<$Res>
    implements $SignUpStateCopyWith<$Res> {
  _$SignUpStateCopyWithImpl(this._self, this._then);

  final SignUpState _self;
  final $Res Function(SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? session = freezed,Object? error = freezed,Object? accountCreated = null,}) {
  return _then(_self.copyWith(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as SignUpStage,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as AuthSession?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DomainException?,accountCreated: null == accountCreated ? _self.accountCreated : accountCreated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $AuthSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}/// Create a copy of SignUpState
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


/// Adds pattern-matching-related methods to [SignUpState].
extension SignUpStatePatterns on SignUpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpState value)  $default,){
final _that = this;
switch (_that) {
case _SignUpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpState value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SignUpStage stage,  AuthSession? session,  DomainException? error,  bool accountCreated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.stage,_that.session,_that.error,_that.accountCreated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SignUpStage stage,  AuthSession? session,  DomainException? error,  bool accountCreated)  $default,) {final _that = this;
switch (_that) {
case _SignUpState():
return $default(_that.stage,_that.session,_that.error,_that.accountCreated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SignUpStage stage,  AuthSession? session,  DomainException? error,  bool accountCreated)?  $default,) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.stage,_that.session,_that.error,_that.accountCreated);case _:
  return null;

}
}

}

/// @nodoc


class _SignUpState extends SignUpState {
  const _SignUpState({required this.stage, this.session, this.error, this.accountCreated = false}): super._();
  

/// Etapa que la interfaz debe comunicar al usuario.
@override final  SignUpStage stage;
/// Sesion persistida luego del auto-login exitoso.
@override final  AuthSession? session;
/// Error bloqueante de registro o auto-login.
@override final  DomainException? error;
/// Indica que el alta termino aunque un paso posterior haya fallado.
@override@JsonKey() final  bool accountCreated;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpStateCopyWith<_SignUpState> get copyWith => __$SignUpStateCopyWithImpl<_SignUpState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpState&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.session, session) || other.session == session)&&(identical(other.error, error) || other.error == error)&&(identical(other.accountCreated, accountCreated) || other.accountCreated == accountCreated));
}


@override
int get hashCode => Object.hash(runtimeType,stage,session,error,accountCreated);

@override
String toString() {
  return 'SignUpState(stage: $stage, session: $session, error: $error, accountCreated: $accountCreated)';
}


}

/// @nodoc
abstract mixin class _$SignUpStateCopyWith<$Res> implements $SignUpStateCopyWith<$Res> {
  factory _$SignUpStateCopyWith(_SignUpState value, $Res Function(_SignUpState) _then) = __$SignUpStateCopyWithImpl;
@override @useResult
$Res call({
 SignUpStage stage, AuthSession? session, DomainException? error, bool accountCreated
});


@override $AuthSessionCopyWith<$Res>? get session;@override $DomainExceptionCopyWith<$Res>? get error;

}
/// @nodoc
class __$SignUpStateCopyWithImpl<$Res>
    implements _$SignUpStateCopyWith<$Res> {
  __$SignUpStateCopyWithImpl(this._self, this._then);

  final _SignUpState _self;
  final $Res Function(_SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? session = freezed,Object? error = freezed,Object? accountCreated = null,}) {
  return _then(_SignUpState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as SignUpStage,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as AuthSession?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as DomainException?,accountCreated: null == accountCreated ? _self.accountCreated : accountCreated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $AuthSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}/// Create a copy of SignUpState
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
