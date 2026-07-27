// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSessionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthSessionState()';
}


}

/// @nodoc
class $AuthSessionStateCopyWith<$Res>  {
$AuthSessionStateCopyWith(AuthSessionState _, $Res Function(AuthSessionState) __);
}


/// Adds pattern-matching-related methods to [AuthSessionState].
extension AuthSessionStatePatterns on AuthSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthSessionChecking value)?  checking,TResult Function( AuthSessionAuthenticated value)?  authenticated,TResult Function( AuthSessionUnauthenticated value)?  unauthenticated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthSessionChecking() when checking != null:
return checking(_that);case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that);case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthSessionChecking value)  checking,required TResult Function( AuthSessionAuthenticated value)  authenticated,required TResult Function( AuthSessionUnauthenticated value)  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthSessionChecking():
return checking(_that);case AuthSessionAuthenticated():
return authenticated(_that);case AuthSessionUnauthenticated():
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthSessionChecking value)?  checking,TResult? Function( AuthSessionAuthenticated value)?  authenticated,TResult? Function( AuthSessionUnauthenticated value)?  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthSessionChecking() when checking != null:
return checking(_that);case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that);case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  checking,TResult Function( AuthSession session)?  authenticated,TResult Function()?  unauthenticated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthSessionChecking() when checking != null:
return checking();case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that.session);case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  checking,required TResult Function( AuthSession session)  authenticated,required TResult Function()  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthSessionChecking():
return checking();case AuthSessionAuthenticated():
return authenticated(_that.session);case AuthSessionUnauthenticated():
return unauthenticated();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  checking,TResult? Function( AuthSession session)?  authenticated,TResult? Function()?  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthSessionChecking() when checking != null:
return checking();case AuthSessionAuthenticated() when authenticated != null:
return authenticated(_that.session);case AuthSessionUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
  return null;

}
}

}

/// @nodoc


class AuthSessionChecking implements AuthSessionState {
  const AuthSessionChecking();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionChecking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthSessionState.checking()';
}


}




/// @nodoc


class AuthSessionAuthenticated implements AuthSessionState {
  const AuthSessionAuthenticated(this.session);
  

 final  AuthSession session;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionAuthenticatedCopyWith<AuthSessionAuthenticated> get copyWith => _$AuthSessionAuthenticatedCopyWithImpl<AuthSessionAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionAuthenticated&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,session);

@override
String toString() {
  return 'AuthSessionState.authenticated(session: $session)';
}


}

/// @nodoc
abstract mixin class $AuthSessionAuthenticatedCopyWith<$Res> implements $AuthSessionStateCopyWith<$Res> {
  factory $AuthSessionAuthenticatedCopyWith(AuthSessionAuthenticated value, $Res Function(AuthSessionAuthenticated) _then) = _$AuthSessionAuthenticatedCopyWithImpl;
@useResult
$Res call({
 AuthSession session
});


$AuthSessionCopyWith<$Res> get session;

}
/// @nodoc
class _$AuthSessionAuthenticatedCopyWithImpl<$Res>
    implements $AuthSessionAuthenticatedCopyWith<$Res> {
  _$AuthSessionAuthenticatedCopyWithImpl(this._self, this._then);

  final AuthSessionAuthenticated _self;
  final $Res Function(AuthSessionAuthenticated) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,}) {
  return _then(AuthSessionAuthenticated(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as AuthSession,
  ));
}

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthSessionCopyWith<$Res> get session {
  
  return $AuthSessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc


class AuthSessionUnauthenticated implements AuthSessionState {
  const AuthSessionUnauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthSessionState.unauthenticated()';
}


}




// dart format on
