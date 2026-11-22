// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_forage_period.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotForagePeriod {

 String get id; String get establishmentId; String get lotId; String get resourceCode; DateTime get startDate; DateTime get createdAt; DateTime get updatedAt; String? get description; DateTime? get endDate; LotSyncStatus get syncStatus; String? get syncErrorCode; DateTime? get deletedAt;
/// Create a copy of LotForagePeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotForagePeriodCopyWith<LotForagePeriod> get copyWith => _$LotForagePeriodCopyWithImpl<LotForagePeriod>(this as LotForagePeriod, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotForagePeriod&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.resourceCode, resourceCode) || other.resourceCode == resourceCode)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,lotId,resourceCode,startDate,createdAt,updatedAt,description,endDate,syncStatus,syncErrorCode,deletedAt);

@override
String toString() {
  return 'LotForagePeriod(id: $id, establishmentId: $establishmentId, lotId: $lotId, resourceCode: $resourceCode, startDate: $startDate, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, endDate: $endDate, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $LotForagePeriodCopyWith<$Res>  {
  factory $LotForagePeriodCopyWith(LotForagePeriod value, $Res Function(LotForagePeriod) _then) = _$LotForagePeriodCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String lotId, String resourceCode, DateTime startDate, DateTime createdAt, DateTime updatedAt, String? description, DateTime? endDate, LotSyncStatus syncStatus, String? syncErrorCode, DateTime? deletedAt
});




}
/// @nodoc
class _$LotForagePeriodCopyWithImpl<$Res>
    implements $LotForagePeriodCopyWith<$Res> {
  _$LotForagePeriodCopyWithImpl(this._self, this._then);

  final LotForagePeriod _self;
  final $Res Function(LotForagePeriod) _then;

/// Create a copy of LotForagePeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? lotId = null,Object? resourceCode = null,Object? startDate = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? endDate = freezed,Object? syncStatus = null,Object? syncErrorCode = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,resourceCode: null == resourceCode ? _self.resourceCode : resourceCode // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as LotSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LotForagePeriod].
extension LotForagePeriodPatterns on LotForagePeriod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotForagePeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotForagePeriod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotForagePeriod value)  $default,){
final _that = this;
switch (_that) {
case _LotForagePeriod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotForagePeriod value)?  $default,){
final _that = this;
switch (_that) {
case _LotForagePeriod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String lotId,  String resourceCode,  DateTime startDate,  DateTime createdAt,  DateTime updatedAt,  String? description,  DateTime? endDate,  LotSyncStatus syncStatus,  String? syncErrorCode,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotForagePeriod() when $default != null:
return $default(_that.id,_that.establishmentId,_that.lotId,_that.resourceCode,_that.startDate,_that.createdAt,_that.updatedAt,_that.description,_that.endDate,_that.syncStatus,_that.syncErrorCode,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String lotId,  String resourceCode,  DateTime startDate,  DateTime createdAt,  DateTime updatedAt,  String? description,  DateTime? endDate,  LotSyncStatus syncStatus,  String? syncErrorCode,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _LotForagePeriod():
return $default(_that.id,_that.establishmentId,_that.lotId,_that.resourceCode,_that.startDate,_that.createdAt,_that.updatedAt,_that.description,_that.endDate,_that.syncStatus,_that.syncErrorCode,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String lotId,  String resourceCode,  DateTime startDate,  DateTime createdAt,  DateTime updatedAt,  String? description,  DateTime? endDate,  LotSyncStatus syncStatus,  String? syncErrorCode,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _LotForagePeriod() when $default != null:
return $default(_that.id,_that.establishmentId,_that.lotId,_that.resourceCode,_that.startDate,_that.createdAt,_that.updatedAt,_that.description,_that.endDate,_that.syncStatus,_that.syncErrorCode,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LotForagePeriod implements LotForagePeriod {
  const _LotForagePeriod({required this.id, required this.establishmentId, required this.lotId, required this.resourceCode, required this.startDate, required this.createdAt, required this.updatedAt, this.description, this.endDate, this.syncStatus = LotSyncStatus.pending, this.syncErrorCode, this.deletedAt});
  

@override final  String id;
@override final  String establishmentId;
@override final  String lotId;
@override final  String resourceCode;
@override final  DateTime startDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? description;
@override final  DateTime? endDate;
@override@JsonKey() final  LotSyncStatus syncStatus;
@override final  String? syncErrorCode;
@override final  DateTime? deletedAt;

/// Create a copy of LotForagePeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotForagePeriodCopyWith<_LotForagePeriod> get copyWith => __$LotForagePeriodCopyWithImpl<_LotForagePeriod>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotForagePeriod&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.resourceCode, resourceCode) || other.resourceCode == resourceCode)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,lotId,resourceCode,startDate,createdAt,updatedAt,description,endDate,syncStatus,syncErrorCode,deletedAt);

@override
String toString() {
  return 'LotForagePeriod(id: $id, establishmentId: $establishmentId, lotId: $lotId, resourceCode: $resourceCode, startDate: $startDate, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, endDate: $endDate, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$LotForagePeriodCopyWith<$Res> implements $LotForagePeriodCopyWith<$Res> {
  factory _$LotForagePeriodCopyWith(_LotForagePeriod value, $Res Function(_LotForagePeriod) _then) = __$LotForagePeriodCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String lotId, String resourceCode, DateTime startDate, DateTime createdAt, DateTime updatedAt, String? description, DateTime? endDate, LotSyncStatus syncStatus, String? syncErrorCode, DateTime? deletedAt
});




}
/// @nodoc
class __$LotForagePeriodCopyWithImpl<$Res>
    implements _$LotForagePeriodCopyWith<$Res> {
  __$LotForagePeriodCopyWithImpl(this._self, this._then);

  final _LotForagePeriod _self;
  final $Res Function(_LotForagePeriod) _then;

/// Create a copy of LotForagePeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? lotId = null,Object? resourceCode = null,Object? startDate = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? endDate = freezed,Object? syncStatus = null,Object? syncErrorCode = freezed,Object? deletedAt = freezed,}) {
  return _then(_LotForagePeriod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,resourceCode: null == resourceCode ? _self.resourceCode : resourceCode // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as LotSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
