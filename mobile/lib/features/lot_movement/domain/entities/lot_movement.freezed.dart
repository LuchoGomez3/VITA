// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MovementAnimal {

 String get id; String get tag; bool get canMove; String? get lotId;
/// Create a copy of MovementAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementAnimalCopyWith<MovementAnimal> get copyWith => _$MovementAnimalCopyWithImpl<MovementAnimal>(this as MovementAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.canMove, canMove) || other.canMove == canMove)&&(identical(other.lotId, lotId) || other.lotId == lotId));
}


@override
int get hashCode => Object.hash(runtimeType,id,tag,canMove,lotId);

@override
String toString() {
  return 'MovementAnimal(id: $id, tag: $tag, canMove: $canMove, lotId: $lotId)';
}


}

/// @nodoc
abstract mixin class $MovementAnimalCopyWith<$Res>  {
  factory $MovementAnimalCopyWith(MovementAnimal value, $Res Function(MovementAnimal) _then) = _$MovementAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String tag, bool canMove, String? lotId
});




}
/// @nodoc
class _$MovementAnimalCopyWithImpl<$Res>
    implements $MovementAnimalCopyWith<$Res> {
  _$MovementAnimalCopyWithImpl(this._self, this._then);

  final MovementAnimal _self;
  final $Res Function(MovementAnimal) _then;

/// Create a copy of MovementAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tag = null,Object? canMove = null,Object? lotId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,canMove: null == canMove ? _self.canMove : canMove // ignore: cast_nullable_to_non_nullable
as bool,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementAnimal].
extension MovementAnimalPatterns on MovementAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementAnimal value)  $default,){
final _that = this;
switch (_that) {
case _MovementAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _MovementAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tag,  bool canMove,  String? lotId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementAnimal() when $default != null:
return $default(_that.id,_that.tag,_that.canMove,_that.lotId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tag,  bool canMove,  String? lotId)  $default,) {final _that = this;
switch (_that) {
case _MovementAnimal():
return $default(_that.id,_that.tag,_that.canMove,_that.lotId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tag,  bool canMove,  String? lotId)?  $default,) {final _that = this;
switch (_that) {
case _MovementAnimal() when $default != null:
return $default(_that.id,_that.tag,_that.canMove,_that.lotId);case _:
  return null;

}
}

}

/// @nodoc


class _MovementAnimal implements MovementAnimal {
  const _MovementAnimal({required this.id, required this.tag, required this.canMove, this.lotId});
  

@override final  String id;
@override final  String tag;
@override final  bool canMove;
@override final  String? lotId;

/// Create a copy of MovementAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementAnimalCopyWith<_MovementAnimal> get copyWith => __$MovementAnimalCopyWithImpl<_MovementAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.canMove, canMove) || other.canMove == canMove)&&(identical(other.lotId, lotId) || other.lotId == lotId));
}


@override
int get hashCode => Object.hash(runtimeType,id,tag,canMove,lotId);

@override
String toString() {
  return 'MovementAnimal(id: $id, tag: $tag, canMove: $canMove, lotId: $lotId)';
}


}

/// @nodoc
abstract mixin class _$MovementAnimalCopyWith<$Res> implements $MovementAnimalCopyWith<$Res> {
  factory _$MovementAnimalCopyWith(_MovementAnimal value, $Res Function(_MovementAnimal) _then) = __$MovementAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String tag, bool canMove, String? lotId
});




}
/// @nodoc
class __$MovementAnimalCopyWithImpl<$Res>
    implements _$MovementAnimalCopyWith<$Res> {
  __$MovementAnimalCopyWithImpl(this._self, this._then);

  final _MovementAnimal _self;
  final $Res Function(_MovementAnimal) _then;

/// Create a copy of MovementAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tag = null,Object? canMove = null,Object? lotId = freezed,}) {
  return _then(_MovementAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,canMove: null == canMove ? _self.canMove : canMove // ignore: cast_nullable_to_non_nullable
as bool,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MovementLot {

 String get id; String get name;
/// Create a copy of MovementLot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementLotCopyWith<MovementLot> get copyWith => _$MovementLotCopyWithImpl<MovementLot>(this as MovementLot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementLot&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'MovementLot(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $MovementLotCopyWith<$Res>  {
  factory $MovementLotCopyWith(MovementLot value, $Res Function(MovementLot) _then) = _$MovementLotCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$MovementLotCopyWithImpl<$Res>
    implements $MovementLotCopyWith<$Res> {
  _$MovementLotCopyWithImpl(this._self, this._then);

  final MovementLot _self;
  final $Res Function(MovementLot) _then;

/// Create a copy of MovementLot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementLot].
extension MovementLotPatterns on MovementLot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementLot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementLot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementLot value)  $default,){
final _that = this;
switch (_that) {
case _MovementLot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementLot value)?  $default,){
final _that = this;
switch (_that) {
case _MovementLot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementLot() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _MovementLot():
return $default(_that.id,_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _MovementLot() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _MovementLot implements MovementLot {
  const _MovementLot({required this.id, required this.name});
  

@override final  String id;
@override final  String name;

/// Create a copy of MovementLot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementLotCopyWith<_MovementLot> get copyWith => __$MovementLotCopyWithImpl<_MovementLot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementLot&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'MovementLot(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$MovementLotCopyWith<$Res> implements $MovementLotCopyWith<$Res> {
  factory _$MovementLotCopyWith(_MovementLot value, $Res Function(_MovementLot) _then) = __$MovementLotCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$MovementLotCopyWithImpl<$Res>
    implements _$MovementLotCopyWith<$Res> {
  __$MovementLotCopyWithImpl(this._self, this._then);

  final _MovementLot _self;
  final $Res Function(_MovementLot) _then;

/// Create a copy of MovementLot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_MovementLot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AnimalLotMovement {

 String get id; String get establishmentId; String get destinationLotId; List<String> get animalIds; DateTime get occurredAt; String get reason; DateTime get createdAt; String? get sourceLotId; MovementSyncStatus get syncStatus; String? get syncErrorCode;
/// Create a copy of AnimalLotMovement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalLotMovementCopyWith<AnimalLotMovement> get copyWith => _$AnimalLotMovementCopyWithImpl<AnimalLotMovement>(this as AnimalLotMovement, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalLotMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.destinationLotId, destinationLotId) || other.destinationLotId == destinationLotId)&&const DeepCollectionEquality().equals(other.animalIds, animalIds)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sourceLotId, sourceLotId) || other.sourceLotId == sourceLotId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,destinationLotId,const DeepCollectionEquality().hash(animalIds),occurredAt,reason,createdAt,sourceLotId,syncStatus,syncErrorCode);

@override
String toString() {
  return 'AnimalLotMovement(id: $id, establishmentId: $establishmentId, destinationLotId: $destinationLotId, animalIds: $animalIds, occurredAt: $occurredAt, reason: $reason, createdAt: $createdAt, sourceLotId: $sourceLotId, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $AnimalLotMovementCopyWith<$Res>  {
  factory $AnimalLotMovementCopyWith(AnimalLotMovement value, $Res Function(AnimalLotMovement) _then) = _$AnimalLotMovementCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String destinationLotId, List<String> animalIds, DateTime occurredAt, String reason, DateTime createdAt, String? sourceLotId, MovementSyncStatus syncStatus, String? syncErrorCode
});




}
/// @nodoc
class _$AnimalLotMovementCopyWithImpl<$Res>
    implements $AnimalLotMovementCopyWith<$Res> {
  _$AnimalLotMovementCopyWithImpl(this._self, this._then);

  final AnimalLotMovement _self;
  final $Res Function(AnimalLotMovement) _then;

/// Create a copy of AnimalLotMovement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? destinationLotId = null,Object? animalIds = null,Object? occurredAt = null,Object? reason = null,Object? createdAt = null,Object? sourceLotId = freezed,Object? syncStatus = null,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,destinationLotId: null == destinationLotId ? _self.destinationLotId : destinationLotId // ignore: cast_nullable_to_non_nullable
as String,animalIds: null == animalIds ? _self.animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceLotId: freezed == sourceLotId ? _self.sourceLotId : sourceLotId // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as MovementSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalLotMovement].
extension AnimalLotMovementPatterns on AnimalLotMovement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalLotMovement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalLotMovement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalLotMovement value)  $default,){
final _that = this;
switch (_that) {
case _AnimalLotMovement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalLotMovement value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalLotMovement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String destinationLotId,  List<String> animalIds,  DateTime occurredAt,  String reason,  DateTime createdAt,  String? sourceLotId,  MovementSyncStatus syncStatus,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalLotMovement() when $default != null:
return $default(_that.id,_that.establishmentId,_that.destinationLotId,_that.animalIds,_that.occurredAt,_that.reason,_that.createdAt,_that.sourceLotId,_that.syncStatus,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String destinationLotId,  List<String> animalIds,  DateTime occurredAt,  String reason,  DateTime createdAt,  String? sourceLotId,  MovementSyncStatus syncStatus,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _AnimalLotMovement():
return $default(_that.id,_that.establishmentId,_that.destinationLotId,_that.animalIds,_that.occurredAt,_that.reason,_that.createdAt,_that.sourceLotId,_that.syncStatus,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String destinationLotId,  List<String> animalIds,  DateTime occurredAt,  String reason,  DateTime createdAt,  String? sourceLotId,  MovementSyncStatus syncStatus,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _AnimalLotMovement() when $default != null:
return $default(_that.id,_that.establishmentId,_that.destinationLotId,_that.animalIds,_that.occurredAt,_that.reason,_that.createdAt,_that.sourceLotId,_that.syncStatus,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalLotMovement implements AnimalLotMovement {
  const _AnimalLotMovement({required this.id, required this.establishmentId, required this.destinationLotId, required final  List<String> animalIds, required this.occurredAt, required this.reason, required this.createdAt, this.sourceLotId, this.syncStatus = MovementSyncStatus.pending, this.syncErrorCode}): _animalIds = animalIds;
  

@override final  String id;
@override final  String establishmentId;
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
@override final  String? sourceLotId;
@override@JsonKey() final  MovementSyncStatus syncStatus;
@override final  String? syncErrorCode;

/// Create a copy of AnimalLotMovement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalLotMovementCopyWith<_AnimalLotMovement> get copyWith => __$AnimalLotMovementCopyWithImpl<_AnimalLotMovement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalLotMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.destinationLotId, destinationLotId) || other.destinationLotId == destinationLotId)&&const DeepCollectionEquality().equals(other._animalIds, _animalIds)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sourceLotId, sourceLotId) || other.sourceLotId == sourceLotId)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,destinationLotId,const DeepCollectionEquality().hash(_animalIds),occurredAt,reason,createdAt,sourceLotId,syncStatus,syncErrorCode);

@override
String toString() {
  return 'AnimalLotMovement(id: $id, establishmentId: $establishmentId, destinationLotId: $destinationLotId, animalIds: $animalIds, occurredAt: $occurredAt, reason: $reason, createdAt: $createdAt, sourceLotId: $sourceLotId, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$AnimalLotMovementCopyWith<$Res> implements $AnimalLotMovementCopyWith<$Res> {
  factory _$AnimalLotMovementCopyWith(_AnimalLotMovement value, $Res Function(_AnimalLotMovement) _then) = __$AnimalLotMovementCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String destinationLotId, List<String> animalIds, DateTime occurredAt, String reason, DateTime createdAt, String? sourceLotId, MovementSyncStatus syncStatus, String? syncErrorCode
});




}
/// @nodoc
class __$AnimalLotMovementCopyWithImpl<$Res>
    implements _$AnimalLotMovementCopyWith<$Res> {
  __$AnimalLotMovementCopyWithImpl(this._self, this._then);

  final _AnimalLotMovement _self;
  final $Res Function(_AnimalLotMovement) _then;

/// Create a copy of AnimalLotMovement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? destinationLotId = null,Object? animalIds = null,Object? occurredAt = null,Object? reason = null,Object? createdAt = null,Object? sourceLotId = freezed,Object? syncStatus = null,Object? syncErrorCode = freezed,}) {
  return _then(_AnimalLotMovement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,destinationLotId: null == destinationLotId ? _self.destinationLotId : destinationLotId // ignore: cast_nullable_to_non_nullable
as String,animalIds: null == animalIds ? _self._animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceLotId: freezed == sourceLotId ? _self.sourceLotId : sourceLotId // ignore: cast_nullable_to_non_nullable
as String?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as MovementSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MovementContext {

 List<MovementAnimal> get animals; List<MovementLot> get destinations; List<MovementLot> get origins; List<AnimalLotMovement> get history; bool get usingCachedData;
/// Create a copy of MovementContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementContextCopyWith<MovementContext> get copyWith => _$MovementContextCopyWithImpl<MovementContext>(this as MovementContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementContext&&const DeepCollectionEquality().equals(other.animals, animals)&&const DeepCollectionEquality().equals(other.destinations, destinations)&&const DeepCollectionEquality().equals(other.origins, origins)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.usingCachedData, usingCachedData) || other.usingCachedData == usingCachedData));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(animals),const DeepCollectionEquality().hash(destinations),const DeepCollectionEquality().hash(origins),const DeepCollectionEquality().hash(history),usingCachedData);

@override
String toString() {
  return 'MovementContext(animals: $animals, destinations: $destinations, origins: $origins, history: $history, usingCachedData: $usingCachedData)';
}


}

/// @nodoc
abstract mixin class $MovementContextCopyWith<$Res>  {
  factory $MovementContextCopyWith(MovementContext value, $Res Function(MovementContext) _then) = _$MovementContextCopyWithImpl;
@useResult
$Res call({
 List<MovementAnimal> animals, List<MovementLot> destinations, List<MovementLot> origins, List<AnimalLotMovement> history, bool usingCachedData
});




}
/// @nodoc
class _$MovementContextCopyWithImpl<$Res>
    implements $MovementContextCopyWith<$Res> {
  _$MovementContextCopyWithImpl(this._self, this._then);

  final MovementContext _self;
  final $Res Function(MovementContext) _then;

/// Create a copy of MovementContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animals = null,Object? destinations = null,Object? origins = null,Object? history = null,Object? usingCachedData = null,}) {
  return _then(_self.copyWith(
animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<MovementAnimal>,destinations: null == destinations ? _self.destinations : destinations // ignore: cast_nullable_to_non_nullable
as List<MovementLot>,origins: null == origins ? _self.origins : origins // ignore: cast_nullable_to_non_nullable
as List<MovementLot>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<AnimalLotMovement>,usingCachedData: null == usingCachedData ? _self.usingCachedData : usingCachedData // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementContext].
extension MovementContextPatterns on MovementContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementContext value)  $default,){
final _that = this;
switch (_that) {
case _MovementContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementContext value)?  $default,){
final _that = this;
switch (_that) {
case _MovementContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MovementAnimal> animals,  List<MovementLot> destinations,  List<MovementLot> origins,  List<AnimalLotMovement> history,  bool usingCachedData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementContext() when $default != null:
return $default(_that.animals,_that.destinations,_that.origins,_that.history,_that.usingCachedData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MovementAnimal> animals,  List<MovementLot> destinations,  List<MovementLot> origins,  List<AnimalLotMovement> history,  bool usingCachedData)  $default,) {final _that = this;
switch (_that) {
case _MovementContext():
return $default(_that.animals,_that.destinations,_that.origins,_that.history,_that.usingCachedData);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MovementAnimal> animals,  List<MovementLot> destinations,  List<MovementLot> origins,  List<AnimalLotMovement> history,  bool usingCachedData)?  $default,) {final _that = this;
switch (_that) {
case _MovementContext() when $default != null:
return $default(_that.animals,_that.destinations,_that.origins,_that.history,_that.usingCachedData);case _:
  return null;

}
}

}

/// @nodoc


class _MovementContext implements MovementContext {
  const _MovementContext({required final  List<MovementAnimal> animals, required final  List<MovementLot> destinations, required final  List<MovementLot> origins, required final  List<AnimalLotMovement> history, this.usingCachedData = false}): _animals = animals,_destinations = destinations,_origins = origins,_history = history;
  

 final  List<MovementAnimal> _animals;
@override List<MovementAnimal> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}

 final  List<MovementLot> _destinations;
@override List<MovementLot> get destinations {
  if (_destinations is EqualUnmodifiableListView) return _destinations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_destinations);
}

 final  List<MovementLot> _origins;
@override List<MovementLot> get origins {
  if (_origins is EqualUnmodifiableListView) return _origins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_origins);
}

 final  List<AnimalLotMovement> _history;
@override List<AnimalLotMovement> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override@JsonKey() final  bool usingCachedData;

/// Create a copy of MovementContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementContextCopyWith<_MovementContext> get copyWith => __$MovementContextCopyWithImpl<_MovementContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementContext&&const DeepCollectionEquality().equals(other._animals, _animals)&&const DeepCollectionEquality().equals(other._destinations, _destinations)&&const DeepCollectionEquality().equals(other._origins, _origins)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.usingCachedData, usingCachedData) || other.usingCachedData == usingCachedData));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_animals),const DeepCollectionEquality().hash(_destinations),const DeepCollectionEquality().hash(_origins),const DeepCollectionEquality().hash(_history),usingCachedData);

@override
String toString() {
  return 'MovementContext(animals: $animals, destinations: $destinations, origins: $origins, history: $history, usingCachedData: $usingCachedData)';
}


}

/// @nodoc
abstract mixin class _$MovementContextCopyWith<$Res> implements $MovementContextCopyWith<$Res> {
  factory _$MovementContextCopyWith(_MovementContext value, $Res Function(_MovementContext) _then) = __$MovementContextCopyWithImpl;
@override @useResult
$Res call({
 List<MovementAnimal> animals, List<MovementLot> destinations, List<MovementLot> origins, List<AnimalLotMovement> history, bool usingCachedData
});




}
/// @nodoc
class __$MovementContextCopyWithImpl<$Res>
    implements _$MovementContextCopyWith<$Res> {
  __$MovementContextCopyWithImpl(this._self, this._then);

  final _MovementContext _self;
  final $Res Function(_MovementContext) _then;

/// Create a copy of MovementContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animals = null,Object? destinations = null,Object? origins = null,Object? history = null,Object? usingCachedData = null,}) {
  return _then(_MovementContext(
animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<MovementAnimal>,destinations: null == destinations ? _self._destinations : destinations // ignore: cast_nullable_to_non_nullable
as List<MovementLot>,origins: null == origins ? _self._origins : origins // ignore: cast_nullable_to_non_nullable
as List<MovementLot>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<AnimalLotMovement>,usingCachedData: null == usingCachedData ? _self.usingCachedData : usingCachedData // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
