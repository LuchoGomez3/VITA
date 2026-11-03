// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_dashboard_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeDashboardSource {

 List<HomeDashboardAnimal> get animals; List<HomeDashboardWeighing> get weighings; Map<String, String> get categoryNamesById; int get operatingExpensesCents;
/// Create a copy of HomeDashboardSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDashboardSourceCopyWith<HomeDashboardSource> get copyWith => _$HomeDashboardSourceCopyWithImpl<HomeDashboardSource>(this as HomeDashboardSource, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeDashboardSource&&const DeepCollectionEquality().equals(other.animals, animals)&&const DeepCollectionEquality().equals(other.weighings, weighings)&&const DeepCollectionEquality().equals(other.categoryNamesById, categoryNamesById)&&(identical(other.operatingExpensesCents, operatingExpensesCents) || other.operatingExpensesCents == operatingExpensesCents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(animals),const DeepCollectionEquality().hash(weighings),const DeepCollectionEquality().hash(categoryNamesById),operatingExpensesCents);

@override
String toString() {
  return 'HomeDashboardSource(animals: $animals, weighings: $weighings, categoryNamesById: $categoryNamesById, operatingExpensesCents: $operatingExpensesCents)';
}


}

/// @nodoc
abstract mixin class $HomeDashboardSourceCopyWith<$Res>  {
  factory $HomeDashboardSourceCopyWith(HomeDashboardSource value, $Res Function(HomeDashboardSource) _then) = _$HomeDashboardSourceCopyWithImpl;
@useResult
$Res call({
 List<HomeDashboardAnimal> animals, List<HomeDashboardWeighing> weighings, Map<String, String> categoryNamesById, int operatingExpensesCents
});




}
/// @nodoc
class _$HomeDashboardSourceCopyWithImpl<$Res>
    implements $HomeDashboardSourceCopyWith<$Res> {
  _$HomeDashboardSourceCopyWithImpl(this._self, this._then);

  final HomeDashboardSource _self;
  final $Res Function(HomeDashboardSource) _then;

/// Create a copy of HomeDashboardSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animals = null,Object? weighings = null,Object? categoryNamesById = null,Object? operatingExpensesCents = null,}) {
  return _then(_self.copyWith(
animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as List<HomeDashboardAnimal>,weighings: null == weighings ? _self.weighings : weighings // ignore: cast_nullable_to_non_nullable
as List<HomeDashboardWeighing>,categoryNamesById: null == categoryNamesById ? _self.categoryNamesById : categoryNamesById // ignore: cast_nullable_to_non_nullable
as Map<String, String>,operatingExpensesCents: null == operatingExpensesCents ? _self.operatingExpensesCents : operatingExpensesCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeDashboardSource].
extension HomeDashboardSourcePatterns on HomeDashboardSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeDashboardSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeDashboardSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeDashboardSource value)  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeDashboardSource value)?  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HomeDashboardAnimal> animals,  List<HomeDashboardWeighing> weighings,  Map<String, String> categoryNamesById,  int operatingExpensesCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeDashboardSource() when $default != null:
return $default(_that.animals,_that.weighings,_that.categoryNamesById,_that.operatingExpensesCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HomeDashboardAnimal> animals,  List<HomeDashboardWeighing> weighings,  Map<String, String> categoryNamesById,  int operatingExpensesCents)  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardSource():
return $default(_that.animals,_that.weighings,_that.categoryNamesById,_that.operatingExpensesCents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HomeDashboardAnimal> animals,  List<HomeDashboardWeighing> weighings,  Map<String, String> categoryNamesById,  int operatingExpensesCents)?  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardSource() when $default != null:
return $default(_that.animals,_that.weighings,_that.categoryNamesById,_that.operatingExpensesCents);case _:
  return null;

}
}

}

/// @nodoc


class _HomeDashboardSource implements HomeDashboardSource {
  const _HomeDashboardSource({required final  List<HomeDashboardAnimal> animals, required final  List<HomeDashboardWeighing> weighings, required final  Map<String, String> categoryNamesById, required this.operatingExpensesCents}): _animals = animals,_weighings = weighings,_categoryNamesById = categoryNamesById;
  

 final  List<HomeDashboardAnimal> _animals;
@override List<HomeDashboardAnimal> get animals {
  if (_animals is EqualUnmodifiableListView) return _animals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animals);
}

 final  List<HomeDashboardWeighing> _weighings;
@override List<HomeDashboardWeighing> get weighings {
  if (_weighings is EqualUnmodifiableListView) return _weighings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weighings);
}

 final  Map<String, String> _categoryNamesById;
@override Map<String, String> get categoryNamesById {
  if (_categoryNamesById is EqualUnmodifiableMapView) return _categoryNamesById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categoryNamesById);
}

@override final  int operatingExpensesCents;

/// Create a copy of HomeDashboardSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDashboardSourceCopyWith<_HomeDashboardSource> get copyWith => __$HomeDashboardSourceCopyWithImpl<_HomeDashboardSource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeDashboardSource&&const DeepCollectionEquality().equals(other._animals, _animals)&&const DeepCollectionEquality().equals(other._weighings, _weighings)&&const DeepCollectionEquality().equals(other._categoryNamesById, _categoryNamesById)&&(identical(other.operatingExpensesCents, operatingExpensesCents) || other.operatingExpensesCents == operatingExpensesCents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_animals),const DeepCollectionEquality().hash(_weighings),const DeepCollectionEquality().hash(_categoryNamesById),operatingExpensesCents);

@override
String toString() {
  return 'HomeDashboardSource(animals: $animals, weighings: $weighings, categoryNamesById: $categoryNamesById, operatingExpensesCents: $operatingExpensesCents)';
}


}

/// @nodoc
abstract mixin class _$HomeDashboardSourceCopyWith<$Res> implements $HomeDashboardSourceCopyWith<$Res> {
  factory _$HomeDashboardSourceCopyWith(_HomeDashboardSource value, $Res Function(_HomeDashboardSource) _then) = __$HomeDashboardSourceCopyWithImpl;
@override @useResult
$Res call({
 List<HomeDashboardAnimal> animals, List<HomeDashboardWeighing> weighings, Map<String, String> categoryNamesById, int operatingExpensesCents
});




}
/// @nodoc
class __$HomeDashboardSourceCopyWithImpl<$Res>
    implements _$HomeDashboardSourceCopyWith<$Res> {
  __$HomeDashboardSourceCopyWithImpl(this._self, this._then);

  final _HomeDashboardSource _self;
  final $Res Function(_HomeDashboardSource) _then;

/// Create a copy of HomeDashboardSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animals = null,Object? weighings = null,Object? categoryNamesById = null,Object? operatingExpensesCents = null,}) {
  return _then(_HomeDashboardSource(
animals: null == animals ? _self._animals : animals // ignore: cast_nullable_to_non_nullable
as List<HomeDashboardAnimal>,weighings: null == weighings ? _self._weighings : weighings // ignore: cast_nullable_to_non_nullable
as List<HomeDashboardWeighing>,categoryNamesById: null == categoryNamesById ? _self._categoryNamesById : categoryNamesById // ignore: cast_nullable_to_non_nullable
as Map<String, String>,operatingExpensesCents: null == operatingExpensesCents ? _self.operatingExpensesCents : operatingExpensesCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$HomeDashboardAnimal {

 String get id; AnimalProductiveStatus get productiveStatus; DateTime get createdAt; DateTime? get deletedAt; DateTime? get productiveStatusChangedAt; String get categoryId; String get categoryName; String get lotName; double? get initialWeightKg; DateTime get initialWeighingDate;
/// Create a copy of HomeDashboardAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDashboardAnimalCopyWith<HomeDashboardAnimal> get copyWith => _$HomeDashboardAnimalCopyWithImpl<HomeDashboardAnimal>(this as HomeDashboardAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeDashboardAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.productiveStatus, productiveStatus) || other.productiveStatus == productiveStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.productiveStatusChangedAt, productiveStatusChangedAt) || other.productiveStatusChangedAt == productiveStatusChangedAt)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.initialWeightKg, initialWeightKg) || other.initialWeightKg == initialWeightKg)&&(identical(other.initialWeighingDate, initialWeighingDate) || other.initialWeighingDate == initialWeighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,productiveStatus,createdAt,deletedAt,productiveStatusChangedAt,categoryId,categoryName,lotName,initialWeightKg,initialWeighingDate);

@override
String toString() {
  return 'HomeDashboardAnimal(id: $id, productiveStatus: $productiveStatus, createdAt: $createdAt, deletedAt: $deletedAt, productiveStatusChangedAt: $productiveStatusChangedAt, categoryId: $categoryId, categoryName: $categoryName, lotName: $lotName, initialWeightKg: $initialWeightKg, initialWeighingDate: $initialWeighingDate)';
}


}

/// @nodoc
abstract mixin class $HomeDashboardAnimalCopyWith<$Res>  {
  factory $HomeDashboardAnimalCopyWith(HomeDashboardAnimal value, $Res Function(HomeDashboardAnimal) _then) = _$HomeDashboardAnimalCopyWithImpl;
@useResult
$Res call({
 String id, AnimalProductiveStatus productiveStatus, DateTime createdAt, DateTime? deletedAt, DateTime? productiveStatusChangedAt, String categoryId, String categoryName, String lotName, double? initialWeightKg, DateTime initialWeighingDate
});




}
/// @nodoc
class _$HomeDashboardAnimalCopyWithImpl<$Res>
    implements $HomeDashboardAnimalCopyWith<$Res> {
  _$HomeDashboardAnimalCopyWithImpl(this._self, this._then);

  final HomeDashboardAnimal _self;
  final $Res Function(HomeDashboardAnimal) _then;

/// Create a copy of HomeDashboardAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productiveStatus = null,Object? createdAt = null,Object? deletedAt = freezed,Object? productiveStatusChangedAt = freezed,Object? categoryId = null,Object? categoryName = null,Object? lotName = null,Object? initialWeightKg = freezed,Object? initialWeighingDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productiveStatus: null == productiveStatus ? _self.productiveStatus : productiveStatus // ignore: cast_nullable_to_non_nullable
as AnimalProductiveStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productiveStatusChangedAt: freezed == productiveStatusChangedAt ? _self.productiveStatusChangedAt : productiveStatusChangedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,initialWeightKg: freezed == initialWeightKg ? _self.initialWeightKg : initialWeightKg // ignore: cast_nullable_to_non_nullable
as double?,initialWeighingDate: null == initialWeighingDate ? _self.initialWeighingDate : initialWeighingDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeDashboardAnimal].
extension HomeDashboardAnimalPatterns on HomeDashboardAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeDashboardAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeDashboardAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeDashboardAnimal value)  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeDashboardAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AnimalProductiveStatus productiveStatus,  DateTime createdAt,  DateTime? deletedAt,  DateTime? productiveStatusChangedAt,  String categoryId,  String categoryName,  String lotName,  double? initialWeightKg,  DateTime initialWeighingDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeDashboardAnimal() when $default != null:
return $default(_that.id,_that.productiveStatus,_that.createdAt,_that.deletedAt,_that.productiveStatusChangedAt,_that.categoryId,_that.categoryName,_that.lotName,_that.initialWeightKg,_that.initialWeighingDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AnimalProductiveStatus productiveStatus,  DateTime createdAt,  DateTime? deletedAt,  DateTime? productiveStatusChangedAt,  String categoryId,  String categoryName,  String lotName,  double? initialWeightKg,  DateTime initialWeighingDate)  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardAnimal():
return $default(_that.id,_that.productiveStatus,_that.createdAt,_that.deletedAt,_that.productiveStatusChangedAt,_that.categoryId,_that.categoryName,_that.lotName,_that.initialWeightKg,_that.initialWeighingDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AnimalProductiveStatus productiveStatus,  DateTime createdAt,  DateTime? deletedAt,  DateTime? productiveStatusChangedAt,  String categoryId,  String categoryName,  String lotName,  double? initialWeightKg,  DateTime initialWeighingDate)?  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardAnimal() when $default != null:
return $default(_that.id,_that.productiveStatus,_that.createdAt,_that.deletedAt,_that.productiveStatusChangedAt,_that.categoryId,_that.categoryName,_that.lotName,_that.initialWeightKg,_that.initialWeighingDate);case _:
  return null;

}
}

}

/// @nodoc


class _HomeDashboardAnimal implements HomeDashboardAnimal {
  const _HomeDashboardAnimal({required this.id, required this.productiveStatus, required this.createdAt, required this.deletedAt, required this.productiveStatusChangedAt, required this.categoryId, required this.categoryName, required this.lotName, required this.initialWeightKg, required this.initialWeighingDate});
  

@override final  String id;
@override final  AnimalProductiveStatus productiveStatus;
@override final  DateTime createdAt;
@override final  DateTime? deletedAt;
@override final  DateTime? productiveStatusChangedAt;
@override final  String categoryId;
@override final  String categoryName;
@override final  String lotName;
@override final  double? initialWeightKg;
@override final  DateTime initialWeighingDate;

/// Create a copy of HomeDashboardAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDashboardAnimalCopyWith<_HomeDashboardAnimal> get copyWith => __$HomeDashboardAnimalCopyWithImpl<_HomeDashboardAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeDashboardAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.productiveStatus, productiveStatus) || other.productiveStatus == productiveStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.productiveStatusChangedAt, productiveStatusChangedAt) || other.productiveStatusChangedAt == productiveStatusChangedAt)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.initialWeightKg, initialWeightKg) || other.initialWeightKg == initialWeightKg)&&(identical(other.initialWeighingDate, initialWeighingDate) || other.initialWeighingDate == initialWeighingDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,productiveStatus,createdAt,deletedAt,productiveStatusChangedAt,categoryId,categoryName,lotName,initialWeightKg,initialWeighingDate);

@override
String toString() {
  return 'HomeDashboardAnimal(id: $id, productiveStatus: $productiveStatus, createdAt: $createdAt, deletedAt: $deletedAt, productiveStatusChangedAt: $productiveStatusChangedAt, categoryId: $categoryId, categoryName: $categoryName, lotName: $lotName, initialWeightKg: $initialWeightKg, initialWeighingDate: $initialWeighingDate)';
}


}

/// @nodoc
abstract mixin class _$HomeDashboardAnimalCopyWith<$Res> implements $HomeDashboardAnimalCopyWith<$Res> {
  factory _$HomeDashboardAnimalCopyWith(_HomeDashboardAnimal value, $Res Function(_HomeDashboardAnimal) _then) = __$HomeDashboardAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, AnimalProductiveStatus productiveStatus, DateTime createdAt, DateTime? deletedAt, DateTime? productiveStatusChangedAt, String categoryId, String categoryName, String lotName, double? initialWeightKg, DateTime initialWeighingDate
});




}
/// @nodoc
class __$HomeDashboardAnimalCopyWithImpl<$Res>
    implements _$HomeDashboardAnimalCopyWith<$Res> {
  __$HomeDashboardAnimalCopyWithImpl(this._self, this._then);

  final _HomeDashboardAnimal _self;
  final $Res Function(_HomeDashboardAnimal) _then;

/// Create a copy of HomeDashboardAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productiveStatus = null,Object? createdAt = null,Object? deletedAt = freezed,Object? productiveStatusChangedAt = freezed,Object? categoryId = null,Object? categoryName = null,Object? lotName = null,Object? initialWeightKg = freezed,Object? initialWeighingDate = null,}) {
  return _then(_HomeDashboardAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productiveStatus: null == productiveStatus ? _self.productiveStatus : productiveStatus // ignore: cast_nullable_to_non_nullable
as AnimalProductiveStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productiveStatusChangedAt: freezed == productiveStatusChangedAt ? _self.productiveStatusChangedAt : productiveStatusChangedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,initialWeightKg: freezed == initialWeightKg ? _self.initialWeightKg : initialWeightKg // ignore: cast_nullable_to_non_nullable
as double?,initialWeighingDate: null == initialWeighingDate ? _self.initialWeighingDate : initialWeighingDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$HomeDashboardWeighing {

 String get animalId; double get weightKg; DateTime get date;
/// Create a copy of HomeDashboardWeighing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDashboardWeighingCopyWith<HomeDashboardWeighing> get copyWith => _$HomeDashboardWeighingCopyWithImpl<HomeDashboardWeighing>(this as HomeDashboardWeighing, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeDashboardWeighing&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,weightKg,date);

@override
String toString() {
  return 'HomeDashboardWeighing(animalId: $animalId, weightKg: $weightKg, date: $date)';
}


}

/// @nodoc
abstract mixin class $HomeDashboardWeighingCopyWith<$Res>  {
  factory $HomeDashboardWeighingCopyWith(HomeDashboardWeighing value, $Res Function(HomeDashboardWeighing) _then) = _$HomeDashboardWeighingCopyWithImpl;
@useResult
$Res call({
 String animalId, double weightKg, DateTime date
});




}
/// @nodoc
class _$HomeDashboardWeighingCopyWithImpl<$Res>
    implements $HomeDashboardWeighingCopyWith<$Res> {
  _$HomeDashboardWeighingCopyWithImpl(this._self, this._then);

  final HomeDashboardWeighing _self;
  final $Res Function(HomeDashboardWeighing) _then;

/// Create a copy of HomeDashboardWeighing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animalId = null,Object? weightKg = null,Object? date = null,}) {
  return _then(_self.copyWith(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeDashboardWeighing].
extension HomeDashboardWeighingPatterns on HomeDashboardWeighing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeDashboardWeighing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeDashboardWeighing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeDashboardWeighing value)  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardWeighing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeDashboardWeighing value)?  $default,){
final _that = this;
switch (_that) {
case _HomeDashboardWeighing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String animalId,  double weightKg,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeDashboardWeighing() when $default != null:
return $default(_that.animalId,_that.weightKg,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String animalId,  double weightKg,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardWeighing():
return $default(_that.animalId,_that.weightKg,_that.date);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String animalId,  double weightKg,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _HomeDashboardWeighing() when $default != null:
return $default(_that.animalId,_that.weightKg,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _HomeDashboardWeighing implements HomeDashboardWeighing {
  const _HomeDashboardWeighing({required this.animalId, required this.weightKg, required this.date});
  

@override final  String animalId;
@override final  double weightKg;
@override final  DateTime date;

/// Create a copy of HomeDashboardWeighing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDashboardWeighingCopyWith<_HomeDashboardWeighing> get copyWith => __$HomeDashboardWeighingCopyWithImpl<_HomeDashboardWeighing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeDashboardWeighing&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,weightKg,date);

@override
String toString() {
  return 'HomeDashboardWeighing(animalId: $animalId, weightKg: $weightKg, date: $date)';
}


}

/// @nodoc
abstract mixin class _$HomeDashboardWeighingCopyWith<$Res> implements $HomeDashboardWeighingCopyWith<$Res> {
  factory _$HomeDashboardWeighingCopyWith(_HomeDashboardWeighing value, $Res Function(_HomeDashboardWeighing) _then) = __$HomeDashboardWeighingCopyWithImpl;
@override @useResult
$Res call({
 String animalId, double weightKg, DateTime date
});




}
/// @nodoc
class __$HomeDashboardWeighingCopyWithImpl<$Res>
    implements _$HomeDashboardWeighingCopyWith<$Res> {
  __$HomeDashboardWeighingCopyWithImpl(this._self, this._then);

  final _HomeDashboardWeighing _self;
  final $Res Function(_HomeDashboardWeighing) _then;

/// Create a copy of HomeDashboardWeighing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = null,Object? weightKg = null,Object? date = null,}) {
  return _then(_HomeDashboardWeighing(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
