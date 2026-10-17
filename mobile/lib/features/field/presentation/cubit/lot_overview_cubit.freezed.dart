// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_overview_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotOverviewState {

 ResultState<void> get loadState; Map<String, String> get establishments; String? get selectedEstablishmentId; List<Lot> get lots; Map<String, int> get animalCounts; LotOverviewView get view;
/// Create a copy of LotOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotOverviewStateCopyWith<LotOverviewState> get copyWith => _$LotOverviewStateCopyWithImpl<LotOverviewState>(this as LotOverviewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotOverviewState&&(identical(other.loadState, loadState) || other.loadState == loadState)&&const DeepCollectionEquality().equals(other.establishments, establishments)&&(identical(other.selectedEstablishmentId, selectedEstablishmentId) || other.selectedEstablishmentId == selectedEstablishmentId)&&const DeepCollectionEquality().equals(other.lots, lots)&&const DeepCollectionEquality().equals(other.animalCounts, animalCounts)&&(identical(other.view, view) || other.view == view));
}


@override
int get hashCode => Object.hash(runtimeType,loadState,const DeepCollectionEquality().hash(establishments),selectedEstablishmentId,const DeepCollectionEquality().hash(lots),const DeepCollectionEquality().hash(animalCounts),view);

@override
String toString() {
  return 'LotOverviewState(loadState: $loadState, establishments: $establishments, selectedEstablishmentId: $selectedEstablishmentId, lots: $lots, animalCounts: $animalCounts, view: $view)';
}


}

/// @nodoc
abstract mixin class $LotOverviewStateCopyWith<$Res>  {
  factory $LotOverviewStateCopyWith(LotOverviewState value, $Res Function(LotOverviewState) _then) = _$LotOverviewStateCopyWithImpl;
@useResult
$Res call({
 ResultState<void> loadState, Map<String, String> establishments, String? selectedEstablishmentId, List<Lot> lots, Map<String, int> animalCounts, LotOverviewView view
});


$ResultStateCopyWith<void, $Res> get loadState;

}
/// @nodoc
class _$LotOverviewStateCopyWithImpl<$Res>
    implements $LotOverviewStateCopyWith<$Res> {
  _$LotOverviewStateCopyWithImpl(this._self, this._then);

  final LotOverviewState _self;
  final $Res Function(LotOverviewState) _then;

/// Create a copy of LotOverviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loadState = null,Object? establishments = null,Object? selectedEstablishmentId = freezed,Object? lots = null,Object? animalCounts = null,Object? view = null,}) {
  return _then(_self.copyWith(
loadState: null == loadState ? _self.loadState : loadState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as Map<String, String>,selectedEstablishmentId: freezed == selectedEstablishmentId ? _self.selectedEstablishmentId : selectedEstablishmentId // ignore: cast_nullable_to_non_nullable
as String?,lots: null == lots ? _self.lots : lots // ignore: cast_nullable_to_non_nullable
as List<Lot>,animalCounts: null == animalCounts ? _self.animalCounts : animalCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as LotOverviewView,
  ));
}
/// Create a copy of LotOverviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get loadState {
  
  return $ResultStateCopyWith<void, $Res>(_self.loadState, (value) {
    return _then(_self.copyWith(loadState: value));
  });
}
}


/// Adds pattern-matching-related methods to [LotOverviewState].
extension LotOverviewStatePatterns on LotOverviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotOverviewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotOverviewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotOverviewState value)  $default,){
final _that = this;
switch (_that) {
case _LotOverviewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotOverviewState value)?  $default,){
final _that = this;
switch (_that) {
case _LotOverviewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<void> loadState,  Map<String, String> establishments,  String? selectedEstablishmentId,  List<Lot> lots,  Map<String, int> animalCounts,  LotOverviewView view)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotOverviewState() when $default != null:
return $default(_that.loadState,_that.establishments,_that.selectedEstablishmentId,_that.lots,_that.animalCounts,_that.view);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<void> loadState,  Map<String, String> establishments,  String? selectedEstablishmentId,  List<Lot> lots,  Map<String, int> animalCounts,  LotOverviewView view)  $default,) {final _that = this;
switch (_that) {
case _LotOverviewState():
return $default(_that.loadState,_that.establishments,_that.selectedEstablishmentId,_that.lots,_that.animalCounts,_that.view);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<void> loadState,  Map<String, String> establishments,  String? selectedEstablishmentId,  List<Lot> lots,  Map<String, int> animalCounts,  LotOverviewView view)?  $default,) {final _that = this;
switch (_that) {
case _LotOverviewState() when $default != null:
return $default(_that.loadState,_that.establishments,_that.selectedEstablishmentId,_that.lots,_that.animalCounts,_that.view);case _:
  return null;

}
}

}

/// @nodoc


class _LotOverviewState extends LotOverviewState {
  const _LotOverviewState({this.loadState = const ResultState<void>.initial(), final  Map<String, String> establishments = const <String, String>{}, this.selectedEstablishmentId, final  List<Lot> lots = const <Lot>[], final  Map<String, int> animalCounts = const <String, int>{}, this.view = LotOverviewView.schematic}): _establishments = establishments,_lots = lots,_animalCounts = animalCounts,super._();
  

@override@JsonKey() final  ResultState<void> loadState;
 final  Map<String, String> _establishments;
@override@JsonKey() Map<String, String> get establishments {
  if (_establishments is EqualUnmodifiableMapView) return _establishments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_establishments);
}

@override final  String? selectedEstablishmentId;
 final  List<Lot> _lots;
@override@JsonKey() List<Lot> get lots {
  if (_lots is EqualUnmodifiableListView) return _lots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lots);
}

 final  Map<String, int> _animalCounts;
@override@JsonKey() Map<String, int> get animalCounts {
  if (_animalCounts is EqualUnmodifiableMapView) return _animalCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_animalCounts);
}

@override@JsonKey() final  LotOverviewView view;

/// Create a copy of LotOverviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotOverviewStateCopyWith<_LotOverviewState> get copyWith => __$LotOverviewStateCopyWithImpl<_LotOverviewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotOverviewState&&(identical(other.loadState, loadState) || other.loadState == loadState)&&const DeepCollectionEquality().equals(other._establishments, _establishments)&&(identical(other.selectedEstablishmentId, selectedEstablishmentId) || other.selectedEstablishmentId == selectedEstablishmentId)&&const DeepCollectionEquality().equals(other._lots, _lots)&&const DeepCollectionEquality().equals(other._animalCounts, _animalCounts)&&(identical(other.view, view) || other.view == view));
}


@override
int get hashCode => Object.hash(runtimeType,loadState,const DeepCollectionEquality().hash(_establishments),selectedEstablishmentId,const DeepCollectionEquality().hash(_lots),const DeepCollectionEquality().hash(_animalCounts),view);

@override
String toString() {
  return 'LotOverviewState(loadState: $loadState, establishments: $establishments, selectedEstablishmentId: $selectedEstablishmentId, lots: $lots, animalCounts: $animalCounts, view: $view)';
}


}

/// @nodoc
abstract mixin class _$LotOverviewStateCopyWith<$Res> implements $LotOverviewStateCopyWith<$Res> {
  factory _$LotOverviewStateCopyWith(_LotOverviewState value, $Res Function(_LotOverviewState) _then) = __$LotOverviewStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<void> loadState, Map<String, String> establishments, String? selectedEstablishmentId, List<Lot> lots, Map<String, int> animalCounts, LotOverviewView view
});


@override $ResultStateCopyWith<void, $Res> get loadState;

}
/// @nodoc
class __$LotOverviewStateCopyWithImpl<$Res>
    implements _$LotOverviewStateCopyWith<$Res> {
  __$LotOverviewStateCopyWithImpl(this._self, this._then);

  final _LotOverviewState _self;
  final $Res Function(_LotOverviewState) _then;

/// Create a copy of LotOverviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loadState = null,Object? establishments = null,Object? selectedEstablishmentId = freezed,Object? lots = null,Object? animalCounts = null,Object? view = null,}) {
  return _then(_LotOverviewState(
loadState: null == loadState ? _self.loadState : loadState // ignore: cast_nullable_to_non_nullable
as ResultState<void>,establishments: null == establishments ? _self._establishments : establishments // ignore: cast_nullable_to_non_nullable
as Map<String, String>,selectedEstablishmentId: freezed == selectedEstablishmentId ? _self.selectedEstablishmentId : selectedEstablishmentId // ignore: cast_nullable_to_non_nullable
as String?,lots: null == lots ? _self._lots : lots // ignore: cast_nullable_to_non_nullable
as List<Lot>,animalCounts: null == animalCounts ? _self._animalCounts : animalCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as LotOverviewView,
  ));
}

/// Create a copy of LotOverviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<void, $Res> get loadState {
  
  return $ResultStateCopyWith<void, $Res>(_self.loadState, (value) {
    return _then(_self.copyWith(loadState: value));
  });
}
}

// dart format on
