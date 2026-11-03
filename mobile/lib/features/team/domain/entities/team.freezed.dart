// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamSnapshot {

 List<TeamMember> get members; List<TeamInvitation> get invitations; DateTime get fetchedAt; bool get isComplete;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamSnapshot&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.invitations, invitations)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(invitations),fetchedAt,isComplete);

@override
String toString() {
  return 'TeamSnapshot(members: $members, invitations: $invitations, fetchedAt: $fetchedAt, isComplete: $isComplete)';
}


}





/// @nodoc


class _TeamSnapshot extends TeamSnapshot {
  const _TeamSnapshot({required final  List<TeamMember> members, required final  List<TeamInvitation> invitations, required this.fetchedAt, this.isComplete = true}): _members = members,_invitations = invitations,super._();
  

 final  List<TeamMember> _members;
@override List<TeamMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<TeamInvitation> _invitations;
@override List<TeamInvitation> get invitations {
  if (_invitations is EqualUnmodifiableListView) return _invitations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitations);
}

@override final  DateTime fetchedAt;
@override@JsonKey() final  bool isComplete;




@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamSnapshot&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._invitations, _invitations)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_invitations),fetchedAt,isComplete);

@override
String toString() {
  return 'TeamSnapshot._value(members: $members, invitations: $invitations, fetchedAt: $fetchedAt, isComplete: $isComplete)';
}


}




/// @nodoc
mixin _$TeamMutation<T> {

 T get value; TeamChange get change; TeamSnapshot get snapshot; DomainException? get persistenceError;
/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMutationCopyWith<T, TeamMutation<T>> get copyWith => _$TeamMutationCopyWithImpl<T, TeamMutation<T>>(this as TeamMutation<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMutation<T>&&const DeepCollectionEquality().equals(other.value, value)&&(identical(other.change, change) || other.change == change)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.persistenceError, persistenceError) || other.persistenceError == persistenceError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value),change,snapshot,persistenceError);

@override
String toString() {
  return 'TeamMutation<$T>(value: $value, change: $change, snapshot: $snapshot, persistenceError: $persistenceError)';
}


}

/// @nodoc
abstract mixin class $TeamMutationCopyWith<T,$Res>  {
  factory $TeamMutationCopyWith(TeamMutation<T> value, $Res Function(TeamMutation<T>) _then) = _$TeamMutationCopyWithImpl;
@useResult
$Res call({
 T value, TeamChange change, TeamSnapshot snapshot, DomainException? persistenceError
});


$TeamChangeCopyWith<$Res> get change;$DomainExceptionCopyWith<$Res>? get persistenceError;

}
/// @nodoc
class _$TeamMutationCopyWithImpl<T,$Res>
    implements $TeamMutationCopyWith<T, $Res> {
  _$TeamMutationCopyWithImpl(this._self, this._then);

  final TeamMutation<T> _self;
  final $Res Function(TeamMutation<T>) _then;

/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = freezed,Object? change = null,Object? snapshot = null,Object? persistenceError = freezed,}) {
  return _then(_self.copyWith(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as TeamChange,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TeamSnapshot,persistenceError: freezed == persistenceError ? _self.persistenceError : persistenceError // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}
/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamChangeCopyWith<$Res> get change {
  
  return $TeamChangeCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get persistenceError {
    if (_self.persistenceError == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.persistenceError!, (value) {
    return _then(_self.copyWith(persistenceError: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamMutation].
extension TeamMutationPatterns<T> on TeamMutation<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMutation<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMutation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMutation<T> value)  $default,){
final _that = this;
switch (_that) {
case _TeamMutation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMutation<T> value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMutation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T value,  TeamChange change,  TeamSnapshot snapshot,  DomainException? persistenceError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMutation() when $default != null:
return $default(_that.value,_that.change,_that.snapshot,_that.persistenceError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T value,  TeamChange change,  TeamSnapshot snapshot,  DomainException? persistenceError)  $default,) {final _that = this;
switch (_that) {
case _TeamMutation():
return $default(_that.value,_that.change,_that.snapshot,_that.persistenceError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T value,  TeamChange change,  TeamSnapshot snapshot,  DomainException? persistenceError)?  $default,) {final _that = this;
switch (_that) {
case _TeamMutation() when $default != null:
return $default(_that.value,_that.change,_that.snapshot,_that.persistenceError);case _:
  return null;

}
}

}

/// @nodoc


class _TeamMutation<T> extends TeamMutation<T> {
  const _TeamMutation({required this.value, required this.change, required this.snapshot, this.persistenceError}): super._();
  

@override final  T value;
@override final  TeamChange change;
@override final  TeamSnapshot snapshot;
@override final  DomainException? persistenceError;

/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMutationCopyWith<T, _TeamMutation<T>> get copyWith => __$TeamMutationCopyWithImpl<T, _TeamMutation<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMutation<T>&&const DeepCollectionEquality().equals(other.value, value)&&(identical(other.change, change) || other.change == change)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.persistenceError, persistenceError) || other.persistenceError == persistenceError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value),change,snapshot,persistenceError);

@override
String toString() {
  return 'TeamMutation<$T>(value: $value, change: $change, snapshot: $snapshot, persistenceError: $persistenceError)';
}


}

/// @nodoc
abstract mixin class _$TeamMutationCopyWith<T,$Res> implements $TeamMutationCopyWith<T, $Res> {
  factory _$TeamMutationCopyWith(_TeamMutation<T> value, $Res Function(_TeamMutation<T>) _then) = __$TeamMutationCopyWithImpl;
@override @useResult
$Res call({
 T value, TeamChange change, TeamSnapshot snapshot, DomainException? persistenceError
});


@override $TeamChangeCopyWith<$Res> get change;@override $DomainExceptionCopyWith<$Res>? get persistenceError;

}
/// @nodoc
class __$TeamMutationCopyWithImpl<T,$Res>
    implements _$TeamMutationCopyWith<T, $Res> {
  __$TeamMutationCopyWithImpl(this._self, this._then);

  final _TeamMutation<T> _self;
  final $Res Function(_TeamMutation<T>) _then;

/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = freezed,Object? change = null,Object? snapshot = null,Object? persistenceError = freezed,}) {
  return _then(_TeamMutation<T>(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as TeamChange,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as TeamSnapshot,persistenceError: freezed == persistenceError ? _self.persistenceError : persistenceError // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}

/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamChangeCopyWith<$Res> get change {
  
  return $TeamChangeCopyWith<$Res>(_self.change, (value) {
    return _then(_self.copyWith(change: value));
  });
}/// Create a copy of TeamMutation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get persistenceError {
    if (_self.persistenceError == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.persistenceError!, (value) {
    return _then(_self.copyWith(persistenceError: value));
  });
}
}

/// @nodoc
mixin _$TeamChange {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamChange);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TeamChange()';
}


}

/// @nodoc
class $TeamChangeCopyWith<$Res>  {
$TeamChangeCopyWith(TeamChange _, $Res Function(TeamChange) __);
}


/// Adds pattern-matching-related methods to [TeamChange].
extension TeamChangePatterns on TeamChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChangedInvitation value)?  invitation,TResult Function( CancelledInvitation value)?  cancelled,TResult Function( RemovedTeamMember value)?  removed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChangedInvitation() when invitation != null:
return invitation(_that);case CancelledInvitation() when cancelled != null:
return cancelled(_that);case RemovedTeamMember() when removed != null:
return removed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChangedInvitation value)  invitation,required TResult Function( CancelledInvitation value)  cancelled,required TResult Function( RemovedTeamMember value)  removed,}){
final _that = this;
switch (_that) {
case ChangedInvitation():
return invitation(_that);case CancelledInvitation():
return cancelled(_that);case RemovedTeamMember():
return removed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChangedInvitation value)?  invitation,TResult? Function( CancelledInvitation value)?  cancelled,TResult? Function( RemovedTeamMember value)?  removed,}){
final _that = this;
switch (_that) {
case ChangedInvitation() when invitation != null:
return invitation(_that);case CancelledInvitation() when cancelled != null:
return cancelled(_that);case RemovedTeamMember() when removed != null:
return removed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TeamInvitation invitation)?  invitation,TResult Function( String invitationId)?  cancelled,TResult Function( String userId)?  removed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChangedInvitation() when invitation != null:
return invitation(_that.invitation);case CancelledInvitation() when cancelled != null:
return cancelled(_that.invitationId);case RemovedTeamMember() when removed != null:
return removed(_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TeamInvitation invitation)  invitation,required TResult Function( String invitationId)  cancelled,required TResult Function( String userId)  removed,}) {final _that = this;
switch (_that) {
case ChangedInvitation():
return invitation(_that.invitation);case CancelledInvitation():
return cancelled(_that.invitationId);case RemovedTeamMember():
return removed(_that.userId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TeamInvitation invitation)?  invitation,TResult? Function( String invitationId)?  cancelled,TResult? Function( String userId)?  removed,}) {final _that = this;
switch (_that) {
case ChangedInvitation() when invitation != null:
return invitation(_that.invitation);case CancelledInvitation() when cancelled != null:
return cancelled(_that.invitationId);case RemovedTeamMember() when removed != null:
return removed(_that.userId);case _:
  return null;

}
}

}

/// @nodoc


class ChangedInvitation extends TeamChange {
  const ChangedInvitation(this.invitation): super._();
  

 final  TeamInvitation invitation;

/// Create a copy of TeamChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangedInvitationCopyWith<ChangedInvitation> get copyWith => _$ChangedInvitationCopyWithImpl<ChangedInvitation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangedInvitation&&(identical(other.invitation, invitation) || other.invitation == invitation));
}


@override
int get hashCode => Object.hash(runtimeType,invitation);

@override
String toString() {
  return 'TeamChange.invitation(invitation: $invitation)';
}


}

/// @nodoc
abstract mixin class $ChangedInvitationCopyWith<$Res> implements $TeamChangeCopyWith<$Res> {
  factory $ChangedInvitationCopyWith(ChangedInvitation value, $Res Function(ChangedInvitation) _then) = _$ChangedInvitationCopyWithImpl;
@useResult
$Res call({
 TeamInvitation invitation
});




}
/// @nodoc
class _$ChangedInvitationCopyWithImpl<$Res>
    implements $ChangedInvitationCopyWith<$Res> {
  _$ChangedInvitationCopyWithImpl(this._self, this._then);

  final ChangedInvitation _self;
  final $Res Function(ChangedInvitation) _then;

/// Create a copy of TeamChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invitation = null,}) {
  return _then(ChangedInvitation(
null == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as TeamInvitation,
  ));
}


}

/// @nodoc


class CancelledInvitation extends TeamChange {
  const CancelledInvitation(this.invitationId): super._();
  

 final  String invitationId;

/// Create a copy of TeamChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelledInvitationCopyWith<CancelledInvitation> get copyWith => _$CancelledInvitationCopyWithImpl<CancelledInvitation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelledInvitation&&(identical(other.invitationId, invitationId) || other.invitationId == invitationId));
}


@override
int get hashCode => Object.hash(runtimeType,invitationId);

@override
String toString() {
  return 'TeamChange.cancelled(invitationId: $invitationId)';
}


}

/// @nodoc
abstract mixin class $CancelledInvitationCopyWith<$Res> implements $TeamChangeCopyWith<$Res> {
  factory $CancelledInvitationCopyWith(CancelledInvitation value, $Res Function(CancelledInvitation) _then) = _$CancelledInvitationCopyWithImpl;
@useResult
$Res call({
 String invitationId
});




}
/// @nodoc
class _$CancelledInvitationCopyWithImpl<$Res>
    implements $CancelledInvitationCopyWith<$Res> {
  _$CancelledInvitationCopyWithImpl(this._self, this._then);

  final CancelledInvitation _self;
  final $Res Function(CancelledInvitation) _then;

/// Create a copy of TeamChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invitationId = null,}) {
  return _then(CancelledInvitation(
null == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RemovedTeamMember extends TeamChange {
  const RemovedTeamMember(this.userId): super._();
  

 final  String userId;

/// Create a copy of TeamChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemovedTeamMemberCopyWith<RemovedTeamMember> get copyWith => _$RemovedTeamMemberCopyWithImpl<RemovedTeamMember>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemovedTeamMember&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'TeamChange.removed(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $RemovedTeamMemberCopyWith<$Res> implements $TeamChangeCopyWith<$Res> {
  factory $RemovedTeamMemberCopyWith(RemovedTeamMember value, $Res Function(RemovedTeamMember) _then) = _$RemovedTeamMemberCopyWithImpl;
@useResult
$Res call({
 String userId
});




}
/// @nodoc
class _$RemovedTeamMemberCopyWithImpl<$Res>
    implements $RemovedTeamMemberCopyWith<$Res> {
  _$RemovedTeamMemberCopyWithImpl(this._self, this._then);

  final RemovedTeamMember _self;
  final $Res Function(RemovedTeamMember) _then;

/// Create a copy of TeamChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(RemovedTeamMember(
null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TeamAcceptance {

 EstablishmentMembership get membership; DomainException? get persistenceError;
/// Create a copy of TeamAcceptance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamAcceptanceCopyWith<TeamAcceptance> get copyWith => _$TeamAcceptanceCopyWithImpl<TeamAcceptance>(this as TeamAcceptance, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamAcceptance&&(identical(other.membership, membership) || other.membership == membership)&&(identical(other.persistenceError, persistenceError) || other.persistenceError == persistenceError));
}


@override
int get hashCode => Object.hash(runtimeType,membership,persistenceError);

@override
String toString() {
  return 'TeamAcceptance(membership: $membership, persistenceError: $persistenceError)';
}


}

/// @nodoc
abstract mixin class $TeamAcceptanceCopyWith<$Res>  {
  factory $TeamAcceptanceCopyWith(TeamAcceptance value, $Res Function(TeamAcceptance) _then) = _$TeamAcceptanceCopyWithImpl;
@useResult
$Res call({
 EstablishmentMembership membership, DomainException? persistenceError
});


$DomainExceptionCopyWith<$Res>? get persistenceError;

}
/// @nodoc
class _$TeamAcceptanceCopyWithImpl<$Res>
    implements $TeamAcceptanceCopyWith<$Res> {
  _$TeamAcceptanceCopyWithImpl(this._self, this._then);

  final TeamAcceptance _self;
  final $Res Function(TeamAcceptance) _then;

/// Create a copy of TeamAcceptance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? membership = null,Object? persistenceError = freezed,}) {
  return _then(_self.copyWith(
membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as EstablishmentMembership,persistenceError: freezed == persistenceError ? _self.persistenceError : persistenceError // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}
/// Create a copy of TeamAcceptance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get persistenceError {
    if (_self.persistenceError == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.persistenceError!, (value) {
    return _then(_self.copyWith(persistenceError: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamAcceptance].
extension TeamAcceptancePatterns on TeamAcceptance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamAcceptance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamAcceptance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamAcceptance value)  $default,){
final _that = this;
switch (_that) {
case _TeamAcceptance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamAcceptance value)?  $default,){
final _that = this;
switch (_that) {
case _TeamAcceptance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EstablishmentMembership membership,  DomainException? persistenceError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamAcceptance() when $default != null:
return $default(_that.membership,_that.persistenceError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EstablishmentMembership membership,  DomainException? persistenceError)  $default,) {final _that = this;
switch (_that) {
case _TeamAcceptance():
return $default(_that.membership,_that.persistenceError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EstablishmentMembership membership,  DomainException? persistenceError)?  $default,) {final _that = this;
switch (_that) {
case _TeamAcceptance() when $default != null:
return $default(_that.membership,_that.persistenceError);case _:
  return null;

}
}

}

/// @nodoc


class _TeamAcceptance implements TeamAcceptance {
  const _TeamAcceptance({required this.membership, this.persistenceError});
  

@override final  EstablishmentMembership membership;
@override final  DomainException? persistenceError;

/// Create a copy of TeamAcceptance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamAcceptanceCopyWith<_TeamAcceptance> get copyWith => __$TeamAcceptanceCopyWithImpl<_TeamAcceptance>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamAcceptance&&(identical(other.membership, membership) || other.membership == membership)&&(identical(other.persistenceError, persistenceError) || other.persistenceError == persistenceError));
}


@override
int get hashCode => Object.hash(runtimeType,membership,persistenceError);

@override
String toString() {
  return 'TeamAcceptance(membership: $membership, persistenceError: $persistenceError)';
}


}

/// @nodoc
abstract mixin class _$TeamAcceptanceCopyWith<$Res> implements $TeamAcceptanceCopyWith<$Res> {
  factory _$TeamAcceptanceCopyWith(_TeamAcceptance value, $Res Function(_TeamAcceptance) _then) = __$TeamAcceptanceCopyWithImpl;
@override @useResult
$Res call({
 EstablishmentMembership membership, DomainException? persistenceError
});


@override $DomainExceptionCopyWith<$Res>? get persistenceError;

}
/// @nodoc
class __$TeamAcceptanceCopyWithImpl<$Res>
    implements _$TeamAcceptanceCopyWith<$Res> {
  __$TeamAcceptanceCopyWithImpl(this._self, this._then);

  final _TeamAcceptance _self;
  final $Res Function(_TeamAcceptance) _then;

/// Create a copy of TeamAcceptance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? membership = null,Object? persistenceError = freezed,}) {
  return _then(_TeamAcceptance(
membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as EstablishmentMembership,persistenceError: freezed == persistenceError ? _self.persistenceError : persistenceError // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}

/// Create a copy of TeamAcceptance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get persistenceError {
    if (_self.persistenceError == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.persistenceError!, (value) {
    return _then(_self.copyWith(persistenceError: value));
  });
}
}

// dart format on
