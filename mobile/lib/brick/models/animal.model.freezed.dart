// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BrickAnimalModel {

 int get nroCaravana; String get sexo; String get raza; double get peso; DateTime get fechaNac; String get categoria; String get pelaje; int? get idLote; int? get caravanaPadre; int? get caravanaMadre; String? get observaciones; DateTime? get syncedAt;
/// Create a copy of BrickAnimalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrickAnimalModelCopyWith<BrickAnimalModel> get copyWith => _$BrickAnimalModelCopyWithImpl<BrickAnimalModel>(this as BrickAnimalModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrickAnimalModel&&(identical(other.nroCaravana, nroCaravana) || other.nroCaravana == nroCaravana)&&(identical(other.sexo, sexo) || other.sexo == sexo)&&(identical(other.raza, raza) || other.raza == raza)&&(identical(other.peso, peso) || other.peso == peso)&&(identical(other.fechaNac, fechaNac) || other.fechaNac == fechaNac)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.pelaje, pelaje) || other.pelaje == pelaje)&&(identical(other.idLote, idLote) || other.idLote == idLote)&&(identical(other.caravanaPadre, caravanaPadre) || other.caravanaPadre == caravanaPadre)&&(identical(other.caravanaMadre, caravanaMadre) || other.caravanaMadre == caravanaMadre)&&(identical(other.observaciones, observaciones) || other.observaciones == observaciones)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,nroCaravana,sexo,raza,peso,fechaNac,categoria,pelaje,idLote,caravanaPadre,caravanaMadre,observaciones,syncedAt);

@override
String toString() {
  return 'BrickAnimalModel(nroCaravana: $nroCaravana, sexo: $sexo, raza: $raza, peso: $peso, fechaNac: $fechaNac, categoria: $categoria, pelaje: $pelaje, idLote: $idLote, caravanaPadre: $caravanaPadre, caravanaMadre: $caravanaMadre, observaciones: $observaciones, syncedAt: $syncedAt)';
}


}

/// @nodoc
abstract mixin class $BrickAnimalModelCopyWith<$Res>  {
  factory $BrickAnimalModelCopyWith(BrickAnimalModel value, $Res Function(BrickAnimalModel) _then) = _$BrickAnimalModelCopyWithImpl;
@useResult
$Res call({
 int nroCaravana, String sexo, String raza, double peso, DateTime fechaNac, String categoria, String pelaje, int? idLote, int? caravanaPadre, int? caravanaMadre, String? observaciones, DateTime? syncedAt
});




}
/// @nodoc
class _$BrickAnimalModelCopyWithImpl<$Res>
    implements $BrickAnimalModelCopyWith<$Res> {
  _$BrickAnimalModelCopyWithImpl(this._self, this._then);

  final BrickAnimalModel _self;
  final $Res Function(BrickAnimalModel) _then;

/// Create a copy of BrickAnimalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nroCaravana = null,Object? sexo = null,Object? raza = null,Object? peso = null,Object? fechaNac = null,Object? categoria = null,Object? pelaje = null,Object? idLote = freezed,Object? caravanaPadre = freezed,Object? caravanaMadre = freezed,Object? observaciones = freezed,Object? syncedAt = freezed,}) {
  return _then(_self.copyWith(
nroCaravana: null == nroCaravana ? _self.nroCaravana : nroCaravana // ignore: cast_nullable_to_non_nullable
as int,sexo: null == sexo ? _self.sexo : sexo // ignore: cast_nullable_to_non_nullable
as String,raza: null == raza ? _self.raza : raza // ignore: cast_nullable_to_non_nullable
as String,peso: null == peso ? _self.peso : peso // ignore: cast_nullable_to_non_nullable
as double,fechaNac: null == fechaNac ? _self.fechaNac : fechaNac // ignore: cast_nullable_to_non_nullable
as DateTime,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,pelaje: null == pelaje ? _self.pelaje : pelaje // ignore: cast_nullable_to_non_nullable
as String,idLote: freezed == idLote ? _self.idLote : idLote // ignore: cast_nullable_to_non_nullable
as int?,caravanaPadre: freezed == caravanaPadre ? _self.caravanaPadre : caravanaPadre // ignore: cast_nullable_to_non_nullable
as int?,caravanaMadre: freezed == caravanaMadre ? _self.caravanaMadre : caravanaMadre // ignore: cast_nullable_to_non_nullable
as int?,observaciones: freezed == observaciones ? _self.observaciones : observaciones // ignore: cast_nullable_to_non_nullable
as String?,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BrickAnimalModel].
extension BrickAnimalModelPatterns on BrickAnimalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrickAnimalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrickAnimalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrickAnimalModel value)  $default,){
final _that = this;
switch (_that) {
case _BrickAnimalModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrickAnimalModel value)?  $default,){
final _that = this;
switch (_that) {
case _BrickAnimalModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int nroCaravana,  String sexo,  String raza,  double peso,  DateTime fechaNac,  String categoria,  String pelaje,  int? idLote,  int? caravanaPadre,  int? caravanaMadre,  String? observaciones,  DateTime? syncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrickAnimalModel() when $default != null:
return $default(_that.nroCaravana,_that.sexo,_that.raza,_that.peso,_that.fechaNac,_that.categoria,_that.pelaje,_that.idLote,_that.caravanaPadre,_that.caravanaMadre,_that.observaciones,_that.syncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int nroCaravana,  String sexo,  String raza,  double peso,  DateTime fechaNac,  String categoria,  String pelaje,  int? idLote,  int? caravanaPadre,  int? caravanaMadre,  String? observaciones,  DateTime? syncedAt)  $default,) {final _that = this;
switch (_that) {
case _BrickAnimalModel():
return $default(_that.nroCaravana,_that.sexo,_that.raza,_that.peso,_that.fechaNac,_that.categoria,_that.pelaje,_that.idLote,_that.caravanaPadre,_that.caravanaMadre,_that.observaciones,_that.syncedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int nroCaravana,  String sexo,  String raza,  double peso,  DateTime fechaNac,  String categoria,  String pelaje,  int? idLote,  int? caravanaPadre,  int? caravanaMadre,  String? observaciones,  DateTime? syncedAt)?  $default,) {final _that = this;
switch (_that) {
case _BrickAnimalModel() when $default != null:
return $default(_that.nroCaravana,_that.sexo,_that.raza,_that.peso,_that.fechaNac,_that.categoria,_that.pelaje,_that.idLote,_that.caravanaPadre,_that.caravanaMadre,_that.observaciones,_that.syncedAt);case _:
  return null;

}
}

}

/// @nodoc


class _BrickAnimalModel implements BrickAnimalModel {
  const _BrickAnimalModel({required this.nroCaravana, required this.sexo, required this.raza, required this.peso, required this.fechaNac, required this.categoria, required this.pelaje, this.idLote, this.caravanaPadre, this.caravanaMadre, this.observaciones, this.syncedAt});
  

@override final  int nroCaravana;
@override final  String sexo;
@override final  String raza;
@override final  double peso;
@override final  DateTime fechaNac;
@override final  String categoria;
@override final  String pelaje;
@override final  int? idLote;
@override final  int? caravanaPadre;
@override final  int? caravanaMadre;
@override final  String? observaciones;
@override final  DateTime? syncedAt;

/// Create a copy of BrickAnimalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrickAnimalModelCopyWith<_BrickAnimalModel> get copyWith => __$BrickAnimalModelCopyWithImpl<_BrickAnimalModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrickAnimalModel&&(identical(other.nroCaravana, nroCaravana) || other.nroCaravana == nroCaravana)&&(identical(other.sexo, sexo) || other.sexo == sexo)&&(identical(other.raza, raza) || other.raza == raza)&&(identical(other.peso, peso) || other.peso == peso)&&(identical(other.fechaNac, fechaNac) || other.fechaNac == fechaNac)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.pelaje, pelaje) || other.pelaje == pelaje)&&(identical(other.idLote, idLote) || other.idLote == idLote)&&(identical(other.caravanaPadre, caravanaPadre) || other.caravanaPadre == caravanaPadre)&&(identical(other.caravanaMadre, caravanaMadre) || other.caravanaMadre == caravanaMadre)&&(identical(other.observaciones, observaciones) || other.observaciones == observaciones)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt));
}


@override
int get hashCode => Object.hash(runtimeType,nroCaravana,sexo,raza,peso,fechaNac,categoria,pelaje,idLote,caravanaPadre,caravanaMadre,observaciones,syncedAt);

@override
String toString() {
  return 'BrickAnimalModel(nroCaravana: $nroCaravana, sexo: $sexo, raza: $raza, peso: $peso, fechaNac: $fechaNac, categoria: $categoria, pelaje: $pelaje, idLote: $idLote, caravanaPadre: $caravanaPadre, caravanaMadre: $caravanaMadre, observaciones: $observaciones, syncedAt: $syncedAt)';
}


}

/// @nodoc
abstract mixin class _$BrickAnimalModelCopyWith<$Res> implements $BrickAnimalModelCopyWith<$Res> {
  factory _$BrickAnimalModelCopyWith(_BrickAnimalModel value, $Res Function(_BrickAnimalModel) _then) = __$BrickAnimalModelCopyWithImpl;
@override @useResult
$Res call({
 int nroCaravana, String sexo, String raza, double peso, DateTime fechaNac, String categoria, String pelaje, int? idLote, int? caravanaPadre, int? caravanaMadre, String? observaciones, DateTime? syncedAt
});




}
/// @nodoc
class __$BrickAnimalModelCopyWithImpl<$Res>
    implements _$BrickAnimalModelCopyWith<$Res> {
  __$BrickAnimalModelCopyWithImpl(this._self, this._then);

  final _BrickAnimalModel _self;
  final $Res Function(_BrickAnimalModel) _then;

/// Create a copy of BrickAnimalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nroCaravana = null,Object? sexo = null,Object? raza = null,Object? peso = null,Object? fechaNac = null,Object? categoria = null,Object? pelaje = null,Object? idLote = freezed,Object? caravanaPadre = freezed,Object? caravanaMadre = freezed,Object? observaciones = freezed,Object? syncedAt = freezed,}) {
  return _then(_BrickAnimalModel(
nroCaravana: null == nroCaravana ? _self.nroCaravana : nroCaravana // ignore: cast_nullable_to_non_nullable
as int,sexo: null == sexo ? _self.sexo : sexo // ignore: cast_nullable_to_non_nullable
as String,raza: null == raza ? _self.raza : raza // ignore: cast_nullable_to_non_nullable
as String,peso: null == peso ? _self.peso : peso // ignore: cast_nullable_to_non_nullable
as double,fechaNac: null == fechaNac ? _self.fechaNac : fechaNac // ignore: cast_nullable_to_non_nullable
as DateTime,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,pelaje: null == pelaje ? _self.pelaje : pelaje // ignore: cast_nullable_to_non_nullable
as String,idLote: freezed == idLote ? _self.idLote : idLote // ignore: cast_nullable_to_non_nullable
as int?,caravanaPadre: freezed == caravanaPadre ? _self.caravanaPadre : caravanaPadre // ignore: cast_nullable_to_non_nullable
as int?,caravanaMadre: freezed == caravanaMadre ? _self.caravanaMadre : caravanaMadre // ignore: cast_nullable_to_non_nullable
as int?,observaciones: freezed == observaciones ? _self.observaciones : observaciones // ignore: cast_nullable_to_non_nullable
as String?,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
