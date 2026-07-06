// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DomainException {

 String get message; DomainErrorCode get code;
/// Create a copy of DomainException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<DomainException> get copyWith => _$DomainExceptionCopyWithImpl<DomainException>(this as DomainException, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainException&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'DomainException(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $DomainExceptionCopyWith<$Res>  {
  factory $DomainExceptionCopyWith(DomainException value, $Res Function(DomainException) _then) = _$DomainExceptionCopyWithImpl;
@useResult
$Res call({
 String message, DomainErrorCode code
});




}
/// @nodoc
class _$DomainExceptionCopyWithImpl<$Res>
    implements $DomainExceptionCopyWith<$Res> {
  _$DomainExceptionCopyWithImpl(this._self, this._then);

  final DomainException _self;
  final $Res Function(DomainException) _then;

/// Create a copy of DomainException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? code = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as DomainErrorCode,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainException].
extension DomainExceptionPatterns on DomainException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainException value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainException() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainException value)  $default,){
final _that = this;
switch (_that) {
case _DomainException():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainException value)?  $default,){
final _that = this;
switch (_that) {
case _DomainException() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  DomainErrorCode code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainException() when $default != null:
return $default(_that.message,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  DomainErrorCode code)  $default,) {final _that = this;
switch (_that) {
case _DomainException():
return $default(_that.message,_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  DomainErrorCode code)?  $default,) {final _that = this;
switch (_that) {
case _DomainException() when $default != null:
return $default(_that.message,_that.code);case _:
  return null;

}
}

}

/// @nodoc


class _DomainException implements DomainException {
  const _DomainException({required this.message, this.code = DomainErrorCode.unknown});
  

@override final  String message;
@override@JsonKey() final  DomainErrorCode code;

/// Create a copy of DomainException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainExceptionCopyWith<_DomainException> get copyWith => __$DomainExceptionCopyWithImpl<_DomainException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainException&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,message,code);

@override
String toString() {
  return 'DomainException(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class _$DomainExceptionCopyWith<$Res> implements $DomainExceptionCopyWith<$Res> {
  factory _$DomainExceptionCopyWith(_DomainException value, $Res Function(_DomainException) _then) = __$DomainExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message, DomainErrorCode code
});




}
/// @nodoc
class __$DomainExceptionCopyWithImpl<$Res>
    implements _$DomainExceptionCopyWith<$Res> {
  __$DomainExceptionCopyWithImpl(this._self, this._then);

  final _DomainException _self;
  final $Res Function(_DomainException) _then;

/// Create a copy of DomainException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = null,}) {
  return _then(_DomainException(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as DomainErrorCode,
  ));
}


}

// dart format on
