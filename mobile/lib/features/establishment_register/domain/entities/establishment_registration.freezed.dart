// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'establishment_registration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EstablishmentRegistration {

 String get nombre; String get descripcion; List<String> get tiposProduccion; String get cuitTitular; String get nroRenspa; String get provincia; String get departamento; String get localidad; double get latitud; double get longitud; double get superficieHectareas; int get cantidadVertices;
/// Create a copy of EstablishmentRegistration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EstablishmentRegistrationCopyWith<EstablishmentRegistration> get copyWith => _$EstablishmentRegistrationCopyWithImpl<EstablishmentRegistration>(this as EstablishmentRegistration, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EstablishmentRegistration&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.descripcion, descripcion) || other.descripcion == descripcion)&&const DeepCollectionEquality().equals(other.tiposProduccion, tiposProduccion)&&(identical(other.cuitTitular, cuitTitular) || other.cuitTitular == cuitTitular)&&(identical(other.nroRenspa, nroRenspa) || other.nroRenspa == nroRenspa)&&(identical(other.provincia, provincia) || other.provincia == provincia)&&(identical(other.departamento, departamento) || other.departamento == departamento)&&(identical(other.localidad, localidad) || other.localidad == localidad)&&(identical(other.latitud, latitud) || other.latitud == latitud)&&(identical(other.longitud, longitud) || other.longitud == longitud)&&(identical(other.superficieHectareas, superficieHectareas) || other.superficieHectareas == superficieHectareas)&&(identical(other.cantidadVertices, cantidadVertices) || other.cantidadVertices == cantidadVertices));
}


@override
int get hashCode => Object.hash(runtimeType,nombre,descripcion,const DeepCollectionEquality().hash(tiposProduccion),cuitTitular,nroRenspa,provincia,departamento,localidad,latitud,longitud,superficieHectareas,cantidadVertices);

@override
String toString() {
  return 'EstablishmentRegistration(nombre: $nombre, descripcion: $descripcion, tiposProduccion: $tiposProduccion, cuitTitular: $cuitTitular, nroRenspa: $nroRenspa, provincia: $provincia, departamento: $departamento, localidad: $localidad, latitud: $latitud, longitud: $longitud, superficieHectareas: $superficieHectareas, cantidadVertices: $cantidadVertices)';
}


}

/// @nodoc
abstract mixin class $EstablishmentRegistrationCopyWith<$Res>  {
  factory $EstablishmentRegistrationCopyWith(EstablishmentRegistration value, $Res Function(EstablishmentRegistration) _then) = _$EstablishmentRegistrationCopyWithImpl;
@useResult
$Res call({
 String nombre, String descripcion, List<String> tiposProduccion, String cuitTitular, String nroRenspa, String provincia, String departamento, String localidad, double latitud, double longitud, double superficieHectareas, int cantidadVertices
});




}
/// @nodoc
class _$EstablishmentRegistrationCopyWithImpl<$Res>
    implements $EstablishmentRegistrationCopyWith<$Res> {
  _$EstablishmentRegistrationCopyWithImpl(this._self, this._then);

  final EstablishmentRegistration _self;
  final $Res Function(EstablishmentRegistration) _then;

/// Create a copy of EstablishmentRegistration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nombre = null,Object? descripcion = null,Object? tiposProduccion = null,Object? cuitTitular = null,Object? nroRenspa = null,Object? provincia = null,Object? departamento = null,Object? localidad = null,Object? latitud = null,Object? longitud = null,Object? superficieHectareas = null,Object? cantidadVertices = null,}) {
  return _then(_self.copyWith(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,descripcion: null == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String,tiposProduccion: null == tiposProduccion ? _self.tiposProduccion : tiposProduccion // ignore: cast_nullable_to_non_nullable
as List<String>,cuitTitular: null == cuitTitular ? _self.cuitTitular : cuitTitular // ignore: cast_nullable_to_non_nullable
as String,nroRenspa: null == nroRenspa ? _self.nroRenspa : nroRenspa // ignore: cast_nullable_to_non_nullable
as String,provincia: null == provincia ? _self.provincia : provincia // ignore: cast_nullable_to_non_nullable
as String,departamento: null == departamento ? _self.departamento : departamento // ignore: cast_nullable_to_non_nullable
as String,localidad: null == localidad ? _self.localidad : localidad // ignore: cast_nullable_to_non_nullable
as String,latitud: null == latitud ? _self.latitud : latitud // ignore: cast_nullable_to_non_nullable
as double,longitud: null == longitud ? _self.longitud : longitud // ignore: cast_nullable_to_non_nullable
as double,superficieHectareas: null == superficieHectareas ? _self.superficieHectareas : superficieHectareas // ignore: cast_nullable_to_non_nullable
as double,cantidadVertices: null == cantidadVertices ? _self.cantidadVertices : cantidadVertices // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EstablishmentRegistration].
extension EstablishmentRegistrationPatterns on EstablishmentRegistration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EstablishmentRegistration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EstablishmentRegistration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EstablishmentRegistration value)  $default,){
final _that = this;
switch (_that) {
case _EstablishmentRegistration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EstablishmentRegistration value)?  $default,){
final _that = this;
switch (_that) {
case _EstablishmentRegistration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nombre,  String descripcion,  List<String> tiposProduccion,  String cuitTitular,  String nroRenspa,  String provincia,  String departamento,  String localidad,  double latitud,  double longitud,  double superficieHectareas,  int cantidadVertices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EstablishmentRegistration() when $default != null:
return $default(_that.nombre,_that.descripcion,_that.tiposProduccion,_that.cuitTitular,_that.nroRenspa,_that.provincia,_that.departamento,_that.localidad,_that.latitud,_that.longitud,_that.superficieHectareas,_that.cantidadVertices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nombre,  String descripcion,  List<String> tiposProduccion,  String cuitTitular,  String nroRenspa,  String provincia,  String departamento,  String localidad,  double latitud,  double longitud,  double superficieHectareas,  int cantidadVertices)  $default,) {final _that = this;
switch (_that) {
case _EstablishmentRegistration():
return $default(_that.nombre,_that.descripcion,_that.tiposProduccion,_that.cuitTitular,_that.nroRenspa,_that.provincia,_that.departamento,_that.localidad,_that.latitud,_that.longitud,_that.superficieHectareas,_that.cantidadVertices);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nombre,  String descripcion,  List<String> tiposProduccion,  String cuitTitular,  String nroRenspa,  String provincia,  String departamento,  String localidad,  double latitud,  double longitud,  double superficieHectareas,  int cantidadVertices)?  $default,) {final _that = this;
switch (_that) {
case _EstablishmentRegistration() when $default != null:
return $default(_that.nombre,_that.descripcion,_that.tiposProduccion,_that.cuitTitular,_that.nroRenspa,_that.provincia,_that.departamento,_that.localidad,_that.latitud,_that.longitud,_that.superficieHectareas,_that.cantidadVertices);case _:
  return null;

}
}

}

/// @nodoc


class _EstablishmentRegistration implements EstablishmentRegistration {
  const _EstablishmentRegistration({required this.nombre, required this.descripcion, required final  List<String> tiposProduccion, required this.cuitTitular, required this.nroRenspa, required this.provincia, required this.departamento, required this.localidad, required this.latitud, required this.longitud, required this.superficieHectareas, required this.cantidadVertices}): _tiposProduccion = tiposProduccion;
  

@override final  String nombre;
@override final  String descripcion;
 final  List<String> _tiposProduccion;
@override List<String> get tiposProduccion {
  if (_tiposProduccion is EqualUnmodifiableListView) return _tiposProduccion;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tiposProduccion);
}

@override final  String cuitTitular;
@override final  String nroRenspa;
@override final  String provincia;
@override final  String departamento;
@override final  String localidad;
@override final  double latitud;
@override final  double longitud;
@override final  double superficieHectareas;
@override final  int cantidadVertices;

/// Create a copy of EstablishmentRegistration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EstablishmentRegistrationCopyWith<_EstablishmentRegistration> get copyWith => __$EstablishmentRegistrationCopyWithImpl<_EstablishmentRegistration>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EstablishmentRegistration&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.descripcion, descripcion) || other.descripcion == descripcion)&&const DeepCollectionEquality().equals(other._tiposProduccion, _tiposProduccion)&&(identical(other.cuitTitular, cuitTitular) || other.cuitTitular == cuitTitular)&&(identical(other.nroRenspa, nroRenspa) || other.nroRenspa == nroRenspa)&&(identical(other.provincia, provincia) || other.provincia == provincia)&&(identical(other.departamento, departamento) || other.departamento == departamento)&&(identical(other.localidad, localidad) || other.localidad == localidad)&&(identical(other.latitud, latitud) || other.latitud == latitud)&&(identical(other.longitud, longitud) || other.longitud == longitud)&&(identical(other.superficieHectareas, superficieHectareas) || other.superficieHectareas == superficieHectareas)&&(identical(other.cantidadVertices, cantidadVertices) || other.cantidadVertices == cantidadVertices));
}


@override
int get hashCode => Object.hash(runtimeType,nombre,descripcion,const DeepCollectionEquality().hash(_tiposProduccion),cuitTitular,nroRenspa,provincia,departamento,localidad,latitud,longitud,superficieHectareas,cantidadVertices);

@override
String toString() {
  return 'EstablishmentRegistration(nombre: $nombre, descripcion: $descripcion, tiposProduccion: $tiposProduccion, cuitTitular: $cuitTitular, nroRenspa: $nroRenspa, provincia: $provincia, departamento: $departamento, localidad: $localidad, latitud: $latitud, longitud: $longitud, superficieHectareas: $superficieHectareas, cantidadVertices: $cantidadVertices)';
}


}

/// @nodoc
abstract mixin class _$EstablishmentRegistrationCopyWith<$Res> implements $EstablishmentRegistrationCopyWith<$Res> {
  factory _$EstablishmentRegistrationCopyWith(_EstablishmentRegistration value, $Res Function(_EstablishmentRegistration) _then) = __$EstablishmentRegistrationCopyWithImpl;
@override @useResult
$Res call({
 String nombre, String descripcion, List<String> tiposProduccion, String cuitTitular, String nroRenspa, String provincia, String departamento, String localidad, double latitud, double longitud, double superficieHectareas, int cantidadVertices
});




}
/// @nodoc
class __$EstablishmentRegistrationCopyWithImpl<$Res>
    implements _$EstablishmentRegistrationCopyWith<$Res> {
  __$EstablishmentRegistrationCopyWithImpl(this._self, this._then);

  final _EstablishmentRegistration _self;
  final $Res Function(_EstablishmentRegistration) _then;

/// Create a copy of EstablishmentRegistration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nombre = null,Object? descripcion = null,Object? tiposProduccion = null,Object? cuitTitular = null,Object? nroRenspa = null,Object? provincia = null,Object? departamento = null,Object? localidad = null,Object? latitud = null,Object? longitud = null,Object? superficieHectareas = null,Object? cantidadVertices = null,}) {
  return _then(_EstablishmentRegistration(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,descripcion: null == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String,tiposProduccion: null == tiposProduccion ? _self._tiposProduccion : tiposProduccion // ignore: cast_nullable_to_non_nullable
as List<String>,cuitTitular: null == cuitTitular ? _self.cuitTitular : cuitTitular // ignore: cast_nullable_to_non_nullable
as String,nroRenspa: null == nroRenspa ? _self.nroRenspa : nroRenspa // ignore: cast_nullable_to_non_nullable
as String,provincia: null == provincia ? _self.provincia : provincia // ignore: cast_nullable_to_non_nullable
as String,departamento: null == departamento ? _self.departamento : departamento // ignore: cast_nullable_to_non_nullable
as String,localidad: null == localidad ? _self.localidad : localidad // ignore: cast_nullable_to_non_nullable
as String,latitud: null == latitud ? _self.latitud : latitud // ignore: cast_nullable_to_non_nullable
as double,longitud: null == longitud ? _self.longitud : longitud // ignore: cast_nullable_to_non_nullable
as double,superficieHectareas: null == superficieHectareas ? _self.superficieHectareas : superficieHectareas // ignore: cast_nullable_to_non_nullable
as double,cantidadVertices: null == cantidadVertices ? _self.cantidadVertices : cantidadVertices // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RegisteredEstablishment {

 String get id; EstablishmentRegistration get registration; DateTime get createdAt; UserRole get role;
/// Create a copy of RegisteredEstablishment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisteredEstablishmentCopyWith<RegisteredEstablishment> get copyWith => _$RegisteredEstablishmentCopyWithImpl<RegisteredEstablishment>(this as RegisteredEstablishment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisteredEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,id,registration,createdAt,role);

@override
String toString() {
  return 'RegisteredEstablishment(id: $id, registration: $registration, createdAt: $createdAt, role: $role)';
}


}

/// @nodoc
abstract mixin class $RegisteredEstablishmentCopyWith<$Res>  {
  factory $RegisteredEstablishmentCopyWith(RegisteredEstablishment value, $Res Function(RegisteredEstablishment) _then) = _$RegisteredEstablishmentCopyWithImpl;
@useResult
$Res call({
 String id, EstablishmentRegistration registration, DateTime createdAt, UserRole role
});


$EstablishmentRegistrationCopyWith<$Res> get registration;

}
/// @nodoc
class _$RegisteredEstablishmentCopyWithImpl<$Res>
    implements $RegisteredEstablishmentCopyWith<$Res> {
  _$RegisteredEstablishmentCopyWithImpl(this._self, this._then);

  final RegisteredEstablishment _self;
  final $Res Function(RegisteredEstablishment) _then;

/// Create a copy of RegisteredEstablishment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? registration = null,Object? createdAt = null,Object? role = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,registration: null == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as EstablishmentRegistration,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}
/// Create a copy of RegisteredEstablishment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstablishmentRegistrationCopyWith<$Res> get registration {
  
  return $EstablishmentRegistrationCopyWith<$Res>(_self.registration, (value) {
    return _then(_self.copyWith(registration: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegisteredEstablishment].
extension RegisteredEstablishmentPatterns on RegisteredEstablishment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisteredEstablishment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisteredEstablishment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisteredEstablishment value)  $default,){
final _that = this;
switch (_that) {
case _RegisteredEstablishment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisteredEstablishment value)?  $default,){
final _that = this;
switch (_that) {
case _RegisteredEstablishment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  EstablishmentRegistration registration,  DateTime createdAt,  UserRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisteredEstablishment() when $default != null:
return $default(_that.id,_that.registration,_that.createdAt,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  EstablishmentRegistration registration,  DateTime createdAt,  UserRole role)  $default,) {final _that = this;
switch (_that) {
case _RegisteredEstablishment():
return $default(_that.id,_that.registration,_that.createdAt,_that.role);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  EstablishmentRegistration registration,  DateTime createdAt,  UserRole role)?  $default,) {final _that = this;
switch (_that) {
case _RegisteredEstablishment() when $default != null:
return $default(_that.id,_that.registration,_that.createdAt,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _RegisteredEstablishment implements RegisteredEstablishment {
  const _RegisteredEstablishment({required this.id, required this.registration, required this.createdAt, required this.role});
  

@override final  String id;
@override final  EstablishmentRegistration registration;
@override final  DateTime createdAt;
@override final  UserRole role;

/// Create a copy of RegisteredEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisteredEstablishmentCopyWith<_RegisteredEstablishment> get copyWith => __$RegisteredEstablishmentCopyWithImpl<_RegisteredEstablishment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisteredEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.registration, registration) || other.registration == registration)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,id,registration,createdAt,role);

@override
String toString() {
  return 'RegisteredEstablishment(id: $id, registration: $registration, createdAt: $createdAt, role: $role)';
}


}

/// @nodoc
abstract mixin class _$RegisteredEstablishmentCopyWith<$Res> implements $RegisteredEstablishmentCopyWith<$Res> {
  factory _$RegisteredEstablishmentCopyWith(_RegisteredEstablishment value, $Res Function(_RegisteredEstablishment) _then) = __$RegisteredEstablishmentCopyWithImpl;
@override @useResult
$Res call({
 String id, EstablishmentRegistration registration, DateTime createdAt, UserRole role
});


@override $EstablishmentRegistrationCopyWith<$Res> get registration;

}
/// @nodoc
class __$RegisteredEstablishmentCopyWithImpl<$Res>
    implements _$RegisteredEstablishmentCopyWith<$Res> {
  __$RegisteredEstablishmentCopyWithImpl(this._self, this._then);

  final _RegisteredEstablishment _self;
  final $Res Function(_RegisteredEstablishment) _then;

/// Create a copy of RegisteredEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? registration = null,Object? createdAt = null,Object? role = null,}) {
  return _then(_RegisteredEstablishment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,registration: null == registration ? _self.registration : registration // ignore: cast_nullable_to_non_nullable
as EstablishmentRegistration,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,
  ));
}

/// Create a copy of RegisteredEstablishment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EstablishmentRegistrationCopyWith<$Res> get registration {
  
  return $EstablishmentRegistrationCopyWith<$Res>(_self.registration, (value) {
    return _then(_self.copyWith(registration: value));
  });
}
}

// dart format on
