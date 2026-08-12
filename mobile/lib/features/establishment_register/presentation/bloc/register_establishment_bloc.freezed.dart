// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_establishment_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterEstablishmentEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterEstablishmentEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterEstablishmentEvent()';
}


}

/// @nodoc
class $RegisterEstablishmentEventCopyWith<$Res>  {
$RegisterEstablishmentEventCopyWith(RegisterEstablishmentEvent _, $Res Function(RegisterEstablishmentEvent) __);
}


/// Adds pattern-matching-related methods to [RegisterEstablishmentEvent].
extension RegisterEstablishmentEventPatterns on RegisterEstablishmentEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DraftChanged value)?  draftChanged,TResult Function( _NextStepRequested value)?  nextStepRequested,TResult Function( _PreviousStepRequested value)?  previousStepRequested,TResult Function( _StepRequested value)?  stepRequested,TResult Function( _SubmitRequested value)?  submitRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _StepRequested() when stepRequested != null:
return stepRequested(_that);case _SubmitRequested() when submitRequested != null:
return submitRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DraftChanged value)  draftChanged,required TResult Function( _NextStepRequested value)  nextStepRequested,required TResult Function( _PreviousStepRequested value)  previousStepRequested,required TResult Function( _StepRequested value)  stepRequested,required TResult Function( _SubmitRequested value)  submitRequested,}){
final _that = this;
switch (_that) {
case _DraftChanged():
return draftChanged(_that);case _NextStepRequested():
return nextStepRequested(_that);case _PreviousStepRequested():
return previousStepRequested(_that);case _StepRequested():
return stepRequested(_that);case _SubmitRequested():
return submitRequested(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DraftChanged value)?  draftChanged,TResult? Function( _NextStepRequested value)?  nextStepRequested,TResult? Function( _PreviousStepRequested value)?  previousStepRequested,TResult? Function( _StepRequested value)?  stepRequested,TResult? Function( _SubmitRequested value)?  submitRequested,}){
final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _StepRequested() when stepRequested != null:
return stepRequested(_that);case _SubmitRequested() when submitRequested != null:
return submitRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( RegisterEstablishmentDraft draft)?  draftChanged,TResult Function()?  nextStepRequested,TResult Function()?  previousStepRequested,TResult Function( RegisterEstablishmentStep step)?  stepRequested,TResult Function()?  submitRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _StepRequested() when stepRequested != null:
return stepRequested(_that.step);case _SubmitRequested() when submitRequested != null:
return submitRequested();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( RegisterEstablishmentDraft draft)  draftChanged,required TResult Function()  nextStepRequested,required TResult Function()  previousStepRequested,required TResult Function( RegisterEstablishmentStep step)  stepRequested,required TResult Function()  submitRequested,}) {final _that = this;
switch (_that) {
case _DraftChanged():
return draftChanged(_that.draft);case _NextStepRequested():
return nextStepRequested();case _PreviousStepRequested():
return previousStepRequested();case _StepRequested():
return stepRequested(_that.step);case _SubmitRequested():
return submitRequested();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( RegisterEstablishmentDraft draft)?  draftChanged,TResult? Function()?  nextStepRequested,TResult? Function()?  previousStepRequested,TResult? Function( RegisterEstablishmentStep step)?  stepRequested,TResult? Function()?  submitRequested,}) {final _that = this;
switch (_that) {
case _DraftChanged() when draftChanged != null:
return draftChanged(_that.draft);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _StepRequested() when stepRequested != null:
return stepRequested(_that.step);case _SubmitRequested() when submitRequested != null:
return submitRequested();case _:
  return null;

}
}

}

/// @nodoc


class _DraftChanged implements RegisterEstablishmentEvent {
  const _DraftChanged(this.draft);
  

 final  RegisterEstablishmentDraft draft;

/// Create a copy of RegisterEstablishmentEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftChangedCopyWith<_DraftChanged> get copyWith => __$DraftChangedCopyWithImpl<_DraftChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftChanged&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,draft);

@override
String toString() {
  return 'RegisterEstablishmentEvent.draftChanged(draft: $draft)';
}


}

/// @nodoc
abstract mixin class _$DraftChangedCopyWith<$Res> implements $RegisterEstablishmentEventCopyWith<$Res> {
  factory _$DraftChangedCopyWith(_DraftChanged value, $Res Function(_DraftChanged) _then) = __$DraftChangedCopyWithImpl;
@useResult
$Res call({
 RegisterEstablishmentDraft draft
});


$RegisterEstablishmentDraftCopyWith<$Res> get draft;

}
/// @nodoc
class __$DraftChangedCopyWithImpl<$Res>
    implements _$DraftChangedCopyWith<$Res> {
  __$DraftChangedCopyWithImpl(this._self, this._then);

  final _DraftChanged _self;
  final $Res Function(_DraftChanged) _then;

/// Create a copy of RegisterEstablishmentEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? draft = null,}) {
  return _then(_DraftChanged(
null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterEstablishmentDraft,
  ));
}

/// Create a copy of RegisterEstablishmentEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterEstablishmentDraftCopyWith<$Res> get draft {
  
  return $RegisterEstablishmentDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

/// @nodoc


class _NextStepRequested implements RegisterEstablishmentEvent {
  const _NextStepRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NextStepRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterEstablishmentEvent.nextStepRequested()';
}


}




/// @nodoc


class _PreviousStepRequested implements RegisterEstablishmentEvent {
  const _PreviousStepRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviousStepRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterEstablishmentEvent.previousStepRequested()';
}


}




/// @nodoc


class _StepRequested implements RegisterEstablishmentEvent {
  const _StepRequested(this.step);
  

 final  RegisterEstablishmentStep step;

/// Create a copy of RegisterEstablishmentEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepRequestedCopyWith<_StepRequested> get copyWith => __$StepRequestedCopyWithImpl<_StepRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StepRequested&&(identical(other.step, step) || other.step == step));
}


@override
int get hashCode => Object.hash(runtimeType,step);

@override
String toString() {
  return 'RegisterEstablishmentEvent.stepRequested(step: $step)';
}


}

/// @nodoc
abstract mixin class _$StepRequestedCopyWith<$Res> implements $RegisterEstablishmentEventCopyWith<$Res> {
  factory _$StepRequestedCopyWith(_StepRequested value, $Res Function(_StepRequested) _then) = __$StepRequestedCopyWithImpl;
@useResult
$Res call({
 RegisterEstablishmentStep step
});




}
/// @nodoc
class __$StepRequestedCopyWithImpl<$Res>
    implements _$StepRequestedCopyWith<$Res> {
  __$StepRequestedCopyWithImpl(this._self, this._then);

  final _StepRequested _self;
  final $Res Function(_StepRequested) _then;

/// Create a copy of RegisterEstablishmentEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? step = null,}) {
  return _then(_StepRequested(
null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as RegisterEstablishmentStep,
  ));
}


}

/// @nodoc


class _SubmitRequested implements RegisterEstablishmentEvent {
  const _SubmitRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegisterEstablishmentEvent.submitRequested()';
}


}




/// @nodoc
mixin _$RegisterEstablishmentDraft {

 String get nombre; String get descripcion; Set<String> get tiposProduccion; String get cuitTitular; String get nroRenspa; String get provincia; String get departamento; String get localidad; double get latitud; double get longitud; bool get ubicacionConfirmadaPorGps; double get superficieHectareas; int get cantidadVertices; int get cantidadUnidadesProductivas;
/// Create a copy of RegisterEstablishmentDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterEstablishmentDraftCopyWith<RegisterEstablishmentDraft> get copyWith => _$RegisterEstablishmentDraftCopyWithImpl<RegisterEstablishmentDraft>(this as RegisterEstablishmentDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterEstablishmentDraft&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.descripcion, descripcion) || other.descripcion == descripcion)&&const DeepCollectionEquality().equals(other.tiposProduccion, tiposProduccion)&&(identical(other.cuitTitular, cuitTitular) || other.cuitTitular == cuitTitular)&&(identical(other.nroRenspa, nroRenspa) || other.nroRenspa == nroRenspa)&&(identical(other.provincia, provincia) || other.provincia == provincia)&&(identical(other.departamento, departamento) || other.departamento == departamento)&&(identical(other.localidad, localidad) || other.localidad == localidad)&&(identical(other.latitud, latitud) || other.latitud == latitud)&&(identical(other.longitud, longitud) || other.longitud == longitud)&&(identical(other.ubicacionConfirmadaPorGps, ubicacionConfirmadaPorGps) || other.ubicacionConfirmadaPorGps == ubicacionConfirmadaPorGps)&&(identical(other.superficieHectareas, superficieHectareas) || other.superficieHectareas == superficieHectareas)&&(identical(other.cantidadVertices, cantidadVertices) || other.cantidadVertices == cantidadVertices)&&(identical(other.cantidadUnidadesProductivas, cantidadUnidadesProductivas) || other.cantidadUnidadesProductivas == cantidadUnidadesProductivas));
}


@override
int get hashCode => Object.hash(runtimeType,nombre,descripcion,const DeepCollectionEquality().hash(tiposProduccion),cuitTitular,nroRenspa,provincia,departamento,localidad,latitud,longitud,ubicacionConfirmadaPorGps,superficieHectareas,cantidadVertices,cantidadUnidadesProductivas);

@override
String toString() {
  return 'RegisterEstablishmentDraft(nombre: $nombre, descripcion: $descripcion, tiposProduccion: $tiposProduccion, cuitTitular: $cuitTitular, nroRenspa: $nroRenspa, provincia: $provincia, departamento: $departamento, localidad: $localidad, latitud: $latitud, longitud: $longitud, ubicacionConfirmadaPorGps: $ubicacionConfirmadaPorGps, superficieHectareas: $superficieHectareas, cantidadVertices: $cantidadVertices, cantidadUnidadesProductivas: $cantidadUnidadesProductivas)';
}


}

/// @nodoc
abstract mixin class $RegisterEstablishmentDraftCopyWith<$Res>  {
  factory $RegisterEstablishmentDraftCopyWith(RegisterEstablishmentDraft value, $Res Function(RegisterEstablishmentDraft) _then) = _$RegisterEstablishmentDraftCopyWithImpl;
@useResult
$Res call({
 String nombre, String descripcion, Set<String> tiposProduccion, String cuitTitular, String nroRenspa, String provincia, String departamento, String localidad, double latitud, double longitud, bool ubicacionConfirmadaPorGps, double superficieHectareas, int cantidadVertices, int cantidadUnidadesProductivas
});




}
/// @nodoc
class _$RegisterEstablishmentDraftCopyWithImpl<$Res>
    implements $RegisterEstablishmentDraftCopyWith<$Res> {
  _$RegisterEstablishmentDraftCopyWithImpl(this._self, this._then);

  final RegisterEstablishmentDraft _self;
  final $Res Function(RegisterEstablishmentDraft) _then;

/// Create a copy of RegisterEstablishmentDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nombre = null,Object? descripcion = null,Object? tiposProduccion = null,Object? cuitTitular = null,Object? nroRenspa = null,Object? provincia = null,Object? departamento = null,Object? localidad = null,Object? latitud = null,Object? longitud = null,Object? ubicacionConfirmadaPorGps = null,Object? superficieHectareas = null,Object? cantidadVertices = null,Object? cantidadUnidadesProductivas = null,}) {
  return _then(_self.copyWith(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,descripcion: null == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String,tiposProduccion: null == tiposProduccion ? _self.tiposProduccion : tiposProduccion // ignore: cast_nullable_to_non_nullable
as Set<String>,cuitTitular: null == cuitTitular ? _self.cuitTitular : cuitTitular // ignore: cast_nullable_to_non_nullable
as String,nroRenspa: null == nroRenspa ? _self.nroRenspa : nroRenspa // ignore: cast_nullable_to_non_nullable
as String,provincia: null == provincia ? _self.provincia : provincia // ignore: cast_nullable_to_non_nullable
as String,departamento: null == departamento ? _self.departamento : departamento // ignore: cast_nullable_to_non_nullable
as String,localidad: null == localidad ? _self.localidad : localidad // ignore: cast_nullable_to_non_nullable
as String,latitud: null == latitud ? _self.latitud : latitud // ignore: cast_nullable_to_non_nullable
as double,longitud: null == longitud ? _self.longitud : longitud // ignore: cast_nullable_to_non_nullable
as double,ubicacionConfirmadaPorGps: null == ubicacionConfirmadaPorGps ? _self.ubicacionConfirmadaPorGps : ubicacionConfirmadaPorGps // ignore: cast_nullable_to_non_nullable
as bool,superficieHectareas: null == superficieHectareas ? _self.superficieHectareas : superficieHectareas // ignore: cast_nullable_to_non_nullable
as double,cantidadVertices: null == cantidadVertices ? _self.cantidadVertices : cantidadVertices // ignore: cast_nullable_to_non_nullable
as int,cantidadUnidadesProductivas: null == cantidadUnidadesProductivas ? _self.cantidadUnidadesProductivas : cantidadUnidadesProductivas // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterEstablishmentDraft].
extension RegisterEstablishmentDraftPatterns on RegisterEstablishmentDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterEstablishmentDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterEstablishmentDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterEstablishmentDraft value)  $default,){
final _that = this;
switch (_that) {
case _RegisterEstablishmentDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterEstablishmentDraft value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterEstablishmentDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nombre,  String descripcion,  Set<String> tiposProduccion,  String cuitTitular,  String nroRenspa,  String provincia,  String departamento,  String localidad,  double latitud,  double longitud,  bool ubicacionConfirmadaPorGps,  double superficieHectareas,  int cantidadVertices,  int cantidadUnidadesProductivas)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterEstablishmentDraft() when $default != null:
return $default(_that.nombre,_that.descripcion,_that.tiposProduccion,_that.cuitTitular,_that.nroRenspa,_that.provincia,_that.departamento,_that.localidad,_that.latitud,_that.longitud,_that.ubicacionConfirmadaPorGps,_that.superficieHectareas,_that.cantidadVertices,_that.cantidadUnidadesProductivas);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nombre,  String descripcion,  Set<String> tiposProduccion,  String cuitTitular,  String nroRenspa,  String provincia,  String departamento,  String localidad,  double latitud,  double longitud,  bool ubicacionConfirmadaPorGps,  double superficieHectareas,  int cantidadVertices,  int cantidadUnidadesProductivas)  $default,) {final _that = this;
switch (_that) {
case _RegisterEstablishmentDraft():
return $default(_that.nombre,_that.descripcion,_that.tiposProduccion,_that.cuitTitular,_that.nroRenspa,_that.provincia,_that.departamento,_that.localidad,_that.latitud,_that.longitud,_that.ubicacionConfirmadaPorGps,_that.superficieHectareas,_that.cantidadVertices,_that.cantidadUnidadesProductivas);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nombre,  String descripcion,  Set<String> tiposProduccion,  String cuitTitular,  String nroRenspa,  String provincia,  String departamento,  String localidad,  double latitud,  double longitud,  bool ubicacionConfirmadaPorGps,  double superficieHectareas,  int cantidadVertices,  int cantidadUnidadesProductivas)?  $default,) {final _that = this;
switch (_that) {
case _RegisterEstablishmentDraft() when $default != null:
return $default(_that.nombre,_that.descripcion,_that.tiposProduccion,_that.cuitTitular,_that.nroRenspa,_that.provincia,_that.departamento,_that.localidad,_that.latitud,_that.longitud,_that.ubicacionConfirmadaPorGps,_that.superficieHectareas,_that.cantidadVertices,_that.cantidadUnidadesProductivas);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterEstablishmentDraft implements RegisterEstablishmentDraft {
  const _RegisterEstablishmentDraft({required this.nombre, required this.descripcion, required final  Set<String> tiposProduccion, required this.cuitTitular, required this.nroRenspa, required this.provincia, required this.departamento, required this.localidad, required this.latitud, required this.longitud, required this.ubicacionConfirmadaPorGps, required this.superficieHectareas, required this.cantidadVertices, required this.cantidadUnidadesProductivas}): _tiposProduccion = tiposProduccion;
  

@override final  String nombre;
@override final  String descripcion;
 final  Set<String> _tiposProduccion;
@override Set<String> get tiposProduccion {
  if (_tiposProduccion is EqualUnmodifiableSetView) return _tiposProduccion;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_tiposProduccion);
}

@override final  String cuitTitular;
@override final  String nroRenspa;
@override final  String provincia;
@override final  String departamento;
@override final  String localidad;
@override final  double latitud;
@override final  double longitud;
@override final  bool ubicacionConfirmadaPorGps;
@override final  double superficieHectareas;
@override final  int cantidadVertices;
@override final  int cantidadUnidadesProductivas;

/// Create a copy of RegisterEstablishmentDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterEstablishmentDraftCopyWith<_RegisterEstablishmentDraft> get copyWith => __$RegisterEstablishmentDraftCopyWithImpl<_RegisterEstablishmentDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterEstablishmentDraft&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.descripcion, descripcion) || other.descripcion == descripcion)&&const DeepCollectionEquality().equals(other._tiposProduccion, _tiposProduccion)&&(identical(other.cuitTitular, cuitTitular) || other.cuitTitular == cuitTitular)&&(identical(other.nroRenspa, nroRenspa) || other.nroRenspa == nroRenspa)&&(identical(other.provincia, provincia) || other.provincia == provincia)&&(identical(other.departamento, departamento) || other.departamento == departamento)&&(identical(other.localidad, localidad) || other.localidad == localidad)&&(identical(other.latitud, latitud) || other.latitud == latitud)&&(identical(other.longitud, longitud) || other.longitud == longitud)&&(identical(other.ubicacionConfirmadaPorGps, ubicacionConfirmadaPorGps) || other.ubicacionConfirmadaPorGps == ubicacionConfirmadaPorGps)&&(identical(other.superficieHectareas, superficieHectareas) || other.superficieHectareas == superficieHectareas)&&(identical(other.cantidadVertices, cantidadVertices) || other.cantidadVertices == cantidadVertices)&&(identical(other.cantidadUnidadesProductivas, cantidadUnidadesProductivas) || other.cantidadUnidadesProductivas == cantidadUnidadesProductivas));
}


@override
int get hashCode => Object.hash(runtimeType,nombre,descripcion,const DeepCollectionEquality().hash(_tiposProduccion),cuitTitular,nroRenspa,provincia,departamento,localidad,latitud,longitud,ubicacionConfirmadaPorGps,superficieHectareas,cantidadVertices,cantidadUnidadesProductivas);

@override
String toString() {
  return 'RegisterEstablishmentDraft(nombre: $nombre, descripcion: $descripcion, tiposProduccion: $tiposProduccion, cuitTitular: $cuitTitular, nroRenspa: $nroRenspa, provincia: $provincia, departamento: $departamento, localidad: $localidad, latitud: $latitud, longitud: $longitud, ubicacionConfirmadaPorGps: $ubicacionConfirmadaPorGps, superficieHectareas: $superficieHectareas, cantidadVertices: $cantidadVertices, cantidadUnidadesProductivas: $cantidadUnidadesProductivas)';
}


}

/// @nodoc
abstract mixin class _$RegisterEstablishmentDraftCopyWith<$Res> implements $RegisterEstablishmentDraftCopyWith<$Res> {
  factory _$RegisterEstablishmentDraftCopyWith(_RegisterEstablishmentDraft value, $Res Function(_RegisterEstablishmentDraft) _then) = __$RegisterEstablishmentDraftCopyWithImpl;
@override @useResult
$Res call({
 String nombre, String descripcion, Set<String> tiposProduccion, String cuitTitular, String nroRenspa, String provincia, String departamento, String localidad, double latitud, double longitud, bool ubicacionConfirmadaPorGps, double superficieHectareas, int cantidadVertices, int cantidadUnidadesProductivas
});




}
/// @nodoc
class __$RegisterEstablishmentDraftCopyWithImpl<$Res>
    implements _$RegisterEstablishmentDraftCopyWith<$Res> {
  __$RegisterEstablishmentDraftCopyWithImpl(this._self, this._then);

  final _RegisterEstablishmentDraft _self;
  final $Res Function(_RegisterEstablishmentDraft) _then;

/// Create a copy of RegisterEstablishmentDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nombre = null,Object? descripcion = null,Object? tiposProduccion = null,Object? cuitTitular = null,Object? nroRenspa = null,Object? provincia = null,Object? departamento = null,Object? localidad = null,Object? latitud = null,Object? longitud = null,Object? ubicacionConfirmadaPorGps = null,Object? superficieHectareas = null,Object? cantidadVertices = null,Object? cantidadUnidadesProductivas = null,}) {
  return _then(_RegisterEstablishmentDraft(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,descripcion: null == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String,tiposProduccion: null == tiposProduccion ? _self._tiposProduccion : tiposProduccion // ignore: cast_nullable_to_non_nullable
as Set<String>,cuitTitular: null == cuitTitular ? _self.cuitTitular : cuitTitular // ignore: cast_nullable_to_non_nullable
as String,nroRenspa: null == nroRenspa ? _self.nroRenspa : nroRenspa // ignore: cast_nullable_to_non_nullable
as String,provincia: null == provincia ? _self.provincia : provincia // ignore: cast_nullable_to_non_nullable
as String,departamento: null == departamento ? _self.departamento : departamento // ignore: cast_nullable_to_non_nullable
as String,localidad: null == localidad ? _self.localidad : localidad // ignore: cast_nullable_to_non_nullable
as String,latitud: null == latitud ? _self.latitud : latitud // ignore: cast_nullable_to_non_nullable
as double,longitud: null == longitud ? _self.longitud : longitud // ignore: cast_nullable_to_non_nullable
as double,ubicacionConfirmadaPorGps: null == ubicacionConfirmadaPorGps ? _self.ubicacionConfirmadaPorGps : ubicacionConfirmadaPorGps // ignore: cast_nullable_to_non_nullable
as bool,superficieHectareas: null == superficieHectareas ? _self.superficieHectareas : superficieHectareas // ignore: cast_nullable_to_non_nullable
as double,cantidadVertices: null == cantidadVertices ? _self.cantidadVertices : cantidadVertices // ignore: cast_nullable_to_non_nullable
as int,cantidadUnidadesProductivas: null == cantidadUnidadesProductivas ? _self.cantidadUnidadesProductivas : cantidadUnidadesProductivas // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$RegisterEstablishmentState {

 RegisterEstablishmentStep get currentStep; RegisterEstablishmentDraft get draft; ResultState<RegisteredEstablishment> get submitResult;
/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterEstablishmentStateCopyWith<RegisterEstablishmentState> get copyWith => _$RegisterEstablishmentStateCopyWithImpl<RegisterEstablishmentState>(this as RegisterEstablishmentState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterEstablishmentState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.submitResult, submitResult) || other.submitResult == submitResult));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,draft,submitResult);

@override
String toString() {
  return 'RegisterEstablishmentState(currentStep: $currentStep, draft: $draft, submitResult: $submitResult)';
}


}

/// @nodoc
abstract mixin class $RegisterEstablishmentStateCopyWith<$Res>  {
  factory $RegisterEstablishmentStateCopyWith(RegisterEstablishmentState value, $Res Function(RegisterEstablishmentState) _then) = _$RegisterEstablishmentStateCopyWithImpl;
@useResult
$Res call({
 RegisterEstablishmentStep currentStep, RegisterEstablishmentDraft draft, ResultState<RegisteredEstablishment> submitResult
});


$RegisterEstablishmentDraftCopyWith<$Res> get draft;$ResultStateCopyWith<RegisteredEstablishment, $Res> get submitResult;

}
/// @nodoc
class _$RegisterEstablishmentStateCopyWithImpl<$Res>
    implements $RegisterEstablishmentStateCopyWith<$Res> {
  _$RegisterEstablishmentStateCopyWithImpl(this._self, this._then);

  final RegisterEstablishmentState _self;
  final $Res Function(RegisterEstablishmentState) _then;

/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? draft = null,Object? submitResult = null,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RegisterEstablishmentStep,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterEstablishmentDraft,submitResult: null == submitResult ? _self.submitResult : submitResult // ignore: cast_nullable_to_non_nullable
as ResultState<RegisteredEstablishment>,
  ));
}
/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterEstablishmentDraftCopyWith<$Res> get draft {
  
  return $RegisterEstablishmentDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<RegisteredEstablishment, $Res> get submitResult {
  
  return $ResultStateCopyWith<RegisteredEstablishment, $Res>(_self.submitResult, (value) {
    return _then(_self.copyWith(submitResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [RegisterEstablishmentState].
extension RegisterEstablishmentStatePatterns on RegisterEstablishmentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterEstablishmentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterEstablishmentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterEstablishmentState value)  $default,){
final _that = this;
switch (_that) {
case _RegisterEstablishmentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterEstablishmentState value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterEstablishmentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegisterEstablishmentStep currentStep,  RegisterEstablishmentDraft draft,  ResultState<RegisteredEstablishment> submitResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterEstablishmentState() when $default != null:
return $default(_that.currentStep,_that.draft,_that.submitResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegisterEstablishmentStep currentStep,  RegisterEstablishmentDraft draft,  ResultState<RegisteredEstablishment> submitResult)  $default,) {final _that = this;
switch (_that) {
case _RegisterEstablishmentState():
return $default(_that.currentStep,_that.draft,_that.submitResult);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegisterEstablishmentStep currentStep,  RegisterEstablishmentDraft draft,  ResultState<RegisteredEstablishment> submitResult)?  $default,) {final _that = this;
switch (_that) {
case _RegisterEstablishmentState() when $default != null:
return $default(_that.currentStep,_that.draft,_that.submitResult);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterEstablishmentState implements RegisterEstablishmentState {
  const _RegisterEstablishmentState({required this.currentStep, required this.draft, this.submitResult = const ResultState<RegisteredEstablishment>.initial()});
  

@override final  RegisterEstablishmentStep currentStep;
@override final  RegisterEstablishmentDraft draft;
@override@JsonKey() final  ResultState<RegisteredEstablishment> submitResult;

/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterEstablishmentStateCopyWith<_RegisterEstablishmentState> get copyWith => __$RegisterEstablishmentStateCopyWithImpl<_RegisterEstablishmentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterEstablishmentState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.submitResult, submitResult) || other.submitResult == submitResult));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,draft,submitResult);

@override
String toString() {
  return 'RegisterEstablishmentState(currentStep: $currentStep, draft: $draft, submitResult: $submitResult)';
}


}

/// @nodoc
abstract mixin class _$RegisterEstablishmentStateCopyWith<$Res> implements $RegisterEstablishmentStateCopyWith<$Res> {
  factory _$RegisterEstablishmentStateCopyWith(_RegisterEstablishmentState value, $Res Function(_RegisterEstablishmentState) _then) = __$RegisterEstablishmentStateCopyWithImpl;
@override @useResult
$Res call({
 RegisterEstablishmentStep currentStep, RegisterEstablishmentDraft draft, ResultState<RegisteredEstablishment> submitResult
});


@override $RegisterEstablishmentDraftCopyWith<$Res> get draft;@override $ResultStateCopyWith<RegisteredEstablishment, $Res> get submitResult;

}
/// @nodoc
class __$RegisterEstablishmentStateCopyWithImpl<$Res>
    implements _$RegisterEstablishmentStateCopyWith<$Res> {
  __$RegisterEstablishmentStateCopyWithImpl(this._self, this._then);

  final _RegisterEstablishmentState _self;
  final $Res Function(_RegisterEstablishmentState) _then;

/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? draft = null,Object? submitResult = null,}) {
  return _then(_RegisterEstablishmentState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as RegisterEstablishmentStep,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as RegisterEstablishmentDraft,submitResult: null == submitResult ? _self.submitResult : submitResult // ignore: cast_nullable_to_non_nullable
as ResultState<RegisteredEstablishment>,
  ));
}

/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RegisterEstablishmentDraftCopyWith<$Res> get draft {
  
  return $RegisterEstablishmentDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of RegisterEstablishmentState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<RegisteredEstablishment, $Res> get submitResult {
  
  return $ResultStateCopyWith<RegisteredEstablishment, $Res>(_self.submitResult, (value) {
    return _then(_self.copyWith(submitResult: value));
  });
}
}

// dart format on
