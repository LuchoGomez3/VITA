// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalWeightRecord {

/// UUID del pesaje.
 String get id;/// Peso registrado en kilogramos.
 double get weightKg;/// Fecha y hora en que se realizo el pesaje.
 DateTime get date;/// Metodo usado para obtener el peso.
 AnimalWeighingMethod get method;
/// Create a copy of AnimalWeightRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalWeightRecordCopyWith<AnimalWeightRecord> get copyWith => _$AnimalWeightRecordCopyWithImpl<AnimalWeightRecord>(this as AnimalWeightRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalWeightRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.date, date) || other.date == date)&&(identical(other.method, method) || other.method == method));
}


@override
int get hashCode => Object.hash(runtimeType,id,weightKg,date,method);

@override
String toString() {
  return 'AnimalWeightRecord(id: $id, weightKg: $weightKg, date: $date, method: $method)';
}


}

/// @nodoc
abstract mixin class $AnimalWeightRecordCopyWith<$Res>  {
  factory $AnimalWeightRecordCopyWith(AnimalWeightRecord value, $Res Function(AnimalWeightRecord) _then) = _$AnimalWeightRecordCopyWithImpl;
@useResult
$Res call({
 String id, double weightKg, DateTime date, AnimalWeighingMethod method
});




}
/// @nodoc
class _$AnimalWeightRecordCopyWithImpl<$Res>
    implements $AnimalWeightRecordCopyWith<$Res> {
  _$AnimalWeightRecordCopyWithImpl(this._self, this._then);

  final AnimalWeightRecord _self;
  final $Res Function(AnimalWeightRecord) _then;

/// Create a copy of AnimalWeightRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? weightKg = null,Object? date = null,Object? method = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalWeightRecord].
extension AnimalWeightRecordPatterns on AnimalWeightRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalWeightRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalWeightRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalWeightRecord value)  $default,){
final _that = this;
switch (_that) {
case _AnimalWeightRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalWeightRecord value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalWeightRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double weightKg,  DateTime date,  AnimalWeighingMethod method)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalWeightRecord() when $default != null:
return $default(_that.id,_that.weightKg,_that.date,_that.method);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double weightKg,  DateTime date,  AnimalWeighingMethod method)  $default,) {final _that = this;
switch (_that) {
case _AnimalWeightRecord():
return $default(_that.id,_that.weightKg,_that.date,_that.method);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double weightKg,  DateTime date,  AnimalWeighingMethod method)?  $default,) {final _that = this;
switch (_that) {
case _AnimalWeightRecord() when $default != null:
return $default(_that.id,_that.weightKg,_that.date,_that.method);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalWeightRecord implements AnimalWeightRecord {
  const _AnimalWeightRecord({required this.id, required this.weightKg, required this.date, required this.method});
  

/// UUID del pesaje.
@override final  String id;
/// Peso registrado en kilogramos.
@override final  double weightKg;
/// Fecha y hora en que se realizo el pesaje.
@override final  DateTime date;
/// Metodo usado para obtener el peso.
@override final  AnimalWeighingMethod method;

/// Create a copy of AnimalWeightRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalWeightRecordCopyWith<_AnimalWeightRecord> get copyWith => __$AnimalWeightRecordCopyWithImpl<_AnimalWeightRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalWeightRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.date, date) || other.date == date)&&(identical(other.method, method) || other.method == method));
}


@override
int get hashCode => Object.hash(runtimeType,id,weightKg,date,method);

@override
String toString() {
  return 'AnimalWeightRecord(id: $id, weightKg: $weightKg, date: $date, method: $method)';
}


}

/// @nodoc
abstract mixin class _$AnimalWeightRecordCopyWith<$Res> implements $AnimalWeightRecordCopyWith<$Res> {
  factory _$AnimalWeightRecordCopyWith(_AnimalWeightRecord value, $Res Function(_AnimalWeightRecord) _then) = __$AnimalWeightRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, double weightKg, DateTime date, AnimalWeighingMethod method
});




}
/// @nodoc
class __$AnimalWeightRecordCopyWithImpl<$Res>
    implements _$AnimalWeightRecordCopyWith<$Res> {
  __$AnimalWeightRecordCopyWithImpl(this._self, this._then);

  final _AnimalWeightRecord _self;
  final $Res Function(_AnimalWeightRecord) _then;

/// Create a copy of AnimalWeightRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? weightKg = null,Object? date = null,Object? method = null,}) {
  return _then(_AnimalWeightRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,
  ));
}


}

/// @nodoc
mixin _$AnimalDetailCategory {

 String get id; String get name; bool get allowsReproductiveStatus; AnimalSex? get allowedSex;
/// Create a copy of AnimalDetailCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalDetailCategoryCopyWith<AnimalDetailCategory> get copyWith => _$AnimalDetailCategoryCopyWithImpl<AnimalDetailCategory>(this as AnimalDetailCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDetailCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.allowsReproductiveStatus, allowsReproductiveStatus) || other.allowsReproductiveStatus == allowsReproductiveStatus)&&(identical(other.allowedSex, allowedSex) || other.allowedSex == allowedSex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,allowsReproductiveStatus,allowedSex);

@override
String toString() {
  return 'AnimalDetailCategory(id: $id, name: $name, allowsReproductiveStatus: $allowsReproductiveStatus, allowedSex: $allowedSex)';
}


}

/// @nodoc
abstract mixin class $AnimalDetailCategoryCopyWith<$Res>  {
  factory $AnimalDetailCategoryCopyWith(AnimalDetailCategory value, $Res Function(AnimalDetailCategory) _then) = _$AnimalDetailCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool allowsReproductiveStatus, AnimalSex? allowedSex
});




}
/// @nodoc
class _$AnimalDetailCategoryCopyWithImpl<$Res>
    implements $AnimalDetailCategoryCopyWith<$Res> {
  _$AnimalDetailCategoryCopyWithImpl(this._self, this._then);

  final AnimalDetailCategory _self;
  final $Res Function(AnimalDetailCategory) _then;

/// Create a copy of AnimalDetailCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? allowsReproductiveStatus = null,Object? allowedSex = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,allowsReproductiveStatus: null == allowsReproductiveStatus ? _self.allowsReproductiveStatus : allowsReproductiveStatus // ignore: cast_nullable_to_non_nullable
as bool,allowedSex: freezed == allowedSex ? _self.allowedSex : allowedSex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalDetailCategory].
extension AnimalDetailCategoryPatterns on AnimalDetailCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalDetailCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalDetailCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalDetailCategory value)  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalDetailCategory value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool allowsReproductiveStatus,  AnimalSex? allowedSex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalDetailCategory() when $default != null:
return $default(_that.id,_that.name,_that.allowsReproductiveStatus,_that.allowedSex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool allowsReproductiveStatus,  AnimalSex? allowedSex)  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailCategory():
return $default(_that.id,_that.name,_that.allowsReproductiveStatus,_that.allowedSex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool allowsReproductiveStatus,  AnimalSex? allowedSex)?  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailCategory() when $default != null:
return $default(_that.id,_that.name,_that.allowsReproductiveStatus,_that.allowedSex);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalDetailCategory implements AnimalDetailCategory {
  const _AnimalDetailCategory({required this.id, required this.name, required this.allowsReproductiveStatus, this.allowedSex});
  

@override final  String id;
@override final  String name;
@override final  bool allowsReproductiveStatus;
@override final  AnimalSex? allowedSex;

/// Create a copy of AnimalDetailCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalDetailCategoryCopyWith<_AnimalDetailCategory> get copyWith => __$AnimalDetailCategoryCopyWithImpl<_AnimalDetailCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalDetailCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.allowsReproductiveStatus, allowsReproductiveStatus) || other.allowsReproductiveStatus == allowsReproductiveStatus)&&(identical(other.allowedSex, allowedSex) || other.allowedSex == allowedSex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,allowsReproductiveStatus,allowedSex);

@override
String toString() {
  return 'AnimalDetailCategory(id: $id, name: $name, allowsReproductiveStatus: $allowsReproductiveStatus, allowedSex: $allowedSex)';
}


}

/// @nodoc
abstract mixin class _$AnimalDetailCategoryCopyWith<$Res> implements $AnimalDetailCategoryCopyWith<$Res> {
  factory _$AnimalDetailCategoryCopyWith(_AnimalDetailCategory value, $Res Function(_AnimalDetailCategory) _then) = __$AnimalDetailCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool allowsReproductiveStatus, AnimalSex? allowedSex
});




}
/// @nodoc
class __$AnimalDetailCategoryCopyWithImpl<$Res>
    implements _$AnimalDetailCategoryCopyWith<$Res> {
  __$AnimalDetailCategoryCopyWithImpl(this._self, this._then);

  final _AnimalDetailCategory _self;
  final $Res Function(_AnimalDetailCategory) _then;

/// Create a copy of AnimalDetailCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? allowsReproductiveStatus = null,Object? allowedSex = freezed,}) {
  return _then(_AnimalDetailCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,allowsReproductiveStatus: null == allowsReproductiveStatus ? _self.allowsReproductiveStatus : allowsReproductiveStatus // ignore: cast_nullable_to_non_nullable
as bool,allowedSex: freezed == allowedSex ? _self.allowedSex : allowedSex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,
  ));
}


}

/// @nodoc
mixin _$AnimalDetailObservation {

 String get id; String get text; DateTime get date; AnimalSyncStatus get syncStatus; String? get syncErrorCode;
/// Create a copy of AnimalDetailObservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalDetailObservationCopyWith<AnimalDetailObservation> get copyWith => _$AnimalDetailObservationCopyWithImpl<AnimalDetailObservation>(this as AnimalDetailObservation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDetailObservation&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.date, date) || other.date == date)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,date,syncStatus,syncErrorCode);

@override
String toString() {
  return 'AnimalDetailObservation(id: $id, text: $text, date: $date, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $AnimalDetailObservationCopyWith<$Res>  {
  factory $AnimalDetailObservationCopyWith(AnimalDetailObservation value, $Res Function(AnimalDetailObservation) _then) = _$AnimalDetailObservationCopyWithImpl;
@useResult
$Res call({
 String id, String text, DateTime date, AnimalSyncStatus syncStatus, String? syncErrorCode
});




}
/// @nodoc
class _$AnimalDetailObservationCopyWithImpl<$Res>
    implements $AnimalDetailObservationCopyWith<$Res> {
  _$AnimalDetailObservationCopyWithImpl(this._self, this._then);

  final AnimalDetailObservation _self;
  final $Res Function(AnimalDetailObservation) _then;

/// Create a copy of AnimalDetailObservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? date = null,Object? syncStatus = null,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalDetailObservation].
extension AnimalDetailObservationPatterns on AnimalDetailObservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalDetailObservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalDetailObservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalDetailObservation value)  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailObservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalDetailObservation value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailObservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  DateTime date,  AnimalSyncStatus syncStatus,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalDetailObservation() when $default != null:
return $default(_that.id,_that.text,_that.date,_that.syncStatus,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  DateTime date,  AnimalSyncStatus syncStatus,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailObservation():
return $default(_that.id,_that.text,_that.date,_that.syncStatus,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  DateTime date,  AnimalSyncStatus syncStatus,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailObservation() when $default != null:
return $default(_that.id,_that.text,_that.date,_that.syncStatus,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalDetailObservation implements AnimalDetailObservation {
  const _AnimalDetailObservation({required this.id, required this.text, required this.date, required this.syncStatus, this.syncErrorCode});
  

@override final  String id;
@override final  String text;
@override final  DateTime date;
@override final  AnimalSyncStatus syncStatus;
@override final  String? syncErrorCode;

/// Create a copy of AnimalDetailObservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalDetailObservationCopyWith<_AnimalDetailObservation> get copyWith => __$AnimalDetailObservationCopyWithImpl<_AnimalDetailObservation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalDetailObservation&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.date, date) || other.date == date)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,date,syncStatus,syncErrorCode);

@override
String toString() {
  return 'AnimalDetailObservation(id: $id, text: $text, date: $date, syncStatus: $syncStatus, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$AnimalDetailObservationCopyWith<$Res> implements $AnimalDetailObservationCopyWith<$Res> {
  factory _$AnimalDetailObservationCopyWith(_AnimalDetailObservation value, $Res Function(_AnimalDetailObservation) _then) = __$AnimalDetailObservationCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, DateTime date, AnimalSyncStatus syncStatus, String? syncErrorCode
});




}
/// @nodoc
class __$AnimalDetailObservationCopyWithImpl<$Res>
    implements _$AnimalDetailObservationCopyWith<$Res> {
  __$AnimalDetailObservationCopyWithImpl(this._self, this._then);

  final _AnimalDetailObservation _self;
  final $Res Function(_AnimalDetailObservation) _then;

/// Create a copy of AnimalDetailObservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? date = null,Object? syncStatus = null,Object? syncErrorCode = freezed,}) {
  return _then(_AnimalDetailObservation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AnimalLotMovementEvent {

 String get id; DateTime get date; String get destinationName; String get reason; AnimalSyncStatus get syncStatus; String? get sourceName; String? get syncErrorCode;
/// Create a copy of AnimalLotMovementEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalLotMovementEventCopyWith<AnimalLotMovementEvent> get copyWith => _$AnimalLotMovementEventCopyWithImpl<AnimalLotMovementEvent>(this as AnimalLotMovementEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalLotMovementEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.destinationName, destinationName) || other.destinationName == destinationName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,destinationName,reason,syncStatus,sourceName,syncErrorCode);

@override
String toString() {
  return 'AnimalLotMovementEvent(id: $id, date: $date, destinationName: $destinationName, reason: $reason, syncStatus: $syncStatus, sourceName: $sourceName, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $AnimalLotMovementEventCopyWith<$Res>  {
  factory $AnimalLotMovementEventCopyWith(AnimalLotMovementEvent value, $Res Function(AnimalLotMovementEvent) _then) = _$AnimalLotMovementEventCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, String destinationName, String reason, AnimalSyncStatus syncStatus, String? sourceName, String? syncErrorCode
});




}
/// @nodoc
class _$AnimalLotMovementEventCopyWithImpl<$Res>
    implements $AnimalLotMovementEventCopyWith<$Res> {
  _$AnimalLotMovementEventCopyWithImpl(this._self, this._then);

  final AnimalLotMovementEvent _self;
  final $Res Function(AnimalLotMovementEvent) _then;

/// Create a copy of AnimalLotMovementEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? destinationName = null,Object? reason = null,Object? syncStatus = null,Object? sourceName = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,destinationName: null == destinationName ? _self.destinationName : destinationName // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalLotMovementEvent].
extension AnimalLotMovementEventPatterns on AnimalLotMovementEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalLotMovementEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalLotMovementEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalLotMovementEvent value)  $default,){
final _that = this;
switch (_that) {
case _AnimalLotMovementEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalLotMovementEvent value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalLotMovementEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  String destinationName,  String reason,  AnimalSyncStatus syncStatus,  String? sourceName,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalLotMovementEvent() when $default != null:
return $default(_that.id,_that.date,_that.destinationName,_that.reason,_that.syncStatus,_that.sourceName,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  String destinationName,  String reason,  AnimalSyncStatus syncStatus,  String? sourceName,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _AnimalLotMovementEvent():
return $default(_that.id,_that.date,_that.destinationName,_that.reason,_that.syncStatus,_that.sourceName,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  String destinationName,  String reason,  AnimalSyncStatus syncStatus,  String? sourceName,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _AnimalLotMovementEvent() when $default != null:
return $default(_that.id,_that.date,_that.destinationName,_that.reason,_that.syncStatus,_that.sourceName,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalLotMovementEvent implements AnimalLotMovementEvent {
  const _AnimalLotMovementEvent({required this.id, required this.date, required this.destinationName, required this.reason, required this.syncStatus, this.sourceName, this.syncErrorCode});
  

@override final  String id;
@override final  DateTime date;
@override final  String destinationName;
@override final  String reason;
@override final  AnimalSyncStatus syncStatus;
@override final  String? sourceName;
@override final  String? syncErrorCode;

/// Create a copy of AnimalLotMovementEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalLotMovementEventCopyWith<_AnimalLotMovementEvent> get copyWith => __$AnimalLotMovementEventCopyWithImpl<_AnimalLotMovementEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalLotMovementEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.destinationName, destinationName) || other.destinationName == destinationName)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,destinationName,reason,syncStatus,sourceName,syncErrorCode);

@override
String toString() {
  return 'AnimalLotMovementEvent(id: $id, date: $date, destinationName: $destinationName, reason: $reason, syncStatus: $syncStatus, sourceName: $sourceName, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$AnimalLotMovementEventCopyWith<$Res> implements $AnimalLotMovementEventCopyWith<$Res> {
  factory _$AnimalLotMovementEventCopyWith(_AnimalLotMovementEvent value, $Res Function(_AnimalLotMovementEvent) _then) = __$AnimalLotMovementEventCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, String destinationName, String reason, AnimalSyncStatus syncStatus, String? sourceName, String? syncErrorCode
});




}
/// @nodoc
class __$AnimalLotMovementEventCopyWithImpl<$Res>
    implements _$AnimalLotMovementEventCopyWith<$Res> {
  __$AnimalLotMovementEventCopyWithImpl(this._self, this._then);

  final _AnimalLotMovementEvent _self;
  final $Res Function(_AnimalLotMovementEvent) _then;

/// Create a copy of AnimalLotMovementEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? destinationName = null,Object? reason = null,Object? syncStatus = null,Object? sourceName = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_AnimalLotMovementEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,destinationName: null == destinationName ? _self.destinationName : destinationName // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,sourceName: freezed == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AnimalDetail {

/// UUID generado por mobile y usado tambien por backend.
 String get id;/// Numero RFID oficial del animal.
 String get rfidTagNumber;/// Numero visual de caravana mostrado en UI.
 String get visualTag;/// Sexo del animal.
 AnimalSex get sex;/// Raza declarada del animal.
 String get breed;/// Fecha de nacimiento.
 DateTime get birthDate;/// ID backend de la categoria productiva.
 String get categoryId;/// Nombre visible de la categoria si existe en cache local.
 String get categoryName;/// ID backend del lote/potrero actual.
 String get lotId;/// Nombre visible del lote si existe en cache local.
 String get lotName;/// ID backend del establecimiento.
 String get establishmentId;/// Ultimo peso conocido por la app.
 double get currentWeight;/// Metodo asociado al ultimo peso conocido.
 AnimalWeighingMethod get weighingMethod;/// Fecha del ultimo pesaje conocido.
 DateTime get weighingDate;/// Estado local de sincronizacion con backend.
 AnimalSyncStatus get syncStatus;/// Ultima actualizacion conocida.
 DateTime get updatedAt;/// Historial real de pesajes ordenado desde el mas antiguo al mas reciente.
 List<AnimalWeightRecord> get weightHistory;/// Estado productivo del animal; una muerte no implica borrado lógico.
 AnimalStatus get status;/// Condición reproductiva opcional leída del backend o del cambio local.
 AnimalReproductiveStatus? get reproductiveStatus;/// Catálogo del establecimiento disponible también sin conexión.
 List<AnimalDetailCategory> get categories;/// Entradas independientes; no reemplazan el texto legacy del alta.
 List<AnimalDetailObservation> get observationHistory;/// Movimientos locales y remotos; incluye pendientes y rechazos visibles.
 List<AnimalLotMovementEvent> get lotMovementHistory;/// ID backend de la madre, si existe.
 String? get motherId;/// ID backend del padre, si existe.
 String? get fatherId;/// Pelaje declarado.
 String? get coat;/// Observaciones libres.
 String? get observations;/// Ruta de la foto guardada en los datos privados de esta instalación.
 String? get localPhotoPath;/// Foto incluida en la app por caravana, usada si no hay captura local.
 String? get photoAssetPath;/// Codigo de rechazo de sync guardado localmente.
 String? get syncErrorCode;
/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalDetailCopyWith<AnimalDetail> get copyWith => _$AnimalDetailCopyWithImpl<AnimalDetail>(this as AnimalDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.weightHistory, weightHistory)&&(identical(other.status, status) || other.status == status)&&(identical(other.reproductiveStatus, reproductiveStatus) || other.reproductiveStatus == reproductiveStatus)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.observationHistory, observationHistory)&&const DeepCollectionEquality().equals(other.lotMovementHistory, lotMovementHistory)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.localPhotoPath, localPhotoPath) || other.localPhotoPath == localPhotoPath)&&(identical(other.photoAssetPath, photoAssetPath) || other.photoAssetPath == photoAssetPath)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,rfidTagNumber,visualTag,sex,breed,birthDate,categoryId,categoryName,lotId,lotName,establishmentId,currentWeight,weighingMethod,weighingDate,syncStatus,updatedAt,const DeepCollectionEquality().hash(weightHistory),status,reproductiveStatus,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(observationHistory),const DeepCollectionEquality().hash(lotMovementHistory),motherId,fatherId,coat,observations,localPhotoPath,photoAssetPath,syncErrorCode]);

@override
String toString() {
  return 'AnimalDetail(id: $id, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, birthDate: $birthDate, categoryId: $categoryId, categoryName: $categoryName, lotId: $lotId, lotName: $lotName, establishmentId: $establishmentId, currentWeight: $currentWeight, weighingMethod: $weighingMethod, weighingDate: $weighingDate, syncStatus: $syncStatus, updatedAt: $updatedAt, weightHistory: $weightHistory, status: $status, reproductiveStatus: $reproductiveStatus, categories: $categories, observationHistory: $observationHistory, lotMovementHistory: $lotMovementHistory, motherId: $motherId, fatherId: $fatherId, coat: $coat, observations: $observations, localPhotoPath: $localPhotoPath, photoAssetPath: $photoAssetPath, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $AnimalDetailCopyWith<$Res>  {
  factory $AnimalDetailCopyWith(AnimalDetail value, $Res Function(AnimalDetail) _then) = _$AnimalDetailCopyWithImpl;
@useResult
$Res call({
 String id, String rfidTagNumber, String visualTag, AnimalSex sex, String breed, DateTime birthDate, String categoryId, String categoryName, String lotId, String lotName, String establishmentId, double currentWeight, AnimalWeighingMethod weighingMethod, DateTime weighingDate, AnimalSyncStatus syncStatus, DateTime updatedAt, List<AnimalWeightRecord> weightHistory, AnimalStatus status, AnimalReproductiveStatus? reproductiveStatus, List<AnimalDetailCategory> categories, List<AnimalDetailObservation> observationHistory, List<AnimalLotMovementEvent> lotMovementHistory, String? motherId, String? fatherId, String? coat, String? observations, String? localPhotoPath, String? photoAssetPath, String? syncErrorCode
});




}
/// @nodoc
class _$AnimalDetailCopyWithImpl<$Res>
    implements $AnimalDetailCopyWith<$Res> {
  _$AnimalDetailCopyWithImpl(this._self, this._then);

  final AnimalDetail _self;
  final $Res Function(AnimalDetail) _then;

/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? categoryId = null,Object? categoryName = null,Object? lotId = null,Object? lotName = null,Object? establishmentId = null,Object? currentWeight = null,Object? weighingMethod = null,Object? weighingDate = null,Object? syncStatus = null,Object? updatedAt = null,Object? weightHistory = null,Object? status = null,Object? reproductiveStatus = freezed,Object? categories = null,Object? observationHistory = null,Object? lotMovementHistory = null,Object? motherId = freezed,Object? fatherId = freezed,Object? coat = freezed,Object? observations = freezed,Object? localPhotoPath = freezed,Object? photoAssetPath = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,weighingMethod: null == weighingMethod ? _self.weighingMethod : weighingMethod // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,weighingDate: null == weighingDate ? _self.weighingDate : weighingDate // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weightHistory: null == weightHistory ? _self.weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
as List<AnimalWeightRecord>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnimalStatus,reproductiveStatus: freezed == reproductiveStatus ? _self.reproductiveStatus : reproductiveStatus // ignore: cast_nullable_to_non_nullable
as AnimalReproductiveStatus?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<AnimalDetailCategory>,observationHistory: null == observationHistory ? _self.observationHistory : observationHistory // ignore: cast_nullable_to_non_nullable
as List<AnimalDetailObservation>,lotMovementHistory: null == lotMovementHistory ? _self.lotMovementHistory : lotMovementHistory // ignore: cast_nullable_to_non_nullable
as List<AnimalLotMovementEvent>,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,coat: freezed == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,localPhotoPath: freezed == localPhotoPath ? _self.localPhotoPath : localPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,photoAssetPath: freezed == photoAssetPath ? _self.photoAssetPath : photoAssetPath // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalDetail].
extension AnimalDetailPatterns on AnimalDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalDetail value)  $default,){
final _that = this;
switch (_that) {
case _AnimalDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String categoryId,  String categoryName,  String lotId,  String lotName,  String establishmentId,  double currentWeight,  AnimalWeighingMethod weighingMethod,  DateTime weighingDate,  AnimalSyncStatus syncStatus,  DateTime updatedAt,  List<AnimalWeightRecord> weightHistory,  AnimalStatus status,  AnimalReproductiveStatus? reproductiveStatus,  List<AnimalDetailCategory> categories,  List<AnimalDetailObservation> observationHistory,  List<AnimalLotMovementEvent> lotMovementHistory,  String? motherId,  String? fatherId,  String? coat,  String? observations,  String? localPhotoPath,  String? photoAssetPath,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.categoryId,_that.categoryName,_that.lotId,_that.lotName,_that.establishmentId,_that.currentWeight,_that.weighingMethod,_that.weighingDate,_that.syncStatus,_that.updatedAt,_that.weightHistory,_that.status,_that.reproductiveStatus,_that.categories,_that.observationHistory,_that.lotMovementHistory,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.localPhotoPath,_that.photoAssetPath,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String categoryId,  String categoryName,  String lotId,  String lotName,  String establishmentId,  double currentWeight,  AnimalWeighingMethod weighingMethod,  DateTime weighingDate,  AnimalSyncStatus syncStatus,  DateTime updatedAt,  List<AnimalWeightRecord> weightHistory,  AnimalStatus status,  AnimalReproductiveStatus? reproductiveStatus,  List<AnimalDetailCategory> categories,  List<AnimalDetailObservation> observationHistory,  List<AnimalLotMovementEvent> lotMovementHistory,  String? motherId,  String? fatherId,  String? coat,  String? observations,  String? localPhotoPath,  String? photoAssetPath,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _AnimalDetail():
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.categoryId,_that.categoryName,_that.lotId,_that.lotName,_that.establishmentId,_that.currentWeight,_that.weighingMethod,_that.weighingDate,_that.syncStatus,_that.updatedAt,_that.weightHistory,_that.status,_that.reproductiveStatus,_that.categories,_that.observationHistory,_that.lotMovementHistory,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.localPhotoPath,_that.photoAssetPath,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rfidTagNumber,  String visualTag,  AnimalSex sex,  String breed,  DateTime birthDate,  String categoryId,  String categoryName,  String lotId,  String lotName,  String establishmentId,  double currentWeight,  AnimalWeighingMethod weighingMethod,  DateTime weighingDate,  AnimalSyncStatus syncStatus,  DateTime updatedAt,  List<AnimalWeightRecord> weightHistory,  AnimalStatus status,  AnimalReproductiveStatus? reproductiveStatus,  List<AnimalDetailCategory> categories,  List<AnimalDetailObservation> observationHistory,  List<AnimalLotMovementEvent> lotMovementHistory,  String? motherId,  String? fatherId,  String? coat,  String? observations,  String? localPhotoPath,  String? photoAssetPath,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _AnimalDetail() when $default != null:
return $default(_that.id,_that.rfidTagNumber,_that.visualTag,_that.sex,_that.breed,_that.birthDate,_that.categoryId,_that.categoryName,_that.lotId,_that.lotName,_that.establishmentId,_that.currentWeight,_that.weighingMethod,_that.weighingDate,_that.syncStatus,_that.updatedAt,_that.weightHistory,_that.status,_that.reproductiveStatus,_that.categories,_that.observationHistory,_that.lotMovementHistory,_that.motherId,_that.fatherId,_that.coat,_that.observations,_that.localPhotoPath,_that.photoAssetPath,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalDetail implements AnimalDetail {
  const _AnimalDetail({required this.id, required this.rfidTagNumber, required this.visualTag, required this.sex, required this.breed, required this.birthDate, required this.categoryId, required this.categoryName, required this.lotId, required this.lotName, required this.establishmentId, required this.currentWeight, required this.weighingMethod, required this.weighingDate, required this.syncStatus, required this.updatedAt, required final  List<AnimalWeightRecord> weightHistory, this.status = AnimalStatus.active, this.reproductiveStatus, final  List<AnimalDetailCategory> categories = const <AnimalDetailCategory>[], final  List<AnimalDetailObservation> observationHistory = const <AnimalDetailObservation>[], final  List<AnimalLotMovementEvent> lotMovementHistory = const <AnimalLotMovementEvent>[], this.motherId, this.fatherId, this.coat, this.observations, this.localPhotoPath, this.photoAssetPath, this.syncErrorCode}): _weightHistory = weightHistory,_categories = categories,_observationHistory = observationHistory,_lotMovementHistory = lotMovementHistory;
  

/// UUID generado por mobile y usado tambien por backend.
@override final  String id;
/// Numero RFID oficial del animal.
@override final  String rfidTagNumber;
/// Numero visual de caravana mostrado en UI.
@override final  String visualTag;
/// Sexo del animal.
@override final  AnimalSex sex;
/// Raza declarada del animal.
@override final  String breed;
/// Fecha de nacimiento.
@override final  DateTime birthDate;
/// ID backend de la categoria productiva.
@override final  String categoryId;
/// Nombre visible de la categoria si existe en cache local.
@override final  String categoryName;
/// ID backend del lote/potrero actual.
@override final  String lotId;
/// Nombre visible del lote si existe en cache local.
@override final  String lotName;
/// ID backend del establecimiento.
@override final  String establishmentId;
/// Ultimo peso conocido por la app.
@override final  double currentWeight;
/// Metodo asociado al ultimo peso conocido.
@override final  AnimalWeighingMethod weighingMethod;
/// Fecha del ultimo pesaje conocido.
@override final  DateTime weighingDate;
/// Estado local de sincronizacion con backend.
@override final  AnimalSyncStatus syncStatus;
/// Ultima actualizacion conocida.
@override final  DateTime updatedAt;
/// Historial real de pesajes ordenado desde el mas antiguo al mas reciente.
 final  List<AnimalWeightRecord> _weightHistory;
/// Historial real de pesajes ordenado desde el mas antiguo al mas reciente.
@override List<AnimalWeightRecord> get weightHistory {
  if (_weightHistory is EqualUnmodifiableListView) return _weightHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weightHistory);
}

/// Estado productivo del animal; una muerte no implica borrado lógico.
@override@JsonKey() final  AnimalStatus status;
/// Condición reproductiva opcional leída del backend o del cambio local.
@override final  AnimalReproductiveStatus? reproductiveStatus;
/// Catálogo del establecimiento disponible también sin conexión.
 final  List<AnimalDetailCategory> _categories;
/// Catálogo del establecimiento disponible también sin conexión.
@override@JsonKey() List<AnimalDetailCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// Entradas independientes; no reemplazan el texto legacy del alta.
 final  List<AnimalDetailObservation> _observationHistory;
/// Entradas independientes; no reemplazan el texto legacy del alta.
@override@JsonKey() List<AnimalDetailObservation> get observationHistory {
  if (_observationHistory is EqualUnmodifiableListView) return _observationHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_observationHistory);
}

/// Movimientos locales y remotos; incluye pendientes y rechazos visibles.
 final  List<AnimalLotMovementEvent> _lotMovementHistory;
/// Movimientos locales y remotos; incluye pendientes y rechazos visibles.
@override@JsonKey() List<AnimalLotMovementEvent> get lotMovementHistory {
  if (_lotMovementHistory is EqualUnmodifiableListView) return _lotMovementHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lotMovementHistory);
}

/// ID backend de la madre, si existe.
@override final  String? motherId;
/// ID backend del padre, si existe.
@override final  String? fatherId;
/// Pelaje declarado.
@override final  String? coat;
/// Observaciones libres.
@override final  String? observations;
/// Ruta de la foto guardada en los datos privados de esta instalación.
@override final  String? localPhotoPath;
/// Foto incluida en la app por caravana, usada si no hay captura local.
@override final  String? photoAssetPath;
/// Codigo de rechazo de sync guardado localmente.
@override final  String? syncErrorCode;

/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalDetailCopyWith<_AnimalDetail> get copyWith => __$AnimalDetailCopyWithImpl<_AnimalDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber)&&(identical(other.visualTag, visualTag) || other.visualTag == visualTag)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.lotName, lotName) || other.lotName == lotName)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.weighingMethod, weighingMethod) || other.weighingMethod == weighingMethod)&&(identical(other.weighingDate, weighingDate) || other.weighingDate == weighingDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._weightHistory, _weightHistory)&&(identical(other.status, status) || other.status == status)&&(identical(other.reproductiveStatus, reproductiveStatus) || other.reproductiveStatus == reproductiveStatus)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._observationHistory, _observationHistory)&&const DeepCollectionEquality().equals(other._lotMovementHistory, _lotMovementHistory)&&(identical(other.motherId, motherId) || other.motherId == motherId)&&(identical(other.fatherId, fatherId) || other.fatherId == fatherId)&&(identical(other.coat, coat) || other.coat == coat)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.localPhotoPath, localPhotoPath) || other.localPhotoPath == localPhotoPath)&&(identical(other.photoAssetPath, photoAssetPath) || other.photoAssetPath == photoAssetPath)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,rfidTagNumber,visualTag,sex,breed,birthDate,categoryId,categoryName,lotId,lotName,establishmentId,currentWeight,weighingMethod,weighingDate,syncStatus,updatedAt,const DeepCollectionEquality().hash(_weightHistory),status,reproductiveStatus,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_observationHistory),const DeepCollectionEquality().hash(_lotMovementHistory),motherId,fatherId,coat,observations,localPhotoPath,photoAssetPath,syncErrorCode]);

@override
String toString() {
  return 'AnimalDetail(id: $id, rfidTagNumber: $rfidTagNumber, visualTag: $visualTag, sex: $sex, breed: $breed, birthDate: $birthDate, categoryId: $categoryId, categoryName: $categoryName, lotId: $lotId, lotName: $lotName, establishmentId: $establishmentId, currentWeight: $currentWeight, weighingMethod: $weighingMethod, weighingDate: $weighingDate, syncStatus: $syncStatus, updatedAt: $updatedAt, weightHistory: $weightHistory, status: $status, reproductiveStatus: $reproductiveStatus, categories: $categories, observationHistory: $observationHistory, lotMovementHistory: $lotMovementHistory, motherId: $motherId, fatherId: $fatherId, coat: $coat, observations: $observations, localPhotoPath: $localPhotoPath, photoAssetPath: $photoAssetPath, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$AnimalDetailCopyWith<$Res> implements $AnimalDetailCopyWith<$Res> {
  factory _$AnimalDetailCopyWith(_AnimalDetail value, $Res Function(_AnimalDetail) _then) = __$AnimalDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String rfidTagNumber, String visualTag, AnimalSex sex, String breed, DateTime birthDate, String categoryId, String categoryName, String lotId, String lotName, String establishmentId, double currentWeight, AnimalWeighingMethod weighingMethod, DateTime weighingDate, AnimalSyncStatus syncStatus, DateTime updatedAt, List<AnimalWeightRecord> weightHistory, AnimalStatus status, AnimalReproductiveStatus? reproductiveStatus, List<AnimalDetailCategory> categories, List<AnimalDetailObservation> observationHistory, List<AnimalLotMovementEvent> lotMovementHistory, String? motherId, String? fatherId, String? coat, String? observations, String? localPhotoPath, String? photoAssetPath, String? syncErrorCode
});




}
/// @nodoc
class __$AnimalDetailCopyWithImpl<$Res>
    implements _$AnimalDetailCopyWith<$Res> {
  __$AnimalDetailCopyWithImpl(this._self, this._then);

  final _AnimalDetail _self;
  final $Res Function(_AnimalDetail) _then;

/// Create a copy of AnimalDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rfidTagNumber = null,Object? visualTag = null,Object? sex = null,Object? breed = null,Object? birthDate = null,Object? categoryId = null,Object? categoryName = null,Object? lotId = null,Object? lotName = null,Object? establishmentId = null,Object? currentWeight = null,Object? weighingMethod = null,Object? weighingDate = null,Object? syncStatus = null,Object? updatedAt = null,Object? weightHistory = null,Object? status = null,Object? reproductiveStatus = freezed,Object? categories = null,Object? observationHistory = null,Object? lotMovementHistory = null,Object? motherId = freezed,Object? fatherId = freezed,Object? coat = freezed,Object? observations = freezed,Object? localPhotoPath = freezed,Object? photoAssetPath = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_AnimalDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rfidTagNumber: null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,visualTag: null == visualTag ? _self.visualTag : visualTag // ignore: cast_nullable_to_non_nullable
as String,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,breed: null == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,lotId: null == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String,lotName: null == lotName ? _self.lotName : lotName // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,weighingMethod: null == weighingMethod ? _self.weighingMethod : weighingMethod // ignore: cast_nullable_to_non_nullable
as AnimalWeighingMethod,weighingDate: null == weighingDate ? _self.weighingDate : weighingDate // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as AnimalSyncStatus,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,weightHistory: null == weightHistory ? _self._weightHistory : weightHistory // ignore: cast_nullable_to_non_nullable
as List<AnimalWeightRecord>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnimalStatus,reproductiveStatus: freezed == reproductiveStatus ? _self.reproductiveStatus : reproductiveStatus // ignore: cast_nullable_to_non_nullable
as AnimalReproductiveStatus?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<AnimalDetailCategory>,observationHistory: null == observationHistory ? _self._observationHistory : observationHistory // ignore: cast_nullable_to_non_nullable
as List<AnimalDetailObservation>,lotMovementHistory: null == lotMovementHistory ? _self._lotMovementHistory : lotMovementHistory // ignore: cast_nullable_to_non_nullable
as List<AnimalLotMovementEvent>,motherId: freezed == motherId ? _self.motherId : motherId // ignore: cast_nullable_to_non_nullable
as String?,fatherId: freezed == fatherId ? _self.fatherId : fatherId // ignore: cast_nullable_to_non_nullable
as String?,coat: freezed == coat ? _self.coat : coat // ignore: cast_nullable_to_non_nullable
as String?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,localPhotoPath: freezed == localPhotoPath ? _self.localPhotoPath : localPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,photoAssetPath: freezed == photoAssetPath ? _self.photoAssetPath : photoAssetPath // ignore: cast_nullable_to_non_nullable
as String?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
