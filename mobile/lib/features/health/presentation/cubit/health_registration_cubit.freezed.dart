// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_registration_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthRegistrationState {

 List<EstablishmentMembership> get establishments; List<HealthRecipient> get recipients; String? get establishmentId; HealthCatalog? get catalog; ResultState<void> get preparation; ResultState<void> get submission; String? get selectionMessage; int get pendingReadings;
/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthRegistrationStateCopyWith<HealthRegistrationState> get copyWith => _$HealthRegistrationStateCopyWithImpl<HealthRegistrationState>(this as HealthRegistrationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthRegistrationState&&const DeepCollectionEquality().equals(other.establishments, establishments)&&const DeepCollectionEquality().equals(other.recipients, recipients)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.catalog, catalog) || other.catalog == catalog)&&(identical(other.preparation, preparation) || other.preparation == preparation)&&(identical(other.submission, submission) || other.submission == submission)&&(identical(other.selectionMessage, selectionMessage) || other.selectionMessage == selectionMessage)&&(identical(other.pendingReadings, pendingReadings) || other.pendingReadings == pendingReadings));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(establishments),const DeepCollectionEquality().hash(recipients),establishmentId,catalog,preparation,submission,selectionMessage,pendingReadings);

@override
String toString() {
  return 'HealthRegistrationState(establishments: $establishments, recipients: $recipients, establishmentId: $establishmentId, catalog: $catalog, preparation: $preparation, submission: $submission, selectionMessage: $selectionMessage, pendingReadings: $pendingReadings)';
}


}

/// @nodoc
abstract mixin class $HealthRegistrationStateCopyWith<$Res>  {
  factory $HealthRegistrationStateCopyWith(HealthRegistrationState value, $Res Function(HealthRegistrationState) _then) = _$HealthRegistrationStateCopyWithImpl;
@useResult
$Res call({
 List<EstablishmentMembership> establishments, List<HealthRecipient> recipients, String? establishmentId, HealthCatalog? catalog, ResultState<void> preparation, ResultState<void> submission, String? selectionMessage, int pendingReadings
});


$HealthCatalogCopyWith<$Res>? get catalog;$ResultStateCopyWith<void, $Res> get preparation;$ResultStateCopyWith<void, $Res> get submission;

}
/// @nodoc
class _$HealthRegistrationStateCopyWithImpl<$Res>
    implements $HealthRegistrationStateCopyWith<$Res> {
  _$HealthRegistrationStateCopyWithImpl(this._self, this._then);

  final HealthRegistrationState _self;
  final $Res Function(HealthRegistrationState) _then;

/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishments = null,Object? recipients = null,Object? establishmentId = freezed,Object? catalog = freezed,Object? preparation = null,Object? submission = null,Object? selectionMessage = freezed,Object? pendingReadings = null,}) {
  return _then(_self.copyWith(
establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as List<EstablishmentMembership>,recipients: null == recipients ? _self.recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<HealthRecipient>,establishmentId: freezed == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String?,catalog: freezed == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as HealthCatalog?,preparation: null == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as ResultState<void>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<void>,selectionMessage: freezed == selectionMessage ? _self.selectionMessage : selectionMessage // ignore: cast_nullable_to_non_nullable
as String?,pendingReadings: null == pendingReadings ? _self.pendingReadings : pendingReadings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthCatalogCopyWith<$Res>? get catalog {
    if (_self.catalog == null) {
    return null;
  }

  return $HealthCatalogCopyWith<$Res>(_self.catalog!, (value) {
    return _then(_self.copyWith(catalog: value));
  });
}/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get preparation {
  
  return $ResultStateCopyWith<void, $Res>(_self.preparation, (value) {
    return _then(_self.copyWith(preparation: value));
  });
}/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get submission {
  
  return $ResultStateCopyWith<void, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}


/// Adds pattern-matching-related methods to [HealthRegistrationState].
extension HealthRegistrationStatePatterns on HealthRegistrationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthRegistrationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthRegistrationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthRegistrationState value)  $default,){
final _that = this;
switch (_that) {
case _HealthRegistrationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthRegistrationState value)?  $default,){
final _that = this;
switch (_that) {
case _HealthRegistrationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<EstablishmentMembership> establishments,  List<HealthRecipient> recipients,  String? establishmentId,  HealthCatalog? catalog,  ResultState<void> preparation,  ResultState<void> submission,  String? selectionMessage,  int pendingReadings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthRegistrationState() when $default != null:
return $default(_that.establishments,_that.recipients,_that.establishmentId,_that.catalog,_that.preparation,_that.submission,_that.selectionMessage,_that.pendingReadings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<EstablishmentMembership> establishments,  List<HealthRecipient> recipients,  String? establishmentId,  HealthCatalog? catalog,  ResultState<void> preparation,  ResultState<void> submission,  String? selectionMessage,  int pendingReadings)  $default,) {final _that = this;
switch (_that) {
case _HealthRegistrationState():
return $default(_that.establishments,_that.recipients,_that.establishmentId,_that.catalog,_that.preparation,_that.submission,_that.selectionMessage,_that.pendingReadings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<EstablishmentMembership> establishments,  List<HealthRecipient> recipients,  String? establishmentId,  HealthCatalog? catalog,  ResultState<void> preparation,  ResultState<void> submission,  String? selectionMessage,  int pendingReadings)?  $default,) {final _that = this;
switch (_that) {
case _HealthRegistrationState() when $default != null:
return $default(_that.establishments,_that.recipients,_that.establishmentId,_that.catalog,_that.preparation,_that.submission,_that.selectionMessage,_that.pendingReadings);case _:
  return null;

}
}

}

/// @nodoc


class _HealthRegistrationState implements HealthRegistrationState {
  const _HealthRegistrationState({final  List<EstablishmentMembership> establishments = const [], final  List<HealthRecipient> recipients = const [], this.establishmentId, this.catalog, this.preparation = const ResultState<void>.initial(), this.submission = const ResultState<void>.initial(), this.selectionMessage, this.pendingReadings = 0}): _establishments = establishments,_recipients = recipients;
  

 final  List<EstablishmentMembership> _establishments;
@override@JsonKey() List<EstablishmentMembership> get establishments {
  if (_establishments is EqualUnmodifiableListView) return _establishments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_establishments);
}

 final  List<HealthRecipient> _recipients;
@override@JsonKey() List<HealthRecipient> get recipients {
  if (_recipients is EqualUnmodifiableListView) return _recipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipients);
}

@override final  String? establishmentId;
@override final  HealthCatalog? catalog;
@override@JsonKey() final  ResultState<void> preparation;
@override@JsonKey() final  ResultState<void> submission;
@override final  String? selectionMessage;
@override@JsonKey() final  int pendingReadings;

/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthRegistrationStateCopyWith<_HealthRegistrationState> get copyWith => __$HealthRegistrationStateCopyWithImpl<_HealthRegistrationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthRegistrationState&&const DeepCollectionEquality().equals(other._establishments, _establishments)&&const DeepCollectionEquality().equals(other._recipients, _recipients)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.catalog, catalog) || other.catalog == catalog)&&(identical(other.preparation, preparation) || other.preparation == preparation)&&(identical(other.submission, submission) || other.submission == submission)&&(identical(other.selectionMessage, selectionMessage) || other.selectionMessage == selectionMessage)&&(identical(other.pendingReadings, pendingReadings) || other.pendingReadings == pendingReadings));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_establishments),const DeepCollectionEquality().hash(_recipients),establishmentId,catalog,preparation,submission,selectionMessage,pendingReadings);

@override
String toString() {
  return 'HealthRegistrationState(establishments: $establishments, recipients: $recipients, establishmentId: $establishmentId, catalog: $catalog, preparation: $preparation, submission: $submission, selectionMessage: $selectionMessage, pendingReadings: $pendingReadings)';
}


}

/// @nodoc
abstract mixin class _$HealthRegistrationStateCopyWith<$Res> implements $HealthRegistrationStateCopyWith<$Res> {
  factory _$HealthRegistrationStateCopyWith(_HealthRegistrationState value, $Res Function(_HealthRegistrationState) _then) = __$HealthRegistrationStateCopyWithImpl;
@override @useResult
$Res call({
 List<EstablishmentMembership> establishments, List<HealthRecipient> recipients, String? establishmentId, HealthCatalog? catalog, ResultState<void> preparation, ResultState<void> submission, String? selectionMessage, int pendingReadings
});


@override $HealthCatalogCopyWith<$Res>? get catalog;@override $ResultStateCopyWith<void, $Res> get preparation;@override $ResultStateCopyWith<void, $Res> get submission;

}
/// @nodoc
class __$HealthRegistrationStateCopyWithImpl<$Res>
    implements _$HealthRegistrationStateCopyWith<$Res> {
  __$HealthRegistrationStateCopyWithImpl(this._self, this._then);

  final _HealthRegistrationState _self;
  final $Res Function(_HealthRegistrationState) _then;

/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishments = null,Object? recipients = null,Object? establishmentId = freezed,Object? catalog = freezed,Object? preparation = null,Object? submission = null,Object? selectionMessage = freezed,Object? pendingReadings = null,}) {
  return _then(_HealthRegistrationState(
establishments: null == establishments ? _self._establishments : establishments // ignore: cast_nullable_to_non_nullable
as List<EstablishmentMembership>,recipients: null == recipients ? _self._recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<HealthRecipient>,establishmentId: freezed == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String?,catalog: freezed == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as HealthCatalog?,preparation: null == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as ResultState<void>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<void>,selectionMessage: freezed == selectionMessage ? _self.selectionMessage : selectionMessage // ignore: cast_nullable_to_non_nullable
as String?,pendingReadings: null == pendingReadings ? _self.pendingReadings : pendingReadings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthCatalogCopyWith<$Res>? get catalog {
    if (_self.catalog == null) {
    return null;
  }

  return $HealthCatalogCopyWith<$Res>(_self.catalog!, (value) {
    return _then(_self.copyWith(catalog: value));
  });
}/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get preparation {
  
  return $ResultStateCopyWith<void, $Res>(_self.preparation, (value) {
    return _then(_self.copyWith(preparation: value));
  });
}/// Create a copy of HealthRegistrationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get submission {
  
  return $ResultStateCopyWith<void, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}
}

// dart format on
