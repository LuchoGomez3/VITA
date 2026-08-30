// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_detail_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotDetailState {

 ResultState<void> get loadState; ResultState<void> get mutationState; Lot? get lot; List<LotAnimalSummary> get animals; List<Lot> get availableDestinations; bool get isDeleted;
/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotDetailStateCopyWith<LotDetailState> get copyWith => _$LotDetailStateCopyWithImpl<LotDetailState>(this as LotDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotDetailState&&(identical(other.loadState, loadState) || other.loadState == loadState)&&(identical(other.mutationState, mutationState) || other.mutationState == mutationState)&&(identical(other.lot, lot) || other.lot == lot)&&const DeepCollectionEquality().equals(other.animals, animals)&&const DeepCollectionEquality().equals(other.availableDestinations, availableDestinations)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}


@override
int get hashCode => Object.hash(runtimeType,loadState,mutationState,lot,const DeepCollectionEquality().hash(animals),const DeepCollectionEquality().hash(availableDestinations),isDeleted);

@override
String toString() {
  return 'LotDetailState(loadState: $loadState, mutationState: $mutationState, lot: $lot, animals: $animals, availableDestinations: $availableDestinations, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $LotDetailStateCopyWith<$Res>  {
  factory $LotDetailStateCopyWith(LotDetailState value, $Res Function(LotDetailState) _then) = _$LotDetailStateCopyWithImpl;
@useResult
$Res call({
 ResultState<void> loadState, ResultState<void> mutationState, Lot? lot, List<LotAnimalSummary> animals, List<Lot> availableDestinations, bool isDeleted
});


$ResultStateCopyWith<void, $Res> get loadState;$ResultStateCopyWith<void, $Res> get mutationState;$LotCopyWith<$Res>? get lot;

}
/// @nodoc
class _$LotDetailStateCopyWithImpl<$Res>
    implements $LotDetailStateCopyWith<$Res> {
  _$LotDetailStateCopyWithImpl(this._self, this._then);

  final LotDetailState _self;
  final $Res Function(LotDetailState) _then;

/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loadState = null,Object? mutationState = null,Object? lot = freezed,Object? animals = null,Object? availableDestinations = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
loadState: null == loadState ? _self.loadState : loadState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,mutationState: null == mutationState ? _self.mutationState : mutationState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,lot: freezed == lot ? _self.lot : lot // ignore: cast_nullable_to_non_nullable
as Lot?,animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<LotAnimalSummary>,availableDestinations: null == availableDestinations ? _self.availableDestinations : availableDestinations // ignore: cast_nullable_to_non_nullable
as List<Lot>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get loadState {
  
  return $ResultStateCopyWith<void, $Res>(_self.loadState, (value) {
    return _then(_self.copyWith(loadState: value));
  });
}/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get mutationState {
  
  return $ResultStateCopyWith<void, $Res>(_self.mutationState, (value) {
    return _then(_self.copyWith(mutationState: value));
  });
}/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotCopyWith<$Res>? get lot {
    if (_self.lot == null) {
    return null;
  }

  return $LotCopyWith<$Res>(_self.lot!, (value) {
    return _then(_self.copyWith(lot: value));
  });
}
}


/// Adds pattern-matching-related methods to [LotDetailState].
extension LotDetailStatePatterns on LotDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotDetailState value)  $default,){
final _that = this;
switch (_that) {
case _LotDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _LotDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<void> loadState,  ResultState<void> mutationState,  Lot? lot,  List<LotAnimalSummary> animals,  List<Lot> availableDestinations,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotDetailState() when $default != null:
return $default(_that.loadState,_that.mutationState,_that.lot,_that.animals,_that.availableDestinations,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<void> loadState,  ResultState<void> mutationState,  Lot? lot,  List<LotAnimalSummary> animals,  List<Lot> availableDestinations,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _LotDetailState():
return $default(_that.loadState,_that.mutationState,_that.lot,_that.animals,_that.availableDestinations,_that.isDeleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<void> loadState,  ResultState<void> mutationState,  Lot? lot,  List<LotAnimalSummary> animals,  List<Lot> availableDestinations,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _LotDetailState() when $default != null:
return $default(_that.loadState,_that.mutationState,_that.lot,_that.animals,_that.availableDestinations,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc


class _LotDetailState extends LotDetailState {
  const _LotDetailState({this.loadState = const ResultState<void>.initial(), this.mutationState = const ResultState<void>.initial(), this.lot, final  List<LotAnimalSummary> animals = const <LotAnimalSummary>[], final  List<Lot> availableDestinations = const <Lot>[], this.isDeleted = false}): _animals = animals,_availableDestinations = availableDestinations,super._();
  

@override@JsonKey() final  ResultState<void> loadState;
@override@JsonKey() final  ResultState<void> mutationState;
@override final  Lot? lot;
 final  List<LotAnimalSummary> _animals;
@override@JsonKey() List<LotAnimalSummary> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}

 final  List<Lot> _availableDestinations;
@override@JsonKey() List<Lot> get availableDestinations {
  if (_availableDestinations is EqualUnmodifiableListView) return _availableDestinations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableDestinations);
}

@override@JsonKey() final  bool isDeleted;

/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotDetailStateCopyWith<_LotDetailState> get copyWith => __$LotDetailStateCopyWithImpl<_LotDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotDetailState&&(identical(other.loadState, loadState) || other.loadState == loadState)&&(identical(other.mutationState, mutationState) || other.mutationState == mutationState)&&(identical(other.lot, lot) || other.lot == lot)&&const DeepCollectionEquality().equals(other._animals, _animals)&&const DeepCollectionEquality().equals(other._availableDestinations, _availableDestinations)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}


@override
int get hashCode => Object.hash(runtimeType,loadState,mutationState,lot,const DeepCollectionEquality().hash(_animals),const DeepCollectionEquality().hash(_availableDestinations),isDeleted);

@override
String toString() {
  return 'LotDetailState(loadState: $loadState, mutationState: $mutationState, lot: $lot, animals: $animals, availableDestinations: $availableDestinations, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$LotDetailStateCopyWith<$Res> implements $LotDetailStateCopyWith<$Res> {
  factory _$LotDetailStateCopyWith(_LotDetailState value, $Res Function(_LotDetailState) _then) = __$LotDetailStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<void> loadState, ResultState<void> mutationState, Lot? lot, List<LotAnimalSummary> animals, List<Lot> availableDestinations, bool isDeleted
});


@override $ResultStateCopyWith<void, $Res> get loadState;@override $ResultStateCopyWith<void, $Res> get mutationState;@override $LotCopyWith<$Res>? get lot;

}
/// @nodoc
class __$LotDetailStateCopyWithImpl<$Res>
    implements _$LotDetailStateCopyWith<$Res> {
  __$LotDetailStateCopyWithImpl(this._self, this._then);

  final _LotDetailState _self;
  final $Res Function(_LotDetailState) _then;

/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loadState = null,Object? mutationState = null,Object? lot = freezed,Object? animals = null,Object? availableDestinations = null,Object? isDeleted = null,}) {
  return _then(_LotDetailState(
loadState: null == loadState ? _self.loadState : loadState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,mutationState: null == mutationState ? _self.mutationState : mutationState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,lot: freezed == lot ? _self.lot : lot // ignore: cast_nullable_to_non_nullable
as Lot?,animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<LotAnimalSummary>,availableDestinations: null == availableDestinations ? _self._availableDestinations : availableDestinations // ignore: cast_nullable_to_non_nullable
as List<Lot>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get loadState {
  
  return $ResultStateCopyWith<void, $Res>(_self.loadState, (value) {
    return _then(_self.copyWith(loadState: value));
  });
}/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get mutationState {
  
  return $ResultStateCopyWith<void, $Res>(_self.mutationState, (value) {
    return _then(_self.copyWith(mutationState: value));
  });
}/// Create a copy of LotDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotCopyWith<$Res>? get lot {
    if (_self.lot == null) {
    return null;
  }

  return $LotCopyWith<$Res>(_self.lot!, (value) {
    return _then(_self.copyWith(lot: value));
  });
}
}

// dart format on
