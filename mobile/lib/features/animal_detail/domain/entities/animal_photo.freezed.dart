// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalPhoto {

 AnimalPhotoBytes get encodedBytes;
/// Create a copy of AnimalPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalPhotoCopyWith<AnimalPhoto> get copyWith => _$AnimalPhotoCopyWithImpl<AnimalPhoto>(this as AnimalPhoto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalPhoto&&(identical(other.encodedBytes, encodedBytes) || other.encodedBytes == encodedBytes));
}


@override
int get hashCode => Object.hash(runtimeType,encodedBytes);

@override
String toString() {
  return 'AnimalPhoto(encodedBytes: $encodedBytes)';
}


}

/// @nodoc
abstract mixin class $AnimalPhotoCopyWith<$Res>  {
  factory $AnimalPhotoCopyWith(AnimalPhoto value, $Res Function(AnimalPhoto) _then) = _$AnimalPhotoCopyWithImpl;
@useResult
$Res call({
 AnimalPhotoBytes encodedBytes
});




}
/// @nodoc
class _$AnimalPhotoCopyWithImpl<$Res>
    implements $AnimalPhotoCopyWith<$Res> {
  _$AnimalPhotoCopyWithImpl(this._self, this._then);

  final AnimalPhoto _self;
  final $Res Function(AnimalPhoto) _then;

/// Create a copy of AnimalPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encodedBytes = null,}) {
  return _then(_self.copyWith(
encodedBytes: null == encodedBytes ? _self.encodedBytes : encodedBytes // ignore: cast_nullable_to_non_nullable
as AnimalPhotoBytes,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalPhoto].
extension AnimalPhotoPatterns on AnimalPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _AnimalPhoto value)?  immutable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalPhoto() when immutable != null:
return immutable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _AnimalPhoto value)  immutable,}){
final _that = this;
switch (_that) {
case _AnimalPhoto():
return immutable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _AnimalPhoto value)?  immutable,}){
final _that = this;
switch (_that) {
case _AnimalPhoto() when immutable != null:
return immutable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AnimalPhotoBytes encodedBytes)?  immutable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalPhoto() when immutable != null:
return immutable(_that.encodedBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AnimalPhotoBytes encodedBytes)  immutable,}) {final _that = this;
switch (_that) {
case _AnimalPhoto():
return immutable(_that.encodedBytes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AnimalPhotoBytes encodedBytes)?  immutable,}) {final _that = this;
switch (_that) {
case _AnimalPhoto() when immutable != null:
return immutable(_that.encodedBytes);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalPhoto extends AnimalPhoto {
  const _AnimalPhoto({required this.encodedBytes}): super._();


@override final  AnimalPhotoBytes encodedBytes;

/// Create a copy of AnimalPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalPhotoCopyWith<_AnimalPhoto> get copyWith => __$AnimalPhotoCopyWithImpl<_AnimalPhoto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalPhoto&&(identical(other.encodedBytes, encodedBytes) || other.encodedBytes == encodedBytes));
}


@override
int get hashCode => Object.hash(runtimeType,encodedBytes);

@override
String toString() {
  return 'AnimalPhoto.immutable(encodedBytes: $encodedBytes)';
}


}

/// @nodoc
abstract mixin class _$AnimalPhotoCopyWith<$Res> implements $AnimalPhotoCopyWith<$Res> {
  factory _$AnimalPhotoCopyWith(_AnimalPhoto value, $Res Function(_AnimalPhoto) _then) = __$AnimalPhotoCopyWithImpl;
@override @useResult
$Res call({
 AnimalPhotoBytes encodedBytes
});




}
/// @nodoc
class __$AnimalPhotoCopyWithImpl<$Res>
    implements _$AnimalPhotoCopyWith<$Res> {
  __$AnimalPhotoCopyWithImpl(this._self, this._then);

  final _AnimalPhoto _self;
  final $Res Function(_AnimalPhoto) _then;

/// Create a copy of AnimalPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? encodedBytes = null,}) {
  return _then(_AnimalPhoto(
encodedBytes: null == encodedBytes ? _self.encodedBytes : encodedBytes // ignore: cast_nullable_to_non_nullable
as AnimalPhotoBytes,
  ));
}


}

// dart format on
