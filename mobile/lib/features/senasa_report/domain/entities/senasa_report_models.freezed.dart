// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'senasa_report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SenasaEstablishment {

 String get id; String get name; String? get renspa;
/// Create a copy of SenasaEstablishment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaEstablishmentCopyWith<SenasaEstablishment> get copyWith => _$SenasaEstablishmentCopyWithImpl<SenasaEstablishment>(this as SenasaEstablishment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.renspa, renspa) || other.renspa == renspa));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,renspa);

@override
String toString() {
  return 'SenasaEstablishment(id: $id, name: $name, renspa: $renspa)';
}


}

/// @nodoc
abstract mixin class $SenasaEstablishmentCopyWith<$Res>  {
  factory $SenasaEstablishmentCopyWith(SenasaEstablishment value, $Res Function(SenasaEstablishment) _then) = _$SenasaEstablishmentCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? renspa
});




}
/// @nodoc
class _$SenasaEstablishmentCopyWithImpl<$Res>
    implements $SenasaEstablishmentCopyWith<$Res> {
  _$SenasaEstablishmentCopyWithImpl(this._self, this._then);

  final SenasaEstablishment _self;
  final $Res Function(SenasaEstablishment) _then;

/// Create a copy of SenasaEstablishment
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


/// Adds pattern-matching-related methods to [SenasaEstablishment].
extension SenasaEstablishmentPatterns on SenasaEstablishment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaEstablishment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaEstablishment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaEstablishment value)  $default,){
final _that = this;
switch (_that) {
case _SenasaEstablishment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaEstablishment value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaEstablishment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? renspa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaEstablishment() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? renspa)  $default,) {final _that = this;
switch (_that) {
case _SenasaEstablishment():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? renspa)?  $default,) {final _that = this;
switch (_that) {
case _SenasaEstablishment() when $default != null:
return $default(_that.id,_that.name,_that.renspa);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaEstablishment implements SenasaEstablishment {
  const _SenasaEstablishment({required this.id, required this.name, this.renspa});
  

@override final  String id;
@override final  String name;
@override final  String? renspa;

/// Create a copy of SenasaEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaEstablishmentCopyWith<_SenasaEstablishment> get copyWith => __$SenasaEstablishmentCopyWithImpl<_SenasaEstablishment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaEstablishment&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.renspa, renspa) || other.renspa == renspa));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,renspa);

@override
String toString() {
  return 'SenasaEstablishment(id: $id, name: $name, renspa: $renspa)';
}


}

/// @nodoc
abstract mixin class _$SenasaEstablishmentCopyWith<$Res> implements $SenasaEstablishmentCopyWith<$Res> {
  factory _$SenasaEstablishmentCopyWith(_SenasaEstablishment value, $Res Function(_SenasaEstablishment) _then) = __$SenasaEstablishmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? renspa
});




}
/// @nodoc
class __$SenasaEstablishmentCopyWithImpl<$Res>
    implements _$SenasaEstablishmentCopyWith<$Res> {
  __$SenasaEstablishmentCopyWithImpl(this._self, this._then);

  final _SenasaEstablishment _self;
  final $Res Function(_SenasaEstablishment) _then;

/// Create a copy of SenasaEstablishment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? renspa = freezed,}) {
  return _then(_SenasaEstablishment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,renspa: freezed == renspa ? _self.renspa : renspa // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SenasaReportRequest {

 String get establishmentId; String get format; DateTime get from; DateTime get to; String get eventType; String get responsibleName; String get responsibleDni;
/// Create a copy of SenasaReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaReportRequestCopyWith<SenasaReportRequest> get copyWith => _$SenasaReportRequestCopyWithImpl<SenasaReportRequest>(this as SenasaReportRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaReportRequest&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.format, format) || other.format == format)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.responsibleName, responsibleName) || other.responsibleName == responsibleName)&&(identical(other.responsibleDni, responsibleDni) || other.responsibleDni == responsibleDni));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,format,from,to,eventType,responsibleName,responsibleDni);

@override
String toString() {
  return 'SenasaReportRequest(establishmentId: $establishmentId, format: $format, from: $from, to: $to, eventType: $eventType, responsibleName: $responsibleName, responsibleDni: $responsibleDni)';
}


}

/// @nodoc
abstract mixin class $SenasaReportRequestCopyWith<$Res>  {
  factory $SenasaReportRequestCopyWith(SenasaReportRequest value, $Res Function(SenasaReportRequest) _then) = _$SenasaReportRequestCopyWithImpl;
@useResult
$Res call({
 String establishmentId, String format, DateTime from, DateTime to, String eventType, String responsibleName, String responsibleDni
});




}
/// @nodoc
class _$SenasaReportRequestCopyWithImpl<$Res>
    implements $SenasaReportRequestCopyWith<$Res> {
  _$SenasaReportRequestCopyWithImpl(this._self, this._then);

  final SenasaReportRequest _self;
  final $Res Function(SenasaReportRequest) _then;

/// Create a copy of SenasaReportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? format = null,Object? from = null,Object? to = null,Object? eventType = null,Object? responsibleName = null,Object? responsibleDni = null,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,responsibleName: null == responsibleName ? _self.responsibleName : responsibleName // ignore: cast_nullable_to_non_nullable
as String,responsibleDni: null == responsibleDni ? _self.responsibleDni : responsibleDni // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaReportRequest].
extension SenasaReportRequestPatterns on SenasaReportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaReportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaReportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaReportRequest value)  $default,){
final _that = this;
switch (_that) {
case _SenasaReportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaReportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaReportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  String format,  DateTime from,  DateTime to,  String eventType,  String responsibleName,  String responsibleDni)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaReportRequest() when $default != null:
return $default(_that.establishmentId,_that.format,_that.from,_that.to,_that.eventType,_that.responsibleName,_that.responsibleDni);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  String format,  DateTime from,  DateTime to,  String eventType,  String responsibleName,  String responsibleDni)  $default,) {final _that = this;
switch (_that) {
case _SenasaReportRequest():
return $default(_that.establishmentId,_that.format,_that.from,_that.to,_that.eventType,_that.responsibleName,_that.responsibleDni);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  String format,  DateTime from,  DateTime to,  String eventType,  String responsibleName,  String responsibleDni)?  $default,) {final _that = this;
switch (_that) {
case _SenasaReportRequest() when $default != null:
return $default(_that.establishmentId,_that.format,_that.from,_that.to,_that.eventType,_that.responsibleName,_that.responsibleDni);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaReportRequest implements SenasaReportRequest {
  const _SenasaReportRequest({required this.establishmentId, required this.format, required this.from, required this.to, required this.eventType, required this.responsibleName, required this.responsibleDni});
  

@override final  String establishmentId;
@override final  String format;
@override final  DateTime from;
@override final  DateTime to;
@override final  String eventType;
@override final  String responsibleName;
@override final  String responsibleDni;

/// Create a copy of SenasaReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaReportRequestCopyWith<_SenasaReportRequest> get copyWith => __$SenasaReportRequestCopyWithImpl<_SenasaReportRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaReportRequest&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.format, format) || other.format == format)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.responsibleName, responsibleName) || other.responsibleName == responsibleName)&&(identical(other.responsibleDni, responsibleDni) || other.responsibleDni == responsibleDni));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,format,from,to,eventType,responsibleName,responsibleDni);

@override
String toString() {
  return 'SenasaReportRequest(establishmentId: $establishmentId, format: $format, from: $from, to: $to, eventType: $eventType, responsibleName: $responsibleName, responsibleDni: $responsibleDni)';
}


}

/// @nodoc
abstract mixin class _$SenasaReportRequestCopyWith<$Res> implements $SenasaReportRequestCopyWith<$Res> {
  factory _$SenasaReportRequestCopyWith(_SenasaReportRequest value, $Res Function(_SenasaReportRequest) _then) = __$SenasaReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, String format, DateTime from, DateTime to, String eventType, String responsibleName, String responsibleDni
});




}
/// @nodoc
class __$SenasaReportRequestCopyWithImpl<$Res>
    implements _$SenasaReportRequestCopyWith<$Res> {
  __$SenasaReportRequestCopyWithImpl(this._self, this._then);

  final _SenasaReportRequest _self;
  final $Res Function(_SenasaReportRequest) _then;

/// Create a copy of SenasaReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? format = null,Object? from = null,Object? to = null,Object? eventType = null,Object? responsibleName = null,Object? responsibleDni = null,}) {
  return _then(_SenasaReportRequest(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,responsibleName: null == responsibleName ? _self.responsibleName : responsibleName // ignore: cast_nullable_to_non_nullable
as String,responsibleDni: null == responsibleDni ? _self.responsibleDni : responsibleDni // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GeneratedSenasaReport {

 Uint8List get bytes; String get filename; String get mediaType;
/// Create a copy of GeneratedSenasaReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedSenasaReportCopyWith<GeneratedSenasaReport> get copyWith => _$GeneratedSenasaReportCopyWithImpl<GeneratedSenasaReport>(this as GeneratedSenasaReport, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedSenasaReport&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),filename,mediaType);

@override
String toString() {
  return 'GeneratedSenasaReport(bytes: $bytes, filename: $filename, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class $GeneratedSenasaReportCopyWith<$Res>  {
  factory $GeneratedSenasaReportCopyWith(GeneratedSenasaReport value, $Res Function(GeneratedSenasaReport) _then) = _$GeneratedSenasaReportCopyWithImpl;
@useResult
$Res call({
 Uint8List bytes, String filename, String mediaType
});




}
/// @nodoc
class _$GeneratedSenasaReportCopyWithImpl<$Res>
    implements $GeneratedSenasaReportCopyWith<$Res> {
  _$GeneratedSenasaReportCopyWithImpl(this._self, this._then);

  final GeneratedSenasaReport _self;
  final $Res Function(GeneratedSenasaReport) _then;

/// Create a copy of GeneratedSenasaReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? filename = null,Object? mediaType = null,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedSenasaReport].
extension GeneratedSenasaReportPatterns on GeneratedSenasaReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedSenasaReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedSenasaReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedSenasaReport value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedSenasaReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedSenasaReport value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedSenasaReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List bytes,  String filename,  String mediaType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedSenasaReport() when $default != null:
return $default(_that.bytes,_that.filename,_that.mediaType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List bytes,  String filename,  String mediaType)  $default,) {final _that = this;
switch (_that) {
case _GeneratedSenasaReport():
return $default(_that.bytes,_that.filename,_that.mediaType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List bytes,  String filename,  String mediaType)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedSenasaReport() when $default != null:
return $default(_that.bytes,_that.filename,_that.mediaType);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratedSenasaReport implements GeneratedSenasaReport {
  const _GeneratedSenasaReport({required this.bytes, required this.filename, required this.mediaType});
  

@override final  Uint8List bytes;
@override final  String filename;
@override final  String mediaType;

/// Create a copy of GeneratedSenasaReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedSenasaReportCopyWith<_GeneratedSenasaReport> get copyWith => __$GeneratedSenasaReportCopyWithImpl<_GeneratedSenasaReport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedSenasaReport&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),filename,mediaType);

@override
String toString() {
  return 'GeneratedSenasaReport(bytes: $bytes, filename: $filename, mediaType: $mediaType)';
}


}

/// @nodoc
abstract mixin class _$GeneratedSenasaReportCopyWith<$Res> implements $GeneratedSenasaReportCopyWith<$Res> {
  factory _$GeneratedSenasaReportCopyWith(_GeneratedSenasaReport value, $Res Function(_GeneratedSenasaReport) _then) = __$GeneratedSenasaReportCopyWithImpl;
@override @useResult
$Res call({
 Uint8List bytes, String filename, String mediaType
});




}
/// @nodoc
class __$GeneratedSenasaReportCopyWithImpl<$Res>
    implements _$GeneratedSenasaReportCopyWith<$Res> {
  __$GeneratedSenasaReportCopyWithImpl(this._self, this._then);

  final _GeneratedSenasaReport _self;
  final $Res Function(_GeneratedSenasaReport) _then;

/// Create a copy of GeneratedSenasaReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? filename = null,Object? mediaType = null,}) {
  return _then(_GeneratedSenasaReport(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
