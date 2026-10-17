// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_animal_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotAnimalMovement {

 String get id; String get establishmentId; String get sourceLotId; String get destinationLotId; List<String> get animalIds; DateTime get occurredAt; String get reason; DateTime get createdAt; DateTime get updatedAt; String? get responsibleId; DateTime? get deletedAt;
/// Create a copy of LotAnimalMovement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotAnimalMovementCopyWith<LotAnimalMovement> get copyWith => _$LotAnimalMovementCopyWithImpl<LotAnimalMovement>(this as LotAnimalMovement, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotAnimalMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.sourceLotId, sourceLotId) || other.sourceLotId == sourceLotId)&&(identical(other.destinationLotId, destinationLotId) || other.destinationLotId == destinationLotId)&&const DeepCollectionEquality().equals(other.animalIds, animalIds)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.responsibleId, responsibleId) || other.responsibleId == responsibleId)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,sourceLotId,destinationLotId,const DeepCollectionEquality().hash(animalIds),occurredAt,reason,createdAt,updatedAt,responsibleId,deletedAt);

@override
String toString() {
  return 'LotAnimalMovement(id: $id, establishmentId: $establishmentId, sourceLotId: $sourceLotId, destinationLotId: $destinationLotId, animalIds: $animalIds, occurredAt: $occurredAt, reason: $reason, createdAt: $createdAt, updatedAt: $updatedAt, responsibleId: $responsibleId, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $LotAnimalMovementCopyWith<$Res>  {
  factory $LotAnimalMovementCopyWith(LotAnimalMovement value, $Res Function(LotAnimalMovement) _then) = _$LotAnimalMovementCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String sourceLotId, String destinationLotId, List<String> animalIds, DateTime occurredAt, String reason, DateTime createdAt, DateTime updatedAt, String? responsibleId, DateTime? deletedAt
});




}
/// @nodoc
class _$LotAnimalMovementCopyWithImpl<$Res>
    implements $LotAnimalMovementCopyWith<$Res> {
  _$LotAnimalMovementCopyWithImpl(this._self, this._then);

  final LotAnimalMovement _self;
  final $Res Function(LotAnimalMovement) _then;

/// Create a copy of LotAnimalMovement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? sourceLotId = null,Object? destinationLotId = null,Object? animalIds = null,Object? occurredAt = null,Object? reason = null,Object? createdAt = null,Object? updatedAt = null,Object? responsibleId = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,sourceLotId: null == sourceLotId ? _self.sourceLotId : sourceLotId // ignore: cast_nullable_to_non_nullable
as String,destinationLotId: null == destinationLotId ? _self.destinationLotId : destinationLotId // ignore: cast_nullable_to_non_nullable
as String,animalIds: null == animalIds ? _self.animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,responsibleId: freezed == responsibleId ? _self.responsibleId : responsibleId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LotAnimalMovement].
extension LotAnimalMovementPatterns on LotAnimalMovement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotAnimalMovement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotAnimalMovement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotAnimalMovement value)  $default,){
final _that = this;
switch (_that) {
case _LotAnimalMovement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotAnimalMovement value)?  $default,){
final _that = this;
switch (_that) {
case _LotAnimalMovement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String sourceLotId,  String destinationLotId,  List<String> animalIds,  DateTime occurredAt,  String reason,  DateTime createdAt,  DateTime updatedAt,  String? responsibleId,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotAnimalMovement() when $default != null:
return $default(_that.id,_that.establishmentId,_that.sourceLotId,_that.destinationLotId,_that.animalIds,_that.occurredAt,_that.reason,_that.createdAt,_that.updatedAt,_that.responsibleId,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String sourceLotId,  String destinationLotId,  List<String> animalIds,  DateTime occurredAt,  String reason,  DateTime createdAt,  DateTime updatedAt,  String? responsibleId,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _LotAnimalMovement():
return $default(_that.id,_that.establishmentId,_that.sourceLotId,_that.destinationLotId,_that.animalIds,_that.occurredAt,_that.reason,_that.createdAt,_that.updatedAt,_that.responsibleId,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String sourceLotId,  String destinationLotId,  List<String> animalIds,  DateTime occurredAt,  String reason,  DateTime createdAt,  DateTime updatedAt,  String? responsibleId,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _LotAnimalMovement() when $default != null:
return $default(_that.id,_that.establishmentId,_that.sourceLotId,_that.destinationLotId,_that.animalIds,_that.occurredAt,_that.reason,_that.createdAt,_that.updatedAt,_that.responsibleId,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LotAnimalMovement implements LotAnimalMovement {
  const _LotAnimalMovement({required this.id, required this.establishmentId, required this.sourceLotId, required this.destinationLotId, required final  List<String> animalIds, required this.occurredAt, required this.reason, required this.createdAt, required this.updatedAt, this.responsibleId, this.deletedAt}): _animalIds = animalIds;
  

@override final  String id;
@override final  String establishmentId;
@override final  String sourceLotId;
@override final  String destinationLotId;
 final  List<String> _animalIds;
@override List<String> get animalIds {
  if (_animalIds is EqualUnmodifiableListView) return _animalIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animalIds);
}

@override final  DateTime occurredAt;
@override final  String reason;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? responsibleId;
@override final  DateTime? deletedAt;

/// Create a copy of LotAnimalMovement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotAnimalMovementCopyWith<_LotAnimalMovement> get copyWith => __$LotAnimalMovementCopyWithImpl<_LotAnimalMovement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotAnimalMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.sourceLotId, sourceLotId) || other.sourceLotId == sourceLotId)&&(identical(other.destinationLotId, destinationLotId) || other.destinationLotId == destinationLotId)&&const DeepCollectionEquality().equals(other._animalIds, _animalIds)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.responsibleId, responsibleId) || other.responsibleId == responsibleId)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,sourceLotId,destinationLotId,const DeepCollectionEquality().hash(_animalIds),occurredAt,reason,createdAt,updatedAt,responsibleId,deletedAt);

@override
String toString() {
  return 'LotAnimalMovement(id: $id, establishmentId: $establishmentId, sourceLotId: $sourceLotId, destinationLotId: $destinationLotId, animalIds: $animalIds, occurredAt: $occurredAt, reason: $reason, createdAt: $createdAt, updatedAt: $updatedAt, responsibleId: $responsibleId, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$LotAnimalMovementCopyWith<$Res> implements $LotAnimalMovementCopyWith<$Res> {
  factory _$LotAnimalMovementCopyWith(_LotAnimalMovement value, $Res Function(_LotAnimalMovement) _then) = __$LotAnimalMovementCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String sourceLotId, String destinationLotId, List<String> animalIds, DateTime occurredAt, String reason, DateTime createdAt, DateTime updatedAt, String? responsibleId, DateTime? deletedAt
});




}
/// @nodoc
class __$LotAnimalMovementCopyWithImpl<$Res>
    implements _$LotAnimalMovementCopyWith<$Res> {
  __$LotAnimalMovementCopyWithImpl(this._self, this._then);

  final _LotAnimalMovement _self;
  final $Res Function(_LotAnimalMovement) _then;

/// Create a copy of LotAnimalMovement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? sourceLotId = null,Object? destinationLotId = null,Object? animalIds = null,Object? occurredAt = null,Object? reason = null,Object? createdAt = null,Object? updatedAt = null,Object? responsibleId = freezed,Object? deletedAt = freezed,}) {
  return _then(_LotAnimalMovement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,sourceLotId: null == sourceLotId ? _self.sourceLotId : sourceLotId // ignore: cast_nullable_to_non_nullable
as String,destinationLotId: null == destinationLotId ? _self.destinationLotId : destinationLotId // ignore: cast_nullable_to_non_nullable
as String,animalIds: null == animalIds ? _self._animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,responsibleId: freezed == responsibleId ? _self.responsibleId : responsibleId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
