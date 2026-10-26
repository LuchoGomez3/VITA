// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_establishment_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JoinFlow {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinFlow);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'JoinFlow()';
}


}

/// @nodoc
class $JoinFlowCopyWith<$Res>  {
$JoinFlowCopyWith(JoinFlow _, $Res Function(JoinFlow) __);
}


/// Adds pattern-matching-related methods to [JoinFlow].
extension JoinFlowPatterns on JoinFlow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EnteringCode value)?  entering,TResult Function( ConfirmingInvitation value)?  confirming,TResult Function( JoinedEstablishment value)?  joined,TResult Function( RecoveringMembership value)?  recovery,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EnteringCode() when entering != null:
return entering(_that);case ConfirmingInvitation() when confirming != null:
return confirming(_that);case JoinedEstablishment() when joined != null:
return joined(_that);case RecoveringMembership() when recovery != null:
return recovery(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EnteringCode value)  entering,required TResult Function( ConfirmingInvitation value)  confirming,required TResult Function( JoinedEstablishment value)  joined,required TResult Function( RecoveringMembership value)  recovery,}){
final _that = this;
switch (_that) {
case EnteringCode():
return entering(_that);case ConfirmingInvitation():
return confirming(_that);case JoinedEstablishment():
return joined(_that);case RecoveringMembership():
return recovery(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EnteringCode value)?  entering,TResult? Function( ConfirmingInvitation value)?  confirming,TResult? Function( JoinedEstablishment value)?  joined,TResult? Function( RecoveringMembership value)?  recovery,}){
final _that = this;
switch (_that) {
case EnteringCode() when entering != null:
return entering(_that);case ConfirmingInvitation() when confirming != null:
return confirming(_that);case JoinedEstablishment() when joined != null:
return joined(_that);case RecoveringMembership() when recovery != null:
return recovery(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String code)?  entering,TResult Function( String code,  InvitationPreview preview)?  confirming,TResult Function( EstablishmentMembership membership,  InvitationPreview preview)?  joined,TResult Function( String code,  InvitationPreview preview)?  recovery,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EnteringCode() when entering != null:
return entering(_that.code);case ConfirmingInvitation() when confirming != null:
return confirming(_that.code,_that.preview);case JoinedEstablishment() when joined != null:
return joined(_that.membership,_that.preview);case RecoveringMembership() when recovery != null:
return recovery(_that.code,_that.preview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String code)  entering,required TResult Function( String code,  InvitationPreview preview)  confirming,required TResult Function( EstablishmentMembership membership,  InvitationPreview preview)  joined,required TResult Function( String code,  InvitationPreview preview)  recovery,}) {final _that = this;
switch (_that) {
case EnteringCode():
return entering(_that.code);case ConfirmingInvitation():
return confirming(_that.code,_that.preview);case JoinedEstablishment():
return joined(_that.membership,_that.preview);case RecoveringMembership():
return recovery(_that.code,_that.preview);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String code)?  entering,TResult? Function( String code,  InvitationPreview preview)?  confirming,TResult? Function( EstablishmentMembership membership,  InvitationPreview preview)?  joined,TResult? Function( String code,  InvitationPreview preview)?  recovery,}) {final _that = this;
switch (_that) {
case EnteringCode() when entering != null:
return entering(_that.code);case ConfirmingInvitation() when confirming != null:
return confirming(_that.code,_that.preview);case JoinedEstablishment() when joined != null:
return joined(_that.membership,_that.preview);case RecoveringMembership() when recovery != null:
return recovery(_that.code,_that.preview);case _:
  return null;

}
}

}

/// @nodoc


class EnteringCode implements JoinFlow {
  const EnteringCode({this.code = ''});
  

@JsonKey() final  String code;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnteringCodeCopyWith<EnteringCode> get copyWith => _$EnteringCodeCopyWithImpl<EnteringCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnteringCode&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'JoinFlow.entering(code: $code)';
}


}

/// @nodoc
abstract mixin class $EnteringCodeCopyWith<$Res> implements $JoinFlowCopyWith<$Res> {
  factory $EnteringCodeCopyWith(EnteringCode value, $Res Function(EnteringCode) _then) = _$EnteringCodeCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$EnteringCodeCopyWithImpl<$Res>
    implements $EnteringCodeCopyWith<$Res> {
  _$EnteringCodeCopyWithImpl(this._self, this._then);

  final EnteringCode _self;
  final $Res Function(EnteringCode) _then;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(EnteringCode(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ConfirmingInvitation implements JoinFlow {
  const ConfirmingInvitation({required this.code, required this.preview});
  

 final  String code;
 final  InvitationPreview preview;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfirmingInvitationCopyWith<ConfirmingInvitation> get copyWith => _$ConfirmingInvitationCopyWithImpl<ConfirmingInvitation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfirmingInvitation&&(identical(other.code, code) || other.code == code)&&(identical(other.preview, preview) || other.preview == preview));
}


@override
int get hashCode => Object.hash(runtimeType,code,preview);

@override
String toString() {
  return 'JoinFlow.confirming(code: $code, preview: $preview)';
}


}

/// @nodoc
abstract mixin class $ConfirmingInvitationCopyWith<$Res> implements $JoinFlowCopyWith<$Res> {
  factory $ConfirmingInvitationCopyWith(ConfirmingInvitation value, $Res Function(ConfirmingInvitation) _then) = _$ConfirmingInvitationCopyWithImpl;
@useResult
$Res call({
 String code, InvitationPreview preview
});




}
/// @nodoc
class _$ConfirmingInvitationCopyWithImpl<$Res>
    implements $ConfirmingInvitationCopyWith<$Res> {
  _$ConfirmingInvitationCopyWithImpl(this._self, this._then);

  final ConfirmingInvitation _self;
  final $Res Function(ConfirmingInvitation) _then;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? preview = null,}) {
  return _then(ConfirmingInvitation(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as InvitationPreview,
  ));
}


}

/// @nodoc


class JoinedEstablishment implements JoinFlow {
  const JoinedEstablishment({required this.membership, required this.preview});
  

 final  EstablishmentMembership membership;
 final  InvitationPreview preview;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinedEstablishmentCopyWith<JoinedEstablishment> get copyWith => _$JoinedEstablishmentCopyWithImpl<JoinedEstablishment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinedEstablishment&&(identical(other.membership, membership) || other.membership == membership)&&(identical(other.preview, preview) || other.preview == preview));
}


@override
int get hashCode => Object.hash(runtimeType,membership,preview);

@override
String toString() {
  return 'JoinFlow.joined(membership: $membership, preview: $preview)';
}


}

/// @nodoc
abstract mixin class $JoinedEstablishmentCopyWith<$Res> implements $JoinFlowCopyWith<$Res> {
  factory $JoinedEstablishmentCopyWith(JoinedEstablishment value, $Res Function(JoinedEstablishment) _then) = _$JoinedEstablishmentCopyWithImpl;
@useResult
$Res call({
 EstablishmentMembership membership, InvitationPreview preview
});




}
/// @nodoc
class _$JoinedEstablishmentCopyWithImpl<$Res>
    implements $JoinedEstablishmentCopyWith<$Res> {
  _$JoinedEstablishmentCopyWithImpl(this._self, this._then);

  final JoinedEstablishment _self;
  final $Res Function(JoinedEstablishment) _then;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? membership = null,Object? preview = null,}) {
  return _then(JoinedEstablishment(
membership: null == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as EstablishmentMembership,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as InvitationPreview,
  ));
}


}

/// @nodoc


class RecoveringMembership implements JoinFlow {
  const RecoveringMembership({required this.code, required this.preview});
  

 final  String code;
 final  InvitationPreview preview;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveringMembershipCopyWith<RecoveringMembership> get copyWith => _$RecoveringMembershipCopyWithImpl<RecoveringMembership>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveringMembership&&(identical(other.code, code) || other.code == code)&&(identical(other.preview, preview) || other.preview == preview));
}


@override
int get hashCode => Object.hash(runtimeType,code,preview);

@override
String toString() {
  return 'JoinFlow.recovery(code: $code, preview: $preview)';
}


}

/// @nodoc
abstract mixin class $RecoveringMembershipCopyWith<$Res> implements $JoinFlowCopyWith<$Res> {
  factory $RecoveringMembershipCopyWith(RecoveringMembership value, $Res Function(RecoveringMembership) _then) = _$RecoveringMembershipCopyWithImpl;
@useResult
$Res call({
 String code, InvitationPreview preview
});




}
/// @nodoc
class _$RecoveringMembershipCopyWithImpl<$Res>
    implements $RecoveringMembershipCopyWith<$Res> {
  _$RecoveringMembershipCopyWithImpl(this._self, this._then);

  final RecoveringMembership _self;
  final $Res Function(RecoveringMembership) _then;

/// Create a copy of JoinFlow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? preview = null,}) {
  return _then(RecoveringMembership(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,preview: null == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as InvitationPreview,
  ));
}


}

/// @nodoc
mixin _$JoinEstablishmentState {

 JoinFlow get flow; ResultState<InvitationPreview> get validation; ResultState<TeamAcceptance> get acceptance; ResultState<void> get persistence; ResultState<PostAuthenticationSummary> get download;
/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinEstablishmentStateCopyWith<JoinEstablishmentState> get copyWith => _$JoinEstablishmentStateCopyWithImpl<JoinEstablishmentState>(this as JoinEstablishmentState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinEstablishmentState&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.acceptance, acceptance) || other.acceptance == acceptance)&&(identical(other.persistence, persistence) || other.persistence == persistence)&&(identical(other.download, download) || other.download == download));
}


@override
int get hashCode => Object.hash(runtimeType,flow,validation,acceptance,persistence,download);

@override
String toString() {
  return 'JoinEstablishmentState(flow: $flow, validation: $validation, acceptance: $acceptance, persistence: $persistence, download: $download)';
}


}

/// @nodoc
abstract mixin class $JoinEstablishmentStateCopyWith<$Res>  {
  factory $JoinEstablishmentStateCopyWith(JoinEstablishmentState value, $Res Function(JoinEstablishmentState) _then) = _$JoinEstablishmentStateCopyWithImpl;
@useResult
$Res call({
 JoinFlow flow, ResultState<InvitationPreview> validation, ResultState<TeamAcceptance> acceptance, ResultState<void> persistence, ResultState<PostAuthenticationSummary> download
});


$JoinFlowCopyWith<$Res> get flow;$ResultStateCopyWith<({String email, String establishmentId, String establishmentName, DateTime expiresAt, String invitedBy, UserRole? invitedByRole, String? locality, String? province, String? renspa, UserRole role}), $Res> get validation;$ResultStateCopyWith<TeamAcceptance, $Res> get acceptance;$ResultStateCopyWith<void, $Res> get persistence;$ResultStateCopyWith<PostAuthenticationSummary, $Res> get download;

}
/// @nodoc
class _$JoinEstablishmentStateCopyWithImpl<$Res>
    implements $JoinEstablishmentStateCopyWith<$Res> {
  _$JoinEstablishmentStateCopyWithImpl(this._self, this._then);

  final JoinEstablishmentState _self;
  final $Res Function(JoinEstablishmentState) _then;

/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? flow = null,Object? validation = null,Object? acceptance = null,Object? persistence = null,Object? download = null,}) {
  return _then(_self.copyWith(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as JoinFlow,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ResultState<InvitationPreview>,acceptance: null == acceptance ? _self.acceptance : acceptance // ignore: cast_nullable_to_non_nullable
as ResultState<TeamAcceptance>,persistence: null == persistence ? _self.persistence : persistence // ignore: cast_nullable_to_non_nullable
as ResultState<void>,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as ResultState<PostAuthenticationSummary>,
  ));
}
/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JoinFlowCopyWith<$Res> get flow {
  
  return $JoinFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<({String email, String establishmentId, String establishmentName, DateTime expiresAt, String invitedBy, UserRole? invitedByRole, String? locality, String? province, String? renspa, UserRole role}), $Res> get validation {
  
  return $ResultStateCopyWith<({String email, String establishmentId, String establishmentName, DateTime expiresAt, String invitedBy, UserRole? invitedByRole, String? locality, String? province, String? renspa, UserRole role}), $Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<TeamAcceptance, $Res> get acceptance {
  
  return $ResultStateCopyWith<TeamAcceptance, $Res>(_self.acceptance, (value) {
    return _then(_self.copyWith(acceptance: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get persistence {
  
  return $ResultStateCopyWith<void, $Res>(_self.persistence, (value) {
    return _then(_self.copyWith(persistence: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<PostAuthenticationSummary, $Res> get download {
  
  return $ResultStateCopyWith<PostAuthenticationSummary, $Res>(_self.download, (value) {
    return _then(_self.copyWith(download: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinEstablishmentState].
extension JoinEstablishmentStatePatterns on JoinEstablishmentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinEstablishmentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinEstablishmentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinEstablishmentState value)  $default,){
final _that = this;
switch (_that) {
case _JoinEstablishmentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinEstablishmentState value)?  $default,){
final _that = this;
switch (_that) {
case _JoinEstablishmentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( JoinFlow flow,  ResultState<InvitationPreview> validation,  ResultState<TeamAcceptance> acceptance,  ResultState<void> persistence,  ResultState<PostAuthenticationSummary> download)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinEstablishmentState() when $default != null:
return $default(_that.flow,_that.validation,_that.acceptance,_that.persistence,_that.download);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( JoinFlow flow,  ResultState<InvitationPreview> validation,  ResultState<TeamAcceptance> acceptance,  ResultState<void> persistence,  ResultState<PostAuthenticationSummary> download)  $default,) {final _that = this;
switch (_that) {
case _JoinEstablishmentState():
return $default(_that.flow,_that.validation,_that.acceptance,_that.persistence,_that.download);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( JoinFlow flow,  ResultState<InvitationPreview> validation,  ResultState<TeamAcceptance> acceptance,  ResultState<void> persistence,  ResultState<PostAuthenticationSummary> download)?  $default,) {final _that = this;
switch (_that) {
case _JoinEstablishmentState() when $default != null:
return $default(_that.flow,_that.validation,_that.acceptance,_that.persistence,_that.download);case _:
  return null;

}
}

}

/// @nodoc


class _JoinEstablishmentState extends JoinEstablishmentState {
  const _JoinEstablishmentState({this.flow = const JoinFlow.entering(), this.validation = const ResultState<InvitationPreview>.initial(), this.acceptance = const ResultState<TeamAcceptance>.initial(), this.persistence = const ResultState<void>.initial(), this.download = const ResultState<PostAuthenticationSummary>.initial()}): super._();
  

@override@JsonKey() final  JoinFlow flow;
@override@JsonKey() final  ResultState<InvitationPreview> validation;
@override@JsonKey() final  ResultState<TeamAcceptance> acceptance;
@override@JsonKey() final  ResultState<void> persistence;
@override@JsonKey() final  ResultState<PostAuthenticationSummary> download;

/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinEstablishmentStateCopyWith<_JoinEstablishmentState> get copyWith => __$JoinEstablishmentStateCopyWithImpl<_JoinEstablishmentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinEstablishmentState&&(identical(other.flow, flow) || other.flow == flow)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.acceptance, acceptance) || other.acceptance == acceptance)&&(identical(other.persistence, persistence) || other.persistence == persistence)&&(identical(other.download, download) || other.download == download));
}


@override
int get hashCode => Object.hash(runtimeType,flow,validation,acceptance,persistence,download);

@override
String toString() {
  return 'JoinEstablishmentState(flow: $flow, validation: $validation, acceptance: $acceptance, persistence: $persistence, download: $download)';
}


}

/// @nodoc
abstract mixin class _$JoinEstablishmentStateCopyWith<$Res> implements $JoinEstablishmentStateCopyWith<$Res> {
  factory _$JoinEstablishmentStateCopyWith(_JoinEstablishmentState value, $Res Function(_JoinEstablishmentState) _then) = __$JoinEstablishmentStateCopyWithImpl;
@override @useResult
$Res call({
 JoinFlow flow, ResultState<InvitationPreview> validation, ResultState<TeamAcceptance> acceptance, ResultState<void> persistence, ResultState<PostAuthenticationSummary> download
});


@override $JoinFlowCopyWith<$Res> get flow;@override $ResultStateCopyWith<({String email, String establishmentId, String establishmentName, DateTime expiresAt, String invitedBy, UserRole? invitedByRole, String? locality, String? province, String? renspa, UserRole role}), $Res> get validation;@override $ResultStateCopyWith<TeamAcceptance, $Res> get acceptance;@override $ResultStateCopyWith<void, $Res> get persistence;@override $ResultStateCopyWith<PostAuthenticationSummary, $Res> get download;

}
/// @nodoc
class __$JoinEstablishmentStateCopyWithImpl<$Res>
    implements _$JoinEstablishmentStateCopyWith<$Res> {
  __$JoinEstablishmentStateCopyWithImpl(this._self, this._then);

  final _JoinEstablishmentState _self;
  final $Res Function(_JoinEstablishmentState) _then;

/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? flow = null,Object? validation = null,Object? acceptance = null,Object? persistence = null,Object? download = null,}) {
  return _then(_JoinEstablishmentState(
flow: null == flow ? _self.flow : flow // ignore: cast_nullable_to_non_nullable
as JoinFlow,validation: null == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as ResultState<InvitationPreview>,acceptance: null == acceptance ? _self.acceptance : acceptance // ignore: cast_nullable_to_non_nullable
as ResultState<TeamAcceptance>,persistence: null == persistence ? _self.persistence : persistence // ignore: cast_nullable_to_non_nullable
as ResultState<void>,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as ResultState<PostAuthenticationSummary>,
  ));
}

/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JoinFlowCopyWith<$Res> get flow {
  
  return $JoinFlowCopyWith<$Res>(_self.flow, (value) {
    return _then(_self.copyWith(flow: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<({String email, String establishmentId, String establishmentName, DateTime expiresAt, String invitedBy, UserRole? invitedByRole, String? locality, String? province, String? renspa, UserRole role}), $Res> get validation {
  
  return $ResultStateCopyWith<({String email, String establishmentId, String establishmentName, DateTime expiresAt, String invitedBy, UserRole? invitedByRole, String? locality, String? province, String? renspa, UserRole role}), $Res>(_self.validation, (value) {
    return _then(_self.copyWith(validation: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<TeamAcceptance, $Res> get acceptance {
  
  return $ResultStateCopyWith<TeamAcceptance, $Res>(_self.acceptance, (value) {
    return _then(_self.copyWith(acceptance: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get persistence {
  
  return $ResultStateCopyWith<void, $Res>(_self.persistence, (value) {
    return _then(_self.copyWith(persistence: value));
  });
}/// Create a copy of JoinEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<PostAuthenticationSummary, $Res> get download {
  
  return $ResultStateCopyWith<PostAuthenticationSummary, $Res>(_self.download, (value) {
    return _then(_self.copyWith(download: value));
  });
}
}

// dart format on
