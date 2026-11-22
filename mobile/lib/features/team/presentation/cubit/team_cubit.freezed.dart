// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamState {

 ResultState<EstablishmentMembership?> get context; TeamSnapshot? get snapshot; ResultState<TeamSnapshot> get refresh; ResultState<TeamActionResult> get action; String get actionId;
/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamStateCopyWith<TeamState> get copyWith => _$TeamStateCopyWithImpl<TeamState>(this as TeamState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamState&&(identical(other.context, context) || other.context == context)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.action, action) || other.action == action)&&(identical(other.actionId, actionId) || other.actionId == actionId));
}


@override
int get hashCode => Object.hash(runtimeType,context,snapshot,refresh,action,actionId);

@override
String toString() {
  return 'TeamState(context: $context, snapshot: $snapshot, refresh: $refresh, action: $action, actionId: $actionId)';
}


}

/// @nodoc
abstract mixin class $TeamStateCopyWith<$Res>  {
  factory $TeamStateCopyWith(TeamState value, $Res Function(TeamState) _then) = _$TeamStateCopyWithImpl;
@useResult
$Res call({
 ResultState<EstablishmentMembership?> context, TeamSnapshot? snapshot, ResultState<TeamSnapshot> refresh, ResultState<TeamActionResult> action, String actionId
});


$ResultStateCopyWith<EstablishmentMembership?, $Res> get context;$ResultStateCopyWith<TeamSnapshot, $Res> get refresh;$ResultStateCopyWith<({({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})? created, TeamNotice? notice, DomainException? persistenceError}), $Res> get action;

}
/// @nodoc
class _$TeamStateCopyWithImpl<$Res>
    implements $TeamStateCopyWith<$Res> {
  _$TeamStateCopyWithImpl(this._self, this._then);

  final TeamState _self;
  final $Res Function(TeamState) _then;

/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? context = null,Object? snapshot = freezed,Object? refresh = null,Object? action = null,Object? actionId = null,}) {
  return _then(_self.copyWith(
context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ResultState<EstablishmentMembership?>,snapshot: freezed == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TeamSnapshot?,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as ResultState<TeamSnapshot>,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ResultState<TeamActionResult>,actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<EstablishmentMembership?, $Res> get context {
  
  return $ResultStateCopyWith<EstablishmentMembership?, $Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<TeamSnapshot, $Res> get refresh {
  
  return $ResultStateCopyWith<TeamSnapshot, $Res>(_self.refresh, (value) {
    return _then(_self.copyWith(refresh: value));
  });
}/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<({({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})? created, TeamNotice? notice, DomainException? persistenceError}), $Res> get action {
  
  return $ResultStateCopyWith<({({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})? created, TeamNotice? notice, DomainException? persistenceError}), $Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamState].
extension TeamStatePatterns on TeamState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamState value)  $default,){
final _that = this;
switch (_that) {
case _TeamState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamState value)?  $default,){
final _that = this;
switch (_that) {
case _TeamState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<EstablishmentMembership?> context,  TeamSnapshot? snapshot,  ResultState<TeamSnapshot> refresh,  ResultState<TeamActionResult> action,  String actionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamState() when $default != null:
return $default(_that.context,_that.snapshot,_that.refresh,_that.action,_that.actionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<EstablishmentMembership?> context,  TeamSnapshot? snapshot,  ResultState<TeamSnapshot> refresh,  ResultState<TeamActionResult> action,  String actionId)  $default,) {final _that = this;
switch (_that) {
case _TeamState():
return $default(_that.context,_that.snapshot,_that.refresh,_that.action,_that.actionId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<EstablishmentMembership?> context,  TeamSnapshot? snapshot,  ResultState<TeamSnapshot> refresh,  ResultState<TeamActionResult> action,  String actionId)?  $default,) {final _that = this;
switch (_that) {
case _TeamState() when $default != null:
return $default(_that.context,_that.snapshot,_that.refresh,_that.action,_that.actionId);case _:
  return null;

}
}

}

/// @nodoc


class _TeamState extends TeamState {
  const _TeamState({this.context = const ResultState<EstablishmentMembership?>.initial(), this.snapshot, this.refresh = const ResultState<TeamSnapshot>.initial(), this.action = const ResultState<TeamActionResult>.initial(), this.actionId = ''}): super._();
  

@override@JsonKey() final  ResultState<EstablishmentMembership?> context;
@override final  TeamSnapshot? snapshot;
@override@JsonKey() final  ResultState<TeamSnapshot> refresh;
@override@JsonKey() final  ResultState<TeamActionResult> action;
@override@JsonKey() final  String actionId;

/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamStateCopyWith<_TeamState> get copyWith => __$TeamStateCopyWithImpl<_TeamState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamState&&(identical(other.context, context) || other.context == context)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.refresh, refresh) || other.refresh == refresh)&&(identical(other.action, action) || other.action == action)&&(identical(other.actionId, actionId) || other.actionId == actionId));
}


@override
int get hashCode => Object.hash(runtimeType,context,snapshot,refresh,action,actionId);

@override
String toString() {
  return 'TeamState(context: $context, snapshot: $snapshot, refresh: $refresh, action: $action, actionId: $actionId)';
}


}

/// @nodoc
abstract mixin class _$TeamStateCopyWith<$Res> implements $TeamStateCopyWith<$Res> {
  factory _$TeamStateCopyWith(_TeamState value, $Res Function(_TeamState) _then) = __$TeamStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<EstablishmentMembership?> context, TeamSnapshot? snapshot, ResultState<TeamSnapshot> refresh, ResultState<TeamActionResult> action, String actionId
});


@override $ResultStateCopyWith<EstablishmentMembership?, $Res> get context;@override $ResultStateCopyWith<TeamSnapshot, $Res> get refresh;@override $ResultStateCopyWith<({({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})? created, TeamNotice? notice, DomainException? persistenceError}), $Res> get action;

}
/// @nodoc
class __$TeamStateCopyWithImpl<$Res>
    implements _$TeamStateCopyWith<$Res> {
  __$TeamStateCopyWithImpl(this._self, this._then);

  final _TeamState _self;
  final $Res Function(_TeamState) _then;

/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? context = null,Object? snapshot = freezed,Object? refresh = null,Object? action = null,Object? actionId = null,}) {
  return _then(_TeamState(
context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ResultState<EstablishmentMembership?>,snapshot: freezed == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TeamSnapshot?,refresh: null == refresh ? _self.refresh : refresh // ignore: cast_nullable_to_non_nullable
as ResultState<TeamSnapshot>,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ResultState<TeamActionResult>,actionId: null == actionId ? _self.actionId : actionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<EstablishmentMembership?, $Res> get context {
  
  return $ResultStateCopyWith<EstablishmentMembership?, $Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<TeamSnapshot, $Res> get refresh {
  
  return $ResultStateCopyWith<TeamSnapshot, $Res>(_self.refresh, (value) {
    return _then(_self.copyWith(refresh: value));
  });
}/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<({({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})? created, TeamNotice? notice, DomainException? persistenceError}), $Res> get action {
  
  return $ResultStateCopyWith<({({String code, ({DateTime createdAt, String email, bool emailSent, DateTime expiresAt, String id, bool isExpired, UserRole role}) invitation})? created, TeamNotice? notice, DomainException? persistenceError}), $Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}

// dart format on
