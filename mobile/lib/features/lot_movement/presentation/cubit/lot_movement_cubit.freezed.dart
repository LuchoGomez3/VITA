// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_movement_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotMovementState {

 ResultState<MovementContext> get context; ResultState<AnimalLotMovement> get saving; ResultState<void> get retrying; List<String> get selectedIds; String? get sourceLotId; bool get refreshing;
/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotMovementStateCopyWith<LotMovementState> get copyWith => _$LotMovementStateCopyWithImpl<LotMovementState>(this as LotMovementState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotMovementState&&(identical(other.context, context) || other.context == context)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.retrying, retrying) || other.retrying == retrying)&&const DeepCollectionEquality().equals(other.selectedIds, selectedIds)&&(identical(other.sourceLotId, sourceLotId) || other.sourceLotId == sourceLotId)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing));
}


@override
int get hashCode => Object.hash(runtimeType,context,saving,retrying,const DeepCollectionEquality().hash(selectedIds),sourceLotId,refreshing);

@override
String toString() {
  return 'LotMovementState(context: $context, saving: $saving, retrying: $retrying, selectedIds: $selectedIds, sourceLotId: $sourceLotId, refreshing: $refreshing)';
}


}

/// @nodoc
abstract mixin class $LotMovementStateCopyWith<$Res>  {
  factory $LotMovementStateCopyWith(LotMovementState value, $Res Function(LotMovementState) _then) = _$LotMovementStateCopyWithImpl;
@useResult
$Res call({
 ResultState<MovementContext> context, ResultState<AnimalLotMovement> saving, ResultState<void> retrying, List<String> selectedIds, String? sourceLotId, bool refreshing
});


$ResultStateCopyWith<MovementContext, $Res> get context;$ResultStateCopyWith<AnimalLotMovement, $Res> get saving;$ResultStateCopyWith<void, $Res> get retrying;

}
/// @nodoc
class _$LotMovementStateCopyWithImpl<$Res>
    implements $LotMovementStateCopyWith<$Res> {
  _$LotMovementStateCopyWithImpl(this._self, this._then);

  final LotMovementState _self;
  final $Res Function(LotMovementState) _then;

/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? context = null,Object? saving = null,Object? retrying = null,Object? selectedIds = null,Object? sourceLotId = freezed,Object? refreshing = null,}) {
  return _then(_self.copyWith(
context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ResultState<MovementContext>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as ResultState<AnimalLotMovement>,retrying: null == retrying ? _self.retrying : retrying // ignore: cast_nullable_to_non_nullable
as ResultState<void>,selectedIds: null == selectedIds ? _self.selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as List<String>,sourceLotId: freezed == sourceLotId ? _self.sourceLotId : sourceLotId // ignore: cast_nullable_to_non_nullable
as String?,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<MovementContext, $Res> get context {
  
  return $ResultStateCopyWith<MovementContext, $Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<AnimalLotMovement, $Res> get saving {
  
  return $ResultStateCopyWith<AnimalLotMovement, $Res>(_self.saving, (value) {
    return _then(_self.copyWith(saving: value));
  });
}/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get retrying {
  
  return $ResultStateCopyWith<void, $Res>(_self.retrying, (value) {
    return _then(_self.copyWith(retrying: value));
  });
}
}


/// Adds pattern-matching-related methods to [LotMovementState].
extension LotMovementStatePatterns on LotMovementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotMovementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotMovementState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotMovementState value)  $default,){
final _that = this;
switch (_that) {
case _LotMovementState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotMovementState value)?  $default,){
final _that = this;
switch (_that) {
case _LotMovementState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<MovementContext> context,  ResultState<AnimalLotMovement> saving,  ResultState<void> retrying,  List<String> selectedIds,  String? sourceLotId,  bool refreshing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotMovementState() when $default != null:
return $default(_that.context,_that.saving,_that.retrying,_that.selectedIds,_that.sourceLotId,_that.refreshing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<MovementContext> context,  ResultState<AnimalLotMovement> saving,  ResultState<void> retrying,  List<String> selectedIds,  String? sourceLotId,  bool refreshing)  $default,) {final _that = this;
switch (_that) {
case _LotMovementState():
return $default(_that.context,_that.saving,_that.retrying,_that.selectedIds,_that.sourceLotId,_that.refreshing);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<MovementContext> context,  ResultState<AnimalLotMovement> saving,  ResultState<void> retrying,  List<String> selectedIds,  String? sourceLotId,  bool refreshing)?  $default,) {final _that = this;
switch (_that) {
case _LotMovementState() when $default != null:
return $default(_that.context,_that.saving,_that.retrying,_that.selectedIds,_that.sourceLotId,_that.refreshing);case _:
  return null;

}
}

}

/// @nodoc


class _LotMovementState implements LotMovementState {
  const _LotMovementState({this.context = const ResultState<MovementContext>.initial(), this.saving = const ResultState<AnimalLotMovement>.initial(), this.retrying = const ResultState<void>.initial(), final  List<String> selectedIds = const <String>[], this.sourceLotId, this.refreshing = false}): _selectedIds = selectedIds;
  

@override@JsonKey() final  ResultState<MovementContext> context;
@override@JsonKey() final  ResultState<AnimalLotMovement> saving;
@override@JsonKey() final  ResultState<void> retrying;
 final  List<String> _selectedIds;
@override@JsonKey() List<String> get selectedIds {
  if (_selectedIds is EqualUnmodifiableListView) return _selectedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedIds);
}

@override final  String? sourceLotId;
@override@JsonKey() final  bool refreshing;

/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotMovementStateCopyWith<_LotMovementState> get copyWith => __$LotMovementStateCopyWithImpl<_LotMovementState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotMovementState&&(identical(other.context, context) || other.context == context)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.retrying, retrying) || other.retrying == retrying)&&const DeepCollectionEquality().equals(other._selectedIds, _selectedIds)&&(identical(other.sourceLotId, sourceLotId) || other.sourceLotId == sourceLotId)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing));
}


@override
int get hashCode => Object.hash(runtimeType,context,saving,retrying,const DeepCollectionEquality().hash(_selectedIds),sourceLotId,refreshing);

@override
String toString() {
  return 'LotMovementState(context: $context, saving: $saving, retrying: $retrying, selectedIds: $selectedIds, sourceLotId: $sourceLotId, refreshing: $refreshing)';
}


}

/// @nodoc
abstract mixin class _$LotMovementStateCopyWith<$Res> implements $LotMovementStateCopyWith<$Res> {
  factory _$LotMovementStateCopyWith(_LotMovementState value, $Res Function(_LotMovementState) _then) = __$LotMovementStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<MovementContext> context, ResultState<AnimalLotMovement> saving, ResultState<void> retrying, List<String> selectedIds, String? sourceLotId, bool refreshing
});


@override $ResultStateCopyWith<MovementContext, $Res> get context;@override $ResultStateCopyWith<AnimalLotMovement, $Res> get saving;@override $ResultStateCopyWith<void, $Res> get retrying;

}
/// @nodoc
class __$LotMovementStateCopyWithImpl<$Res>
    implements _$LotMovementStateCopyWith<$Res> {
  __$LotMovementStateCopyWithImpl(this._self, this._then);

  final _LotMovementState _self;
  final $Res Function(_LotMovementState) _then;

/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? context = null,Object? saving = null,Object? retrying = null,Object? selectedIds = null,Object? sourceLotId = freezed,Object? refreshing = null,}) {
  return _then(_LotMovementState(
context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as ResultState<MovementContext>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as ResultState<AnimalLotMovement>,retrying: null == retrying ? _self.retrying : retrying // ignore: cast_nullable_to_non_nullable
as ResultState<void>,selectedIds: null == selectedIds ? _self._selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as List<String>,sourceLotId: freezed == sourceLotId ? _self.sourceLotId : sourceLotId // ignore: cast_nullable_to_non_nullable
as String?,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<MovementContext, $Res> get context {
  
  return $ResultStateCopyWith<MovementContext, $Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<AnimalLotMovement, $Res> get saving {
  
  return $ResultStateCopyWith<AnimalLotMovement, $Res>(_self.saving, (value) {
    return _then(_self.copyWith(saving: value));
  });
}/// Create a copy of LotMovementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get retrying {
  
  return $ResultStateCopyWith<void, $Res>(_self.retrying, (value) {
    return _then(_self.copyWith(retrying: value));
  });
}
}

// dart format on
