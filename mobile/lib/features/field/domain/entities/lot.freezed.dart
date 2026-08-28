// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Lot {

 String get id; String get establishmentId; String get name; LotBoundary get boundary; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotCopyWith<Lot> get copyWith => _$LotCopyWithImpl<Lot>(this as Lot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lot&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.boundary, boundary) || other.boundary == boundary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,name,boundary,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'Lot(id: $id, establishmentId: $establishmentId, name: $name, boundary: $boundary, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $LotCopyWith<$Res>  {
  factory $LotCopyWith(Lot value, $Res Function(Lot) _then) = _$LotCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String name, LotBoundary boundary, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$LotBoundaryCopyWith<$Res> get boundary;

}
/// @nodoc
class _$LotCopyWithImpl<$Res>
    implements $LotCopyWith<$Res> {
  _$LotCopyWithImpl(this._self, this._then);

  final Lot _self;
  final $Res Function(Lot) _then;

/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? name = null,Object? boundary = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,boundary: null == boundary ? _self.boundary : boundary // ignore: cast_nullable_to_non_nullable
as LotBoundary,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotBoundaryCopyWith<$Res> get boundary {
  
  return $LotBoundaryCopyWith<$Res>(_self.boundary, (value) {
    return _then(_self.copyWith(boundary: value));
  });
}
}


/// Adds pattern-matching-related methods to [Lot].
extension LotPatterns on Lot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lot value)  $default,){
final _that = this;
switch (_that) {
case _Lot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lot value)?  $default,){
final _that = this;
switch (_that) {
case _Lot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String name,  LotBoundary boundary,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lot() when $default != null:
return $default(_that.id,_that.establishmentId,_that.name,_that.boundary,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String name,  LotBoundary boundary,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Lot():
return $default(_that.id,_that.establishmentId,_that.name,_that.boundary,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String name,  LotBoundary boundary,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Lot() when $default != null:
return $default(_that.id,_that.establishmentId,_that.name,_that.boundary,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Lot implements Lot {
  const _Lot({required this.id, required this.establishmentId, required this.name, required this.boundary, required this.createdAt, required this.updatedAt, this.deletedAt});
  

@override final  String id;
@override final  String establishmentId;
@override final  String name;
@override final  LotBoundary boundary;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotCopyWith<_Lot> get copyWith => __$LotCopyWithImpl<_Lot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lot&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.boundary, boundary) || other.boundary == boundary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,name,boundary,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'Lot(id: $id, establishmentId: $establishmentId, name: $name, boundary: $boundary, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$LotCopyWith<$Res> implements $LotCopyWith<$Res> {
  factory _$LotCopyWith(_Lot value, $Res Function(_Lot) _then) = __$LotCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String name, LotBoundary boundary, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $LotBoundaryCopyWith<$Res> get boundary;

}
/// @nodoc
class __$LotCopyWithImpl<$Res>
    implements _$LotCopyWith<$Res> {
  __$LotCopyWithImpl(this._self, this._then);

  final _Lot _self;
  final $Res Function(_Lot) _then;

/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? name = null,Object? boundary = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Lot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,boundary: null == boundary ? _self.boundary : boundary // ignore: cast_nullable_to_non_nullable
as LotBoundary,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Lot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LotBoundaryCopyWith<$Res> get boundary {
  
  return $LotBoundaryCopyWith<$Res>(_self.boundary, (value) {
    return _then(_self.copyWith(boundary: value));
  });
}
}

// dart format on
