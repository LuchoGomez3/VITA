// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_dashboard_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeDashboardState {

 ResultState<HomeDashboard> get dashboardState; Map<String, EstablishmentMembership> get establishments; String? get selectedEstablishmentId;
/// Create a copy of HomeDashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDashboardStateCopyWith<HomeDashboardState> get copyWith => _$HomeDashboardStateCopyWithImpl<HomeDashboardState>(this as HomeDashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeDashboardState&&(identical(other.dashboardState, dashboardState) || other.dashboardState == dashboardState)&&const DeepCollectionEquality().equals(other.establishments, establishments)&&(identical(other.selectedEstablishmentId, selectedEstablishmentId) || other.selectedEstablishmentId == selectedEstablishmentId));
}


@override
int get hashCode => Object.hash(runtimeType,dashboardState,const DeepCollectionEquality().hash(establishments),selectedEstablishmentId);

@override
String toString() {
  return 'HomeDashboardState(dashboardState: $dashboardState, establishments: $establishments, selectedEstablishmentId: $selectedEstablishmentId)';
}


}

/// @nodoc
abstract mixin class $HomeDashboardStateCopyWith<$Res>  {
  factory $HomeDashboardStateCopyWith(HomeDashboardState value, $Res Function(HomeDashboardState) _then) = _$HomeDashboardStateCopyWithImpl;
@useResult
$Res call({
 ResultState<HomeDashboard> dashboardState, Map<String, EstablishmentMembership> establishments, String? selectedEstablishmentId
});


$ResultStateCopyWith<HomeDashboard, $Res> get dashboardState;

}
/// @nodoc
class _$HomeDashboardStateCopyWithImpl<$Res>
    implements $HomeDashboardStateCopyWith<$Res> {
  _$HomeDashboardStateCopyWithImpl(this._self, this._then);

  final HomeDashboardState _self;
  final $Res Function(HomeDashboardState) _then;

/// Create a copy of HomeDashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dashboardState = null,Object? establishments = null,Object? selectedEstablishmentId = freezed,}) {
  return _then(_self.copyWith(
dashboardState: null == dashboardState ? _self.dashboardState : dashboardState // ignore: cast_nullable_to_non_nullable
as ResultState<HomeDashboard>,establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as Map<String, EstablishmentMembership>,selectedEstablishmentId: freezed == selectedEstablishmentId ? _self.selectedEstablishmentId : selectedEstablishmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HomeDashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<HomeDashboard, $Res> get dashboardState {
  
  return $ResultStateCopyWith<HomeDashboard, $Res>(_self.dashboardState, (value) {
    return _then(_self.copyWith(dashboardState: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeDashboardState].
extension HomeDashboardStatePatterns on HomeDashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeDashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeDashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeDashboardState value)  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeDashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<HomeDashboard> dashboardState,  Map<String, EstablishmentMembership> establishments,  String? selectedEstablishmentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeDashboardState() when $default != null:
return $default(_that.dashboardState,_that.establishments,_that.selectedEstablishmentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<HomeDashboard> dashboardState,  Map<String, EstablishmentMembership> establishments,  String? selectedEstablishmentId)  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardState():
return $default(_that.dashboardState,_that.establishments,_that.selectedEstablishmentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<HomeDashboard> dashboardState,  Map<String, EstablishmentMembership> establishments,  String? selectedEstablishmentId)?  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardState() when $default != null:
return $default(_that.dashboardState,_that.establishments,_that.selectedEstablishmentId);case _:
  return null;

}
}

}

/// @nodoc


class _HomeDashboardState implements HomeDashboardState {
  const _HomeDashboardState({this.dashboardState = const ResultState<HomeDashboard>.initial(), final  Map<String, EstablishmentMembership> establishments = const <String, EstablishmentMembership>{}, this.selectedEstablishmentId}): _establishments = establishments;
  

@override@JsonKey() final  ResultState<HomeDashboard> dashboardState;
 final  Map<String, EstablishmentMembership> _establishments;
@override@JsonKey() Map<String, EstablishmentMembership> get establishments {
  if (_establishments is EqualUnmodifiableMapView) return _establishments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_establishments);
}

@override final  String? selectedEstablishmentId;

/// Create a copy of HomeDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDashboardStateCopyWith<_HomeDashboardState> get copyWith => __$HomeDashboardStateCopyWithImpl<_HomeDashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeDashboardState&&(identical(other.dashboardState, dashboardState) || other.dashboardState == dashboardState)&&const DeepCollectionEquality().equals(other._establishments, _establishments)&&(identical(other.selectedEstablishmentId, selectedEstablishmentId) || other.selectedEstablishmentId == selectedEstablishmentId));
}


@override
int get hashCode => Object.hash(runtimeType,dashboardState,const DeepCollectionEquality().hash(_establishments),selectedEstablishmentId);

@override
String toString() {
  return 'HomeDashboardState(dashboardState: $dashboardState, establishments: $establishments, selectedEstablishmentId: $selectedEstablishmentId)';
}


}

/// @nodoc
abstract mixin class _$HomeDashboardStateCopyWith<$Res> implements $HomeDashboardStateCopyWith<$Res> {
  factory _$HomeDashboardStateCopyWith(_HomeDashboardState value, $Res Function(_HomeDashboardState) _then) = __$HomeDashboardStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<HomeDashboard> dashboardState, Map<String, EstablishmentMembership> establishments, String? selectedEstablishmentId
});


@override $ResultStateCopyWith<HomeDashboard, $Res> get dashboardState;

}
/// @nodoc
class __$HomeDashboardStateCopyWithImpl<$Res>
    implements _$HomeDashboardStateCopyWith<$Res> {
  __$HomeDashboardStateCopyWithImpl(this._self, this._then);

  final _HomeDashboardState _self;
  final $Res Function(_HomeDashboardState) _then;

/// Create a copy of HomeDashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dashboardState = null,Object? establishments = null,Object? selectedEstablishmentId = freezed,}) {
  return _then(_HomeDashboardState(
dashboardState: null == dashboardState ? _self.dashboardState : dashboardState // ignore: cast_nullable_to_non_nullable
as ResultState<HomeDashboard>,establishments: null == establishments ? _self._establishments : establishments // ignore: cast_nullable_to_non_nullable
as Map<String, EstablishmentMembership>,selectedEstablishmentId: freezed == selectedEstablishmentId ? _self.selectedEstablishmentId : selectedEstablishmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HomeDashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<HomeDashboard, $Res> get dashboardState {
  
  return $ResultStateCopyWith<HomeDashboard, $Res>(_self.dashboardState, (value) {
    return _then(_self.copyWith(dashboardState: value));
  });
}
}

// dart format on
