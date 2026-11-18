// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestock_sale_selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivestockSaleAnimal {

 String get id; String get establishmentId; String get rfidTagNumber; String get visualTag; String get categoryName; String get lotName; LivestockSaleAnimalStatus get status;
/// Create a copy of LivestockSaleAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleAnimalCopyWith<LivestockSaleAnimal> get copyWith => _$LivestockSaleAnimalCopyWithImpl<LivestockSaleAnimal>(this as LivestockSaleAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,rfidTagNumber,visualTag,categoryName,lotName,status);

@override
String toString() {
  return 'LivestockSaleAnimal(id: $id, establishmentId: $establishmentId, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, categoryName: $categoryName, lotName: $lotName, status: $status)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleAnimalCopyWith<$Res>  {
  factory $LivestockSaleAnimalCopyWith(LivestockSaleAnimal value, $Res Function(LivestockSaleAnimal) _then) = _$LivestockSaleAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String rfidTagNumber, String visualTag, String categoryName, String lotName, LivestockSaleAnimalStatus status
});




}
/// @nodoc
class _$LivestockSaleAnimalCopyWithImpl<$Res>
    implements $LivestockSaleAnimalCopyWith<$Res> {
  _$LivestockSaleAnimalCopyWithImpl(this._self, this._then);

  final LivestockSaleAnimal _self;
  final $Res Function(LivestockSaleAnimal) _then;

/// Create a copy of LivestockSaleAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? categoryName = null,Object? lotName = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LivestockSaleAnimalStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockSaleAnimal].
extension LivestockSaleAnimalPatterns on LivestockSaleAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleAnimal value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String rfidTagNumber,  String visualTag,  String categoryName,  String lotName,  LivestockSaleAnimalStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleAnimal() when $default != null:
return $default(_that.id,_that.establishmentId,_that.rfidTagNumber,_that.visualTag,_that.categoryName,_that.lotName,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String rfidTagNumber,  String visualTag,  String categoryName,  String lotName,  LivestockSaleAnimalStatus status)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleAnimal():
return $default(_that.id,_that.establishmentId,_that.rfidTagNumber,_that.visualTag,_that.categoryName,_that.lotName,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String rfidTagNumber,  String visualTag,  String categoryName,  String lotName,  LivestockSaleAnimalStatus status)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleAnimal() when $default != null:
return $default(_that.id,_that.establishmentId,_that.rfidTagNumber,_that.visualTag,_that.categoryName,_that.lotName,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleAnimal implements LivestockSaleAnimal {
  const _LivestockSaleAnimal({required this.id, required this.establishmentId, required this.rfidTagNumber, required this.visualTag, required this.categoryName, required this.lotName, required this.status});
  

@override final  String id;
@override final  String establishmentId;
@override final  String rfidTagNumber;
@override final  String visualTag;
@override final  String categoryName;
@override final  String lotName;
@override final  LivestockSaleAnimalStatus status;

/// Create a copy of LivestockSaleAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleAnimalCopyWith<_LivestockSaleAnimal> get copyWith => __$LivestockSaleAnimalCopyWithImpl<_LivestockSaleAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,rfidTagNumber,visualTag,categoryName,lotName,status);

@override
String toString() {
  return 'LivestockSaleAnimal(id: $id, establishmentId: $establishmentId, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, categoryName: $categoryName, lotName: $lotName, status: $status)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleAnimalCopyWith<$Res> implements $LivestockSaleAnimalCopyWith<$Res> {
  factory _$LivestockSaleAnimalCopyWith(_LivestockSaleAnimal value, $Res Function(_LivestockSaleAnimal) _then) = __$LivestockSaleAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String rfidTagNumber, String visualTag, String categoryName, String lotName, LivestockSaleAnimalStatus status
});




}
/// @nodoc
class __$LivestockSaleAnimalCopyWithImpl<$Res>
    implements _$LivestockSaleAnimalCopyWith<$Res> {
  __$LivestockSaleAnimalCopyWithImpl(this._self, this._then);

  final _LivestockSaleAnimal _self;
  final $Res Function(_LivestockSaleAnimal) _then;

/// Create a copy of LivestockSaleAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? categoryName = null,Object? lotName = null,Object? status = null,}) {
  return _then(_LivestockSaleAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LivestockSaleAnimalStatus,
  ));
}


}

/// @nodoc
mixin _$LivestockSaleSelection {

 List<LivestockSaleAnimal> get animals;
/// Create a copy of LivestockSaleSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleSelectionCopyWith<LivestockSaleSelection> get copyWith => _$LivestockSaleSelectionCopyWithImpl<LivestockSaleSelection>(this as LivestockSaleSelection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleSelection&&const DeepCollectionEquality().equals(other.animals, animals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(animals));

@override
String toString() {
  return 'LivestockSaleSelection(animals: $animals)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleSelectionCopyWith<$Res>  {
  factory $LivestockSaleSelectionCopyWith(LivestockSaleSelection value, $Res Function(LivestockSaleSelection) _then) = _$LivestockSaleSelectionCopyWithImpl;
@useResult
$Res call({
 List<LivestockSaleAnimal> animals
});




}
/// @nodoc
class _$LivestockSaleSelectionCopyWithImpl<$Res>
    implements $LivestockSaleSelectionCopyWith<$Res> {
  _$LivestockSaleSelectionCopyWithImpl(this._self, this._then);

  final LivestockSaleSelection _self;
  final $Res Function(LivestockSaleSelection) _then;

/// Create a copy of LivestockSaleSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animals = null,}) {
  return _then(_self.copyWith(
animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<LivestockSaleAnimal>,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockSaleSelection].
extension LivestockSaleSelectionPatterns on LivestockSaleSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleSelection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleSelection value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleSelection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleSelection value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleSelection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LivestockSaleAnimal> animals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleSelection() when $default != null:
return $default(_that.animals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LivestockSaleAnimal> animals)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleSelection():
return $default(_that.animals);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LivestockSaleAnimal> animals)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleSelection() when $default != null:
return $default(_that.animals);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleSelection implements LivestockSaleSelection {
  const _LivestockSaleSelection({final  List<LivestockSaleAnimal> animals = const <LivestockSaleAnimal>[]}): _animals = animals;
  

 final  List<LivestockSaleAnimal> _animals;
@override@JsonKey() List<LivestockSaleAnimal> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}


/// Create a copy of LivestockSaleSelection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleSelectionCopyWith<_LivestockSaleSelection> get copyWith => __$LivestockSaleSelectionCopyWithImpl<_LivestockSaleSelection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleSelection&&const DeepCollectionEquality().equals(other._animals, _animals));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_animals));

@override
String toString() {
  return 'LivestockSaleSelection(animals: $animals)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleSelectionCopyWith<$Res> implements $LivestockSaleSelectionCopyWith<$Res> {
  factory _$LivestockSaleSelectionCopyWith(_LivestockSaleSelection value, $Res Function(_LivestockSaleSelection) _then) = __$LivestockSaleSelectionCopyWithImpl;
@override @useResult
$Res call({
 List<LivestockSaleAnimal> animals
});




}
/// @nodoc
class __$LivestockSaleSelectionCopyWithImpl<$Res>
    implements _$LivestockSaleSelectionCopyWith<$Res> {
  __$LivestockSaleSelectionCopyWithImpl(this._self, this._then);

  final _LivestockSaleSelection _self;
  final $Res Function(_LivestockSaleSelection) _then;

/// Create a copy of LivestockSaleSelection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animals = null,}) {
  return _then(_LivestockSaleSelection(
animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<LivestockSaleAnimal>,
  ));
}


}

// dart format on
