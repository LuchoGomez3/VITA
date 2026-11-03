// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_genealogy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenealogyAnimal {

/// UUID utilizado para abrir su ficha.
 String get id;/// Caravana visual.
 String get visualTag;/// Raza declarada.
 String get breed;/// Categoría actual; vacía si no se pudo resolver.
 String get categoryName;
/// Create a copy of GenealogyAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<GenealogyAnimal> get copyWith => _$GenealogyAnimalCopyWithImpl<GenealogyAnimal>(this as GenealogyAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenealogyAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}


@override
int get hashCode => Object.hash(runtimeType,id,visualTag,breed,categoryName);

@override
String toString() {
  return 'GenealogyAnimal(id: $id, visualTag: $visualTag, breed: $breed, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class $GenealogyAnimalCopyWith<$Res>  {
  factory $GenealogyAnimalCopyWith(GenealogyAnimal value, $Res Function(GenealogyAnimal) _then) = _$GenealogyAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String visualTag, String breed, String categoryName
});




}
/// @nodoc
class _$GenealogyAnimalCopyWithImpl<$Res>
    implements $GenealogyAnimalCopyWith<$Res> {
  _$GenealogyAnimalCopyWithImpl(this._self, this._then);

  final GenealogyAnimal _self;
  final $Res Function(GenealogyAnimal) _then;

/// Create a copy of GenealogyAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? visualTag = null,Object? breed = null,Object? categoryName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GenealogyAnimal].
extension GenealogyAnimalPatterns on GenealogyAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenealogyAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenealogyAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenealogyAnimal value)  $default,){
final _that = this;
switch (_that) {
case _GenealogyAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenealogyAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _GenealogyAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String visualTag,  String breed,  String categoryName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenealogyAnimal() when $default != null:
return $default(_that.id,_that.visualTag,_that.breed,_that.categoryName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String visualTag,  String breed,  String categoryName)  $default,) {final _that = this;
switch (_that) {
case _GenealogyAnimal():
return $default(_that.id,_that.visualTag,_that.breed,_that.categoryName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String visualTag,  String breed,  String categoryName)?  $default,) {final _that = this;
switch (_that) {
case _GenealogyAnimal() when $default != null:
return $default(_that.id,_that.visualTag,_that.breed,_that.categoryName);case _:
  return null;

}
}

}

/// @nodoc


class _GenealogyAnimal implements GenealogyAnimal {
  const _GenealogyAnimal({required this.id, required this.visualTag, required this.breed, required this.categoryName});
  

/// UUID utilizado para abrir su ficha.
@override final  String id;
/// Caravana visual.
@override final  String visualTag;
/// Raza declarada.
@override final  String breed;
/// Categoría actual; vacía si no se pudo resolver.
@override final  String categoryName;

/// Create a copy of GenealogyAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenealogyAnimalCopyWith<_GenealogyAnimal> get copyWith => __$GenealogyAnimalCopyWithImpl<_GenealogyAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenealogyAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}


@override
int get hashCode => Object.hash(runtimeType,id,visualTag,breed,categoryName);

@override
String toString() {
  return 'GenealogyAnimal(id: $id, visualTag: $visualTag, breed: $breed, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class _$GenealogyAnimalCopyWith<$Res> implements $GenealogyAnimalCopyWith<$Res> {
  factory _$GenealogyAnimalCopyWith(_GenealogyAnimal value, $Res Function(_GenealogyAnimal) _then) = __$GenealogyAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String visualTag, String breed, String categoryName
});




}
/// @nodoc
class __$GenealogyAnimalCopyWithImpl<$Res>
    implements _$GenealogyAnimalCopyWith<$Res> {
  __$GenealogyAnimalCopyWithImpl(this._self, this._then);

  final _GenealogyAnimal _self;
  final $Res Function(_GenealogyAnimal) _then;

/// Create a copy of GenealogyAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? visualTag = null,Object? breed = null,Object? categoryName = null,}) {
  return _then(_GenealogyAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GenealogyAnimalRecord {

/// Identidad del animal.
 GenealogyAnimal get animal;/// Fecha utilizada para ordenar las crías.
 DateTime get birthDate;/// UUID de la madre, si fue registrado.
 String? get motherId;/// UUID del padre, si fue registrado.
 String? get fatherId;
/// Create a copy of GenealogyAnimalRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenealogyAnimalRecordCopyWith<GenealogyAnimalRecord> get copyWith => _$GenealogyAnimalRecordCopyWithImpl<GenealogyAnimalRecord>(this as GenealogyAnimalRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenealogyAnimalRecord&&(identical(other.animal, animal) || other.animal == animal)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId));
}


@override
int get hashCode => Object.hash(runtimeType,animal,birthDate,motherId,fatherId);

@override
String toString() {
  return 'GenealogyAnimalRecord(animal: $animal, birthDate: $birthDate, motherId: $motherId, fatherId: $fatherId)';
}


}

/// @nodoc
abstract mixin class $GenealogyAnimalRecordCopyWith<$Res>  {
  factory $GenealogyAnimalRecordCopyWith(GenealogyAnimalRecord value, $Res Function(GenealogyAnimalRecord) _then) = _$GenealogyAnimalRecordCopyWithImpl;
@useResult
$Res call({
 GenealogyAnimal animal, DateTime birthDate, String? motherId, String? fatherId
});


$GenealogyAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class _$GenealogyAnimalRecordCopyWithImpl<$Res>
    implements $GenealogyAnimalRecordCopyWith<$Res> {
  _$GenealogyAnimalRecordCopyWithImpl(this._self, this._then);

  final GenealogyAnimalRecord _self;
  final $Res Function(GenealogyAnimalRecord) _then;

/// Create a copy of GenealogyAnimalRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animal = null,Object? birthDate = null,Object? motherId = freezed,Object? fatherId = freezed,}) {
  return _then(_self.copyWith(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GenealogyAnimalRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res> get animal {
  
  return $GenealogyAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}


/// Adds pattern-matching-related methods to [GenealogyAnimalRecord].
extension GenealogyAnimalRecordPatterns on GenealogyAnimalRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenealogyAnimalRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenealogyAnimalRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenealogyAnimalRecord value)  $default,){
final _that = this;
switch (_that) {
case _GenealogyAnimalRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenealogyAnimalRecord value)?  $default,){
final _that = this;
switch (_that) {
case _GenealogyAnimalRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GenealogyAnimal animal,  DateTime birthDate,  String? motherId,  String? fatherId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenealogyAnimalRecord() when $default != null:
return $default(_that.animal,_that.birthDate,_that.motherId,_that.fatherId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GenealogyAnimal animal,  DateTime birthDate,  String? motherId,  String? fatherId)  $default,) {final _that = this;
switch (_that) {
case _GenealogyAnimalRecord():
return $default(_that.animal,_that.birthDate,_that.motherId,_that.fatherId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GenealogyAnimal animal,  DateTime birthDate,  String? motherId,  String? fatherId)?  $default,) {final _that = this;
switch (_that) {
case _GenealogyAnimalRecord() when $default != null:
return $default(_that.animal,_that.birthDate,_that.motherId,_that.fatherId);case _:
  return null;

}
}

}

/// @nodoc


class _GenealogyAnimalRecord implements GenealogyAnimalRecord {
  const _GenealogyAnimalRecord({required this.animal, required this.birthDate, this.motherId, this.fatherId});
  

/// Identidad del animal.
@override final  GenealogyAnimal animal;
/// Fecha utilizada para ordenar las crías.
@override final  DateTime birthDate;
/// UUID de la madre, si fue registrado.
@override final  String? motherId;
/// UUID del padre, si fue registrado.
@override final  String? fatherId;

/// Create a copy of GenealogyAnimalRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenealogyAnimalRecordCopyWith<_GenealogyAnimalRecord> get copyWith => __$GenealogyAnimalRecordCopyWithImpl<_GenealogyAnimalRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenealogyAnimalRecord&&(identical(other.animal, animal) || other.animal == animal)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId));
}


@override
int get hashCode => Object.hash(runtimeType,animal,birthDate,motherId,fatherId);

@override
String toString() {
  return 'GenealogyAnimalRecord(animal: $animal, birthDate: $birthDate, motherId: $motherId, fatherId: $fatherId)';
}


}

/// @nodoc
abstract mixin class _$GenealogyAnimalRecordCopyWith<$Res> implements $GenealogyAnimalRecordCopyWith<$Res> {
  factory _$GenealogyAnimalRecordCopyWith(_GenealogyAnimalRecord value, $Res Function(_GenealogyAnimalRecord) _then) = __$GenealogyAnimalRecordCopyWithImpl;
@override @useResult
$Res call({
 GenealogyAnimal animal, DateTime birthDate, String? motherId, String? fatherId
});


@override $GenealogyAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class __$GenealogyAnimalRecordCopyWithImpl<$Res>
    implements _$GenealogyAnimalRecordCopyWith<$Res> {
  __$GenealogyAnimalRecordCopyWithImpl(this._self, this._then);

  final _GenealogyAnimalRecord _self;
  final $Res Function(_GenealogyAnimalRecord) _then;

/// Create a copy of GenealogyAnimalRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animal = null,Object? birthDate = null,Object? motherId = freezed,Object? fatherId = freezed,}) {
  return _then(_GenealogyAnimalRecord(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GenealogyAnimalRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res> get animal {
  
  return $GenealogyAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}

/// @nodoc
mixin _$AnimalGenealogy {

/// Padre.
 GenealogyAnimal? get father;/// Madre.
 GenealogyAnimal? get mother;/// Padre del padre.
 GenealogyAnimal? get paternalGrandfather;/// Madre del padre.
 GenealogyAnimal? get paternalGrandmother;/// Padre de la madre.
 GenealogyAnimal? get maternalGrandfather;/// Madre de la madre.
 GenealogyAnimal? get maternalGrandmother;/// Animales que tienen a este como madre o padre.
 List<GenealogyAnimal> get offspring;
/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalGenealogyCopyWith<AnimalGenealogy> get copyWith => _$AnimalGenealogyCopyWithImpl<AnimalGenealogy>(this as AnimalGenealogy, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalGenealogy&&(identical(other.father, father) || other.father == father)&&(identical(other.mother, mother) || other.mother == mother)&&(identical(other.paternalGrandfather, paternalGrandfather) || other.paternalGrandfather == paternalGrandfather)&&(identical(other.paternalGrandmother, paternalGrandmother) || other.paternalGrandmother == paternalGrandmother)&&(identical(other.maternalGrandfather, maternalGrandfather) || other.maternalGrandfather == maternalGrandfather)&&(identical(other.maternalGrandmother, maternalGrandmother) || other.maternalGrandmother == maternalGrandmother)&&const DeepCollectionEquality().equals(other.offspring, offspring));
}


@override
int get hashCode => Object.hash(runtimeType,father,mother,paternalGrandfather,paternalGrandmother,maternalGrandfather,maternalGrandmother,const DeepCollectionEquality().hash(offspring));

@override
String toString() {
  return 'AnimalGenealogy(father: $father, mother: $mother, paternalGrandfather: $paternalGrandfather, paternalGrandmother: $paternalGrandmother, maternalGrandfather: $maternalGrandfather, maternalGrandmother: $maternalGrandmother, offspring: $offspring)';
}


}

/// @nodoc
abstract mixin class $AnimalGenealogyCopyWith<$Res>  {
  factory $AnimalGenealogyCopyWith(AnimalGenealogy value, $Res Function(AnimalGenealogy) _then) = _$AnimalGenealogyCopyWithImpl;
@useResult
$Res call({
 GenealogyAnimal? father, GenealogyAnimal? mother, GenealogyAnimal? paternalGrandfather, GenealogyAnimal? paternalGrandmother, GenealogyAnimal? maternalGrandfather, GenealogyAnimal? maternalGrandmother, List<GenealogyAnimal> offspring
});


$GenealogyAnimalCopyWith<$Res>? get father;$GenealogyAnimalCopyWith<$Res>? get mother;$GenealogyAnimalCopyWith<$Res>? get paternalGrandfather;$GenealogyAnimalCopyWith<$Res>? get paternalGrandmother;$GenealogyAnimalCopyWith<$Res>? get maternalGrandfather;$GenealogyAnimalCopyWith<$Res>? get maternalGrandmother;

}
/// @nodoc
class _$AnimalGenealogyCopyWithImpl<$Res>
    implements $AnimalGenealogyCopyWith<$Res> {
  _$AnimalGenealogyCopyWithImpl(this._self, this._then);

  final AnimalGenealogy _self;
  final $Res Function(AnimalGenealogy) _then;

/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? father = freezed,Object? mother = freezed,Object? paternalGrandfather = freezed,Object? paternalGrandmother = freezed,Object? maternalGrandfather = freezed,Object? maternalGrandmother = freezed,Object? offspring = null,}) {
  return _then(_self.copyWith(
father: freezed == father ? _self.father : father // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,mother: freezed == mother ? _self.mother : mother // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,paternalGrandfather: freezed == paternalGrandfather ? _self.paternalGrandfather : paternalGrandfather // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,paternalGrandmother: freezed == paternalGrandmother ? _self.paternalGrandmother : paternalGrandmother // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,maternalGrandfather: freezed == maternalGrandfather ? _self.maternalGrandfather : maternalGrandfather // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,maternalGrandmother: freezed == maternalGrandmother ? _self.maternalGrandmother : maternalGrandmother // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,offspring: null == offspring ? _self.offspring : offspring // ignore: cast_nullable_to_non_nullable
as List<GenealogyAnimal>,
  ));
}
/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get father {
    if (_self.father == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.father!, (value) {
    return _then(_self.copyWith(father: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get mother {
    if (_self.mother == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.mother!, (value) {
    return _then(_self.copyWith(mother: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get paternalGrandfather {
    if (_self.paternalGrandfather == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.paternalGrandfather!, (value) {
    return _then(_self.copyWith(paternalGrandfather: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get paternalGrandmother {
    if (_self.paternalGrandmother == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.paternalGrandmother!, (value) {
    return _then(_self.copyWith(paternalGrandmother: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get maternalGrandfather {
    if (_self.maternalGrandfather == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.maternalGrandfather!, (value) {
    return _then(_self.copyWith(maternalGrandfather: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get maternalGrandmother {
    if (_self.maternalGrandmother == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.maternalGrandmother!, (value) {
    return _then(_self.copyWith(maternalGrandmother: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnimalGenealogy].
extension AnimalGenealogyPatterns on AnimalGenealogy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalGenealogy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalGenealogy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalGenealogy value)  $default,){
final _that = this;
switch (_that) {
case _AnimalGenealogy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalGenealogy value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalGenealogy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GenealogyAnimal? father,  GenealogyAnimal? mother,  GenealogyAnimal? paternalGrandfather,  GenealogyAnimal? paternalGrandmother,  GenealogyAnimal? maternalGrandfather,  GenealogyAnimal? maternalGrandmother,  List<GenealogyAnimal> offspring)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalGenealogy() when $default != null:
return $default(_that.father,_that.mother,_that.paternalGrandfather,_that.paternalGrandmother,_that.maternalGrandfather,_that.maternalGrandmother,_that.offspring);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GenealogyAnimal? father,  GenealogyAnimal? mother,  GenealogyAnimal? paternalGrandfather,  GenealogyAnimal? paternalGrandmother,  GenealogyAnimal? maternalGrandfather,  GenealogyAnimal? maternalGrandmother,  List<GenealogyAnimal> offspring)  $default,) {final _that = this;
switch (_that) {
case _AnimalGenealogy():
return $default(_that.father,_that.mother,_that.paternalGrandfather,_that.paternalGrandmother,_that.maternalGrandfather,_that.maternalGrandmother,_that.offspring);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GenealogyAnimal? father,  GenealogyAnimal? mother,  GenealogyAnimal? paternalGrandfather,  GenealogyAnimal? paternalGrandmother,  GenealogyAnimal? maternalGrandfather,  GenealogyAnimal? maternalGrandmother,  List<GenealogyAnimal> offspring)?  $default,) {final _that = this;
switch (_that) {
case _AnimalGenealogy() when $default != null:
return $default(_that.father,_that.mother,_that.paternalGrandfather,_that.paternalGrandmother,_that.maternalGrandfather,_that.maternalGrandmother,_that.offspring);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalGenealogy implements AnimalGenealogy {
  const _AnimalGenealogy({this.father, this.mother, this.paternalGrandfather, this.paternalGrandmother, this.maternalGrandfather, this.maternalGrandmother, final  List<GenealogyAnimal> offspring = const []}): _offspring = offspring;
  

/// Padre.
@override final  GenealogyAnimal? father;
/// Madre.
@override final  GenealogyAnimal? mother;
/// Padre del padre.
@override final  GenealogyAnimal? paternalGrandfather;
/// Madre del padre.
@override final  GenealogyAnimal? paternalGrandmother;
/// Padre de la madre.
@override final  GenealogyAnimal? maternalGrandfather;
/// Madre de la madre.
@override final  GenealogyAnimal? maternalGrandmother;
/// Animales que tienen a este como madre o padre.
 final  List<GenealogyAnimal> _offspring;
/// Animales que tienen a este como madre o padre.
@override@JsonKey() List<GenealogyAnimal> get offspring {
  if (_offspring is EqualUnmodifiableListView) return _offspring;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_offspring);
}


/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalGenealogyCopyWith<_AnimalGenealogy> get copyWith => __$AnimalGenealogyCopyWithImpl<_AnimalGenealogy>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalGenealogy&&(identical(other.father, father) || other.father == father)&&(identical(other.mother, mother) || other.mother == mother)&&(identical(other.paternalGrandfather, paternalGrandfather) || other.paternalGrandfather == paternalGrandfather)&&(identical(other.paternalGrandmother, paternalGrandmother) || other.paternalGrandmother == paternalGrandmother)&&(identical(other.maternalGrandfather, maternalGrandfather) || other.maternalGrandfather == maternalGrandfather)&&(identical(other.maternalGrandmother, maternalGrandmother) || other.maternalGrandmother == maternalGrandmother)&&const DeepCollectionEquality().equals(other._offspring, _offspring));
}


@override
int get hashCode => Object.hash(runtimeType,father,mother,paternalGrandfather,paternalGrandmother,maternalGrandfather,maternalGrandmother,const DeepCollectionEquality().hash(_offspring));

@override
String toString() {
  return 'AnimalGenealogy(father: $father, mother: $mother, paternalGrandfather: $paternalGrandfather, paternalGrandmother: $paternalGrandmother, maternalGrandfather: $maternalGrandfather, maternalGrandmother: $maternalGrandmother, offspring: $offspring)';
}


}

/// @nodoc
abstract mixin class _$AnimalGenealogyCopyWith<$Res> implements $AnimalGenealogyCopyWith<$Res> {
  factory _$AnimalGenealogyCopyWith(_AnimalGenealogy value, $Res Function(_AnimalGenealogy) _then) = __$AnimalGenealogyCopyWithImpl;
@override @useResult
$Res call({
 GenealogyAnimal? father, GenealogyAnimal? mother, GenealogyAnimal? paternalGrandfather, GenealogyAnimal? paternalGrandmother, GenealogyAnimal? maternalGrandfather, GenealogyAnimal? maternalGrandmother, List<GenealogyAnimal> offspring
});


@override $GenealogyAnimalCopyWith<$Res>? get father;@override $GenealogyAnimalCopyWith<$Res>? get mother;@override $GenealogyAnimalCopyWith<$Res>? get paternalGrandfather;@override $GenealogyAnimalCopyWith<$Res>? get paternalGrandmother;@override $GenealogyAnimalCopyWith<$Res>? get maternalGrandfather;@override $GenealogyAnimalCopyWith<$Res>? get maternalGrandmother;

}
/// @nodoc
class __$AnimalGenealogyCopyWithImpl<$Res>
    implements _$AnimalGenealogyCopyWith<$Res> {
  __$AnimalGenealogyCopyWithImpl(this._self, this._then);

  final _AnimalGenealogy _self;
  final $Res Function(_AnimalGenealogy) _then;

/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? father = freezed,Object? mother = freezed,Object? paternalGrandfather = freezed,Object? paternalGrandmother = freezed,Object? maternalGrandfather = freezed,Object? maternalGrandmother = freezed,Object? offspring = null,}) {
  return _then(_AnimalGenealogy(
father: freezed == father ? _self.father : father // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,mother: freezed == mother ? _self.mother : mother // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,paternalGrandfather: freezed == paternalGrandfather ? _self.paternalGrandfather : paternalGrandfather // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,paternalGrandmother: freezed == paternalGrandmother ? _self.paternalGrandmother : paternalGrandmother // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,maternalGrandfather: freezed == maternalGrandfather ? _self.maternalGrandfather : maternalGrandfather // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,maternalGrandmother: freezed == maternalGrandmother ? _self.maternalGrandmother : maternalGrandmother // ignore: cast_nullable_to_non_nullable
as GenealogyAnimal?,offspring: null == offspring ? _self._offspring : offspring // ignore: cast_nullable_to_non_nullable
as List<GenealogyAnimal>,
  ));
}

/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get father {
    if (_self.father == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.father!, (value) {
    return _then(_self.copyWith(father: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get mother {
    if (_self.mother == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.mother!, (value) {
    return _then(_self.copyWith(mother: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get paternalGrandfather {
    if (_self.paternalGrandfather == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.paternalGrandfather!, (value) {
    return _then(_self.copyWith(paternalGrandfather: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get paternalGrandmother {
    if (_self.paternalGrandmother == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.paternalGrandmother!, (value) {
    return _then(_self.copyWith(paternalGrandmother: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get maternalGrandfather {
    if (_self.maternalGrandfather == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.maternalGrandfather!, (value) {
    return _then(_self.copyWith(maternalGrandfather: value));
  });
}/// Create a copy of AnimalGenealogy
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenealogyAnimalCopyWith<$Res>? get maternalGrandmother {
    if (_self.maternalGrandmother == null) {
    return null;
  }

  return $GenealogyAnimalCopyWith<$Res>(_self.maternalGrandmother!, (value) {
    return _then(_self.copyWith(maternalGrandmother: value));
  });
}
}

// dart format on
