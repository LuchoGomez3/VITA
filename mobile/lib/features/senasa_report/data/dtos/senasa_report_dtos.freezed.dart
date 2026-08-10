// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'senasa_report_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SenasaReportRequestDto {

@JsonKey(name: 'establecimientoId') String get establishmentId;@JsonKey(name: 'desde') String get from;@JsonKey(name: 'hasta') String get to;@JsonKey(name: 'nombreArchivo') String get filename;
/// Create a copy of SenasaReportRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaReportRequestDtoCopyWith<SenasaReportRequestDto> get copyWith => _$SenasaReportRequestDtoCopyWithImpl<SenasaReportRequestDto>(this as SenasaReportRequestDto, _$identity);

  /// Serializes this SenasaReportRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaReportRequestDto&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.filename, filename) || other.filename == filename));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,establishmentId,from,to,filename);

@override
String toString() {
  return 'SenasaReportRequestDto(establishmentId: $establishmentId, from: $from, to: $to, filename: $filename)';
}


}

/// @nodoc
abstract mixin class $SenasaReportRequestDtoCopyWith<$Res>  {
  factory $SenasaReportRequestDtoCopyWith(SenasaReportRequestDto value, $Res Function(SenasaReportRequestDto) _then) = _$SenasaReportRequestDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'establecimientoId') String establishmentId,@JsonKey(name: 'desde') String from,@JsonKey(name: 'hasta') String to,@JsonKey(name: 'nombreArchivo') String filename
});




}
/// @nodoc
class _$SenasaReportRequestDtoCopyWithImpl<$Res>
    implements $SenasaReportRequestDtoCopyWith<$Res> {
  _$SenasaReportRequestDtoCopyWithImpl(this._self, this._then);

  final SenasaReportRequestDto _self;
  final $Res Function(SenasaReportRequestDto) _then;

/// Create a copy of SenasaReportRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? from = null,Object? to = null,Object? filename = null,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaReportRequestDto].
extension SenasaReportRequestDtoPatterns on SenasaReportRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaReportRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaReportRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaReportRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _SenasaReportRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaReportRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaReportRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'establecimientoId')  String establishmentId, @JsonKey(name: 'desde')  String from, @JsonKey(name: 'hasta')  String to, @JsonKey(name: 'nombreArchivo')  String filename)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaReportRequestDto() when $default != null:
return $default(_that.establishmentId,_that.from,_that.to,_that.filename);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'establecimientoId')  String establishmentId, @JsonKey(name: 'desde')  String from, @JsonKey(name: 'hasta')  String to, @JsonKey(name: 'nombreArchivo')  String filename)  $default,) {final _that = this;
switch (_that) {
case _SenasaReportRequestDto():
return $default(_that.establishmentId,_that.from,_that.to,_that.filename);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'establecimientoId')  String establishmentId, @JsonKey(name: 'desde')  String from, @JsonKey(name: 'hasta')  String to, @JsonKey(name: 'nombreArchivo')  String filename)?  $default,) {final _that = this;
switch (_that) {
case _SenasaReportRequestDto() when $default != null:
return $default(_that.establishmentId,_that.from,_that.to,_that.filename);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SenasaReportRequestDto implements SenasaReportRequestDto {
  const _SenasaReportRequestDto({@JsonKey(name: 'establecimientoId') required this.establishmentId, @JsonKey(name: 'desde') required this.from, @JsonKey(name: 'hasta') required this.to, @JsonKey(name: 'nombreArchivo') required this.filename});
  factory _SenasaReportRequestDto.fromJson(Map<String, dynamic> json) => _$SenasaReportRequestDtoFromJson(json);

@override@JsonKey(name: 'establecimientoId') final  String establishmentId;
@override@JsonKey(name: 'desde') final  String from;
@override@JsonKey(name: 'hasta') final  String to;
@override@JsonKey(name: 'nombreArchivo') final  String filename;

/// Create a copy of SenasaReportRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaReportRequestDtoCopyWith<_SenasaReportRequestDto> get copyWith => __$SenasaReportRequestDtoCopyWithImpl<_SenasaReportRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenasaReportRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaReportRequestDto&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.filename, filename) || other.filename == filename));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,establishmentId,from,to,filename);

@override
String toString() {
  return 'SenasaReportRequestDto(establishmentId: $establishmentId, from: $from, to: $to, filename: $filename)';
}


}

/// @nodoc
abstract mixin class _$SenasaReportRequestDtoCopyWith<$Res> implements $SenasaReportRequestDtoCopyWith<$Res> {
  factory _$SenasaReportRequestDtoCopyWith(_SenasaReportRequestDto value, $Res Function(_SenasaReportRequestDto) _then) = __$SenasaReportRequestDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'establecimientoId') String establishmentId,@JsonKey(name: 'desde') String from,@JsonKey(name: 'hasta') String to,@JsonKey(name: 'nombreArchivo') String filename
});




}
/// @nodoc
class __$SenasaReportRequestDtoCopyWithImpl<$Res>
    implements _$SenasaReportRequestDtoCopyWith<$Res> {
  __$SenasaReportRequestDtoCopyWithImpl(this._self, this._then);

  final _SenasaReportRequestDto _self;
  final $Res Function(_SenasaReportRequestDto) _then;

/// Create a copy of SenasaReportRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? from = null,Object? to = null,Object? filename = null,}) {
  return _then(_SenasaReportRequestDto(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SenasaEstablishmentDto {

 String get id; String get name;@JsonKey(name: 'renspa_number') String? get renspa;
/// Create a copy of SenasaEstablishmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaEstablishmentDtoCopyWith<SenasaEstablishmentDto> get copyWith => _$SenasaEstablishmentDtoCopyWithImpl<SenasaEstablishmentDto>(this as SenasaEstablishmentDto, _$identity);

  /// Serializes this SenasaEstablishmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaEstablishmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.renspa, renspa) || other.renspa == renspa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,renspa);

@override
String toString() {
  return 'SenasaEstablishmentDto(id: $id, name: $name, renspa: $renspa)';
}


}

/// @nodoc
abstract mixin class $SenasaEstablishmentDtoCopyWith<$Res>  {
  factory $SenasaEstablishmentDtoCopyWith(SenasaEstablishmentDto value, $Res Function(SenasaEstablishmentDto) _then) = _$SenasaEstablishmentDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'renspa_number') String? renspa
});




}
/// @nodoc
class _$SenasaEstablishmentDtoCopyWithImpl<$Res>
    implements $SenasaEstablishmentDtoCopyWith<$Res> {
  _$SenasaEstablishmentDtoCopyWithImpl(this._self, this._then);

  final SenasaEstablishmentDto _self;
  final $Res Function(SenasaEstablishmentDto) _then;

/// Create a copy of SenasaEstablishmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? renspa = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,renspa: freezed == renspa ? _self.renspa : renspa // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaEstablishmentDto].
extension SenasaEstablishmentDtoPatterns on SenasaEstablishmentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaEstablishmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaEstablishmentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaEstablishmentDto value)  $default,){
final _that = this;
switch (_that) {
case _SenasaEstablishmentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaEstablishmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaEstablishmentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'renspa_number')  String? renspa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaEstablishmentDto() when $default != null:
return $default(_that.id,_that.name,_that.renspa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'renspa_number')  String? renspa)  $default,) {final _that = this;
switch (_that) {
case _SenasaEstablishmentDto():
return $default(_that.id,_that.name,_that.renspa);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'renspa_number')  String? renspa)?  $default,) {final _that = this;
switch (_that) {
case _SenasaEstablishmentDto() when $default != null:
return $default(_that.id,_that.name,_that.renspa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SenasaEstablishmentDto implements SenasaEstablishmentDto {
  const _SenasaEstablishmentDto({required this.id, required this.name, @JsonKey(name: 'renspa_number') this.renspa});
  factory _SenasaEstablishmentDto.fromJson(Map<String, dynamic> json) => _$SenasaEstablishmentDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'renspa_number') final  String? renspa;

/// Create a copy of SenasaEstablishmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaEstablishmentDtoCopyWith<_SenasaEstablishmentDto> get copyWith => __$SenasaEstablishmentDtoCopyWithImpl<_SenasaEstablishmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenasaEstablishmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaEstablishmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.renspa, renspa) || other.renspa == renspa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,renspa);

@override
String toString() {
  return 'SenasaEstablishmentDto(id: $id, name: $name, renspa: $renspa)';
}


}

/// @nodoc
abstract mixin class _$SenasaEstablishmentDtoCopyWith<$Res> implements $SenasaEstablishmentDtoCopyWith<$Res> {
  factory _$SenasaEstablishmentDtoCopyWith(_SenasaEstablishmentDto value, $Res Function(_SenasaEstablishmentDto) _then) = __$SenasaEstablishmentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'renspa_number') String? renspa
});




}
/// @nodoc
class __$SenasaEstablishmentDtoCopyWithImpl<$Res>
    implements _$SenasaEstablishmentDtoCopyWith<$Res> {
  __$SenasaEstablishmentDtoCopyWithImpl(this._self, this._then);

  final _SenasaEstablishmentDto _self;
  final $Res Function(_SenasaEstablishmentDto) _then;

/// Create a copy of SenasaEstablishmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? renspa = freezed,}) {
  return _then(_SenasaEstablishmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,renspa: freezed == renspa ? _self.renspa : renspa // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SenasaRecordIssueDto {

@JsonKey(name: 'animal_id') String get animalId;@JsonKey(name: 'faltante') List<String> get missingFields;@JsonKey(name: 'caravana') String? get tag;
/// Create a copy of SenasaRecordIssueDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaRecordIssueDtoCopyWith<SenasaRecordIssueDto> get copyWith => _$SenasaRecordIssueDtoCopyWithImpl<SenasaRecordIssueDto>(this as SenasaRecordIssueDto, _$identity);

  /// Serializes this SenasaRecordIssueDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaRecordIssueDto&&(identical(other.animalId, animalId) || other.animalId == animalId)&&const DeepCollectionEquality().equals(other.missingFields, missingFields)&&(identical(other.tag, tag) || other.tag == tag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,animalId,const DeepCollectionEquality().hash(missingFields),tag);

@override
String toString() {
  return 'SenasaRecordIssueDto(animalId: $animalId, missingFields: $missingFields, tag: $tag)';
}


}

/// @nodoc
abstract mixin class $SenasaRecordIssueDtoCopyWith<$Res>  {
  factory $SenasaRecordIssueDtoCopyWith(SenasaRecordIssueDto value, $Res Function(SenasaRecordIssueDto) _then) = _$SenasaRecordIssueDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'animal_id') String animalId,@JsonKey(name: 'faltante') List<String> missingFields,@JsonKey(name: 'caravana') String? tag
});




}
/// @nodoc
class _$SenasaRecordIssueDtoCopyWithImpl<$Res>
    implements $SenasaRecordIssueDtoCopyWith<$Res> {
  _$SenasaRecordIssueDtoCopyWithImpl(this._self, this._then);

  final SenasaRecordIssueDto _self;
  final $Res Function(SenasaRecordIssueDto) _then;

/// Create a copy of SenasaRecordIssueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animalId = null,Object? missingFields = null,Object? tag = freezed,}) {
  return _then(_self.copyWith(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,missingFields: null == missingFields ? _self.missingFields : missingFields // ignore: cast_nullable_to_non_nullable
as List<String>,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaRecordIssueDto].
extension SenasaRecordIssueDtoPatterns on SenasaRecordIssueDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaRecordIssueDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaRecordIssueDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaRecordIssueDto value)  $default,){
final _that = this;
switch (_that) {
case _SenasaRecordIssueDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaRecordIssueDto value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaRecordIssueDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'animal_id')  String animalId, @JsonKey(name: 'faltante')  List<String> missingFields, @JsonKey(name: 'caravana')  String? tag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaRecordIssueDto() when $default != null:
return $default(_that.animalId,_that.missingFields,_that.tag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'animal_id')  String animalId, @JsonKey(name: 'faltante')  List<String> missingFields, @JsonKey(name: 'caravana')  String? tag)  $default,) {final _that = this;
switch (_that) {
case _SenasaRecordIssueDto():
return $default(_that.animalId,_that.missingFields,_that.tag);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'animal_id')  String animalId, @JsonKey(name: 'faltante')  List<String> missingFields, @JsonKey(name: 'caravana')  String? tag)?  $default,) {final _that = this;
switch (_that) {
case _SenasaRecordIssueDto() when $default != null:
return $default(_that.animalId,_that.missingFields,_that.tag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SenasaRecordIssueDto implements SenasaRecordIssueDto {
  const _SenasaRecordIssueDto({@JsonKey(name: 'animal_id') required this.animalId, @JsonKey(name: 'faltante') required final  List<String> missingFields, @JsonKey(name: 'caravana') this.tag}): _missingFields = missingFields;
  factory _SenasaRecordIssueDto.fromJson(Map<String, dynamic> json) => _$SenasaRecordIssueDtoFromJson(json);

@override@JsonKey(name: 'animal_id') final  String animalId;
 final  List<String> _missingFields;
@override@JsonKey(name: 'faltante') List<String> get missingFields {
  if (_missingFields is EqualUnmodifiableListView) return _missingFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingFields);
}

@override@JsonKey(name: 'caravana') final  String? tag;

/// Create a copy of SenasaRecordIssueDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaRecordIssueDtoCopyWith<_SenasaRecordIssueDto> get copyWith => __$SenasaRecordIssueDtoCopyWithImpl<_SenasaRecordIssueDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenasaRecordIssueDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaRecordIssueDto&&(identical(other.animalId, animalId) || other.animalId == animalId)&&const DeepCollectionEquality().equals(other._missingFields, _missingFields)&&(identical(other.tag, tag) || other.tag == tag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,animalId,const DeepCollectionEquality().hash(_missingFields),tag);

@override
String toString() {
  return 'SenasaRecordIssueDto(animalId: $animalId, missingFields: $missingFields, tag: $tag)';
}


}

/// @nodoc
abstract mixin class _$SenasaRecordIssueDtoCopyWith<$Res> implements $SenasaRecordIssueDtoCopyWith<$Res> {
  factory _$SenasaRecordIssueDtoCopyWith(_SenasaRecordIssueDto value, $Res Function(_SenasaRecordIssueDto) _then) = __$SenasaRecordIssueDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'animal_id') String animalId,@JsonKey(name: 'faltante') List<String> missingFields,@JsonKey(name: 'caravana') String? tag
});




}
/// @nodoc
class __$SenasaRecordIssueDtoCopyWithImpl<$Res>
    implements _$SenasaRecordIssueDtoCopyWith<$Res> {
  __$SenasaRecordIssueDtoCopyWithImpl(this._self, this._then);

  final _SenasaRecordIssueDto _self;
  final $Res Function(_SenasaRecordIssueDto) _then;

/// Create a copy of SenasaRecordIssueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = null,Object? missingFields = null,Object? tag = freezed,}) {
  return _then(_SenasaRecordIssueDto(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,missingFields: null == missingFields ? _self._missingFields : missingFields // ignore: cast_nullable_to_non_nullable
as List<String>,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SenasaValidationResultDto {

@JsonKey(name: 'cantidad_exportable') int get exportableAnimals;@JsonKey(name: 'animales_incompletos') List<SenasaRecordIssueDto> get issues;
/// Create a copy of SenasaValidationResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaValidationResultDtoCopyWith<SenasaValidationResultDto> get copyWith => _$SenasaValidationResultDtoCopyWithImpl<SenasaValidationResultDto>(this as SenasaValidationResultDto, _$identity);

  /// Serializes this SenasaValidationResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaValidationResultDto&&(identical(other.exportableAnimals, exportableAnimals) || other.exportableAnimals == exportableAnimals)&&const DeepCollectionEquality().equals(other.issues, issues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportableAnimals,const DeepCollectionEquality().hash(issues));

@override
String toString() {
  return 'SenasaValidationResultDto(exportableAnimals: $exportableAnimals, issues: $issues)';
}


}

/// @nodoc
abstract mixin class $SenasaValidationResultDtoCopyWith<$Res>  {
  factory $SenasaValidationResultDtoCopyWith(SenasaValidationResultDto value, $Res Function(SenasaValidationResultDto) _then) = _$SenasaValidationResultDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'cantidad_exportable') int exportableAnimals,@JsonKey(name: 'animales_incompletos') List<SenasaRecordIssueDto> issues
});




}
/// @nodoc
class _$SenasaValidationResultDtoCopyWithImpl<$Res>
    implements $SenasaValidationResultDtoCopyWith<$Res> {
  _$SenasaValidationResultDtoCopyWithImpl(this._self, this._then);

  final SenasaValidationResultDto _self;
  final $Res Function(SenasaValidationResultDto) _then;

/// Create a copy of SenasaValidationResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exportableAnimals = null,Object? issues = null,}) {
  return _then(_self.copyWith(
exportableAnimals: null == exportableAnimals ? _self.exportableAnimals : exportableAnimals // ignore: cast_nullable_to_non_nullable
as int,issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<SenasaRecordIssueDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaValidationResultDto].
extension SenasaValidationResultDtoPatterns on SenasaValidationResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaValidationResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaValidationResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaValidationResultDto value)  $default,){
final _that = this;
switch (_that) {
case _SenasaValidationResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaValidationResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaValidationResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'cantidad_exportable')  int exportableAnimals, @JsonKey(name: 'animales_incompletos')  List<SenasaRecordIssueDto> issues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaValidationResultDto() when $default != null:
return $default(_that.exportableAnimals,_that.issues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'cantidad_exportable')  int exportableAnimals, @JsonKey(name: 'animales_incompletos')  List<SenasaRecordIssueDto> issues)  $default,) {final _that = this;
switch (_that) {
case _SenasaValidationResultDto():
return $default(_that.exportableAnimals,_that.issues);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'cantidad_exportable')  int exportableAnimals, @JsonKey(name: 'animales_incompletos')  List<SenasaRecordIssueDto> issues)?  $default,) {final _that = this;
switch (_that) {
case _SenasaValidationResultDto() when $default != null:
return $default(_that.exportableAnimals,_that.issues);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SenasaValidationResultDto implements SenasaValidationResultDto {
  const _SenasaValidationResultDto({@JsonKey(name: 'cantidad_exportable') required this.exportableAnimals, @JsonKey(name: 'animales_incompletos') required final  List<SenasaRecordIssueDto> issues}): _issues = issues;
  factory _SenasaValidationResultDto.fromJson(Map<String, dynamic> json) => _$SenasaValidationResultDtoFromJson(json);

@override@JsonKey(name: 'cantidad_exportable') final  int exportableAnimals;
 final  List<SenasaRecordIssueDto> _issues;
@override@JsonKey(name: 'animales_incompletos') List<SenasaRecordIssueDto> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}


/// Create a copy of SenasaValidationResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaValidationResultDtoCopyWith<_SenasaValidationResultDto> get copyWith => __$SenasaValidationResultDtoCopyWithImpl<_SenasaValidationResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenasaValidationResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaValidationResultDto&&(identical(other.exportableAnimals, exportableAnimals) || other.exportableAnimals == exportableAnimals)&&const DeepCollectionEquality().equals(other._issues, _issues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportableAnimals,const DeepCollectionEquality().hash(_issues));

@override
String toString() {
  return 'SenasaValidationResultDto(exportableAnimals: $exportableAnimals, issues: $issues)';
}


}

/// @nodoc
abstract mixin class _$SenasaValidationResultDtoCopyWith<$Res> implements $SenasaValidationResultDtoCopyWith<$Res> {
  factory _$SenasaValidationResultDtoCopyWith(_SenasaValidationResultDto value, $Res Function(_SenasaValidationResultDto) _then) = __$SenasaValidationResultDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'cantidad_exportable') int exportableAnimals,@JsonKey(name: 'animales_incompletos') List<SenasaRecordIssueDto> issues
});




}
/// @nodoc
class __$SenasaValidationResultDtoCopyWithImpl<$Res>
    implements _$SenasaValidationResultDtoCopyWith<$Res> {
  __$SenasaValidationResultDtoCopyWithImpl(this._self, this._then);

  final _SenasaValidationResultDto _self;
  final $Res Function(_SenasaValidationResultDto) _then;

/// Create a copy of SenasaValidationResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exportableAnimals = null,Object? issues = null,}) {
  return _then(_SenasaValidationResultDto(
exportableAnimals: null == exportableAnimals ? _self.exportableAnimals : exportableAnimals // ignore: cast_nullable_to_non_nullable
as int,issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<SenasaRecordIssueDto>,
  ));
}


}


/// @nodoc
mixin _$SenasaExportHistoryItemDto {

 String get id;@JsonKey(name: 'establecimiento_id') String get establishmentId;@JsonKey(name: 'nombre_archivo') String get filename;@JsonKey(name: 'media_type') String get mediaType;@JsonKey(name: 'cantidad_animales') int get animalCount;@JsonKey(name: 'created_at') DateTime get generatedAt;@JsonKey(name: 'desde') DateTime? get from;@JsonKey(name: 'hasta') DateTime? get to;
/// Create a copy of SenasaExportHistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaExportHistoryItemDtoCopyWith<SenasaExportHistoryItemDto> get copyWith => _$SenasaExportHistoryItemDtoCopyWithImpl<SenasaExportHistoryItemDto>(this as SenasaExportHistoryItemDto, _$identity);

  /// Serializes this SenasaExportHistoryItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaExportHistoryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,filename,mediaType,animalCount,generatedAt,from,to);

@override
String toString() {
  return 'SenasaExportHistoryItemDto(id: $id, establishmentId: $establishmentId, filename: $filename, mediaType: $mediaType, animalCount: $animalCount, generatedAt: $generatedAt, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $SenasaExportHistoryItemDtoCopyWith<$Res>  {
  factory $SenasaExportHistoryItemDtoCopyWith(SenasaExportHistoryItemDto value, $Res Function(SenasaExportHistoryItemDto) _then) = _$SenasaExportHistoryItemDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'establecimiento_id') String establishmentId,@JsonKey(name: 'nombre_archivo') String filename,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'cantidad_animales') int animalCount,@JsonKey(name: 'created_at') DateTime generatedAt,@JsonKey(name: 'desde') DateTime? from,@JsonKey(name: 'hasta') DateTime? to
});




}
/// @nodoc
class _$SenasaExportHistoryItemDtoCopyWithImpl<$Res>
    implements $SenasaExportHistoryItemDtoCopyWith<$Res> {
  _$SenasaExportHistoryItemDtoCopyWithImpl(this._self, this._then);

  final SenasaExportHistoryItemDto _self;
  final $Res Function(SenasaExportHistoryItemDto) _then;

/// Create a copy of SenasaExportHistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? filename = null,Object? mediaType = null,Object? animalCount = null,Object? generatedAt = null,Object? from = freezed,Object? to = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaExportHistoryItemDto].
extension SenasaExportHistoryItemDtoPatterns on SenasaExportHistoryItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaExportHistoryItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaExportHistoryItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaExportHistoryItemDto value)  $default,){
final _that = this;
switch (_that) {
case _SenasaExportHistoryItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaExportHistoryItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaExportHistoryItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'establecimiento_id')  String establishmentId, @JsonKey(name: 'nombre_archivo')  String filename, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'cantidad_animales')  int animalCount, @JsonKey(name: 'created_at')  DateTime generatedAt, @JsonKey(name: 'desde')  DateTime? from, @JsonKey(name: 'hasta')  DateTime? to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaExportHistoryItemDto() when $default != null:
return $default(_that.id,_that.establishmentId,_that.filename,_that.mediaType,_that.animalCount,_that.generatedAt,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'establecimiento_id')  String establishmentId, @JsonKey(name: 'nombre_archivo')  String filename, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'cantidad_animales')  int animalCount, @JsonKey(name: 'created_at')  DateTime generatedAt, @JsonKey(name: 'desde')  DateTime? from, @JsonKey(name: 'hasta')  DateTime? to)  $default,) {final _that = this;
switch (_that) {
case _SenasaExportHistoryItemDto():
return $default(_that.id,_that.establishmentId,_that.filename,_that.mediaType,_that.animalCount,_that.generatedAt,_that.from,_that.to);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'establecimiento_id')  String establishmentId, @JsonKey(name: 'nombre_archivo')  String filename, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'cantidad_animales')  int animalCount, @JsonKey(name: 'created_at')  DateTime generatedAt, @JsonKey(name: 'desde')  DateTime? from, @JsonKey(name: 'hasta')  DateTime? to)?  $default,) {final _that = this;
switch (_that) {
case _SenasaExportHistoryItemDto() when $default != null:
return $default(_that.id,_that.establishmentId,_that.filename,_that.mediaType,_that.animalCount,_that.generatedAt,_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SenasaExportHistoryItemDto implements SenasaExportHistoryItemDto {
  const _SenasaExportHistoryItemDto({required this.id, @JsonKey(name: 'establecimiento_id') required this.establishmentId, @JsonKey(name: 'nombre_archivo') required this.filename, @JsonKey(name: 'media_type') required this.mediaType, @JsonKey(name: 'cantidad_animales') required this.animalCount, @JsonKey(name: 'created_at') required this.generatedAt, @JsonKey(name: 'desde') this.from, @JsonKey(name: 'hasta') this.to});
  factory _SenasaExportHistoryItemDto.fromJson(Map<String, dynamic> json) => _$SenasaExportHistoryItemDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'establecimiento_id') final  String establishmentId;
@override@JsonKey(name: 'nombre_archivo') final  String filename;
@override@JsonKey(name: 'media_type') final  String mediaType;
@override@JsonKey(name: 'cantidad_animales') final  int animalCount;
@override@JsonKey(name: 'created_at') final  DateTime generatedAt;
@override@JsonKey(name: 'desde') final  DateTime? from;
@override@JsonKey(name: 'hasta') final  DateTime? to;

/// Create a copy of SenasaExportHistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaExportHistoryItemDtoCopyWith<_SenasaExportHistoryItemDto> get copyWith => __$SenasaExportHistoryItemDtoCopyWithImpl<_SenasaExportHistoryItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenasaExportHistoryItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaExportHistoryItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,filename,mediaType,animalCount,generatedAt,from,to);

@override
String toString() {
  return 'SenasaExportHistoryItemDto(id: $id, establishmentId: $establishmentId, filename: $filename, mediaType: $mediaType, animalCount: $animalCount, generatedAt: $generatedAt, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$SenasaExportHistoryItemDtoCopyWith<$Res> implements $SenasaExportHistoryItemDtoCopyWith<$Res> {
  factory _$SenasaExportHistoryItemDtoCopyWith(_SenasaExportHistoryItemDto value, $Res Function(_SenasaExportHistoryItemDto) _then) = __$SenasaExportHistoryItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'establecimiento_id') String establishmentId,@JsonKey(name: 'nombre_archivo') String filename,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'cantidad_animales') int animalCount,@JsonKey(name: 'created_at') DateTime generatedAt,@JsonKey(name: 'desde') DateTime? from,@JsonKey(name: 'hasta') DateTime? to
});




}
/// @nodoc
class __$SenasaExportHistoryItemDtoCopyWithImpl<$Res>
    implements _$SenasaExportHistoryItemDtoCopyWith<$Res> {
  __$SenasaExportHistoryItemDtoCopyWithImpl(this._self, this._then);

  final _SenasaExportHistoryItemDto _self;
  final $Res Function(_SenasaExportHistoryItemDto) _then;

/// Create a copy of SenasaExportHistoryItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? filename = null,Object? mediaType = null,Object? animalCount = null,Object? generatedAt = null,Object? from = freezed,Object? to = freezed,}) {
  return _then(_SenasaExportHistoryItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
