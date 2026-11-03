// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_team_member_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InviteTeamMemberState {

 UserRole get role; ResultState<List<UserRole>> get initialization; ResultState<TeamMutation<CreatedInvitation>> get submission;
/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteTeamMemberStateCopyWith<InviteTeamMemberState> get copyWith => _$InviteTeamMemberStateCopyWithImpl<InviteTeamMemberState>(this as InviteTeamMemberState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteTeamMemberState&&(identical(other.role, role) || other.role == role)&&(identical(other.initialization, initialization) || other.initialization == initialization)&&(identical(other.submission, submission) || other.submission == submission));
}


@override
int get hashCode => Object.hash(runtimeType,role,initialization,submission);

@override
String toString() {
  return 'InviteTeamMemberState(role: $role, initialization: $initialization, submission: $submission)';
}


}

/// @nodoc
abstract mixin class $InviteTeamMemberStateCopyWith<$Res>  {
  factory $InviteTeamMemberStateCopyWith(InviteTeamMemberState value, $Res Function(InviteTeamMemberState) _then) = _$InviteTeamMemberStateCopyWithImpl;
@useResult
$Res call({
 UserRole role, ResultState<List<UserRole>> initialization, ResultState<TeamMutation<CreatedInvitation>> submission
});


$ResultStateCopyWith<List<UserRole>, $Res> get initialization;$ResultStateCopyWith<TeamMutation<({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})>, $Res> get submission;

}
/// @nodoc
class _$InviteTeamMemberStateCopyWithImpl<$Res>
    implements $InviteTeamMemberStateCopyWith<$Res> {
  _$InviteTeamMemberStateCopyWithImpl(this._self, this._then);

  final InviteTeamMemberState _self;
  final $Res Function(InviteTeamMemberState) _then;

/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? initialization = null,Object? submission = null,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,initialization: null == initialization ? _self.initialization : initialization // ignore: cast_nullable_to_non_nullable
as ResultState<List<UserRole>>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<TeamMutation<CreatedInvitation>>,
  ));
}
/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<UserRole>, $Res> get initialization {
  
  return $ResultStateCopyWith<List<UserRole>, $Res>(_self.initialization, (value) {
    return _then(_self.copyWith(initialization: value));
  });
}/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<TeamMutation<({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})>, $Res> get submission {
  
  return $ResultStateCopyWith<TeamMutation<({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})>, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}


/// Adds pattern-matching-related methods to [InviteTeamMemberState].
extension InviteTeamMemberStatePatterns on InviteTeamMemberState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteTeamMemberState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteTeamMemberState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteTeamMemberState value)  $default,){
final _that = this;
switch (_that) {
case _InviteTeamMemberState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteTeamMemberState value)?  $default,){
final _that = this;
switch (_that) {
case _InviteTeamMemberState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserRole role,  ResultState<List<UserRole>> initialization,  ResultState<TeamMutation<CreatedInvitation>> submission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteTeamMemberState() when $default != null:
return $default(_that.role,_that.initialization,_that.submission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserRole role,  ResultState<List<UserRole>> initialization,  ResultState<TeamMutation<CreatedInvitation>> submission)  $default,) {final _that = this;
switch (_that) {
case _InviteTeamMemberState():
return $default(_that.role,_that.initialization,_that.submission);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserRole role,  ResultState<List<UserRole>> initialization,  ResultState<TeamMutation<CreatedInvitation>> submission)?  $default,) {final _that = this;
switch (_that) {
case _InviteTeamMemberState() when $default != null:
return $default(_that.role,_that.initialization,_that.submission);case _:
  return null;

}
}

}

/// @nodoc


class _InviteTeamMemberState extends InviteTeamMemberState {
  const _InviteTeamMemberState({this.role = UserRole.employee, this.initialization = const ResultState<List<UserRole>>.initial(), this.submission = const ResultState<TeamMutation<CreatedInvitation>>.initial()}): super._();
  

@override@JsonKey() final  UserRole role;
@override@JsonKey() final  ResultState<List<UserRole>> initialization;
@override@JsonKey() final  ResultState<TeamMutation<CreatedInvitation>> submission;

/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteTeamMemberStateCopyWith<_InviteTeamMemberState> get copyWith => __$InviteTeamMemberStateCopyWithImpl<_InviteTeamMemberState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteTeamMemberState&&(identical(other.role, role) || other.role == role)&&(identical(other.initialization, initialization) || other.initialization == initialization)&&(identical(other.submission, submission) || other.submission == submission));
}


@override
int get hashCode => Object.hash(runtimeType,role,initialization,submission);

@override
String toString() {
  return 'InviteTeamMemberState(role: $role, initialization: $initialization, submission: $submission)';
}


}

/// @nodoc
abstract mixin class _$InviteTeamMemberStateCopyWith<$Res> implements $InviteTeamMemberStateCopyWith<$Res> {
  factory _$InviteTeamMemberStateCopyWith(_InviteTeamMemberState value, $Res Function(_InviteTeamMemberState) _then) = __$InviteTeamMemberStateCopyWithImpl;
@override @useResult
$Res call({
 UserRole role, ResultState<List<UserRole>> initialization, ResultState<TeamMutation<CreatedInvitation>> submission
});


@override $ResultStateCopyWith<List<UserRole>, $Res> get initialization;@override $ResultStateCopyWith<TeamMutation<({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})>, $Res> get submission;

}
/// @nodoc
class __$InviteTeamMemberStateCopyWithImpl<$Res>
    implements _$InviteTeamMemberStateCopyWith<$Res> {
  __$InviteTeamMemberStateCopyWithImpl(this._self, this._then);

  final _InviteTeamMemberState _self;
  final $Res Function(_InviteTeamMemberState) _then;

/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? initialization = null,Object? submission = null,}) {
  return _then(_InviteTeamMemberState(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,initialization: null == initialization ? _self.initialization : initialization // ignore: cast_nullable_to_non_nullable
as ResultState<List<UserRole>>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<TeamMutation<CreatedInvitation>>,
  ));
}

/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<UserRole>, $Res> get initialization {
  
  return $ResultStateCopyWith<List<UserRole>, $Res>(_self.initialization, (value) {
    return _then(_self.copyWith(initialization: value));
  });
}/// Create a copy of InviteTeamMemberState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<TeamMutation<({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})>, $Res> get submission {
  
  return $ResultStateCopyWith<TeamMutation<({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})>, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}

// dart format on
