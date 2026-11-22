// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HealthEventDetails {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthEventDetails);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HealthEventDetails()';
}


}

/// @nodoc
class $HealthEventDetailsCopyWith<$Res>  {
$HealthEventDetailsCopyWith(HealthEventDetails _, $Res Function(HealthEventDetails) __);
}


/// Adds pattern-matching-related methods to [HealthEventDetails].
extension HealthEventDetailsPatterns on HealthEventDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HealthApplication value)?  application,TResult Function( HealthObservation value)?  observation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HealthApplication() when application != null:
return application(_that);case HealthObservation() when observation != null:
return observation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HealthApplication value)  application,required TResult Function( HealthObservation value)  observation,}){
final _that = this;
switch (_that) {
case HealthApplication():
return application(_that);case HealthObservation():
return observation(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HealthApplication value)?  application,TResult? Function( HealthObservation value)?  observation,}){
final _that = this;
switch (_that) {
case HealthApplication() when application != null:
return application(_that);case HealthObservation() when observation != null:
return observation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String productId,  String productName,  String dose,  String unit,  String route,  String? batch,  DateTime? expirationDate)?  application,TResult Function( String description,  String? sampleType)?  observation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HealthApplication() when application != null:
return application(_that.productId,_that.productName,_that.dose,_that.unit,_that.route,_that.batch,_that.expirationDate);case HealthObservation() when observation != null:
return observation(_that.description,_that.sampleType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String productId,  String productName,  String dose,  String unit,  String route,  String? batch,  DateTime? expirationDate)  application,required TResult Function( String description,  String? sampleType)  observation,}) {final _that = this;
switch (_that) {
case HealthApplication():
return application(_that.productId,_that.productName,_that.dose,_that.unit,_that.route,_that.batch,_that.expirationDate);case HealthObservation():
return observation(_that.description,_that.sampleType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String productId,  String productName,  String dose,  String unit,  String route,  String? batch,  DateTime? expirationDate)?  application,TResult? Function( String description,  String? sampleType)?  observation,}) {final _that = this;
switch (_that) {
case HealthApplication() when application != null:
return application(_that.productId,_that.productName,_that.dose,_that.unit,_that.route,_that.batch,_that.expirationDate);case HealthObservation() when observation != null:
return observation(_that.description,_that.sampleType);case _:
  return null;

}
}

}

/// @nodoc


class HealthApplication implements HealthEventDetails {
  const HealthApplication({required this.productId, required this.productName, required this.dose, required this.unit, required this.route, this.batch, this.expirationDate});
  

 final  String productId;
 final  String productName;
 final  String dose;
 final  String unit;
 final  String route;
 final  String? batch;
 final  DateTime? expirationDate;

/// Create a copy of HealthEventDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthApplicationCopyWith<HealthApplication> get copyWith => _$HealthApplicationCopyWithImpl<HealthApplication>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthApplication&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.dose, dose) || other.dose == dose)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.route, route) || other.route == route)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate));
}


@override
int get hashCode => Object.hash(runtimeType,productId,productName,dose,unit,route,batch,expirationDate);

@override
String toString() {
  return 'HealthEventDetails.application(productId: $productId, productName: $productName, dose: $dose, unit: $unit, route: $route, batch: $batch, expirationDate: $expirationDate)';
}


}

/// @nodoc
abstract mixin class $HealthApplicationCopyWith<$Res> implements $HealthEventDetailsCopyWith<$Res> {
  factory $HealthApplicationCopyWith(HealthApplication value, $Res Function(HealthApplication) _then) = _$HealthApplicationCopyWithImpl;
@useResult
$Res call({
 String productId, String productName, String dose, String unit, String route, String? batch, DateTime? expirationDate
});




}
/// @nodoc
class _$HealthApplicationCopyWithImpl<$Res>
    implements $HealthApplicationCopyWith<$Res> {
  _$HealthApplicationCopyWithImpl(this._self, this._then);

  final HealthApplication _self;
  final $Res Function(HealthApplication) _then;

/// Create a copy of HealthEventDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? dose = null,Object? unit = null,Object? route = null,Object? batch = freezed,Object? expirationDate = freezed,}) {
  return _then(HealthApplication(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,dose: null == dose ? _self.dose : dose // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,route: null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as String?,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class HealthObservation implements HealthEventDetails {
  const HealthObservation({required this.description, this.sampleType});
  

 final  String description;
 final  String? sampleType;

/// Create a copy of HealthEventDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthObservationCopyWith<HealthObservation> get copyWith => _$HealthObservationCopyWithImpl<HealthObservation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthObservation&&(identical(other.description, description) || other.description == description)&&(identical(other.sampleType, sampleType) || other.sampleType == sampleType));
}


@override
int get hashCode => Object.hash(runtimeType,description,sampleType);

@override
String toString() {
  return 'HealthEventDetails.observation(description: $description, sampleType: $sampleType)';
}


}

/// @nodoc
abstract mixin class $HealthObservationCopyWith<$Res> implements $HealthEventDetailsCopyWith<$Res> {
  factory $HealthObservationCopyWith(HealthObservation value, $Res Function(HealthObservation) _then) = _$HealthObservationCopyWithImpl;
@useResult
$Res call({
 String description, String? sampleType
});




}
/// @nodoc
class _$HealthObservationCopyWithImpl<$Res>
    implements $HealthObservationCopyWith<$Res> {
  _$HealthObservationCopyWithImpl(this._self, this._then);

  final HealthObservation _self;
  final $Res Function(HealthObservation) _then;

/// Create a copy of HealthEventDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? description = null,Object? sampleType = freezed,}) {
  return _then(HealthObservation(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,sampleType: freezed == sampleType ? _self.sampleType : sampleType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$HealthRecipient {

 String get animalId; String get label; String? get lotId; String? get sampleReference;
/// Create a copy of HealthRecipient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthRecipientCopyWith<HealthRecipient> get copyWith => _$HealthRecipientCopyWithImpl<HealthRecipient>(this as HealthRecipient, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthRecipient&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.label, label) || other.label == label)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.sampleReference, sampleReference) || other.sampleReference == sampleReference));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,label,lotId,sampleReference);

@override
String toString() {
  return 'HealthRecipient(animalId: $animalId, label: $label, lotId: $lotId, sampleReference: $sampleReference)';
}


}

/// @nodoc
abstract mixin class $HealthRecipientCopyWith<$Res>  {
  factory $HealthRecipientCopyWith(HealthRecipient value, $Res Function(HealthRecipient) _then) = _$HealthRecipientCopyWithImpl;
@useResult
$Res call({
 String animalId, String label, String? lotId, String? sampleReference
});




}
/// @nodoc
class _$HealthRecipientCopyWithImpl<$Res>
    implements $HealthRecipientCopyWith<$Res> {
  _$HealthRecipientCopyWithImpl(this._self, this._then);

  final HealthRecipient _self;
  final $Res Function(HealthRecipient) _then;

/// Create a copy of HealthRecipient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animalId = null,Object? label = null,Object? lotId = freezed,Object? sampleReference = freezed,}) {
  return _then(_self.copyWith(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,sampleReference: freezed == sampleReference ? _self.sampleReference : sampleReference // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthRecipient].
extension HealthRecipientPatterns on HealthRecipient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthRecipient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthRecipient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthRecipient value)  $default,){
final _that = this;
switch (_that) {
case _HealthRecipient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthRecipient value)?  $default,){
final _that = this;
switch (_that) {
case _HealthRecipient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String animalId,  String label,  String? lotId,  String? sampleReference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthRecipient() when $default != null:
return $default(_that.animalId,_that.label,_that.lotId,_that.sampleReference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String animalId,  String label,  String? lotId,  String? sampleReference)  $default,) {final _that = this;
switch (_that) {
case _HealthRecipient():
return $default(_that.animalId,_that.label,_that.lotId,_that.sampleReference);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String animalId,  String label,  String? lotId,  String? sampleReference)?  $default,) {final _that = this;
switch (_that) {
case _HealthRecipient() when $default != null:
return $default(_that.animalId,_that.label,_that.lotId,_that.sampleReference);case _:
  return null;

}
}

}

/// @nodoc


class _HealthRecipient implements HealthRecipient {
  const _HealthRecipient({required this.animalId, required this.label, this.lotId, this.sampleReference});
  

@override final  String animalId;
@override final  String label;
@override final  String? lotId;
@override final  String? sampleReference;

/// Create a copy of HealthRecipient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthRecipientCopyWith<_HealthRecipient> get copyWith => __$HealthRecipientCopyWithImpl<_HealthRecipient>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthRecipient&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.label, label) || other.label == label)&&(identical(other.lotId, lotId) || other.lotId == lotId)&&(identical(other.sampleReference, sampleReference) || other.sampleReference == sampleReference));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,label,lotId,sampleReference);

@override
String toString() {
  return 'HealthRecipient(animalId: $animalId, label: $label, lotId: $lotId, sampleReference: $sampleReference)';
}


}

/// @nodoc
abstract mixin class _$HealthRecipientCopyWith<$Res> implements $HealthRecipientCopyWith<$Res> {
  factory _$HealthRecipientCopyWith(_HealthRecipient value, $Res Function(_HealthRecipient) _then) = __$HealthRecipientCopyWithImpl;
@override @useResult
$Res call({
 String animalId, String label, String? lotId, String? sampleReference
});




}
/// @nodoc
class __$HealthRecipientCopyWithImpl<$Res>
    implements _$HealthRecipientCopyWith<$Res> {
  __$HealthRecipientCopyWithImpl(this._self, this._then);

  final _HealthRecipient _self;
  final $Res Function(_HealthRecipient) _then;

/// Create a copy of HealthRecipient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = null,Object? label = null,Object? lotId = freezed,Object? sampleReference = freezed,}) {
  return _then(_HealthRecipient(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,lotId: freezed == lotId ? _self.lotId : lotId // ignore: cast_nullable_to_non_nullable
as String?,sampleReference: freezed == sampleReference ? _self.sampleReference : sampleReference // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$HealthRegistration {

 String get establishmentId; DateTime get occurredAt; HealthPractice get practice; HealthEventDetails get details; String get responsible; List<HealthRecipient> get recipients; String? get notes;
/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthRegistrationCopyWith<HealthRegistration> get copyWith => _$HealthRegistrationCopyWithImpl<HealthRegistration>(this as HealthRegistration, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthRegistration&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.practice, practice) || other.practice == practice)&&(identical(other.details, details) || other.details == details)&&(identical(other.responsible, responsible) || other.responsible == responsible)&&const DeepCollectionEquality().equals(other.recipients, recipients)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,occurredAt,practice,details,responsible,const DeepCollectionEquality().hash(recipients),notes);

@override
String toString() {
  return 'HealthRegistration(establishmentId: $establishmentId, occurredAt: $occurredAt, practice: $practice, details: $details, responsible: $responsible, recipients: $recipients, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $HealthRegistrationCopyWith<$Res>  {
  factory $HealthRegistrationCopyWith(HealthRegistration value, $Res Function(HealthRegistration) _then) = _$HealthRegistrationCopyWithImpl;
@useResult
$Res call({
 String establishmentId, DateTime occurredAt, HealthPractice practice, HealthEventDetails details, String responsible, List<HealthRecipient> recipients, String? notes
});


$HealthPracticeCopyWith<$Res> get practice;$HealthEventDetailsCopyWith<$Res> get details;

}
/// @nodoc
class _$HealthRegistrationCopyWithImpl<$Res>
    implements $HealthRegistrationCopyWith<$Res> {
  _$HealthRegistrationCopyWithImpl(this._self, this._then);

  final HealthRegistration _self;
  final $Res Function(HealthRegistration) _then;

/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? occurredAt = null,Object? practice = null,Object? details = null,Object? responsible = null,Object? recipients = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,practice: null == practice ? _self.practice : practice // ignore: cast_nullable_to_non_nullable
as HealthPractice,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as HealthEventDetails,responsible: null == responsible ? _self.responsible : responsible // ignore: cast_nullable_to_non_nullable
as String,recipients: null == recipients ? _self.recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<HealthRecipient>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthPracticeCopyWith<$Res> get practice {
  
  return $HealthPracticeCopyWith<$Res>(_self.practice, (value) {
    return _then(_self.copyWith(practice: value));
  });
}/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthEventDetailsCopyWith<$Res> get details {
  
  return $HealthEventDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}


/// Adds pattern-matching-related methods to [HealthRegistration].
extension HealthRegistrationPatterns on HealthRegistration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthRegistration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthRegistration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthRegistration value)  $default,){
final _that = this;
switch (_that) {
case _HealthRegistration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthRegistration value)?  $default,){
final _that = this;
switch (_that) {
case _HealthRegistration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  DateTime occurredAt,  HealthPractice practice,  HealthEventDetails details,  String responsible,  List<HealthRecipient> recipients,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthRegistration() when $default != null:
return $default(_that.establishmentId,_that.occurredAt,_that.practice,_that.details,_that.responsible,_that.recipients,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  DateTime occurredAt,  HealthPractice practice,  HealthEventDetails details,  String responsible,  List<HealthRecipient> recipients,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _HealthRegistration():
return $default(_that.establishmentId,_that.occurredAt,_that.practice,_that.details,_that.responsible,_that.recipients,_that.notes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  DateTime occurredAt,  HealthPractice practice,  HealthEventDetails details,  String responsible,  List<HealthRecipient> recipients,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _HealthRegistration() when $default != null:
return $default(_that.establishmentId,_that.occurredAt,_that.practice,_that.details,_that.responsible,_that.recipients,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _HealthRegistration implements HealthRegistration {
  const _HealthRegistration({required this.establishmentId, required this.occurredAt, required this.practice, required this.details, required this.responsible, required final  List<HealthRecipient> recipients, this.notes}): _recipients = recipients;
  

@override final  String establishmentId;
@override final  DateTime occurredAt;
@override final  HealthPractice practice;
@override final  HealthEventDetails details;
@override final  String responsible;
 final  List<HealthRecipient> _recipients;
@override List<HealthRecipient> get recipients {
  if (_recipients is EqualUnmodifiableListView) return _recipients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipients);
}

@override final  String? notes;

/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthRegistrationCopyWith<_HealthRegistration> get copyWith => __$HealthRegistrationCopyWithImpl<_HealthRegistration>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthRegistration&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.practice, practice) || other.practice == practice)&&(identical(other.details, details) || other.details == details)&&(identical(other.responsible, responsible) || other.responsible == responsible)&&const DeepCollectionEquality().equals(other._recipients, _recipients)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,occurredAt,practice,details,responsible,const DeepCollectionEquality().hash(_recipients),notes);

@override
String toString() {
  return 'HealthRegistration(establishmentId: $establishmentId, occurredAt: $occurredAt, practice: $practice, details: $details, responsible: $responsible, recipients: $recipients, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$HealthRegistrationCopyWith<$Res> implements $HealthRegistrationCopyWith<$Res> {
  factory _$HealthRegistrationCopyWith(_HealthRegistration value, $Res Function(_HealthRegistration) _then) = __$HealthRegistrationCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, DateTime occurredAt, HealthPractice practice, HealthEventDetails details, String responsible, List<HealthRecipient> recipients, String? notes
});


@override $HealthPracticeCopyWith<$Res> get practice;@override $HealthEventDetailsCopyWith<$Res> get details;

}
/// @nodoc
class __$HealthRegistrationCopyWithImpl<$Res>
    implements _$HealthRegistrationCopyWith<$Res> {
  __$HealthRegistrationCopyWithImpl(this._self, this._then);

  final _HealthRegistration _self;
  final $Res Function(_HealthRegistration) _then;

/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? occurredAt = null,Object? practice = null,Object? details = null,Object? responsible = null,Object? recipients = null,Object? notes = freezed,}) {
  return _then(_HealthRegistration(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,practice: null == practice ? _self.practice : practice // ignore: cast_nullable_to_non_nullable
as HealthPractice,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as HealthEventDetails,responsible: null == responsible ? _self.responsible : responsible // ignore: cast_nullable_to_non_nullable
as String,recipients: null == recipients ? _self._recipients : recipients // ignore: cast_nullable_to_non_nullable
as List<HealthRecipient>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthPracticeCopyWith<$Res> get practice {
  
  return $HealthPracticeCopyWith<$Res>(_self.practice, (value) {
    return _then(_self.copyWith(practice: value));
  });
}/// Create a copy of HealthRegistration
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthEventDetailsCopyWith<$Res> get details {
  
  return $HealthEventDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}

/// @nodoc
mixin _$HealthStudyResult {

 String get value; DateTime get reportedAt; String get reportedById;
/// Create a copy of HealthStudyResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthStudyResultCopyWith<HealthStudyResult> get copyWith => _$HealthStudyResultCopyWithImpl<HealthStudyResult>(this as HealthStudyResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthStudyResult&&(identical(other.value, value) || other.value == value)&&(identical(other.reportedAt, reportedAt) || other.reportedAt == reportedAt)&&(identical(other.reportedById, reportedById) || other.reportedById == reportedById));
}


@override
int get hashCode => Object.hash(runtimeType,value,reportedAt,reportedById);

@override
String toString() {
  return 'HealthStudyResult(value: $value, reportedAt: $reportedAt, reportedById: $reportedById)';
}


}

/// @nodoc
abstract mixin class $HealthStudyResultCopyWith<$Res>  {
  factory $HealthStudyResultCopyWith(HealthStudyResult value, $Res Function(HealthStudyResult) _then) = _$HealthStudyResultCopyWithImpl;
@useResult
$Res call({
 String value, DateTime reportedAt, String reportedById
});




}
/// @nodoc
class _$HealthStudyResultCopyWithImpl<$Res>
    implements $HealthStudyResultCopyWith<$Res> {
  _$HealthStudyResultCopyWithImpl(this._self, this._then);

  final HealthStudyResult _self;
  final $Res Function(HealthStudyResult) _then;

/// Create a copy of HealthStudyResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? reportedAt = null,Object? reportedById = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,reportedAt: null == reportedAt ? _self.reportedAt : reportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reportedById: null == reportedById ? _self.reportedById : reportedById // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HealthStudyResult].
extension HealthStudyResultPatterns on HealthStudyResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthStudyResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthStudyResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthStudyResult value)  $default,){
final _that = this;
switch (_that) {
case _HealthStudyResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthStudyResult value)?  $default,){
final _that = this;
switch (_that) {
case _HealthStudyResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  DateTime reportedAt,  String reportedById)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthStudyResult() when $default != null:
return $default(_that.value,_that.reportedAt,_that.reportedById);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  DateTime reportedAt,  String reportedById)  $default,) {final _that = this;
switch (_that) {
case _HealthStudyResult():
return $default(_that.value,_that.reportedAt,_that.reportedById);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  DateTime reportedAt,  String reportedById)?  $default,) {final _that = this;
switch (_that) {
case _HealthStudyResult() when $default != null:
return $default(_that.value,_that.reportedAt,_that.reportedById);case _:
  return null;

}
}

}

/// @nodoc


class _HealthStudyResult implements HealthStudyResult {
  const _HealthStudyResult({required this.value, required this.reportedAt, required this.reportedById});
  

@override final  String value;
@override final  DateTime reportedAt;
@override final  String reportedById;

/// Create a copy of HealthStudyResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthStudyResultCopyWith<_HealthStudyResult> get copyWith => __$HealthStudyResultCopyWithImpl<_HealthStudyResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthStudyResult&&(identical(other.value, value) || other.value == value)&&(identical(other.reportedAt, reportedAt) || other.reportedAt == reportedAt)&&(identical(other.reportedById, reportedById) || other.reportedById == reportedById));
}


@override
int get hashCode => Object.hash(runtimeType,value,reportedAt,reportedById);

@override
String toString() {
  return 'HealthStudyResult(value: $value, reportedAt: $reportedAt, reportedById: $reportedById)';
}


}

/// @nodoc
abstract mixin class _$HealthStudyResultCopyWith<$Res> implements $HealthStudyResultCopyWith<$Res> {
  factory _$HealthStudyResultCopyWith(_HealthStudyResult value, $Res Function(_HealthStudyResult) _then) = __$HealthStudyResultCopyWithImpl;
@override @useResult
$Res call({
 String value, DateTime reportedAt, String reportedById
});




}
/// @nodoc
class __$HealthStudyResultCopyWithImpl<$Res>
    implements _$HealthStudyResultCopyWith<$Res> {
  __$HealthStudyResultCopyWithImpl(this._self, this._then);

  final _HealthStudyResult _self;
  final $Res Function(_HealthStudyResult) _then;

/// Create a copy of HealthStudyResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? reportedAt = null,Object? reportedById = null,}) {
  return _then(_HealthStudyResult(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,reportedAt: null == reportedAt ? _self.reportedAt : reportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reportedById: null == reportedById ? _self.reportedById : reportedById // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$HealthEvent {

 String get id; String get establishmentId; DateTime get occurredAt; DateTime get createdAt; DateTime get updatedAt; HealthPractice get practice; HealthEventDetails get details; String get responsible; String get recordedById; HealthRecipient get recipient; HealthSyncStatus get syncStatus; HealthSyncStatus? get resultSyncStatus; HealthSyncIssue? get syncIssue; HealthSyncIssue? get resultIssue; HealthRejectionDetails? get syncRejection; HealthRejectionDetails? get resultRejection; HealthStudyResult? get result; String? get notes; DateTime? get deletedAt;
/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HealthEventCopyWith<HealthEvent> get copyWith => _$HealthEventCopyWithImpl<HealthEvent>(this as HealthEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HealthEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.practice, practice) || other.practice == practice)&&(identical(other.details, details) || other.details == details)&&(identical(other.responsible, responsible) || other.responsible == responsible)&&(identical(other.recordedById, recordedById) || other.recordedById == recordedById)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.resultSyncStatus, resultSyncStatus) || other.resultSyncStatus == resultSyncStatus)&&(identical(other.syncIssue, syncIssue) || other.syncIssue == syncIssue)&&(identical(other.resultIssue, resultIssue) || other.resultIssue == resultIssue)&&(identical(other.syncRejection, syncRejection) || other.syncRejection == syncRejection)&&(identical(other.resultRejection, resultRejection) || other.resultRejection == resultRejection)&&(identical(other.result, result) || other.result == result)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,establishmentId,occurredAt,createdAt,updatedAt,practice,details,responsible,recordedById,recipient,syncStatus,resultSyncStatus,syncIssue,resultIssue,syncRejection,resultRejection,result,notes,deletedAt]);

@override
String toString() {
  return 'HealthEvent(id: $id, establishmentId: $establishmentId, occurredAt: $occurredAt, createdAt: $createdAt, updatedAt: $updatedAt, practice: $practice, details: $details, responsible: $responsible, recordedById: $recordedById, recipient: $recipient, syncStatus: $syncStatus, resultSyncStatus: $resultSyncStatus, syncIssue: $syncIssue, resultIssue: $resultIssue, syncRejection: $syncRejection, resultRejection: $resultRejection, result: $result, notes: $notes, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $HealthEventCopyWith<$Res>  {
  factory $HealthEventCopyWith(HealthEvent value, $Res Function(HealthEvent) _then) = _$HealthEventCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, DateTime occurredAt, DateTime createdAt, DateTime updatedAt, HealthPractice practice, HealthEventDetails details, String responsible, String recordedById, HealthRecipient recipient, HealthSyncStatus syncStatus, HealthSyncStatus? resultSyncStatus, HealthSyncIssue? syncIssue, HealthSyncIssue? resultIssue, HealthRejectionDetails? syncRejection, HealthRejectionDetails? resultRejection, HealthStudyResult? result, String? notes, DateTime? deletedAt
});


$HealthPracticeCopyWith<$Res> get practice;$HealthEventDetailsCopyWith<$Res> get details;$HealthRecipientCopyWith<$Res> get recipient;$HealthStudyResultCopyWith<$Res>? get result;

}
/// @nodoc
class _$HealthEventCopyWithImpl<$Res>
    implements $HealthEventCopyWith<$Res> {
  _$HealthEventCopyWithImpl(this._self, this._then);

  final HealthEvent _self;
  final $Res Function(HealthEvent) _then;

/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? occurredAt = null,Object? createdAt = null,Object? updatedAt = null,Object? practice = null,Object? details = null,Object? responsible = null,Object? recordedById = null,Object? recipient = null,Object? syncStatus = null,Object? resultSyncStatus = freezed,Object? syncIssue = freezed,Object? resultIssue = freezed,Object? syncRejection = freezed,Object? resultRejection = freezed,Object? result = freezed,Object? notes = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,practice: null == practice ? _self.practice : practice // ignore: cast_nullable_to_non_nullable
as HealthPractice,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as HealthEventDetails,responsible: null == responsible ? _self.responsible : responsible // ignore: cast_nullable_to_non_nullable
as String,recordedById: null == recordedById ? _self.recordedById : recordedById // ignore: cast_nullable_to_non_nullable
as String,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as HealthRecipient,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as HealthSyncStatus,resultSyncStatus: freezed == resultSyncStatus ? _self.resultSyncStatus : resultSyncStatus // ignore: cast_nullable_to_non_nullable
as HealthSyncStatus?,syncIssue: freezed == syncIssue ? _self.syncIssue : syncIssue // ignore: cast_nullable_to_non_nullable
as HealthSyncIssue?,resultIssue: freezed == resultIssue ? _self.resultIssue : resultIssue // ignore: cast_nullable_to_non_nullable
as HealthSyncIssue?,syncRejection: freezed == syncRejection ? _self.syncRejection : syncRejection // ignore: cast_nullable_to_non_nullable
as HealthRejectionDetails?,resultRejection: freezed == resultRejection ? _self.resultRejection : resultRejection // ignore: cast_nullable_to_non_nullable
as HealthRejectionDetails?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as HealthStudyResult?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthPracticeCopyWith<$Res> get practice {
  
  return $HealthPracticeCopyWith<$Res>(_self.practice, (value) {
    return _then(_self.copyWith(practice: value));
  });
}/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthEventDetailsCopyWith<$Res> get details {
  
  return $HealthEventDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthRecipientCopyWith<$Res> get recipient {
  
  return $HealthRecipientCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthStudyResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $HealthStudyResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [HealthEvent].
extension HealthEventPatterns on HealthEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HealthEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HealthEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HealthEvent value)  $default,){
final _that = this;
switch (_that) {
case _HealthEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HealthEvent value)?  $default,){
final _that = this;
switch (_that) {
case _HealthEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  DateTime occurredAt,  DateTime createdAt,  DateTime updatedAt,  HealthPractice practice,  HealthEventDetails details,  String responsible,  String recordedById,  HealthRecipient recipient,  HealthSyncStatus syncStatus,  HealthSyncStatus? resultSyncStatus,  HealthSyncIssue? syncIssue,  HealthSyncIssue? resultIssue,  HealthRejectionDetails? syncRejection,  HealthRejectionDetails? resultRejection,  HealthStudyResult? result,  String? notes,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HealthEvent() when $default != null:
return $default(_that.id,_that.establishmentId,_that.occurredAt,_that.createdAt,_that.updatedAt,_that.practice,_that.details,_that.responsible,_that.recordedById,_that.recipient,_that.syncStatus,_that.resultSyncStatus,_that.syncIssue,_that.resultIssue,_that.syncRejection,_that.resultRejection,_that.result,_that.notes,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  DateTime occurredAt,  DateTime createdAt,  DateTime updatedAt,  HealthPractice practice,  HealthEventDetails details,  String responsible,  String recordedById,  HealthRecipient recipient,  HealthSyncStatus syncStatus,  HealthSyncStatus? resultSyncStatus,  HealthSyncIssue? syncIssue,  HealthSyncIssue? resultIssue,  HealthRejectionDetails? syncRejection,  HealthRejectionDetails? resultRejection,  HealthStudyResult? result,  String? notes,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _HealthEvent():
return $default(_that.id,_that.establishmentId,_that.occurredAt,_that.createdAt,_that.updatedAt,_that.practice,_that.details,_that.responsible,_that.recordedById,_that.recipient,_that.syncStatus,_that.resultSyncStatus,_that.syncIssue,_that.resultIssue,_that.syncRejection,_that.resultRejection,_that.result,_that.notes,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  DateTime occurredAt,  DateTime createdAt,  DateTime updatedAt,  HealthPractice practice,  HealthEventDetails details,  String responsible,  String recordedById,  HealthRecipient recipient,  HealthSyncStatus syncStatus,  HealthSyncStatus? resultSyncStatus,  HealthSyncIssue? syncIssue,  HealthSyncIssue? resultIssue,  HealthRejectionDetails? syncRejection,  HealthRejectionDetails? resultRejection,  HealthStudyResult? result,  String? notes,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _HealthEvent() when $default != null:
return $default(_that.id,_that.establishmentId,_that.occurredAt,_that.createdAt,_that.updatedAt,_that.practice,_that.details,_that.responsible,_that.recordedById,_that.recipient,_that.syncStatus,_that.resultSyncStatus,_that.syncIssue,_that.resultIssue,_that.syncRejection,_that.resultRejection,_that.result,_that.notes,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _HealthEvent implements HealthEvent {
  const _HealthEvent({required this.id, required this.establishmentId, required this.occurredAt, required this.createdAt, required this.updatedAt, required this.practice, required this.details, required this.responsible, required this.recordedById, required this.recipient, this.syncStatus = HealthSyncStatus.pending, this.resultSyncStatus, this.syncIssue, this.resultIssue, this.syncRejection, this.resultRejection, this.result, this.notes, this.deletedAt});
  

@override final  String id;
@override final  String establishmentId;
@override final  DateTime occurredAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  HealthPractice practice;
@override final  HealthEventDetails details;
@override final  String responsible;
@override final  String recordedById;
@override final  HealthRecipient recipient;
@override@JsonKey() final  HealthSyncStatus syncStatus;
@override final  HealthSyncStatus? resultSyncStatus;
@override final  HealthSyncIssue? syncIssue;
@override final  HealthSyncIssue? resultIssue;
@override final  HealthRejectionDetails? syncRejection;
@override final  HealthRejectionDetails? resultRejection;
@override final  HealthStudyResult? result;
@override final  String? notes;
@override final  DateTime? deletedAt;

/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HealthEventCopyWith<_HealthEvent> get copyWith => __$HealthEventCopyWithImpl<_HealthEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HealthEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.practice, practice) || other.practice == practice)&&(identical(other.details, details) || other.details == details)&&(identical(other.responsible, responsible) || other.responsible == responsible)&&(identical(other.recordedById, recordedById) || other.recordedById == recordedById)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.resultSyncStatus, resultSyncStatus) || other.resultSyncStatus == resultSyncStatus)&&(identical(other.syncIssue, syncIssue) || other.syncIssue == syncIssue)&&(identical(other.resultIssue, resultIssue) || other.resultIssue == resultIssue)&&(identical(other.syncRejection, syncRejection) || other.syncRejection == syncRejection)&&(identical(other.resultRejection, resultRejection) || other.resultRejection == resultRejection)&&(identical(other.result, result) || other.result == result)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,establishmentId,occurredAt,createdAt,updatedAt,practice,details,responsible,recordedById,recipient,syncStatus,resultSyncStatus,syncIssue,resultIssue,syncRejection,resultRejection,result,notes,deletedAt]);

@override
String toString() {
  return 'HealthEvent(id: $id, establishmentId: $establishmentId, occurredAt: $occurredAt, createdAt: $createdAt, updatedAt: $updatedAt, practice: $practice, details: $details, responsible: $responsible, recordedById: $recordedById, recipient: $recipient, syncStatus: $syncStatus, resultSyncStatus: $resultSyncStatus, syncIssue: $syncIssue, resultIssue: $resultIssue, syncRejection: $syncRejection, resultRejection: $resultRejection, result: $result, notes: $notes, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$HealthEventCopyWith<$Res> implements $HealthEventCopyWith<$Res> {
  factory _$HealthEventCopyWith(_HealthEvent value, $Res Function(_HealthEvent) _then) = __$HealthEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, DateTime occurredAt, DateTime createdAt, DateTime updatedAt, HealthPractice practice, HealthEventDetails details, String responsible, String recordedById, HealthRecipient recipient, HealthSyncStatus syncStatus, HealthSyncStatus? resultSyncStatus, HealthSyncIssue? syncIssue, HealthSyncIssue? resultIssue, HealthRejectionDetails? syncRejection, HealthRejectionDetails? resultRejection, HealthStudyResult? result, String? notes, DateTime? deletedAt
});


@override $HealthPracticeCopyWith<$Res> get practice;@override $HealthEventDetailsCopyWith<$Res> get details;@override $HealthRecipientCopyWith<$Res> get recipient;@override $HealthStudyResultCopyWith<$Res>? get result;

}
/// @nodoc
class __$HealthEventCopyWithImpl<$Res>
    implements _$HealthEventCopyWith<$Res> {
  __$HealthEventCopyWithImpl(this._self, this._then);

  final _HealthEvent _self;
  final $Res Function(_HealthEvent) _then;

/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? occurredAt = null,Object? createdAt = null,Object? updatedAt = null,Object? practice = null,Object? details = null,Object? responsible = null,Object? recordedById = null,Object? recipient = null,Object? syncStatus = null,Object? resultSyncStatus = freezed,Object? syncIssue = freezed,Object? resultIssue = freezed,Object? syncRejection = freezed,Object? resultRejection = freezed,Object? result = freezed,Object? notes = freezed,Object? deletedAt = freezed,}) {
  return _then(_HealthEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,practice: null == practice ? _self.practice : practice // ignore: cast_nullable_to_non_nullable
as HealthPractice,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as HealthEventDetails,responsible: null == responsible ? _self.responsible : responsible // ignore: cast_nullable_to_non_nullable
as String,recordedById: null == recordedById ? _self.recordedById : recordedById // ignore: cast_nullable_to_non_nullable
as String,recipient: null == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as HealthRecipient,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as HealthSyncStatus,resultSyncStatus: freezed == resultSyncStatus ? _self.resultSyncStatus : resultSyncStatus // ignore: cast_nullable_to_non_nullable
as HealthSyncStatus?,syncIssue: freezed == syncIssue ? _self.syncIssue : syncIssue // ignore: cast_nullable_to_non_nullable
as HealthSyncIssue?,resultIssue: freezed == resultIssue ? _self.resultIssue : resultIssue // ignore: cast_nullable_to_non_nullable
as HealthSyncIssue?,syncRejection: freezed == syncRejection ? _self.syncRejection : syncRejection // ignore: cast_nullable_to_non_nullable
as HealthRejectionDetails?,resultRejection: freezed == resultRejection ? _self.resultRejection : resultRejection // ignore: cast_nullable_to_non_nullable
as HealthRejectionDetails?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as HealthStudyResult?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthPracticeCopyWith<$Res> get practice {
  
  return $HealthPracticeCopyWith<$Res>(_self.practice, (value) {
    return _then(_self.copyWith(practice: value));
  });
}/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthEventDetailsCopyWith<$Res> get details {
  
  return $HealthEventDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthRecipientCopyWith<$Res> get recipient {
  
  return $HealthRecipientCopyWith<$Res>(_self.recipient, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of HealthEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HealthStudyResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $HealthStudyResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
