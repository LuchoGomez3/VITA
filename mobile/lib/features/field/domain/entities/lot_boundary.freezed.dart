// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_boundary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotBoundary {

 List<LocalPoint> get vertices;
/// Create a copy of LotBoundary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotBoundaryCopyWith<LotBoundary> get copyWith => _$LotBoundaryCopyWithImpl<LotBoundary>(this as LotBoundary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotBoundary&&const DeepCollectionEquality().equals(other.vertices, vertices));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(vertices));

@override
String toString() {
  return 'LotBoundary(vertices: $vertices)';
}


}

/// @nodoc
abstract mixin class $LotBoundaryCopyWith<$Res>  {
  factory $LotBoundaryCopyWith(LotBoundary value, $Res Function(LotBoundary) _then) = _$LotBoundaryCopyWithImpl;
@useResult
$Res call({
 List<LocalPoint> vertices
});




}
/// @nodoc
class _$LotBoundaryCopyWithImpl<$Res>
    implements $LotBoundaryCopyWith<$Res> {
  _$LotBoundaryCopyWithImpl(this._self, this._then);

  final LotBoundary _self;
  final $Res Function(LotBoundary) _then;

/// Create a copy of LotBoundary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vertices = null,}) {
  return _then(_self.copyWith(
vertices: null == vertices ? _self.vertices : vertices // ignore: cast_nullable_to_non_nullable
as List<LocalPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [LotBoundary].
extension LotBoundaryPatterns on LotBoundary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotBoundary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotBoundary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotBoundary value)  $default,){
final _that = this;
switch (_that) {
case _LotBoundary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotBoundary value)?  $default,){
final _that = this;
switch (_that) {
case _LotBoundary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LocalPoint> vertices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotBoundary() when $default != null:
return $default(_that.vertices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LocalPoint> vertices)  $default,) {final _that = this;
switch (_that) {
case _LotBoundary():
return $default(_that.vertices);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LocalPoint> vertices)?  $default,) {final _that = this;
switch (_that) {
case _LotBoundary() when $default != null:
return $default(_that.vertices);case _:
  return null;

}
}

}

/// @nodoc


class _LotBoundary implements LotBoundary {
  const _LotBoundary({final  List<LocalPoint> vertices = const <LocalPoint>[]}): _vertices = vertices;
  

 final  List<LocalPoint> _vertices;
@override@JsonKey() List<LocalPoint> get vertices {
  if (_vertices is EqualUnmodifiableListView) return _vertices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vertices);
}


/// Create a copy of LotBoundary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotBoundaryCopyWith<_LotBoundary> get copyWith => __$LotBoundaryCopyWithImpl<_LotBoundary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotBoundary&&const DeepCollectionEquality().equals(other._vertices, _vertices));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_vertices));

@override
String toString() {
  return 'LotBoundary(vertices: $vertices)';
}


}

/// @nodoc
abstract mixin class _$LotBoundaryCopyWith<$Res> implements $LotBoundaryCopyWith<$Res> {
  factory _$LotBoundaryCopyWith(_LotBoundary value, $Res Function(_LotBoundary) _then) = __$LotBoundaryCopyWithImpl;
@override @useResult
$Res call({
 List<LocalPoint> vertices
});




}
/// @nodoc
class __$LotBoundaryCopyWithImpl<$Res>
    implements _$LotBoundaryCopyWith<$Res> {
  __$LotBoundaryCopyWithImpl(this._self, this._then);

  final _LotBoundary _self;
  final $Res Function(_LotBoundary) _then;

/// Create a copy of LotBoundary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vertices = null,}) {
  return _then(_LotBoundary(
vertices: null == vertices ? _self._vertices : vertices // ignore: cast_nullable_to_non_nullable
as List<LocalPoint>,
  ));
}


}

// dart format on
