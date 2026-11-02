// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movement_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MovementAnimal {

 String get id; String get establishmentId; String get visualTag; String get rfidTagNumber; String get breed; String get categoryName; String get lotId; String get lotName;
/// Create a copy of MovementAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementAnimalCopyWith<MovementAnimal> get copyWith => _$MovementAnimalCopyWithImpl<MovementAnimal>(this as MovementAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,visualTag,rfidTagNumber,breed,categoryName,lotId,lotName);

@override
String toString() {
  return 'MovementAnimal(id: $id, establishmentId: $establishmentId, visualTag: $visualTag, rfidTagNumber: $rfidTagNumber, breed: $breed, categoryName: $categoryName, lotId: $lotId, lotName: $lotName)';
}


}

/// @nodoc
abstract mixin class $MovementAnimalCopyWith<$Res>  {
  factory $MovementAnimalCopyWith(MovementAnimal value, $Res Function(MovementAnimal) _then) = _$MovementAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String visualTag, String rfidTagNumber, String breed, String categoryName, String lotId, String lotName
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String visualTag,  String rfidTagNumber,  String breed,  String categoryName,  String lotId,  String lotName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementAnimal() when $default != null:
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
case _MovementAnimal():
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
case _MovementAnimal() when $default != null:
return $default(_that.id,_that.establishmentId,_that.visualTag,_that.rfidTagNumber,_that.breed,_that.categoryName,_that.lotId,_that.lotName);case _:
  return null;

}
}

}

/// @nodoc


class _MovementAnimal implements MovementAnimal {
  const _MovementAnimal({required this.id, required this.establishmentId, required this.visualTag, required this.rfidTagNumber, required this.breed, required this.categoryName, required this.lotId, required this.lotName});
  

@override final  String id;
@override final  String establishmentId;
@override final  String visualTag;
@override final  String rfidTagNumber;
@override final  String breed;
@override final  String categoryName;
@override final  String lotId;
@override final  String lotName;

/// Create a copy of MovementAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementAnimalCopyWith<_MovementAnimal> get copyWith => __$MovementAnimalCopyWithImpl<_MovementAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,visualTag,rfidTagNumber,breed,categoryName,lotId,lotName);

@override
String toString() {
  return 'MovementAnimal(id: $id, establishmentId: $establishmentId, visualTag: $visualTag, rfidTagNumber: $rfidTagNumber, breed: $breed, categoryName: $categoryName, lotId: $lotId, lotName: $lotName)';
}


}

/// @nodoc
abstract mixin class _$MovementAnimalCopyWith<$Res> implements $MovementAnimalCopyWith<$Res> {
  factory _$MovementAnimalCopyWith(_MovementAnimal value, $Res Function(_MovementAnimal) _then) = __$MovementAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String visualTag, String rfidTagNumber, String breed, String categoryName, String lotId, String lotName
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? visualTag = null,Object? rfidTagNumber = null,Object? breed = null,Object? categoryName = null,Object? lotId = null,Object? lotName = null,}) {
  return _then(_MovementAnimal(
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
mixin _$MovementDestination {

 String get id; String get name; int get animalCount;
/// Create a copy of MovementDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementDestinationCopyWith<MovementDestination> get copyWith => _$MovementDestinationCopyWithImpl<MovementDestination>(this as MovementDestination, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementDestination&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,animalCount);

@override
String toString() {
  return 'MovementDestination(id: $id, name: $name, animalCount: $animalCount)';
}


}

/// @nodoc
abstract mixin class $MovementDestinationCopyWith<$Res>  {
  factory $MovementDestinationCopyWith(MovementDestination value, $Res Function(MovementDestination) _then) = _$MovementDestinationCopyWithImpl;
@useResult
$Res call({
 String id, String name, int animalCount
});




}
/// @nodoc
class _$MovementDestinationCopyWithImpl<$Res>
    implements $MovementDestinationCopyWith<$Res> {
  _$MovementDestinationCopyWithImpl(this._self, this._then);

  final MovementDestination _self;
  final $Res Function(MovementDestination) _then;

/// Create a copy of MovementDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? animalCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementDestination].
extension MovementDestinationPatterns on MovementDestination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementDestination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementDestination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementDestination value)  $default,){
final _that = this;
switch (_that) {
case _MovementDestination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementDestination value)?  $default,){
final _that = this;
switch (_that) {
case _MovementDestination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int animalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementDestination() when $default != null:
return $default(_that.id,_that.name,_that.animalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int animalCount)  $default,) {final _that = this;
switch (_that) {
case _MovementDestination():
return $default(_that.id,_that.name,_that.animalCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int animalCount)?  $default,) {final _that = this;
switch (_that) {
case _MovementDestination() when $default != null:
return $default(_that.id,_that.name,_that.animalCount);case _:
  return null;

}
}

}

/// @nodoc


class _MovementDestination implements MovementDestination {
  const _MovementDestination({required this.id, required this.name, required this.animalCount});
  

@override final  String id;
@override final  String name;
@override final  int animalCount;

/// Create a copy of MovementDestination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementDestinationCopyWith<_MovementDestination> get copyWith => __$MovementDestinationCopyWithImpl<_MovementDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementDestination&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,animalCount);

@override
String toString() {
  return 'MovementDestination(id: $id, name: $name, animalCount: $animalCount)';
}


}

/// @nodoc
abstract mixin class _$MovementDestinationCopyWith<$Res> implements $MovementDestinationCopyWith<$Res> {
  factory _$MovementDestinationCopyWith(_MovementDestination value, $Res Function(_MovementDestination) _then) = __$MovementDestinationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int animalCount
});




}
/// @nodoc
class __$MovementDestinationCopyWithImpl<$Res>
    implements _$MovementDestinationCopyWith<$Res> {
  __$MovementDestinationCopyWithImpl(this._self, this._then);

  final _MovementDestination _self;
  final $Res Function(_MovementDestination) _then;

/// Create a copy of MovementDestination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? animalCount = null,}) {
  return _then(_MovementDestination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GroupMovementPreparation {

 MovementAnimal get animal; List<MovementDestination> get destinations;
/// Create a copy of GroupMovementPreparation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMovementPreparationCopyWith<GroupMovementPreparation> get copyWith => _$GroupMovementPreparationCopyWithImpl<GroupMovementPreparation>(this as GroupMovementPreparation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMovementPreparation&&(identical(other.animal, animal) || other.animal == animal)&&const DeepCollectionEquality().equals(other.destinations, destinations));
}


@override
int get hashCode => Object.hash(runtimeType,animal,const DeepCollectionEquality().hash(destinations));

@override
String toString() {
  return 'GroupMovementPreparation(animal: $animal, destinations: $destinations)';
}


}

/// @nodoc
abstract mixin class $GroupMovementPreparationCopyWith<$Res>  {
  factory $GroupMovementPreparationCopyWith(GroupMovementPreparation value, $Res Function(GroupMovementPreparation) _then) = _$GroupMovementPreparationCopyWithImpl;
@useResult
$Res call({
 MovementAnimal animal, List<MovementDestination> destinations
});


$MovementAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class _$GroupMovementPreparationCopyWithImpl<$Res>
    implements $GroupMovementPreparationCopyWith<$Res> {
  _$GroupMovementPreparationCopyWithImpl(this._self, this._then);

  final GroupMovementPreparation _self;
  final $Res Function(GroupMovementPreparation) _then;

/// Create a copy of GroupMovementPreparation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animal = null,Object? destinations = null,}) {
  return _then(_self.copyWith(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as MovementAnimal,destinations: null == destinations ? _self.destinations : destinations // ignore: cast_nullable_to_non_nullable
as List<MovementDestination>,
  ));
}
/// Create a copy of GroupMovementPreparation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovementAnimalCopyWith<$Res> get animal {
  
  return $MovementAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupMovementPreparation].
extension GroupMovementPreparationPatterns on GroupMovementPreparation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMovementPreparation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMovementPreparation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMovementPreparation value)  $default,){
final _that = this;
switch (_that) {
case _GroupMovementPreparation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMovementPreparation value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMovementPreparation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MovementAnimal animal,  List<MovementDestination> destinations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMovementPreparation() when $default != null:
return $default(_that.animal,_that.destinations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MovementAnimal animal,  List<MovementDestination> destinations)  $default,) {final _that = this;
switch (_that) {
case _GroupMovementPreparation():
return $default(_that.animal,_that.destinations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MovementAnimal animal,  List<MovementDestination> destinations)?  $default,) {final _that = this;
switch (_that) {
case _GroupMovementPreparation() when $default != null:
return $default(_that.animal,_that.destinations);case _:
  return null;

}
}

}

/// @nodoc


class _GroupMovementPreparation implements GroupMovementPreparation {
  const _GroupMovementPreparation({required this.animal, required final  List<MovementDestination> destinations}): _destinations = destinations;
  

@override final  MovementAnimal animal;
 final  List<MovementDestination> _destinations;
@override List<MovementDestination> get destinations {
  if (_destinations is EqualUnmodifiableListView) return _destinations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_destinations);
}


/// Create a copy of GroupMovementPreparation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMovementPreparationCopyWith<_GroupMovementPreparation> get copyWith => __$GroupMovementPreparationCopyWithImpl<_GroupMovementPreparation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMovementPreparation&&(identical(other.animal, animal) || other.animal == animal)&&const DeepCollectionEquality().equals(other._destinations, _destinations));
}


@override
int get hashCode => Object.hash(runtimeType,animal,const DeepCollectionEquality().hash(_destinations));

@override
String toString() {
  return 'GroupMovementPreparation(animal: $animal, destinations: $destinations)';
}


}

/// @nodoc
abstract mixin class _$GroupMovementPreparationCopyWith<$Res> implements $GroupMovementPreparationCopyWith<$Res> {
  factory _$GroupMovementPreparationCopyWith(_GroupMovementPreparation value, $Res Function(_GroupMovementPreparation) _then) = __$GroupMovementPreparationCopyWithImpl;
@override @useResult
$Res call({
 MovementAnimal animal, List<MovementDestination> destinations
});


@override $MovementAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class __$GroupMovementPreparationCopyWithImpl<$Res>
    implements _$GroupMovementPreparationCopyWith<$Res> {
  __$GroupMovementPreparationCopyWithImpl(this._self, this._then);

  final _GroupMovementPreparation _self;
  final $Res Function(_GroupMovementPreparation) _then;

/// Create a copy of GroupMovementPreparation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animal = null,Object? destinations = null,}) {
  return _then(_GroupMovementPreparation(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as MovementAnimal,destinations: null == destinations ? _self._destinations : destinations // ignore: cast_nullable_to_non_nullable
as List<MovementDestination>,
  ));
}

/// Create a copy of GroupMovementPreparation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovementAnimalCopyWith<$Res> get animal {
  
  return $MovementAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}

/// @nodoc
mixin _$MovementHistoryEntry {

 String get movementId; String? get fromLotName; String get toLotName; DateTime get occurredAt; String get reason; bool get isPending;
/// Create a copy of MovementHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementHistoryEntryCopyWith<MovementHistoryEntry> get copyWith => _$MovementHistoryEntryCopyWithImpl<MovementHistoryEntry>(this as MovementHistoryEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementHistoryEntry&&(identical(other.movementId, movementId) || other.movementId == movementId)&&(identical(other.fromLotName, fromLotName) || other.fromLotName == fromLotName)&&(identical(other.toLotName, toLotName) || other.toLotName == toLotName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.isPending, isPending) || other.isPending == isPending));
}


@override
int get hashCode => Object.hash(runtimeType,movementId,fromLotName,toLotName,occurredAt,reason,isPending);

@override
String toString() {
  return 'MovementHistoryEntry(movementId: $movementId, fromLotName: $fromLotName, toLotName: $toLotName, occurredAt: $occurredAt, reason: $reason, isPending: $isPending)';
}


}

/// @nodoc
abstract mixin class $MovementHistoryEntryCopyWith<$Res>  {
  factory $MovementHistoryEntryCopyWith(MovementHistoryEntry value, $Res Function(MovementHistoryEntry) _then) = _$MovementHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String movementId, String? fromLotName, String toLotName, DateTime occurredAt, String reason, bool isPending
});




}
/// @nodoc
class _$MovementHistoryEntryCopyWithImpl<$Res>
    implements $MovementHistoryEntryCopyWith<$Res> {
  _$MovementHistoryEntryCopyWithImpl(this._self, this._then);

  final MovementHistoryEntry _self;
  final $Res Function(MovementHistoryEntry) _then;

/// Create a copy of MovementHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movementId = null,Object? fromLotName = freezed,Object? toLotName = null,Object? occurredAt = null,Object? reason = null,Object? isPending = null,}) {
  return _then(_self.copyWith(
movementId: null == movementId ? _self.movementId : movementId // ignore: cast_nullable_to_non_nullable
as String,fromLotName: freezed == fromLotName ? _self.fromLotName : fromLotName // ignore: cast_nullable_to_non_nullable
as String?,toLotName: null == toLotName ? _self.toLotName : toLotName // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementHistoryEntry].
extension MovementHistoryEntryPatterns on MovementHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _MovementHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MovementHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String movementId,  String? fromLotName,  String toLotName,  DateTime occurredAt,  String reason,  bool isPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementHistoryEntry() when $default != null:
return $default(_that.movementId,_that.fromLotName,_that.toLotName,_that.occurredAt,_that.reason,_that.isPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String movementId,  String? fromLotName,  String toLotName,  DateTime occurredAt,  String reason,  bool isPending)  $default,) {final _that = this;
switch (_that) {
case _MovementHistoryEntry():
return $default(_that.movementId,_that.fromLotName,_that.toLotName,_that.occurredAt,_that.reason,_that.isPending);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String movementId,  String? fromLotName,  String toLotName,  DateTime occurredAt,  String reason,  bool isPending)?  $default,) {final _that = this;
switch (_that) {
case _MovementHistoryEntry() when $default != null:
return $default(_that.movementId,_that.fromLotName,_that.toLotName,_that.occurredAt,_that.reason,_that.isPending);case _:
  return null;

}
}

}

/// @nodoc


class _MovementHistoryEntry implements MovementHistoryEntry {
  const _MovementHistoryEntry({required this.movementId, required this.fromLotName, required this.toLotName, required this.occurredAt, required this.reason, required this.isPending});
  

@override final  String movementId;
@override final  String? fromLotName;
@override final  String toLotName;
@override final  DateTime occurredAt;
@override final  String reason;
@override final  bool isPending;

/// Create a copy of MovementHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementHistoryEntryCopyWith<_MovementHistoryEntry> get copyWith => __$MovementHistoryEntryCopyWithImpl<_MovementHistoryEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementHistoryEntry&&(identical(other.movementId, movementId) || other.movementId == movementId)&&(identical(other.fromLotName, fromLotName) || other.fromLotName == fromLotName)&&(identical(other.toLotName, toLotName) || other.toLotName == toLotName)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.isPending, isPending) || other.isPending == isPending));
}


@override
int get hashCode => Object.hash(runtimeType,movementId,fromLotName,toLotName,occurredAt,reason,isPending);

@override
String toString() {
  return 'MovementHistoryEntry(movementId: $movementId, fromLotName: $fromLotName, toLotName: $toLotName, occurredAt: $occurredAt, reason: $reason, isPending: $isPending)';
}


}

/// @nodoc
abstract mixin class _$MovementHistoryEntryCopyWith<$Res> implements $MovementHistoryEntryCopyWith<$Res> {
  factory _$MovementHistoryEntryCopyWith(_MovementHistoryEntry value, $Res Function(_MovementHistoryEntry) _then) = __$MovementHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String movementId, String? fromLotName, String toLotName, DateTime occurredAt, String reason, bool isPending
});




}
/// @nodoc
class __$MovementHistoryEntryCopyWithImpl<$Res>
    implements _$MovementHistoryEntryCopyWith<$Res> {
  __$MovementHistoryEntryCopyWithImpl(this._self, this._then);

  final _MovementHistoryEntry _self;
  final $Res Function(_MovementHistoryEntry) _then;

/// Create a copy of MovementHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movementId = null,Object? fromLotName = freezed,Object? toLotName = null,Object? occurredAt = null,Object? reason = null,Object? isPending = null,}) {
  return _then(_MovementHistoryEntry(
movementId: null == movementId ? _self.movementId : movementId // ignore: cast_nullable_to_non_nullable
as String,fromLotName: freezed == fromLotName ? _self.fromLotName : fromLotName // ignore: cast_nullable_to_non_nullable
as String?,toLotName: null == toLotName ? _self.toLotName : toLotName // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$GroupMovementSummary {

 int get movedCount; int get alreadyThereCount;
/// Create a copy of GroupMovementSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMovementSummaryCopyWith<GroupMovementSummary> get copyWith => _$GroupMovementSummaryCopyWithImpl<GroupMovementSummary>(this as GroupMovementSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMovementSummary&&(identical(other.movedCount, movedCount) || other.movedCount == movedCount)&&(identical(other.alreadyThereCount, alreadyThereCount) || other.alreadyThereCount == alreadyThereCount));
}


@override
int get hashCode => Object.hash(runtimeType,movedCount,alreadyThereCount);

@override
String toString() {
  return 'GroupMovementSummary(movedCount: $movedCount, alreadyThereCount: $alreadyThereCount)';
}


}

/// @nodoc
abstract mixin class $GroupMovementSummaryCopyWith<$Res>  {
  factory $GroupMovementSummaryCopyWith(GroupMovementSummary value, $Res Function(GroupMovementSummary) _then) = _$GroupMovementSummaryCopyWithImpl;
@useResult
$Res call({
 int movedCount, int alreadyThereCount
});




}
/// @nodoc
class _$GroupMovementSummaryCopyWithImpl<$Res>
    implements $GroupMovementSummaryCopyWith<$Res> {
  _$GroupMovementSummaryCopyWithImpl(this._self, this._then);

  final GroupMovementSummary _self;
  final $Res Function(GroupMovementSummary) _then;

/// Create a copy of GroupMovementSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movedCount = null,Object? alreadyThereCount = null,}) {
  return _then(_self.copyWith(
movedCount: null == movedCount ? _self.movedCount : movedCount // ignore: cast_nullable_to_non_nullable
as int,alreadyThereCount: null == alreadyThereCount ? _self.alreadyThereCount : alreadyThereCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupMovementSummary].
extension GroupMovementSummaryPatterns on GroupMovementSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMovementSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMovementSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMovementSummary value)  $default,){
final _that = this;
switch (_that) {
case _GroupMovementSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMovementSummary value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMovementSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int movedCount,  int alreadyThereCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMovementSummary() when $default != null:
return $default(_that.movedCount,_that.alreadyThereCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int movedCount,  int alreadyThereCount)  $default,) {final _that = this;
switch (_that) {
case _GroupMovementSummary():
return $default(_that.movedCount,_that.alreadyThereCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int movedCount,  int alreadyThereCount)?  $default,) {final _that = this;
switch (_that) {
case _GroupMovementSummary() when $default != null:
return $default(_that.movedCount,_that.alreadyThereCount);case _:
  return null;

}
}

}

/// @nodoc


class _GroupMovementSummary implements GroupMovementSummary {
  const _GroupMovementSummary({required this.movedCount, required this.alreadyThereCount});
  

@override final  int movedCount;
@override final  int alreadyThereCount;

/// Create a copy of GroupMovementSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMovementSummaryCopyWith<_GroupMovementSummary> get copyWith => __$GroupMovementSummaryCopyWithImpl<_GroupMovementSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMovementSummary&&(identical(other.movedCount, movedCount) || other.movedCount == movedCount)&&(identical(other.alreadyThereCount, alreadyThereCount) || other.alreadyThereCount == alreadyThereCount));
}


@override
int get hashCode => Object.hash(runtimeType,movedCount,alreadyThereCount);

@override
String toString() {
  return 'GroupMovementSummary(movedCount: $movedCount, alreadyThereCount: $alreadyThereCount)';
}


}

/// @nodoc
abstract mixin class _$GroupMovementSummaryCopyWith<$Res> implements $GroupMovementSummaryCopyWith<$Res> {
  factory _$GroupMovementSummaryCopyWith(_GroupMovementSummary value, $Res Function(_GroupMovementSummary) _then) = __$GroupMovementSummaryCopyWithImpl;
@override @useResult
$Res call({
 int movedCount, int alreadyThereCount
});




}
/// @nodoc
class __$GroupMovementSummaryCopyWithImpl<$Res>
    implements _$GroupMovementSummaryCopyWith<$Res> {
  __$GroupMovementSummaryCopyWithImpl(this._self, this._then);

  final _GroupMovementSummary _self;
  final $Res Function(_GroupMovementSummary) _then;

/// Create a copy of GroupMovementSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movedCount = null,Object? alreadyThereCount = null,}) {
  return _then(_GroupMovementSummary(
movedCount: null == movedCount ? _self.movedCount : movedCount // ignore: cast_nullable_to_non_nullable
as int,alreadyThereCount: null == alreadyThereCount ? _self.alreadyThereCount : alreadyThereCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
