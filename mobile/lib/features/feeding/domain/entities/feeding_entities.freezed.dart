// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feeding_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Food {

 String get id; String get name; String get categoryCode; String get unitCode; bool get isGlobal;
/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodCopyWith<Food> get copyWith => _$FoodCopyWithImpl<Food>(this as Food, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Food&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryCode, categoryCode) || other.categoryCode == categoryCode)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.isGlobal, isGlobal) || other.isGlobal == isGlobal));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,categoryCode,unitCode,isGlobal);

@override
String toString() {
  return 'Food(id: $id, name: $name, categoryCode: $categoryCode, unitCode: $unitCode, isGlobal: $isGlobal)';
}


}

/// @nodoc
abstract mixin class $FoodCopyWith<$Res>  {
  factory $FoodCopyWith(Food value, $Res Function(Food) _then) = _$FoodCopyWithImpl;
@useResult
$Res call({
 String id, String name, String categoryCode, String unitCode, bool isGlobal
});




}
/// @nodoc
class _$FoodCopyWithImpl<$Res>
    implements $FoodCopyWith<$Res> {
  _$FoodCopyWithImpl(this._self, this._then);

  final Food _self;
  final $Res Function(Food) _then;

/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? categoryCode = null,Object? unitCode = null,Object? isGlobal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryCode: null == categoryCode ? _self.categoryCode : categoryCode // ignore: cast_nullable_to_non_nullable
as String,unitCode: null == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String,isGlobal: null == isGlobal ? _self.isGlobal : isGlobal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Food].
extension FoodPatterns on Food {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Food value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Food() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Food value)  $default,){
final _that = this;
switch (_that) {
case _Food():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Food value)?  $default,){
final _that = this;
switch (_that) {
case _Food() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String categoryCode,  String unitCode,  bool isGlobal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Food() when $default != null:
return $default(_that.id,_that.name,_that.categoryCode,_that.unitCode,_that.isGlobal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String categoryCode,  String unitCode,  bool isGlobal)  $default,) {final _that = this;
switch (_that) {
case _Food():
return $default(_that.id,_that.name,_that.categoryCode,_that.unitCode,_that.isGlobal);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String categoryCode,  String unitCode,  bool isGlobal)?  $default,) {final _that = this;
switch (_that) {
case _Food() when $default != null:
return $default(_that.id,_that.name,_that.categoryCode,_that.unitCode,_that.isGlobal);case _:
  return null;

}
}

}

/// @nodoc


class _Food implements Food {
  const _Food({required this.id, required this.name, required this.categoryCode, required this.unitCode, this.isGlobal = false});
  

@override final  String id;
@override final  String name;
@override final  String categoryCode;
@override final  String unitCode;
@override@JsonKey() final  bool isGlobal;

/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodCopyWith<_Food> get copyWith => __$FoodCopyWithImpl<_Food>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Food&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryCode, categoryCode) || other.categoryCode == categoryCode)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.isGlobal, isGlobal) || other.isGlobal == isGlobal));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,categoryCode,unitCode,isGlobal);

@override
String toString() {
  return 'Food(id: $id, name: $name, categoryCode: $categoryCode, unitCode: $unitCode, isGlobal: $isGlobal)';
}


}

/// @nodoc
abstract mixin class _$FoodCopyWith<$Res> implements $FoodCopyWith<$Res> {
  factory _$FoodCopyWith(_Food value, $Res Function(_Food) _then) = __$FoodCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String categoryCode, String unitCode, bool isGlobal
});




}
/// @nodoc
class __$FoodCopyWithImpl<$Res>
    implements _$FoodCopyWith<$Res> {
  __$FoodCopyWithImpl(this._self, this._then);

  final _Food _self;
  final $Res Function(_Food) _then;

/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? categoryCode = null,Object? unitCode = null,Object? isGlobal = null,}) {
  return _then(_Food(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryCode: null == categoryCode ? _self.categoryCode : categoryCode // ignore: cast_nullable_to_non_nullable
as String,unitCode: null == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String,isGlobal: null == isGlobal ? _self.isGlobal : isGlobal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$FeedingAnimal {

 String get id; String get establishmentId; String get visualTag; String get rfidTagNumber; String get breed; String get categoryName; String get lotId; String get lotName;
/// Create a copy of FeedingAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedingAnimalCopyWith<FeedingAnimal> get copyWith => _$FeedingAnimalCopyWithImpl<FeedingAnimal>(this as FeedingAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedingAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,visualTag,rfidTagNumber,breed,categoryName,lotId,lotName);

@override
String toString() {
  return 'FeedingAnimal(id: $id, establishmentId: $establishmentId, visualTag: $visualTag, rfidTagNumber: $rfidTagNumber, breed: $breed, categoryName: $categoryName, lotId: $lotId, lotName: $lotName)';
}


}

/// @nodoc
abstract mixin class $FeedingAnimalCopyWith<$Res>  {
  factory $FeedingAnimalCopyWith(FeedingAnimal value, $Res Function(FeedingAnimal) _then) = _$FeedingAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String visualTag, String rfidTagNumber, String breed, String categoryName, String lotId, String lotName
});




}
/// @nodoc
class _$FeedingAnimalCopyWithImpl<$Res>
    implements $FeedingAnimalCopyWith<$Res> {
  _$FeedingAnimalCopyWithImpl(this._self, this._then);

  final FeedingAnimal _self;
  final $Res Function(FeedingAnimal) _then;

/// Create a copy of FeedingAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? visualTag = null,Object? rfidTagNumber = null,Object? breed = null,Object? categoryName = null,Object? lotId = null,Object? lotName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedingAnimal].
extension FeedingAnimalPatterns on FeedingAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedingAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedingAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedingAnimal value)  $default,){
final _that = this;
switch (_that) {
case _FeedingAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedingAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _FeedingAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String visualTag,  String rfidTagNumber,  String breed,  String categoryName,  String lotId,  String lotName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedingAnimal() when $default != null:
return $default(_that.id,_that.establishmentId,_that.visualTag,_that.rfidTagNumber,_that.breed,_that.categoryName,_that.lotId,_that.lotName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String visualTag,  String rfidTagNumber,  String breed,  String categoryName,  String lotId,  String lotName)  $default,) {final _that = this;
switch (_that) {
case _FeedingAnimal():
return $default(_that.id,_that.establishmentId,_that.visualTag,_that.rfidTagNumber,_that.breed,_that.categoryName,_that.lotId,_that.lotName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String visualTag,  String rfidTagNumber,  String breed,  String categoryName,  String lotId,  String lotName)?  $default,) {final _that = this;
switch (_that) {
case _FeedingAnimal() when $default != null:
return $default(_that.id,_that.establishmentId,_that.visualTag,_that.rfidTagNumber,_that.breed,_that.categoryName,_that.lotId,_that.lotName);case _:
  return null;

}
}

}

/// @nodoc


class _FeedingAnimal implements FeedingAnimal {
  const _FeedingAnimal({required this.id, required this.establishmentId, required this.visualTag, required this.rfidTagNumber, required this.breed, required this.categoryName, required this.lotId, required this.lotName});
  

@override final  String id;
@override final  String establishmentId;
@override final  String visualTag;
@override final  String rfidTagNumber;
@override final  String breed;
@override final  String categoryName;
@override final  String lotId;
@override final  String lotName;

/// Create a copy of FeedingAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedingAnimalCopyWith<_FeedingAnimal> get copyWith => __$FeedingAnimalCopyWithImpl<_FeedingAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedingAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,visualTag,rfidTagNumber,breed,categoryName,lotId,lotName);

@override
String toString() {
  return 'FeedingAnimal(id: $id, establishmentId: $establishmentId, visualTag: $visualTag, rfidTagNumber: $rfidTagNumber, breed: $breed, categoryName: $categoryName, lotId: $lotId, lotName: $lotName)';
}


}

/// @nodoc
abstract mixin class _$FeedingAnimalCopyWith<$Res> implements $FeedingAnimalCopyWith<$Res> {
  factory _$FeedingAnimalCopyWith(_FeedingAnimal value, $Res Function(_FeedingAnimal) _then) = __$FeedingAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String visualTag, String rfidTagNumber, String breed, String categoryName, String lotId, String lotName
});




}
/// @nodoc
class __$FeedingAnimalCopyWithImpl<$Res>
    implements _$FeedingAnimalCopyWith<$Res> {
  __$FeedingAnimalCopyWithImpl(this._self, this._then);

  final _FeedingAnimal _self;
  final $Res Function(_FeedingAnimal) _then;

/// Create a copy of FeedingAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? visualTag = null,Object? rfidTagNumber = null,Object? breed = null,Object? categoryName = null,Object? lotId = null,Object? lotName = null,}) {
  return _then(_FeedingAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$FeedingLot {

 String get id; String get name;
/// Create a copy of FeedingLot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedingLotCopyWith<FeedingLot> get copyWith => _$FeedingLotCopyWithImpl<FeedingLot>(this as FeedingLot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedingLot&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'FeedingLot(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $FeedingLotCopyWith<$Res>  {
  factory $FeedingLotCopyWith(FeedingLot value, $Res Function(FeedingLot) _then) = _$FeedingLotCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$FeedingLotCopyWithImpl<$Res>
    implements $FeedingLotCopyWith<$Res> {
  _$FeedingLotCopyWithImpl(this._self, this._then);

  final FeedingLot _self;
  final $Res Function(FeedingLot) _then;

/// Create a copy of FeedingLot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedingLot].
extension FeedingLotPatterns on FeedingLot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedingLot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedingLot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedingLot value)  $default,){
final _that = this;
switch (_that) {
case _FeedingLot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedingLot value)?  $default,){
final _that = this;
switch (_that) {
case _FeedingLot() when $default != null:
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
case _FeedingLot() when $default != null:
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
case _FeedingLot():
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
case _FeedingLot() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _FeedingLot implements FeedingLot {
  const _FeedingLot({required this.id, required this.name});
  

@override final  String id;
@override final  String name;

/// Create a copy of FeedingLot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedingLotCopyWith<_FeedingLot> get copyWith => __$FeedingLotCopyWithImpl<_FeedingLot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedingLot&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'FeedingLot(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$FeedingLotCopyWith<$Res> implements $FeedingLotCopyWith<$Res> {
  factory _$FeedingLotCopyWith(_FeedingLot value, $Res Function(_FeedingLot) _then) = __$FeedingLotCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$FeedingLotCopyWithImpl<$Res>
    implements _$FeedingLotCopyWith<$Res> {
  __$FeedingLotCopyWithImpl(this._self, this._then);

  final _FeedingLot _self;
  final $Res Function(_FeedingLot) _then;

/// Create a copy of FeedingLot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_FeedingLot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$FeedingRecord {

 String get id; String get establishmentId; FeedingType get type; String get foodId; DateTime get startDate; String get quantity; String get unitCode; FeedingQuantityBasis get basis; List<String> get animalIds; DateTime get createdAt; DateTime get updatedAt; String? get lotId; DateTime? get endDate; String? get reason;
/// Create a copy of FeedingRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedingRecordCopyWith<FeedingRecord> get copyWith => _$FeedingRecordCopyWithImpl<FeedingRecord>(this as FeedingRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedingRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.type, type) || other.type == type)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.basis, basis) || other.basis == basis)&&const DeepCollectionEquality().equals(other.animalIds, animalIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,type,foodId,startDate,quantity,unitCode,basis,const DeepCollectionEquality().hash(animalIds),createdAt,updatedAt,lotId,endDate,reason);

@override
String toString() {
  return 'FeedingRecord(id: $id, establishmentId: $establishmentId, type: $type, foodId: $foodId, startDate: $startDate, quantity: $quantity, unitCode: $unitCode, basis: $basis, animalIds: $animalIds, createdAt: $createdAt, updatedAt: $updatedAt, lotId: $lotId, endDate: $endDate, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $FeedingRecordCopyWith<$Res>  {
  factory $FeedingRecordCopyWith(FeedingRecord value, $Res Function(FeedingRecord) _then) = _$FeedingRecordCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, FeedingType type, String foodId, DateTime startDate, String quantity, String unitCode, FeedingQuantityBasis basis, List<String> animalIds, DateTime createdAt, DateTime updatedAt, String? lotId, DateTime? endDate, String? reason
});




}
/// @nodoc
class _$FeedingRecordCopyWithImpl<$Res>
    implements $FeedingRecordCopyWith<$Res> {
  _$FeedingRecordCopyWithImpl(this._self, this._then);

  final FeedingRecord _self;
  final $Res Function(FeedingRecord) _then;

/// Create a copy of FeedingRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? type = null,Object? foodId = null,Object? startDate = null,Object? quantity = null,Object? unitCode = null,Object? basis = null,Object? animalIds = null,Object? createdAt = null,Object? updatedAt = null,Object? lotId = freezed,Object? endDate = freezed,Object? reason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedingType,foodId: null == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,unitCode: null == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as FeedingQuantityBasis,animalIds: null == animalIds ? _self.animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedingRecord].
extension FeedingRecordPatterns on FeedingRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedingRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedingRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedingRecord value)  $default,){
final _that = this;
switch (_that) {
case _FeedingRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedingRecord value)?  $default,){
final _that = this;
switch (_that) {
case _FeedingRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  FeedingType type,  String foodId,  DateTime startDate,  String quantity,  String unitCode,  FeedingQuantityBasis basis,  List<String> animalIds,  DateTime createdAt,  DateTime updatedAt,  String? lotId,  DateTime? endDate,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedingRecord() when $default != null:
return $default(_that.id,_that.establishmentId,_that.type,_that.foodId,_that.startDate,_that.quantity,_that.unitCode,_that.basis,_that.animalIds,_that.createdAt,_that.updatedAt,_that.lotId,_that.endDate,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  FeedingType type,  String foodId,  DateTime startDate,  String quantity,  String unitCode,  FeedingQuantityBasis basis,  List<String> animalIds,  DateTime createdAt,  DateTime updatedAt,  String? lotId,  DateTime? endDate,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _FeedingRecord():
return $default(_that.id,_that.establishmentId,_that.type,_that.foodId,_that.startDate,_that.quantity,_that.unitCode,_that.basis,_that.animalIds,_that.createdAt,_that.updatedAt,_that.lotId,_that.endDate,_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  FeedingType type,  String foodId,  DateTime startDate,  String quantity,  String unitCode,  FeedingQuantityBasis basis,  List<String> animalIds,  DateTime createdAt,  DateTime updatedAt,  String? lotId,  DateTime? endDate,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _FeedingRecord() when $default != null:
return $default(_that.id,_that.establishmentId,_that.type,_that.foodId,_that.startDate,_that.quantity,_that.unitCode,_that.basis,_that.animalIds,_that.createdAt,_that.updatedAt,_that.lotId,_that.endDate,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _FeedingRecord implements FeedingRecord {
  const _FeedingRecord({required this.id, required this.establishmentId, required this.type, required this.foodId, required this.startDate, required this.quantity, required this.unitCode, required this.basis, required final  List<String> animalIds, required this.createdAt, required this.updatedAt, this.lotId, this.endDate, this.reason}): _animalIds = animalIds;
  

@override final  String id;
@override final  String establishmentId;
@override final  FeedingType type;
@override final  String foodId;
@override final  DateTime startDate;
@override final  String quantity;
@override final  String unitCode;
@override final  FeedingQuantityBasis basis;
 final  List<String> _animalIds;
@override List<String> get animalIds {
  if (_animalIds is EqualUnmodifiableListView) return _animalIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animalIds);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? lotId;
@override final  DateTime? endDate;
@override final  String? reason;

/// Create a copy of FeedingRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedingRecordCopyWith<_FeedingRecord> get copyWith => __$FeedingRecordCopyWithImpl<_FeedingRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedingRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.type, type) || other.type == type)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.basis, basis) || other.basis == basis)&&const DeepCollectionEquality().equals(other._animalIds, _animalIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,type,foodId,startDate,quantity,unitCode,basis,const DeepCollectionEquality().hash(_animalIds),createdAt,updatedAt,lotId,endDate,reason);

@override
String toString() {
  return 'FeedingRecord(id: $id, establishmentId: $establishmentId, type: $type, foodId: $foodId, startDate: $startDate, quantity: $quantity, unitCode: $unitCode, basis: $basis, animalIds: $animalIds, createdAt: $createdAt, updatedAt: $updatedAt, lotId: $lotId, endDate: $endDate, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$FeedingRecordCopyWith<$Res> implements $FeedingRecordCopyWith<$Res> {
  factory _$FeedingRecordCopyWith(_FeedingRecord value, $Res Function(_FeedingRecord) _then) = __$FeedingRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, FeedingType type, String foodId, DateTime startDate, String quantity, String unitCode, FeedingQuantityBasis basis, List<String> animalIds, DateTime createdAt, DateTime updatedAt, String? lotId, DateTime? endDate, String? reason
});




}
/// @nodoc
class __$FeedingRecordCopyWithImpl<$Res>
    implements _$FeedingRecordCopyWith<$Res> {
  __$FeedingRecordCopyWithImpl(this._self, this._then);

  final _FeedingRecord _self;
  final $Res Function(_FeedingRecord) _then;

/// Create a copy of FeedingRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? type = null,Object? foodId = null,Object? startDate = null,Object? quantity = null,Object? unitCode = null,Object? basis = null,Object? animalIds = null,Object? createdAt = null,Object? updatedAt = null,Object? lotId = freezed,Object? endDate = freezed,Object? reason = freezed,}) {
  return _then(_FeedingRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedingType,foodId: null == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,unitCode: null == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as FeedingQuantityBasis,animalIds: null == animalIds ? _self._animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$FeedingTimelineEntry {

 String? get lotName; DateTime get from; DateTime? get to;
/// Create a copy of FeedingTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedingTimelineEntryCopyWith<FeedingTimelineEntry> get copyWith => _$FeedingTimelineEntryCopyWithImpl<FeedingTimelineEntry>(this as FeedingTimelineEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedingTimelineEntry&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,lotName,from,to);

@override
String toString() {
  return 'FeedingTimelineEntry(lotName: $lotName, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $FeedingTimelineEntryCopyWith<$Res>  {
  factory $FeedingTimelineEntryCopyWith(FeedingTimelineEntry value, $Res Function(FeedingTimelineEntry) _then) = _$FeedingTimelineEntryCopyWithImpl;
@useResult
$Res call({
 String lotName, DateTime from, DateTime? to
});




}
/// @nodoc
class _$FeedingTimelineEntryCopyWithImpl<$Res>
    implements $FeedingTimelineEntryCopyWith<$Res> {
  _$FeedingTimelineEntryCopyWithImpl(this._self, this._then);

  final FeedingTimelineEntry _self;
  final $Res Function(FeedingTimelineEntry) _then;

/// Create a copy of FeedingTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lotName = null,Object? from = null,Object? to = freezed,}) {
  return _then(_self.copyWith(
lotName: null == lotName ? _self.lotName! : lotName // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedingTimelineEntry].
extension FeedingTimelineEntryPatterns on FeedingTimelineEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GrazingEntry value)?  grazing,TResult Function( SupplementEntry value)?  supplement,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GrazingEntry() when grazing != null:
return grazing(_that);case SupplementEntry() when supplement != null:
return supplement(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GrazingEntry value)  grazing,required TResult Function( SupplementEntry value)  supplement,}){
final _that = this;
switch (_that) {
case GrazingEntry():
return grazing(_that);case SupplementEntry():
return supplement(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GrazingEntry value)?  grazing,TResult? Function( SupplementEntry value)?  supplement,}){
final _that = this;
switch (_that) {
case GrazingEntry() when grazing != null:
return grazing(_that);case SupplementEntry() when supplement != null:
return supplement(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String lotId,  String lotName,  DateTime from,  String? resourceCode,  String? resourceDescription,  DateTime? to,  GrazingEstimateReason? estimateReason,  bool pending)?  grazing,TResult Function( String recordId,  FeedingType type,  String foodName,  String quantity,  String unitCode,  FeedingQuantityBasis basis,  DateTime from,  FeedingSyncStatus syncStatus,  DateTime? to,  String? lotName,  String? reason,  String? syncErrorCode)?  supplement,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GrazingEntry() when grazing != null:
return grazing(_that.lotId,_that.lotName,_that.from,_that.resourceCode,_that.resourceDescription,_that.to,_that.estimateReason,_that.pending);case SupplementEntry() when supplement != null:
return supplement(_that.recordId,_that.type,_that.foodName,_that.quantity,_that.unitCode,_that.basis,_that.from,_that.syncStatus,_that.to,_that.lotName,_that.reason,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String lotId,  String lotName,  DateTime from,  String? resourceCode,  String? resourceDescription,  DateTime? to,  GrazingEstimateReason? estimateReason,  bool pending)  grazing,required TResult Function( String recordId,  FeedingType type,  String foodName,  String quantity,  String unitCode,  FeedingQuantityBasis basis,  DateTime from,  FeedingSyncStatus syncStatus,  DateTime? to,  String? lotName,  String? reason,  String? syncErrorCode)  supplement,}) {final _that = this;
switch (_that) {
case GrazingEntry():
return grazing(_that.lotId,_that.lotName,_that.from,_that.resourceCode,_that.resourceDescription,_that.to,_that.estimateReason,_that.pending);case SupplementEntry():
return supplement(_that.recordId,_that.type,_that.foodName,_that.quantity,_that.unitCode,_that.basis,_that.from,_that.syncStatus,_that.to,_that.lotName,_that.reason,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String lotId,  String lotName,  DateTime from,  String? resourceCode,  String? resourceDescription,  DateTime? to,  GrazingEstimateReason? estimateReason,  bool pending)?  grazing,TResult? Function( String recordId,  FeedingType type,  String foodName,  String quantity,  String unitCode,  FeedingQuantityBasis basis,  DateTime from,  FeedingSyncStatus syncStatus,  DateTime? to,  String? lotName,  String? reason,  String? syncErrorCode)?  supplement,}) {final _that = this;
switch (_that) {
case GrazingEntry() when grazing != null:
return grazing(_that.lotId,_that.lotName,_that.from,_that.resourceCode,_that.resourceDescription,_that.to,_that.estimateReason,_that.pending);case SupplementEntry() when supplement != null:
return supplement(_that.recordId,_that.type,_that.foodName,_that.quantity,_that.unitCode,_that.basis,_that.from,_that.syncStatus,_that.to,_that.lotName,_that.reason,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class GrazingEntry extends FeedingTimelineEntry {
  const GrazingEntry({required this.lotId, required this.lotName, required this.from, this.resourceCode, this.resourceDescription, this.to, this.estimateReason, this.pending = false}): super._();
  

 final  String lotId;
@override final  String lotName;
@override final  DateTime from;
 final  String? resourceCode;
 final  String? resourceDescription;
@override final  DateTime? to;
 final  GrazingEstimateReason? estimateReason;
@JsonKey() final  bool pending;

/// Create a copy of FeedingTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrazingEntryCopyWith<GrazingEntry> get copyWith => _$GrazingEntryCopyWithImpl<GrazingEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrazingEntry&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.from, from) || other.from == from)&&(identical(other.resourceCode, resourceCode) || other.resourceCode == resourceCode)&&(identical(other.resourceDescription, resourceDescription) || other.resourceDescription == resourceDescription)&&(identical(other.to, to) || other.to == to)&&(identical(other.estimateReason, estimateReason) || other.estimateReason == estimateReason)&&(identical(other.pending, pending) || other.pending == pending));
}


@override
int get hashCode => Object.hash(runtimeType,lotId,lotName,from,resourceCode,resourceDescription,to,estimateReason,pending);

@override
String toString() {
  return 'FeedingTimelineEntry.grazing(lotId: $lotId, lotName: $lotName, from: $from, resourceCode: $resourceCode, resourceDescription: $resourceDescription, to: $to, estimateReason: $estimateReason, pending: $pending)';
}


}

/// @nodoc
abstract mixin class $GrazingEntryCopyWith<$Res> implements $FeedingTimelineEntryCopyWith<$Res> {
  factory $GrazingEntryCopyWith(GrazingEntry value, $Res Function(GrazingEntry) _then) = _$GrazingEntryCopyWithImpl;
@override @useResult
$Res call({
 String lotId, String lotName, DateTime from, String? resourceCode, String? resourceDescription, DateTime? to, GrazingEstimateReason? estimateReason, bool pending
});




}
/// @nodoc
class _$GrazingEntryCopyWithImpl<$Res>
    implements $GrazingEntryCopyWith<$Res> {
  _$GrazingEntryCopyWithImpl(this._self, this._then);

  final GrazingEntry _self;
  final $Res Function(GrazingEntry) _then;

/// Create a copy of FeedingTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lotId = null,Object? lotName = null,Object? from = null,Object? resourceCode = freezed,Object? resourceDescription = freezed,Object? to = freezed,Object? estimateReason = freezed,Object? pending = null,}) {
  return _then(GrazingEntry(
lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,resourceCode: freezed == resourceCode ? _self.resourceCode : resourceCode // ignore: cast_nullable_to_non_nullable
as String?,resourceDescription: freezed == resourceDescription ? _self.resourceDescription : resourceDescription // ignore: cast_nullable_to_non_nullable
as String?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,estimateReason: freezed == estimateReason ? _self.estimateReason : estimateReason // ignore: cast_nullable_to_non_nullable
as GrazingEstimateReason?,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SupplementEntry extends FeedingTimelineEntry {
  const SupplementEntry({required this.recordId, required this.type, required this.foodName, required this.quantity, required this.unitCode, required this.basis, required this.from, required this.syncStatus, this.to, this.lotName, this.reason, this.syncErrorCode}): super._();
  

 final  String recordId;
 final  FeedingType type;
 final  String foodName;
 final  String quantity;
 final  String unitCode;
 final  FeedingQuantityBasis basis;
@override final  DateTime from;
 final  FeedingSyncStatus syncStatus;
@override final  DateTime? to;
@override final  String? lotName;
 final  String? reason;
 final  String? syncErrorCode;

/// Create a copy of FeedingTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplementEntryCopyWith<SupplementEntry> get copyWith => _$SupplementEntryCopyWithImpl<SupplementEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplementEntry&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.type, type) || other.type == type)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitCode, unitCode) || other.unitCode == unitCode)&&(identical(other.basis, basis) || other.basis == basis)&&(identical(other.from, from) || other.from == from)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.to, to) || other.to == to)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,recordId,type,foodName,quantity,unitCode,basis,from,syncStatus,to,lotName,reason,syncErrorCode);

@override
String toString() {
  return 'FeedingTimelineEntry.supplement(recordId: $recordId, type: $type, foodName: $foodName, quantity: $quantity, unitCode: $unitCode, basis: $basis, from: $from, syncStatus: $syncStatus, to: $to, lotName: $lotName, reason: $reason, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $SupplementEntryCopyWith<$Res> implements $FeedingTimelineEntryCopyWith<$Res> {
  factory $SupplementEntryCopyWith(SupplementEntry value, $Res Function(SupplementEntry) _then) = _$SupplementEntryCopyWithImpl;
@override @useResult
$Res call({
 String recordId, FeedingType type, String foodName, String quantity, String unitCode, FeedingQuantityBasis basis, DateTime from, FeedingSyncStatus syncStatus, DateTime? to, String? lotName, String? reason, String? syncErrorCode
});




}
/// @nodoc
class _$SupplementEntryCopyWithImpl<$Res>
    implements $SupplementEntryCopyWith<$Res> {
  _$SupplementEntryCopyWithImpl(this._self, this._then);

  final SupplementEntry _self;
  final $Res Function(SupplementEntry) _then;

/// Create a copy of FeedingTimelineEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recordId = null,Object? type = null,Object? foodName = null,Object? quantity = null,Object? unitCode = null,Object? basis = null,Object? from = null,Object? syncStatus = null,Object? to = freezed,Object? lotName = freezed,Object? reason = freezed,Object? syncErrorCode = freezed,}) {
  return _then(SupplementEntry(
recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedingType,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,unitCode: null == unitCode ? _self.unitCode : unitCode // ignore: cast_nullable_to_non_nullable
as String,basis: null == basis ? _self.basis : basis // ignore: cast_nullable_to_non_nullable
as FeedingQuantityBasis,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as FeedingSyncStatus,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,lotName: freezed == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AnimalFeedingHistory {

 List<FeedingTimelineEntry> get entries; GrazingEntry? get currentGrazing; List<SupplementEntry> get ongoingSupplements; String? get currentLotId; bool get currentLotHasForage;
/// Create a copy of AnimalFeedingHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalFeedingHistoryCopyWith<AnimalFeedingHistory> get copyWith => _$AnimalFeedingHistoryCopyWithImpl<AnimalFeedingHistory>(this as AnimalFeedingHistory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalFeedingHistory&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.currentGrazing, currentGrazing)&&const DeepCollectionEquality().equals(other.ongoingSupplements, ongoingSupplements)&&(identical(other.currentLotId, currentLotId) || other.currentLotId == currentLotId)&&(identical(other.currentLotHasForage, currentLotHasForage) || other.currentLotHasForage == currentLotHasForage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(currentGrazing),const DeepCollectionEquality().hash(ongoingSupplements),currentLotId,currentLotHasForage);

@override
String toString() {
  return 'AnimalFeedingHistory(entries: $entries, currentGrazing: $currentGrazing, ongoingSupplements: $ongoingSupplements, currentLotId: $currentLotId, currentLotHasForage: $currentLotHasForage)';
}


}

/// @nodoc
abstract mixin class $AnimalFeedingHistoryCopyWith<$Res>  {
  factory $AnimalFeedingHistoryCopyWith(AnimalFeedingHistory value, $Res Function(AnimalFeedingHistory) _then) = _$AnimalFeedingHistoryCopyWithImpl;
@useResult
$Res call({
 List<FeedingTimelineEntry> entries, GrazingEntry? currentGrazing, List<SupplementEntry> ongoingSupplements, String? currentLotId, bool currentLotHasForage
});




}
/// @nodoc
class _$AnimalFeedingHistoryCopyWithImpl<$Res>
    implements $AnimalFeedingHistoryCopyWith<$Res> {
  _$AnimalFeedingHistoryCopyWithImpl(this._self, this._then);

  final AnimalFeedingHistory _self;
  final $Res Function(AnimalFeedingHistory) _then;

/// Create a copy of AnimalFeedingHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? currentGrazing = freezed,Object? ongoingSupplements = null,Object? currentLotId = freezed,Object? currentLotHasForage = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<FeedingTimelineEntry>,currentGrazing: freezed == currentGrazing ? _self.currentGrazing : currentGrazing // ignore: cast_nullable_to_non_nullable
as GrazingEntry?,ongoingSupplements: null == ongoingSupplements ? _self.ongoingSupplements : ongoingSupplements // ignore: cast_nullable_to_non_nullable
as List<SupplementEntry>,currentLotId: freezed == currentLotId ? _self.currentLotId : currentLotId // ignore: cast_nullable_to_non_nullable
as String?,currentLotHasForage: null == currentLotHasForage ? _self.currentLotHasForage : currentLotHasForage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalFeedingHistory].
extension AnimalFeedingHistoryPatterns on AnimalFeedingHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalFeedingHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalFeedingHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalFeedingHistory value)  $default,){
final _that = this;
switch (_that) {
case _AnimalFeedingHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalFeedingHistory value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalFeedingHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FeedingTimelineEntry> entries,  GrazingEntry? currentGrazing,  List<SupplementEntry> ongoingSupplements,  String? currentLotId,  bool currentLotHasForage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalFeedingHistory() when $default != null:
return $default(_that.entries,_that.currentGrazing,_that.ongoingSupplements,_that.currentLotId,_that.currentLotHasForage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FeedingTimelineEntry> entries,  GrazingEntry? currentGrazing,  List<SupplementEntry> ongoingSupplements,  String? currentLotId,  bool currentLotHasForage)  $default,) {final _that = this;
switch (_that) {
case _AnimalFeedingHistory():
return $default(_that.entries,_that.currentGrazing,_that.ongoingSupplements,_that.currentLotId,_that.currentLotHasForage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FeedingTimelineEntry> entries,  GrazingEntry? currentGrazing,  List<SupplementEntry> ongoingSupplements,  String? currentLotId,  bool currentLotHasForage)?  $default,) {final _that = this;
switch (_that) {
case _AnimalFeedingHistory() when $default != null:
return $default(_that.entries,_that.currentGrazing,_that.ongoingSupplements,_that.currentLotId,_that.currentLotHasForage);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalFeedingHistory implements AnimalFeedingHistory {
  const _AnimalFeedingHistory({required final  List<FeedingTimelineEntry> entries, this.currentGrazing, final  List<SupplementEntry> ongoingSupplements = const <SupplementEntry>[], this.currentLotId, this.currentLotHasForage = false}): _entries = entries,_ongoingSupplements = ongoingSupplements;
  

 final  List<FeedingTimelineEntry> _entries;
@override List<FeedingTimelineEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  GrazingEntry? currentGrazing;
 final  List<SupplementEntry> _ongoingSupplements;
@override@JsonKey() List<SupplementEntry> get ongoingSupplements {
  if (_ongoingSupplements is EqualUnmodifiableListView) return _ongoingSupplements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ongoingSupplements);
}

@override final  String? currentLotId;
@override@JsonKey() final  bool currentLotHasForage;

/// Create a copy of AnimalFeedingHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalFeedingHistoryCopyWith<_AnimalFeedingHistory> get copyWith => __$AnimalFeedingHistoryCopyWithImpl<_AnimalFeedingHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalFeedingHistory&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other.currentGrazing, currentGrazing)&&const DeepCollectionEquality().equals(other._ongoingSupplements, _ongoingSupplements)&&(identical(other.currentLotId, currentLotId) || other.currentLotId == currentLotId)&&(identical(other.currentLotHasForage, currentLotHasForage) || other.currentLotHasForage == currentLotHasForage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(currentGrazing),const DeepCollectionEquality().hash(_ongoingSupplements),currentLotId,currentLotHasForage);

@override
String toString() {
  return 'AnimalFeedingHistory(entries: $entries, currentGrazing: $currentGrazing, ongoingSupplements: $ongoingSupplements, currentLotId: $currentLotId, currentLotHasForage: $currentLotHasForage)';
}


}

/// @nodoc
abstract mixin class _$AnimalFeedingHistoryCopyWith<$Res> implements $AnimalFeedingHistoryCopyWith<$Res> {
  factory _$AnimalFeedingHistoryCopyWith(_AnimalFeedingHistory value, $Res Function(_AnimalFeedingHistory) _then) = __$AnimalFeedingHistoryCopyWithImpl;
@override @useResult
$Res call({
 List<FeedingTimelineEntry> entries, GrazingEntry? currentGrazing, List<SupplementEntry> ongoingSupplements, String? currentLotId, bool currentLotHasForage
});




}
/// @nodoc
class __$AnimalFeedingHistoryCopyWithImpl<$Res>
    implements _$AnimalFeedingHistoryCopyWith<$Res> {
  __$AnimalFeedingHistoryCopyWithImpl(this._self, this._then);

  final _AnimalFeedingHistory _self;
  final $Res Function(_AnimalFeedingHistory) _then;

/// Create a copy of AnimalFeedingHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? currentGrazing = freezed,Object? ongoingSupplements = null,Object? currentLotId = freezed,Object? currentLotHasForage = null,}) {
  return _then(_AnimalFeedingHistory(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<FeedingTimelineEntry>,currentGrazing: freezed == currentGrazing ? _self.currentGrazing : currentGrazing // ignore: cast_nullable_to_non_nullable
as GrazingEntry?,ongoingSupplements: null == ongoingSupplements ? _self._ongoingSupplements : ongoingSupplements // ignore: cast_nullable_to_non_nullable
as List<SupplementEntry>,currentLotId: freezed == currentLotId ? _self.currentLotId : currentLotId // ignore: cast_nullable_to_non_nullable
as String?,currentLotHasForage: null == currentLotHasForage ? _self.currentLotHasForage : currentLotHasForage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
