// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lot_animal_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LotAnimalSummary {

 String get id; String get establishmentId; String get lotId; String get rfidTagNumber; String get visualTag; String get categoryName;
/// Create a copy of LotAnimalSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotAnimalSummaryCopyWith<LotAnimalSummary> get copyWith => _$LotAnimalSummaryCopyWithImpl<LotAnimalSummary>(this as LotAnimalSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotAnimalSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,lotId,rfidTagNumber,visualTag,categoryName);

@override
String toString() {
  return 'LotAnimalSummary(id: $id, establishmentId: $establishmentId, lotId: $lotId, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class $LotAnimalSummaryCopyWith<$Res>  {
  factory $LotAnimalSummaryCopyWith(LotAnimalSummary value, $Res Function(LotAnimalSummary) _then) = _$LotAnimalSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String lotId, String rfidTagNumber, String visualTag, String categoryName
});




}
/// @nodoc
class _$LotAnimalSummaryCopyWithImpl<$Res>
    implements $LotAnimalSummaryCopyWith<$Res> {
  _$LotAnimalSummaryCopyWithImpl(this._self, this._then);

  final LotAnimalSummary _self;
  final $Res Function(LotAnimalSummary) _then;

/// Create a copy of LotAnimalSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? lotId = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? categoryName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LotAnimalSummary].
extension LotAnimalSummaryPatterns on LotAnimalSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotAnimalSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotAnimalSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotAnimalSummary value)  $default,){
final _that = this;
switch (_that) {
case _LotAnimalSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotAnimalSummary value)?  $default,){
final _that = this;
switch (_that) {
case _LotAnimalSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String lotId,  String rfidTagNumber,  String visualTag,  String categoryName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotAnimalSummary() when $default != null:
return $default(_that.id,_that.establishmentId,_that.lotId,_that.rfidTagNumber,_that.visualTag,_that.categoryName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String lotId,  String rfidTagNumber,  String visualTag,  String categoryName)  $default,) {final _that = this;
switch (_that) {
case _LotAnimalSummary():
return $default(_that.id,_that.establishmentId,_that.lotId,_that.rfidTagNumber,_that.visualTag,_that.categoryName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String lotId,  String rfidTagNumber,  String visualTag,  String categoryName)?  $default,) {final _that = this;
switch (_that) {
case _LotAnimalSummary() when $default != null:
return $default(_that.id,_that.establishmentId,_that.lotId,_that.rfidTagNumber,_that.visualTag,_that.categoryName);case _:
  return null;

}
}

}

/// @nodoc


class _LotAnimalSummary implements LotAnimalSummary {
  const _LotAnimalSummary({required this.id, required this.establishmentId, required this.lotId, required this.rfidTagNumber, required this.visualTag, required this.categoryName});
  

@override final  String id;
@override final  String establishmentId;
@override final  String lotId;
@override final  String rfidTagNumber;
@override final  String visualTag;
@override final  String categoryName;

/// Create a copy of LotAnimalSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotAnimalSummaryCopyWith<_LotAnimalSummary> get copyWith => __$LotAnimalSummaryCopyWithImpl<_LotAnimalSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotAnimalSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,lotId,rfidTagNumber,visualTag,categoryName);

@override
String toString() {
  return 'LotAnimalSummary(id: $id, establishmentId: $establishmentId, lotId: $lotId, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class _$LotAnimalSummaryCopyWith<$Res> implements $LotAnimalSummaryCopyWith<$Res> {
  factory _$LotAnimalSummaryCopyWith(_LotAnimalSummary value, $Res Function(_LotAnimalSummary) _then) = __$LotAnimalSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String lotId, String rfidTagNumber, String visualTag, String categoryName
});




}
/// @nodoc
class __$LotAnimalSummaryCopyWithImpl<$Res>
    implements _$LotAnimalSummaryCopyWith<$Res> {
  __$LotAnimalSummaryCopyWithImpl(this._self, this._then);

  final _LotAnimalSummary _self;
  final $Res Function(_LotAnimalSummary) _then;

/// Create a copy of LotAnimalSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? lotId = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? categoryName = null,}) {
  return _then(_LotAnimalSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
