// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_bounds.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocalBounds {

 LocalPoint get minimum; LocalPoint get maximum;
/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalBoundsCopyWith<LocalBounds> get copyWith => _$LocalBoundsCopyWithImpl<LocalBounds>(this as LocalBounds, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalBounds&&(identical(other.minimum, minimum) || other.minimum == minimum)&&(identical(other.maximum, maximum) || other.maximum == maximum));
}


@override
int get hashCode => Object.hash(runtimeType,minimum,maximum);

@override
String toString() {
  return 'LocalBounds(minimum: $minimum, maximum: $maximum)';
}


}

/// @nodoc
abstract mixin class $LocalBoundsCopyWith<$Res>  {
  factory $LocalBoundsCopyWith(LocalBounds value, $Res Function(LocalBounds) _then) = _$LocalBoundsCopyWithImpl;
@useResult
$Res call({
 LocalPoint minimum, LocalPoint maximum
});


$LocalPointCopyWith<$Res> get minimum;$LocalPointCopyWith<$Res> get maximum;

}
/// @nodoc
class _$LocalBoundsCopyWithImpl<$Res>
    implements $LocalBoundsCopyWith<$Res> {
  _$LocalBoundsCopyWithImpl(this._self, this._then);

  final LocalBounds _self;
  final $Res Function(LocalBounds) _then;

/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minimum = null,Object? maximum = null,}) {
  return _then(_self.copyWith(
minimum: null == minimum ? _self.minimum : minimum // ignore: cast_nullable_to_non_nullable
as LocalPoint,maximum: null == maximum ? _self.maximum : maximum // ignore: cast_nullable_to_non_nullable
as LocalPoint,
  ));
}
/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalPointCopyWith<$Res> get minimum {
  
  return $LocalPointCopyWith<$Res>(_self.minimum, (value) {
    return _then(_self.copyWith(minimum: value));
  });
}/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalPointCopyWith<$Res> get maximum {
  
  return $LocalPointCopyWith<$Res>(_self.maximum, (value) {
    return _then(_self.copyWith(maximum: value));
  });
}
}


/// Adds pattern-matching-related methods to [LocalBounds].
extension LocalBoundsPatterns on LocalBounds {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalBounds value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalBounds() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalBounds value)  $default,){
final _that = this;
switch (_that) {
case _LocalBounds():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalBounds value)?  $default,){
final _that = this;
switch (_that) {
case _LocalBounds() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalPoint minimum,  LocalPoint maximum)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalBounds() when $default != null:
return $default(_that.minimum,_that.maximum);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalPoint minimum,  LocalPoint maximum)  $default,) {final _that = this;
switch (_that) {
case _LocalBounds():
return $default(_that.minimum,_that.maximum);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalPoint minimum,  LocalPoint maximum)?  $default,) {final _that = this;
switch (_that) {
case _LocalBounds() when $default != null:
return $default(_that.minimum,_that.maximum);case _:
  return null;

}
}

}

/// @nodoc


class _LocalBounds implements LocalBounds {
  const _LocalBounds({required this.minimum, required this.maximum});
  

@override final  LocalPoint minimum;
@override final  LocalPoint maximum;

/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalBoundsCopyWith<_LocalBounds> get copyWith => __$LocalBoundsCopyWithImpl<_LocalBounds>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalBounds&&(identical(other.minimum, minimum) || other.minimum == minimum)&&(identical(other.maximum, maximum) || other.maximum == maximum));
}


@override
int get hashCode => Object.hash(runtimeType,minimum,maximum);

@override
String toString() {
  return 'LocalBounds(minimum: $minimum, maximum: $maximum)';
}


}

/// @nodoc
abstract mixin class _$LocalBoundsCopyWith<$Res> implements $LocalBoundsCopyWith<$Res> {
  factory _$LocalBoundsCopyWith(_LocalBounds value, $Res Function(_LocalBounds) _then) = __$LocalBoundsCopyWithImpl;
@override @useResult
$Res call({
 LocalPoint minimum, LocalPoint maximum
});


@override $LocalPointCopyWith<$Res> get minimum;@override $LocalPointCopyWith<$Res> get maximum;

}
/// @nodoc
class __$LocalBoundsCopyWithImpl<$Res>
    implements _$LocalBoundsCopyWith<$Res> {
  __$LocalBoundsCopyWithImpl(this._self, this._then);

  final _LocalBounds _self;
  final $Res Function(_LocalBounds) _then;

/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minimum = null,Object? maximum = null,}) {
  return _then(_LocalBounds(
minimum: null == minimum ? _self.minimum : minimum // ignore: cast_nullable_to_non_nullable
as LocalPoint,maximum: null == maximum ? _self.maximum : maximum // ignore: cast_nullable_to_non_nullable
as LocalPoint,
  ));
}

/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalPointCopyWith<$Res> get minimum {
  
  return $LocalPointCopyWith<$Res>(_self.minimum, (value) {
    return _then(_self.copyWith(minimum: value));
  });
}/// Create a copy of LocalBounds
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocalPointCopyWith<$Res> get maximum {
  
  return $LocalPointCopyWith<$Res>(_self.maximum, (value) {
    return _then(_self.copyWith(maximum: value));
  });
}
}

// dart format on
