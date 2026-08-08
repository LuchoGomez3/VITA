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

 String get establishmentId; DateTime get from; DateTime get to; String get fileName; int get animalCount;
/// Create a copy of SenasaReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaReportRequestCopyWith<SenasaReportRequest> get copyWith => _$SenasaReportRequestCopyWithImpl<SenasaReportRequest>(this as SenasaReportRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaReportRequest&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,from,to,fileName,animalCount);

@override
String toString() {
  return 'SenasaReportRequest(establishmentId: $establishmentId, from: $from, to: $to, fileName: $fileName, animalCount: $animalCount)';
}


}

/// @nodoc
abstract mixin class $SenasaReportRequestCopyWith<$Res>  {
  factory $SenasaReportRequestCopyWith(SenasaReportRequest value, $Res Function(SenasaReportRequest) _then) = _$SenasaReportRequestCopyWithImpl;
@useResult
$Res call({
 String establishmentId, DateTime from, DateTime to, String fileName, int animalCount
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
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? from = null,Object? to = null,Object? fileName = null,Object? animalCount = null,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  DateTime from,  DateTime to,  String fileName,  int animalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaReportRequest() when $default != null:
return $default(_that.establishmentId,_that.from,_that.to,_that.fileName,_that.animalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  DateTime from,  DateTime to,  String fileName,  int animalCount)  $default,) {final _that = this;
switch (_that) {
case _SenasaReportRequest():
return $default(_that.establishmentId,_that.from,_that.to,_that.fileName,_that.animalCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  DateTime from,  DateTime to,  String fileName,  int animalCount)?  $default,) {final _that = this;
switch (_that) {
case _SenasaReportRequest() when $default != null:
return $default(_that.establishmentId,_that.from,_that.to,_that.fileName,_that.animalCount);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaReportRequest implements SenasaReportRequest {
  const _SenasaReportRequest({required this.establishmentId, required this.from, required this.to, required this.fileName, required this.animalCount});
  

@override final  String establishmentId;
@override final  DateTime from;
@override final  DateTime to;
@override final  String fileName;
@override final  int animalCount;

/// Create a copy of SenasaReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaReportRequestCopyWith<_SenasaReportRequest> get copyWith => __$SenasaReportRequestCopyWithImpl<_SenasaReportRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaReportRequest&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,from,to,fileName,animalCount);

@override
String toString() {
  return 'SenasaReportRequest(establishmentId: $establishmentId, from: $from, to: $to, fileName: $fileName, animalCount: $animalCount)';
}


}

/// @nodoc
abstract mixin class _$SenasaReportRequestCopyWith<$Res> implements $SenasaReportRequestCopyWith<$Res> {
  factory _$SenasaReportRequestCopyWith(_SenasaReportRequest value, $Res Function(_SenasaReportRequest) _then) = __$SenasaReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, DateTime from, DateTime to, String fileName, int animalCount
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
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? from = null,Object? to = null,Object? fileName = null,Object? animalCount = null,}) {
  return _then(_SenasaReportRequest(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SenasaReportValidationRequest {

 String get establishmentId; DateTime get from; DateTime get to; String get fileName;
/// Create a copy of SenasaReportValidationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaReportValidationRequestCopyWith<SenasaReportValidationRequest> get copyWith => _$SenasaReportValidationRequestCopyWithImpl<SenasaReportValidationRequest>(this as SenasaReportValidationRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaReportValidationRequest&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,from,to,fileName);

@override
String toString() {
  return 'SenasaReportValidationRequest(establishmentId: $establishmentId, from: $from, to: $to, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $SenasaReportValidationRequestCopyWith<$Res>  {
  factory $SenasaReportValidationRequestCopyWith(SenasaReportValidationRequest value, $Res Function(SenasaReportValidationRequest) _then) = _$SenasaReportValidationRequestCopyWithImpl;
@useResult
$Res call({
 String establishmentId, DateTime from, DateTime to, String fileName
});




}
/// @nodoc
class _$SenasaReportValidationRequestCopyWithImpl<$Res>
    implements $SenasaReportValidationRequestCopyWith<$Res> {
  _$SenasaReportValidationRequestCopyWithImpl(this._self, this._then);

  final SenasaReportValidationRequest _self;
  final $Res Function(SenasaReportValidationRequest) _then;

/// Create a copy of SenasaReportValidationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? from = null,Object? to = null,Object? fileName = null,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaReportValidationRequest].
extension SenasaReportValidationRequestPatterns on SenasaReportValidationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaReportValidationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaReportValidationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaReportValidationRequest value)  $default,){
final _that = this;
switch (_that) {
case _SenasaReportValidationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaReportValidationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaReportValidationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  DateTime from,  DateTime to,  String fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaReportValidationRequest() when $default != null:
return $default(_that.establishmentId,_that.from,_that.to,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  DateTime from,  DateTime to,  String fileName)  $default,) {final _that = this;
switch (_that) {
case _SenasaReportValidationRequest():
return $default(_that.establishmentId,_that.from,_that.to,_that.fileName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  DateTime from,  DateTime to,  String fileName)?  $default,) {final _that = this;
switch (_that) {
case _SenasaReportValidationRequest() when $default != null:
return $default(_that.establishmentId,_that.from,_that.to,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaReportValidationRequest implements SenasaReportValidationRequest {
  const _SenasaReportValidationRequest({required this.establishmentId, required this.from, required this.to, required this.fileName});
  

@override final  String establishmentId;
@override final  DateTime from;
@override final  DateTime to;
@override final  String fileName;

/// Create a copy of SenasaReportValidationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaReportValidationRequestCopyWith<_SenasaReportValidationRequest> get copyWith => __$SenasaReportValidationRequestCopyWithImpl<_SenasaReportValidationRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaReportValidationRequest&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,from,to,fileName);

@override
String toString() {
  return 'SenasaReportValidationRequest(establishmentId: $establishmentId, from: $from, to: $to, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$SenasaReportValidationRequestCopyWith<$Res> implements $SenasaReportValidationRequestCopyWith<$Res> {
  factory _$SenasaReportValidationRequestCopyWith(_SenasaReportValidationRequest value, $Res Function(_SenasaReportValidationRequest) _then) = __$SenasaReportValidationRequestCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, DateTime from, DateTime to, String fileName
});




}
/// @nodoc
class __$SenasaReportValidationRequestCopyWithImpl<$Res>
    implements _$SenasaReportValidationRequestCopyWith<$Res> {
  __$SenasaReportValidationRequestCopyWithImpl(this._self, this._then);

  final _SenasaReportValidationRequest _self;
  final $Res Function(_SenasaReportValidationRequest) _then;

/// Create a copy of SenasaReportValidationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? from = null,Object? to = null,Object? fileName = null,}) {
  return _then(_SenasaReportValidationRequest(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SenasaRecordIssue {

 String get animalId; List<String> get missingFields; String? get tag;
/// Create a copy of SenasaRecordIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaRecordIssueCopyWith<SenasaRecordIssue> get copyWith => _$SenasaRecordIssueCopyWithImpl<SenasaRecordIssue>(this as SenasaRecordIssue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaRecordIssue&&(identical(other.animalId, animalId) || other.animalId == animalId)&&const DeepCollectionEquality().equals(other.missingFields, missingFields)&&(identical(other.tag, tag) || other.tag == tag));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,const DeepCollectionEquality().hash(missingFields),tag);

@override
String toString() {
  return 'SenasaRecordIssue(animalId: $animalId, missingFields: $missingFields, tag: $tag)';
}


}

/// @nodoc
abstract mixin class $SenasaRecordIssueCopyWith<$Res>  {
  factory $SenasaRecordIssueCopyWith(SenasaRecordIssue value, $Res Function(SenasaRecordIssue) _then) = _$SenasaRecordIssueCopyWithImpl;
@useResult
$Res call({
 String animalId, List<String> missingFields, String? tag
});




}
/// @nodoc
class _$SenasaRecordIssueCopyWithImpl<$Res>
    implements $SenasaRecordIssueCopyWith<$Res> {
  _$SenasaRecordIssueCopyWithImpl(this._self, this._then);

  final SenasaRecordIssue _self;
  final $Res Function(SenasaRecordIssue) _then;

/// Create a copy of SenasaRecordIssue
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


/// Adds pattern-matching-related methods to [SenasaRecordIssue].
extension SenasaRecordIssuePatterns on SenasaRecordIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaRecordIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaRecordIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaRecordIssue value)  $default,){
final _that = this;
switch (_that) {
case _SenasaRecordIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaRecordIssue value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaRecordIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String animalId,  List<String> missingFields,  String? tag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaRecordIssue() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String animalId,  List<String> missingFields,  String? tag)  $default,) {final _that = this;
switch (_that) {
case _SenasaRecordIssue():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String animalId,  List<String> missingFields,  String? tag)?  $default,) {final _that = this;
switch (_that) {
case _SenasaRecordIssue() when $default != null:
return $default(_that.animalId,_that.missingFields,_that.tag);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaRecordIssue implements SenasaRecordIssue {
  const _SenasaRecordIssue({required this.animalId, required final  List<String> missingFields, this.tag}): _missingFields = missingFields;
  

@override final  String animalId;
 final  List<String> _missingFields;
@override List<String> get missingFields {
  if (_missingFields is EqualUnmodifiableListView) return _missingFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingFields);
}

@override final  String? tag;

/// Create a copy of SenasaRecordIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaRecordIssueCopyWith<_SenasaRecordIssue> get copyWith => __$SenasaRecordIssueCopyWithImpl<_SenasaRecordIssue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaRecordIssue&&(identical(other.animalId, animalId) || other.animalId == animalId)&&const DeepCollectionEquality().equals(other._missingFields, _missingFields)&&(identical(other.tag, tag) || other.tag == tag));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,const DeepCollectionEquality().hash(_missingFields),tag);

@override
String toString() {
  return 'SenasaRecordIssue(animalId: $animalId, missingFields: $missingFields, tag: $tag)';
}


}

/// @nodoc
abstract mixin class _$SenasaRecordIssueCopyWith<$Res> implements $SenasaRecordIssueCopyWith<$Res> {
  factory _$SenasaRecordIssueCopyWith(_SenasaRecordIssue value, $Res Function(_SenasaRecordIssue) _then) = __$SenasaRecordIssueCopyWithImpl;
@override @useResult
$Res call({
 String animalId, List<String> missingFields, String? tag
});




}
/// @nodoc
class __$SenasaRecordIssueCopyWithImpl<$Res>
    implements _$SenasaRecordIssueCopyWith<$Res> {
  __$SenasaRecordIssueCopyWithImpl(this._self, this._then);

  final _SenasaRecordIssue _self;
  final $Res Function(_SenasaRecordIssue) _then;

/// Create a copy of SenasaRecordIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = null,Object? missingFields = null,Object? tag = freezed,}) {
  return _then(_SenasaRecordIssue(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,missingFields: null == missingFields ? _self._missingFields : missingFields // ignore: cast_nullable_to_non_nullable
as List<String>,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SenasaValidationResult {

 int get exportableAnimals; List<SenasaRecordIssue> get issues;
/// Create a copy of SenasaValidationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaValidationResultCopyWith<SenasaValidationResult> get copyWith => _$SenasaValidationResultCopyWithImpl<SenasaValidationResult>(this as SenasaValidationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaValidationResult&&(identical(other.exportableAnimals, exportableAnimals) || other.exportableAnimals == exportableAnimals)&&const DeepCollectionEquality().equals(other.issues, issues));
}


@override
int get hashCode => Object.hash(runtimeType,exportableAnimals,const DeepCollectionEquality().hash(issues));

@override
String toString() {
  return 'SenasaValidationResult(exportableAnimals: $exportableAnimals, issues: $issues)';
}


}

/// @nodoc
abstract mixin class $SenasaValidationResultCopyWith<$Res>  {
  factory $SenasaValidationResultCopyWith(SenasaValidationResult value, $Res Function(SenasaValidationResult) _then) = _$SenasaValidationResultCopyWithImpl;
@useResult
$Res call({
 int exportableAnimals, List<SenasaRecordIssue> issues
});




}
/// @nodoc
class _$SenasaValidationResultCopyWithImpl<$Res>
    implements $SenasaValidationResultCopyWith<$Res> {
  _$SenasaValidationResultCopyWithImpl(this._self, this._then);

  final SenasaValidationResult _self;
  final $Res Function(SenasaValidationResult) _then;

/// Create a copy of SenasaValidationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exportableAnimals = null,Object? issues = null,}) {
  return _then(_self.copyWith(
exportableAnimals: null == exportableAnimals ? _self.exportableAnimals : exportableAnimals // ignore: cast_nullable_to_non_nullable
as int,issues: null == issues ? _self.issues : issues // ignore: cast_nullable_to_non_nullable
as List<SenasaRecordIssue>,
  ));
}

}


/// Adds pattern-matching-related methods to [SenasaValidationResult].
extension SenasaValidationResultPatterns on SenasaValidationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaValidationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaValidationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaValidationResult value)  $default,){
final _that = this;
switch (_that) {
case _SenasaValidationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaValidationResult value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaValidationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int exportableAnimals,  List<SenasaRecordIssue> issues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaValidationResult() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int exportableAnimals,  List<SenasaRecordIssue> issues)  $default,) {final _that = this;
switch (_that) {
case _SenasaValidationResult():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int exportableAnimals,  List<SenasaRecordIssue> issues)?  $default,) {final _that = this;
switch (_that) {
case _SenasaValidationResult() when $default != null:
return $default(_that.exportableAnimals,_that.issues);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaValidationResult implements SenasaValidationResult {
  const _SenasaValidationResult({required this.exportableAnimals, final  List<SenasaRecordIssue> issues = const <SenasaRecordIssue>[]}): _issues = issues;
  

@override final  int exportableAnimals;
 final  List<SenasaRecordIssue> _issues;
@override@JsonKey() List<SenasaRecordIssue> get issues {
  if (_issues is EqualUnmodifiableListView) return _issues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_issues);
}


/// Create a copy of SenasaValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaValidationResultCopyWith<_SenasaValidationResult> get copyWith => __$SenasaValidationResultCopyWithImpl<_SenasaValidationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaValidationResult&&(identical(other.exportableAnimals, exportableAnimals) || other.exportableAnimals == exportableAnimals)&&const DeepCollectionEquality().equals(other._issues, _issues));
}


@override
int get hashCode => Object.hash(runtimeType,exportableAnimals,const DeepCollectionEquality().hash(_issues));

@override
String toString() {
  return 'SenasaValidationResult(exportableAnimals: $exportableAnimals, issues: $issues)';
}


}

/// @nodoc
abstract mixin class _$SenasaValidationResultCopyWith<$Res> implements $SenasaValidationResultCopyWith<$Res> {
  factory _$SenasaValidationResultCopyWith(_SenasaValidationResult value, $Res Function(_SenasaValidationResult) _then) = __$SenasaValidationResultCopyWithImpl;
@override @useResult
$Res call({
 int exportableAnimals, List<SenasaRecordIssue> issues
});




}
/// @nodoc
class __$SenasaValidationResultCopyWithImpl<$Res>
    implements _$SenasaValidationResultCopyWith<$Res> {
  __$SenasaValidationResultCopyWithImpl(this._self, this._then);

  final _SenasaValidationResult _self;
  final $Res Function(_SenasaValidationResult) _then;

/// Create a copy of SenasaValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exportableAnimals = null,Object? issues = null,}) {
  return _then(_SenasaValidationResult(
exportableAnimals: null == exportableAnimals ? _self.exportableAnimals : exportableAnimals // ignore: cast_nullable_to_non_nullable
as int,issues: null == issues ? _self._issues : issues // ignore: cast_nullable_to_non_nullable
as List<SenasaRecordIssue>,
  ));
}


}

/// @nodoc
mixin _$GeneratedSenasaReport {

 Uint8List get bytes; String get filename; String get mediaType; DateTime get generatedAt; int get animalCount;
/// Create a copy of GeneratedSenasaReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedSenasaReportCopyWith<GeneratedSenasaReport> get copyWith => _$GeneratedSenasaReportCopyWithImpl<GeneratedSenasaReport>(this as GeneratedSenasaReport, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedSenasaReport&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),filename,mediaType,generatedAt,animalCount);

@override
String toString() {
  return 'GeneratedSenasaReport(bytes: $bytes, filename: $filename, mediaType: $mediaType, generatedAt: $generatedAt, animalCount: $animalCount)';
}


}

/// @nodoc
abstract mixin class $GeneratedSenasaReportCopyWith<$Res>  {
  factory $GeneratedSenasaReportCopyWith(GeneratedSenasaReport value, $Res Function(GeneratedSenasaReport) _then) = _$GeneratedSenasaReportCopyWithImpl;
@useResult
$Res call({
 Uint8List bytes, String filename, String mediaType, DateTime generatedAt, int animalCount
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
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? filename = null,Object? mediaType = null,Object? generatedAt = null,Object? animalCount = null,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List bytes,  String filename,  String mediaType,  DateTime generatedAt,  int animalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedSenasaReport() when $default != null:
return $default(_that.bytes,_that.filename,_that.mediaType,_that.generatedAt,_that.animalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List bytes,  String filename,  String mediaType,  DateTime generatedAt,  int animalCount)  $default,) {final _that = this;
switch (_that) {
case _GeneratedSenasaReport():
return $default(_that.bytes,_that.filename,_that.mediaType,_that.generatedAt,_that.animalCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List bytes,  String filename,  String mediaType,  DateTime generatedAt,  int animalCount)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedSenasaReport() when $default != null:
return $default(_that.bytes,_that.filename,_that.mediaType,_that.generatedAt,_that.animalCount);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratedSenasaReport implements GeneratedSenasaReport {
  const _GeneratedSenasaReport({required this.bytes, required this.filename, required this.mediaType, required this.generatedAt, required this.animalCount});
  

@override final  Uint8List bytes;
@override final  String filename;
@override final  String mediaType;
@override final  DateTime generatedAt;
@override final  int animalCount;

/// Create a copy of GeneratedSenasaReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedSenasaReportCopyWith<_GeneratedSenasaReport> get copyWith => __$GeneratedSenasaReportCopyWithImpl<_GeneratedSenasaReport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedSenasaReport&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),filename,mediaType,generatedAt,animalCount);

@override
String toString() {
  return 'GeneratedSenasaReport(bytes: $bytes, filename: $filename, mediaType: $mediaType, generatedAt: $generatedAt, animalCount: $animalCount)';
}


}

/// @nodoc
abstract mixin class _$GeneratedSenasaReportCopyWith<$Res> implements $GeneratedSenasaReportCopyWith<$Res> {
  factory _$GeneratedSenasaReportCopyWith(_GeneratedSenasaReport value, $Res Function(_GeneratedSenasaReport) _then) = __$GeneratedSenasaReportCopyWithImpl;
@override @useResult
$Res call({
 Uint8List bytes, String filename, String mediaType, DateTime generatedAt, int animalCount
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
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? filename = null,Object? mediaType = null,Object? generatedAt = null,Object? animalCount = null,}) {
  return _then(_GeneratedSenasaReport(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,filename: null == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,animalCount: null == animalCount ? _self.animalCount : animalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SenasaExportHistoryItem {

 String get id; String get establishmentId; String get filename; String get mediaType; int get animalCount; DateTime get generatedAt; DateTime? get from; DateTime? get to;
/// Create a copy of SenasaExportHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenasaExportHistoryItemCopyWith<SenasaExportHistoryItem> get copyWith => _$SenasaExportHistoryItemCopyWithImpl<SenasaExportHistoryItem>(this as SenasaExportHistoryItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenasaExportHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,filename,mediaType,animalCount,generatedAt,from,to);

@override
String toString() {
  return 'SenasaExportHistoryItem(id: $id, establishmentId: $establishmentId, filename: $filename, mediaType: $mediaType, animalCount: $animalCount, generatedAt: $generatedAt, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $SenasaExportHistoryItemCopyWith<$Res>  {
  factory $SenasaExportHistoryItemCopyWith(SenasaExportHistoryItem value, $Res Function(SenasaExportHistoryItem) _then) = _$SenasaExportHistoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, String filename, String mediaType, int animalCount, DateTime generatedAt, DateTime? from, DateTime? to
});




}
/// @nodoc
class _$SenasaExportHistoryItemCopyWithImpl<$Res>
    implements $SenasaExportHistoryItemCopyWith<$Res> {
  _$SenasaExportHistoryItemCopyWithImpl(this._self, this._then);

  final SenasaExportHistoryItem _self;
  final $Res Function(SenasaExportHistoryItem) _then;

/// Create a copy of SenasaExportHistoryItem
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


/// Adds pattern-matching-related methods to [SenasaExportHistoryItem].
extension SenasaExportHistoryItemPatterns on SenasaExportHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenasaExportHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenasaExportHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenasaExportHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _SenasaExportHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenasaExportHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _SenasaExportHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String filename,  String mediaType,  int animalCount,  DateTime generatedAt,  DateTime? from,  DateTime? to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenasaExportHistoryItem() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  String filename,  String mediaType,  int animalCount,  DateTime generatedAt,  DateTime? from,  DateTime? to)  $default,) {final _that = this;
switch (_that) {
case _SenasaExportHistoryItem():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  String filename,  String mediaType,  int animalCount,  DateTime generatedAt,  DateTime? from,  DateTime? to)?  $default,) {final _that = this;
switch (_that) {
case _SenasaExportHistoryItem() when $default != null:
return $default(_that.id,_that.establishmentId,_that.filename,_that.mediaType,_that.animalCount,_that.generatedAt,_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _SenasaExportHistoryItem implements SenasaExportHistoryItem {
  const _SenasaExportHistoryItem({required this.id, required this.establishmentId, required this.filename, required this.mediaType, required this.animalCount, required this.generatedAt, this.from, this.to});
  

@override final  String id;
@override final  String establishmentId;
@override final  String filename;
@override final  String mediaType;
@override final  int animalCount;
@override final  DateTime generatedAt;
@override final  DateTime? from;
@override final  DateTime? to;

/// Create a copy of SenasaExportHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenasaExportHistoryItemCopyWith<_SenasaExportHistoryItem> get copyWith => __$SenasaExportHistoryItemCopyWithImpl<_SenasaExportHistoryItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenasaExportHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.animalCount, animalCount) || other.animalCount == animalCount)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,id,establishmentId,filename,mediaType,animalCount,generatedAt,from,to);

@override
String toString() {
  return 'SenasaExportHistoryItem(id: $id, establishmentId: $establishmentId, filename: $filename, mediaType: $mediaType, animalCount: $animalCount, generatedAt: $generatedAt, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$SenasaExportHistoryItemCopyWith<$Res> implements $SenasaExportHistoryItemCopyWith<$Res> {
  factory _$SenasaExportHistoryItemCopyWith(_SenasaExportHistoryItem value, $Res Function(_SenasaExportHistoryItem) _then) = __$SenasaExportHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, String filename, String mediaType, int animalCount, DateTime generatedAt, DateTime? from, DateTime? to
});




}
/// @nodoc
class __$SenasaExportHistoryItemCopyWithImpl<$Res>
    implements _$SenasaExportHistoryItemCopyWith<$Res> {
  __$SenasaExportHistoryItemCopyWithImpl(this._self, this._then);

  final _SenasaExportHistoryItem _self;
  final $Res Function(_SenasaExportHistoryItem) _then;

/// Create a copy of SenasaExportHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? filename = null,Object? mediaType = null,Object? animalCount = null,Object? generatedAt = null,Object? from = freezed,Object? to = freezed,}) {
  return _then(_SenasaExportHistoryItem(
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
