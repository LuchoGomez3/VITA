// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_movement_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupMovementState {

 ResultState<GroupMovementPreparation> get preparation; ResultState<MovementAnimal> get tagResolution; ResultState<GroupMovementSummary> get submission; List<MovementAnimal> get animals;/// Cambios durables acumulados, incluso si un grupo posterior falla.
 GroupMovementSummary get savedSummary; String? get destinationId; DateTime? get occurredAt;
/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMovementStateCopyWith<GroupMovementState> get copyWith => _$GroupMovementStateCopyWithImpl<GroupMovementState>(this as GroupMovementState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMovementState&&(identical(other.preparation, preparation) || other.preparation == preparation)&&(identical(other.tagResolution, tagResolution) || other.tagResolution == tagResolution)&&(identical(other.submission, submission) || other.submission == submission)&&const DeepCollectionEquality().equals(other.animals, animals)&&(identical(other.savedSummary, savedSummary) || other.savedSummary == savedSummary)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}


@override
int get hashCode => Object.hash(runtimeType,preparation,tagResolution,submission,const DeepCollectionEquality().hash(animals),savedSummary,destinationId,occurredAt);

@override
String toString() {
  return 'GroupMovementState(preparation: $preparation, tagResolution: $tagResolution, submission: $submission, animals: $animals, savedSummary: $savedSummary, destinationId: $destinationId, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $GroupMovementStateCopyWith<$Res>  {
  factory $GroupMovementStateCopyWith(GroupMovementState value, $Res Function(GroupMovementState) _then) = _$GroupMovementStateCopyWithImpl;
@useResult
$Res call({
 ResultState<GroupMovementPreparation> preparation, ResultState<MovementAnimal> tagResolution, ResultState<GroupMovementSummary> submission, List<MovementAnimal> animals, GroupMovementSummary savedSummary, String? destinationId, DateTime? occurredAt
});


$ResultStateCopyWith<GroupMovementPreparation, $Res> get preparation;$ResultStateCopyWith<MovementAnimal, $Res> get tagResolution;$ResultStateCopyWith<GroupMovementSummary, $Res> get submission;$GroupMovementSummaryCopyWith<$Res> get savedSummary;

}
/// @nodoc
class _$GroupMovementStateCopyWithImpl<$Res>
    implements $GroupMovementStateCopyWith<$Res> {
  _$GroupMovementStateCopyWithImpl(this._self, this._then);

  final GroupMovementState _self;
  final $Res Function(GroupMovementState) _then;

/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preparation = null,Object? tagResolution = null,Object? submission = null,Object? animals = null,Object? savedSummary = null,Object? destinationId = freezed,Object? occurredAt = freezed,}) {
  return _then(_self.copyWith(
preparation: null == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as ResultState<GroupMovementPreparation>,tagResolution: null == tagResolution ? _self.tagResolution : tagResolution // ignore: cast_nullable_to_non_nullable
as ResultState<MovementAnimal>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<GroupMovementSummary>,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<MovementAnimal>,savedSummary: null == savedSummary ? _self.savedSummary : savedSummary // ignore: cast_nullable_to_non_nullable
as GroupMovementSummary,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GroupMovementPreparation, $Res> get preparation {
  
  return $ResultStateCopyWith<GroupMovementPreparation, $Res>(_self.preparation, (value) {
    return _then(_self.copyWith(preparation: value));
  });
}/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<MovementAnimal, $Res> get tagResolution {
  
  return $ResultStateCopyWith<MovementAnimal, $Res>(_self.tagResolution, (value) {
    return _then(_self.copyWith(tagResolution: value));
  });
}/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GroupMovementSummary, $Res> get submission {
  
  return $ResultStateCopyWith<GroupMovementSummary, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupMovementSummaryCopyWith<$Res> get savedSummary {
  
  return $GroupMovementSummaryCopyWith<$Res>(_self.savedSummary, (value) {
    return _then(_self.copyWith(savedSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupMovementState].
extension GroupMovementStatePatterns on GroupMovementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMovementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMovementState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMovementState value)  $default,){
final _that = this;
switch (_that) {
case _GroupMovementState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMovementState value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMovementState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<GroupMovementPreparation> preparation,  ResultState<MovementAnimal> tagResolution,  ResultState<GroupMovementSummary> submission,  List<MovementAnimal> animals,  GroupMovementSummary savedSummary,  String? destinationId,  DateTime? occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMovementState() when $default != null:
return $default(_that.preparation,_that.tagResolution,_that.submission,_that.animals,_that.savedSummary,_that.destinationId,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<GroupMovementPreparation> preparation,  ResultState<MovementAnimal> tagResolution,  ResultState<GroupMovementSummary> submission,  List<MovementAnimal> animals,  GroupMovementSummary savedSummary,  String? destinationId,  DateTime? occurredAt)  $default,) {final _that = this;
switch (_that) {
case _GroupMovementState():
return $default(_that.preparation,_that.tagResolution,_that.submission,_that.animals,_that.savedSummary,_that.destinationId,_that.occurredAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<GroupMovementPreparation> preparation,  ResultState<MovementAnimal> tagResolution,  ResultState<GroupMovementSummary> submission,  List<MovementAnimal> animals,  GroupMovementSummary savedSummary,  String? destinationId,  DateTime? occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _GroupMovementState() when $default != null:
return $default(_that.preparation,_that.tagResolution,_that.submission,_that.animals,_that.savedSummary,_that.destinationId,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc


class _GroupMovementState extends GroupMovementState {
  const _GroupMovementState({this.preparation = const ResultState<GroupMovementPreparation>.initial(), this.tagResolution = const ResultState<MovementAnimal>.initial(), this.submission = const ResultState<GroupMovementSummary>.initial(), final  List<MovementAnimal> animals = const [], this.savedSummary = const GroupMovementSummary(movedCount: 0, alreadyThereCount: 0), this.destinationId, this.occurredAt}): _animals = animals,super._();
  

@override@JsonKey() final  ResultState<GroupMovementPreparation> preparation;
@override@JsonKey() final  ResultState<MovementAnimal> tagResolution;
@override@JsonKey() final  ResultState<GroupMovementSummary> submission;
 final  List<MovementAnimal> _animals;
@override@JsonKey() List<MovementAnimal> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}

/// Cambios durables acumulados, incluso si un grupo posterior falla.
@override@JsonKey() final  GroupMovementSummary savedSummary;
@override final  String? destinationId;
@override final  DateTime? occurredAt;

/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMovementStateCopyWith<_GroupMovementState> get copyWith => __$GroupMovementStateCopyWithImpl<_GroupMovementState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMovementState&&(identical(other.preparation, preparation) || other.preparation == preparation)&&(identical(other.tagResolution, tagResolution) || other.tagResolution == tagResolution)&&(identical(other.submission, submission) || other.submission == submission)&&const DeepCollectionEquality().equals(other._animals, _animals)&&(identical(other.savedSummary, savedSummary) || other.savedSummary == savedSummary)&&(identical(other.destinationId, destinationId) || other.destinationId == destinationId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}


@override
int get hashCode => Object.hash(runtimeType,preparation,tagResolution,submission,const DeepCollectionEquality().hash(_animals),savedSummary,destinationId,occurredAt);

@override
String toString() {
  return 'GroupMovementState(preparation: $preparation, tagResolution: $tagResolution, submission: $submission, animals: $animals, savedSummary: $savedSummary, destinationId: $destinationId, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$GroupMovementStateCopyWith<$Res> implements $GroupMovementStateCopyWith<$Res> {
  factory _$GroupMovementStateCopyWith(_GroupMovementState value, $Res Function(_GroupMovementState) _then) = __$GroupMovementStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<GroupMovementPreparation> preparation, ResultState<MovementAnimal> tagResolution, ResultState<GroupMovementSummary> submission, List<MovementAnimal> animals, GroupMovementSummary savedSummary, String? destinationId, DateTime? occurredAt
});


@override $ResultStateCopyWith<GroupMovementPreparation, $Res> get preparation;@override $ResultStateCopyWith<MovementAnimal, $Res> get tagResolution;@override $ResultStateCopyWith<GroupMovementSummary, $Res> get submission;@override $GroupMovementSummaryCopyWith<$Res> get savedSummary;

}
/// @nodoc
class __$GroupMovementStateCopyWithImpl<$Res>
    implements _$GroupMovementStateCopyWith<$Res> {
  __$GroupMovementStateCopyWithImpl(this._self, this._then);

  final _GroupMovementState _self;
  final $Res Function(_GroupMovementState) _then;

/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preparation = null,Object? tagResolution = null,Object? submission = null,Object? animals = null,Object? savedSummary = null,Object? destinationId = freezed,Object? occurredAt = freezed,}) {
  return _then(_GroupMovementState(
preparation: null == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as ResultState<GroupMovementPreparation>,tagResolution: null == tagResolution ? _self.tagResolution : tagResolution // ignore: cast_nullable_to_non_nullable
as ResultState<MovementAnimal>,submission: null == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ResultState<GroupMovementSummary>,animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<MovementAnimal>,savedSummary: null == savedSummary ? _self.savedSummary : savedSummary // ignore: cast_nullable_to_non_nullable
as GroupMovementSummary,destinationId: freezed == destinationId ? _self.destinationId : destinationId // ignore: cast_nullable_to_non_nullable
as String?,occurredAt: freezed == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GroupMovementPreparation, $Res> get preparation {
  
  return $ResultStateCopyWith<GroupMovementPreparation, $Res>(_self.preparation, (value) {
    return _then(_self.copyWith(preparation: value));
  });
}/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<MovementAnimal, $Res> get tagResolution {
  
  return $ResultStateCopyWith<MovementAnimal, $Res>(_self.tagResolution, (value) {
    return _then(_self.copyWith(tagResolution: value));
  });
}/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<GroupMovementSummary, $Res> get submission {
  
  return $ResultStateCopyWith<GroupMovementSummary, $Res>(_self.submission, (value) {
    return _then(_self.copyWith(submission: value));
  });
}/// Create a copy of GroupMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupMovementSummaryCopyWith<$Res> get savedSummary {
  
  return $GroupMovementSummaryCopyWith<$Res>(_self.savedSummary, (value) {
    return _then(_self.copyWith(savedSummary: value));
  });
}
}

// dart format on
