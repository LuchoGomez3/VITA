// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalListState {

 ResultState<List<AnimalListEntry>> get animals;/// Texto buscado (caravana, RFID o raza).
 String get query;/// Categoría elegida en los chips, o `null` para "Todos".
 String? get category;/// Establecimientos del usuario, para el selector de la cabecera.
 List<EstablishmentMembership> get establishments;/// Establecimiento elegido, o `null` para ver todos.
 String? get establishmentId;
/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalListStateCopyWith<AnimalListState> get copyWith => _$AnimalListStateCopyWithImpl<AnimalListState>(this as AnimalListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalListState&&(identical(other.animals, animals) || other.animals == animals)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.establishments, establishments)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId));
}


@override
int get hashCode => Object.hash(runtimeType,animals,query,category,const DeepCollectionEquality().hash(establishments),establishmentId);

@override
String toString() {
  return 'AnimalListState(animals: $animals, query: $query, category: $category, establishments: $establishments, establishmentId: $establishmentId)';
}


}

/// @nodoc
abstract mixin class $AnimalListStateCopyWith<$Res>  {
  factory $AnimalListStateCopyWith(AnimalListState value, $Res Function(AnimalListState) _then) = _$AnimalListStateCopyWithImpl;
@useResult
$Res call({
 ResultState<List<AnimalListEntry>> animals, String query, String? category, List<EstablishmentMembership> establishments, String? establishmentId
});


$ResultStateCopyWith<List<AnimalListEntry>, $Res> get animals;

}
/// @nodoc
class _$AnimalListStateCopyWithImpl<$Res>
    implements $AnimalListStateCopyWith<$Res> {
  _$AnimalListStateCopyWithImpl(this._self, this._then);

  final AnimalListState _self;
  final $Res Function(AnimalListState) _then;

/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animals = null,Object? query = null,Object? category = freezed,Object? establishments = null,Object? establishmentId = freezed,}) {
  return _then(_self.copyWith(
animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalListEntry>>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,establishments: null == establishments ? _self.establishments : establishments // ignore: cast_nullable_to_non_nullable
as List<EstablishmentMembership>,establishmentId: freezed == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalListEntry>, $Res> get animals {
  
  return $ResultStateCopyWith<List<AnimalListEntry>, $Res>(_self.animals, (value) {
    return _then(_self.copyWith(animals: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnimalListState].
extension AnimalListStatePatterns on AnimalListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalListState value)  $default,){
final _that = this;
switch (_that) {
case _AnimalListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalListState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ResultState<List<AnimalListEntry>> animals,  String query,  String? category,  List<EstablishmentMembership> establishments,  String? establishmentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
return $default(_that.animals,_that.query,_that.category,_that.establishments,_that.establishmentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ResultState<List<AnimalListEntry>> animals,  String query,  String? category,  List<EstablishmentMembership> establishments,  String? establishmentId)  $default,) {final _that = this;
switch (_that) {
case _AnimalListState():
return $default(_that.animals,_that.query,_that.category,_that.establishments,_that.establishmentId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ResultState<List<AnimalListEntry>> animals,  String query,  String? category,  List<EstablishmentMembership> establishments,  String? establishmentId)?  $default,) {final _that = this;
switch (_that) {
case _AnimalListState() when $default != null:
return $default(_that.animals,_that.query,_that.category,_that.establishments,_that.establishmentId);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalListState extends AnimalListState {
  const _AnimalListState({this.animals = const ResultState<List<AnimalListEntry>>.initial(), this.query = '', this.category, final  List<EstablishmentMembership> establishments = const <EstablishmentMembership>[], this.establishmentId}): _establishments = establishments,super._();
  

@override@JsonKey() final  ResultState<List<AnimalListEntry>> animals;
/// Texto buscado (caravana, RFID o raza).
@override@JsonKey() final  String query;
/// Categoría elegida en los chips, o `null` para "Todos".
@override final  String? category;
/// Establecimientos del usuario, para el selector de la cabecera.
 final  List<EstablishmentMembership> _establishments;
/// Establecimientos del usuario, para el selector de la cabecera.
@override@JsonKey() List<EstablishmentMembership> get establishments {
  if (_establishments is EqualUnmodifiableListView) return _establishments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_establishments);
}

/// Establecimiento elegido, o `null` para ver todos.
@override final  String? establishmentId;

/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalListStateCopyWith<_AnimalListState> get copyWith => __$AnimalListStateCopyWithImpl<_AnimalListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalListState&&(identical(other.animals, animals) || other.animals == animals)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._establishments, _establishments)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId));
}


@override
int get hashCode => Object.hash(runtimeType,animals,query,category,const DeepCollectionEquality().hash(_establishments),establishmentId);

@override
String toString() {
  return 'AnimalListState(animals: $animals, query: $query, category: $category, establishments: $establishments, establishmentId: $establishmentId)';
}


}

/// @nodoc
abstract mixin class _$AnimalListStateCopyWith<$Res> implements $AnimalListStateCopyWith<$Res> {
  factory _$AnimalListStateCopyWith(_AnimalListState value, $Res Function(_AnimalListState) _then) = __$AnimalListStateCopyWithImpl;
@override @useResult
$Res call({
 ResultState<List<AnimalListEntry>> animals, String query, String? category, List<EstablishmentMembership> establishments, String? establishmentId
});


@override $ResultStateCopyWith<List<AnimalListEntry>, $Res> get animals;

}
/// @nodoc
class __$AnimalListStateCopyWithImpl<$Res>
    implements _$AnimalListStateCopyWith<$Res> {
  __$AnimalListStateCopyWithImpl(this._self, this._then);

  final _AnimalListState _self;
  final $Res Function(_AnimalListState) _then;

/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animals = null,Object? query = null,Object? category = freezed,Object? establishments = null,Object? establishmentId = freezed,}) {
  return _then(_AnimalListState(
animals: null == animals ? _self.animals : animals // ignore: cast_nullable_to_non_nullable
as ResultState<List<AnimalListEntry>>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,establishments: null == establishments ? _self._establishments : establishments // ignore: cast_nullable_to_non_nullable
as List<EstablishmentMembership>,establishmentId: freezed == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AnimalListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<AnimalListEntry>, $Res> get animals {
  
  return $ResultStateCopyWith<List<AnimalListEntry>, $Res>(_self.animals, (value) {
    return _then(_self.copyWith(animals: value));
  });
}
}

// dart format on
