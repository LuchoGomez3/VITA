// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'boundary_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BoundaryPoint {

 double get latitud; double get longitud;
/// Create a copy of BoundaryPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoundaryPointCopyWith<BoundaryPoint> get copyWith => _$BoundaryPointCopyWithImpl<BoundaryPoint>(this as BoundaryPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoundaryPoint&&(identical(other.latitud, latitud) || other.latitud == latitud)&&(identical(other.longitud, longitud) || other.longitud == longitud));
}


@override
int get hashCode => Object.hash(runtimeType,latitud,longitud);

@override
String toString() {
  return 'BoundaryPoint(latitud: $latitud, longitud: $longitud)';
}


}

/// @nodoc
abstract mixin class $BoundaryPointCopyWith<$Res>  {
  factory $BoundaryPointCopyWith(BoundaryPoint value, $Res Function(BoundaryPoint) _then) = _$BoundaryPointCopyWithImpl;
@useResult
$Res call({
 double latitud, double longitud
});




}
/// @nodoc
class _$BoundaryPointCopyWithImpl<$Res>
    implements $BoundaryPointCopyWith<$Res> {
  _$BoundaryPointCopyWithImpl(this._self, this._then);

  final BoundaryPoint _self;
  final $Res Function(BoundaryPoint) _then;

/// Create a copy of BoundaryPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitud = null,Object? longitud = null,}) {
  return _then(_self.copyWith(
latitud: null == latitud ? _self.latitud : latitud // ignore: cast_nullable_to_non_nullable
as double,longitud: null == longitud ? _self.longitud : longitud // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BoundaryPoint].
extension BoundaryPointPatterns on BoundaryPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoundaryPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoundaryPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoundaryPoint value)  $default,){
final _that = this;
switch (_that) {
case _BoundaryPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoundaryPoint value)?  $default,){
final _that = this;
switch (_that) {
case _BoundaryPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitud,  double longitud)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoundaryPoint() when $default != null:
return $default(_that.latitud,_that.longitud);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitud,  double longitud)  $default,) {final _that = this;
switch (_that) {
case _BoundaryPoint():
return $default(_that.latitud,_that.longitud);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitud,  double longitud)?  $default,) {final _that = this;
switch (_that) {
case _BoundaryPoint() when $default != null:
return $default(_that.latitud,_that.longitud);case _:
  return null;

}
}

}

/// @nodoc


class _BoundaryPoint implements BoundaryPoint {
  const _BoundaryPoint({required this.latitud, required this.longitud});
  

@override final  double latitud;
@override final  double longitud;

/// Create a copy of BoundaryPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoundaryPointCopyWith<_BoundaryPoint> get copyWith => __$BoundaryPointCopyWithImpl<_BoundaryPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoundaryPoint&&(identical(other.latitud, latitud) || other.latitud == latitud)&&(identical(other.longitud, longitud) || other.longitud == longitud));
}


@override
int get hashCode => Object.hash(runtimeType,latitud,longitud);

@override
String toString() {
  return 'BoundaryPoint(latitud: $latitud, longitud: $longitud)';
}


}

/// @nodoc
abstract mixin class _$BoundaryPointCopyWith<$Res> implements $BoundaryPointCopyWith<$Res> {
  factory _$BoundaryPointCopyWith(_BoundaryPoint value, $Res Function(_BoundaryPoint) _then) = __$BoundaryPointCopyWithImpl;
@override @useResult
$Res call({
 double latitud, double longitud
});




}
/// @nodoc
class __$BoundaryPointCopyWithImpl<$Res>
    implements _$BoundaryPointCopyWith<$Res> {
  __$BoundaryPointCopyWithImpl(this._self, this._then);

  final _BoundaryPoint _self;
  final $Res Function(_BoundaryPoint) _then;

/// Create a copy of BoundaryPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitud = null,Object? longitud = null,}) {
  return _then(_BoundaryPoint(
latitud: null == latitud ? _self.latitud : latitud // ignore: cast_nullable_to_non_nullable
as double,longitud: null == longitud ? _self.longitud : longitud // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
