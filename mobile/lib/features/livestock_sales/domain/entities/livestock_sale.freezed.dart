// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestock_sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivestockSaleInitialPayment {

 String get id; DateTime get date; int get amountCents; LivestockSalePaymentMethod get method; DateTime get createdAt; DateTime get updatedAt; String? get observations;
/// Create a copy of LivestockSaleInitialPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleInitialPaymentCopyWith<LivestockSaleInitialPayment> get copyWith => _$LivestockSaleInitialPaymentCopyWithImpl<LivestockSaleInitialPayment>(this as LivestockSaleInitialPayment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleInitialPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.method, method) || other.method == method)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.observations, observations) || other.observations == observations));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,amountCents,method,createdAt,updatedAt,observations);

@override
String toString() {
  return 'LivestockSaleInitialPayment(id: $id, date: $date, amountCents: $amountCents, method: $method, createdAt: $createdAt, updatedAt: $updatedAt, observations: $observations)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleInitialPaymentCopyWith<$Res>  {
  factory $LivestockSaleInitialPaymentCopyWith(LivestockSaleInitialPayment value, $Res Function(LivestockSaleInitialPayment) _then) = _$LivestockSaleInitialPaymentCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, int amountCents, LivestockSalePaymentMethod method, DateTime createdAt, DateTime updatedAt, String? observations
});




}
/// @nodoc
class _$LivestockSaleInitialPaymentCopyWithImpl<$Res>
    implements $LivestockSaleInitialPaymentCopyWith<$Res> {
  _$LivestockSaleInitialPaymentCopyWithImpl(this._self, this._then);

  final LivestockSaleInitialPayment _self;
  final $Res Function(LivestockSaleInitialPayment) _then;

/// Create a copy of LivestockSaleInitialPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? amountCents = null,Object? method = null,Object? createdAt = null,Object? updatedAt = null,Object? observations = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockSaleInitialPayment].
extension LivestockSaleInitialPaymentPatterns on LivestockSaleInitialPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleInitialPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleInitialPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleInitialPayment value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleInitialPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleInitialPayment value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleInitialPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  int amountCents,  LivestockSalePaymentMethod method,  DateTime createdAt,  DateTime updatedAt,  String? observations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleInitialPayment() when $default != null:
return $default(_that.id,_that.date,_that.amountCents,_that.method,_that.createdAt,_that.updatedAt,_that.observations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  int amountCents,  LivestockSalePaymentMethod method,  DateTime createdAt,  DateTime updatedAt,  String? observations)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleInitialPayment():
return $default(_that.id,_that.date,_that.amountCents,_that.method,_that.createdAt,_that.updatedAt,_that.observations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  int amountCents,  LivestockSalePaymentMethod method,  DateTime createdAt,  DateTime updatedAt,  String? observations)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleInitialPayment() when $default != null:
return $default(_that.id,_that.date,_that.amountCents,_that.method,_that.createdAt,_that.updatedAt,_that.observations);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleInitialPayment implements LivestockSaleInitialPayment {
  const _LivestockSaleInitialPayment({required this.id, required this.date, required this.amountCents, required this.method, required this.createdAt, required this.updatedAt, this.observations});
  

@override final  String id;
@override final  DateTime date;
@override final  int amountCents;
@override final  LivestockSalePaymentMethod method;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? observations;

/// Create a copy of LivestockSaleInitialPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleInitialPaymentCopyWith<_LivestockSaleInitialPayment> get copyWith => __$LivestockSaleInitialPaymentCopyWithImpl<_LivestockSaleInitialPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleInitialPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.method, method) || other.method == method)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.observations, observations) || other.observations == observations));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,amountCents,method,createdAt,updatedAt,observations);

@override
String toString() {
  return 'LivestockSaleInitialPayment(id: $id, date: $date, amountCents: $amountCents, method: $method, createdAt: $createdAt, updatedAt: $updatedAt, observations: $observations)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleInitialPaymentCopyWith<$Res> implements $LivestockSaleInitialPaymentCopyWith<$Res> {
  factory _$LivestockSaleInitialPaymentCopyWith(_LivestockSaleInitialPayment value, $Res Function(_LivestockSaleInitialPayment) _then) = __$LivestockSaleInitialPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, int amountCents, LivestockSalePaymentMethod method, DateTime createdAt, DateTime updatedAt, String? observations
});




}
/// @nodoc
class __$LivestockSaleInitialPaymentCopyWithImpl<$Res>
    implements _$LivestockSaleInitialPaymentCopyWith<$Res> {
  __$LivestockSaleInitialPaymentCopyWithImpl(this._self, this._then);

  final _LivestockSaleInitialPayment _self;
  final $Res Function(_LivestockSaleInitialPayment) _then;

/// Create a copy of LivestockSaleInitialPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? amountCents = null,Object? method = null,Object? createdAt = null,Object? updatedAt = null,Object? observations = freezed,}) {
  return _then(_LivestockSaleInitialPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LivestockSaleInitialPaymentDraft {

 DateTime get date; int get amountCents; LivestockSalePaymentMethod get method; String? get observations;
/// Create a copy of LivestockSaleInitialPaymentDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleInitialPaymentDraftCopyWith<LivestockSaleInitialPaymentDraft> get copyWith => _$LivestockSaleInitialPaymentDraftCopyWithImpl<LivestockSaleInitialPaymentDraft>(this as LivestockSaleInitialPaymentDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleInitialPaymentDraft&&(identical(other.date, date) || other.date == date)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.method, method) || other.method == method)&&(identical(other.observations, observations) || other.observations == observations));
}


@override
int get hashCode => Object.hash(runtimeType,date,amountCents,method,observations);

@override
String toString() {
  return 'LivestockSaleInitialPaymentDraft(date: $date, amountCents: $amountCents, method: $method, observations: $observations)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleInitialPaymentDraftCopyWith<$Res>  {
  factory $LivestockSaleInitialPaymentDraftCopyWith(LivestockSaleInitialPaymentDraft value, $Res Function(LivestockSaleInitialPaymentDraft) _then) = _$LivestockSaleInitialPaymentDraftCopyWithImpl;
@useResult
$Res call({
 DateTime date, int amountCents, LivestockSalePaymentMethod method, String? observations
});




}
/// @nodoc
class _$LivestockSaleInitialPaymentDraftCopyWithImpl<$Res>
    implements $LivestockSaleInitialPaymentDraftCopyWith<$Res> {
  _$LivestockSaleInitialPaymentDraftCopyWithImpl(this._self, this._then);

  final LivestockSaleInitialPaymentDraft _self;
  final $Res Function(LivestockSaleInitialPaymentDraft) _then;

/// Create a copy of LivestockSaleInitialPaymentDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? amountCents = null,Object? method = null,Object? observations = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockSaleInitialPaymentDraft].
extension LivestockSaleInitialPaymentDraftPatterns on LivestockSaleInitialPaymentDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleInitialPaymentDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleInitialPaymentDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleInitialPaymentDraft value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleInitialPaymentDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleInitialPaymentDraft value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleInitialPaymentDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int amountCents,  LivestockSalePaymentMethod method,  String? observations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleInitialPaymentDraft() when $default != null:
return $default(_that.date,_that.amountCents,_that.method,_that.observations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int amountCents,  LivestockSalePaymentMethod method,  String? observations)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleInitialPaymentDraft():
return $default(_that.date,_that.amountCents,_that.method,_that.observations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int amountCents,  LivestockSalePaymentMethod method,  String? observations)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleInitialPaymentDraft() when $default != null:
return $default(_that.date,_that.amountCents,_that.method,_that.observations);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleInitialPaymentDraft implements LivestockSaleInitialPaymentDraft {
  const _LivestockSaleInitialPaymentDraft({required this.date, required this.amountCents, required this.method, this.observations});
  

@override final  DateTime date;
@override final  int amountCents;
@override final  LivestockSalePaymentMethod method;
@override final  String? observations;

/// Create a copy of LivestockSaleInitialPaymentDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleInitialPaymentDraftCopyWith<_LivestockSaleInitialPaymentDraft> get copyWith => __$LivestockSaleInitialPaymentDraftCopyWithImpl<_LivestockSaleInitialPaymentDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleInitialPaymentDraft&&(identical(other.date, date) || other.date == date)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.method, method) || other.method == method)&&(identical(other.observations, observations) || other.observations == observations));
}


@override
int get hashCode => Object.hash(runtimeType,date,amountCents,method,observations);

@override
String toString() {
  return 'LivestockSaleInitialPaymentDraft(date: $date, amountCents: $amountCents, method: $method, observations: $observations)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleInitialPaymentDraftCopyWith<$Res> implements $LivestockSaleInitialPaymentDraftCopyWith<$Res> {
  factory _$LivestockSaleInitialPaymentDraftCopyWith(_LivestockSaleInitialPaymentDraft value, $Res Function(_LivestockSaleInitialPaymentDraft) _then) = __$LivestockSaleInitialPaymentDraftCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int amountCents, LivestockSalePaymentMethod method, String? observations
});




}
/// @nodoc
class __$LivestockSaleInitialPaymentDraftCopyWithImpl<$Res>
    implements _$LivestockSaleInitialPaymentDraftCopyWith<$Res> {
  __$LivestockSaleInitialPaymentDraftCopyWithImpl(this._self, this._then);

  final _LivestockSaleInitialPaymentDraft _self;
  final $Res Function(_LivestockSaleInitialPaymentDraft) _then;

/// Create a copy of LivestockSaleInitialPaymentDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? amountCents = null,Object? method = null,Object? observations = freezed,}) {
  return _then(_LivestockSaleInitialPaymentDraft(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LivestockSaleDraft {

 String get establishmentId; DateTime get operationDate; LivestockSaleBuyerType get buyerType; String get buyerName; bool get isCompany; String get dteNumber; LivestockSaleType get saleType; int get totalAmountCents; List<String> get animalIds; LivestockSalePaymentCondition get paymentCondition; String? get buyerLastName; int? get totalWeightGrams; int? get pricePerKgMicros; String? get observations; LivestockSaleInitialPaymentDraft? get initialPayment;
/// Create a copy of LivestockSaleDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleDraftCopyWith<LivestockSaleDraft> get copyWith => _$LivestockSaleDraftCopyWithImpl<LivestockSaleDraft>(this as LivestockSaleDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleDraft&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.totalAmountCents, totalAmountCents) || other.totalAmountCents == totalAmountCents)&&const DeepCollectionEquality().equals(other.animalIds, animalIds)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.totalWeightGrams, totalWeightGrams) || other.totalWeightGrams == totalWeightGrams)&&(identical(other.pricePerKgMicros, pricePerKgMicros) || other.pricePerKgMicros == pricePerKgMicros)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.initialPayment, initialPayment) || other.initialPayment == initialPayment));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,operationDate,buyerType,buyerName,isCompany,dteNumber,saleType,totalAmountCents,const DeepCollectionEquality().hash(animalIds),paymentCondition,buyerLastName,totalWeightGrams,pricePerKgMicros,observations,initialPayment);

@override
String toString() {
  return 'LivestockSaleDraft(establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, dteNumber: $dteNumber, saleType: $saleType, totalAmountCents: $totalAmountCents, animalIds: $animalIds, paymentCondition: $paymentCondition, buyerLastName: $buyerLastName, totalWeightGrams: $totalWeightGrams, pricePerKgMicros: $pricePerKgMicros, observations: $observations, initialPayment: $initialPayment)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleDraftCopyWith<$Res>  {
  factory $LivestockSaleDraftCopyWith(LivestockSaleDraft value, $Res Function(LivestockSaleDraft) _then) = _$LivestockSaleDraftCopyWithImpl;
@useResult
$Res call({
 String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String dteNumber, LivestockSaleType saleType, int totalAmountCents, List<String> animalIds, LivestockSalePaymentCondition paymentCondition, String? buyerLastName, int? totalWeightGrams, int? pricePerKgMicros, String? observations, LivestockSaleInitialPaymentDraft? initialPayment
});


$LivestockSaleInitialPaymentDraftCopyWith<$Res>? get initialPayment;

}
/// @nodoc
class _$LivestockSaleDraftCopyWithImpl<$Res>
    implements $LivestockSaleDraftCopyWith<$Res> {
  _$LivestockSaleDraftCopyWithImpl(this._self, this._then);

  final LivestockSaleDraft _self;
  final $Res Function(LivestockSaleDraft) _then;

/// Create a copy of LivestockSaleDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? dteNumber = null,Object? saleType = null,Object? totalAmountCents = null,Object? animalIds = null,Object? paymentCondition = null,Object? buyerLastName = freezed,Object? totalWeightGrams = freezed,Object? pricePerKgMicros = freezed,Object? observations = freezed,Object? initialPayment = freezed,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,totalAmountCents: null == totalAmountCents ? _self.totalAmountCents : totalAmountCents // ignore: cast_nullable_to_non_nullable
as int,animalIds: null == animalIds ? _self.animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,buyerLastName: freezed == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String?,totalWeightGrams: freezed == totalWeightGrams ? _self.totalWeightGrams : totalWeightGrams // ignore: cast_nullable_to_non_nullable
as int?,pricePerKgMicros: freezed == pricePerKgMicros ? _self.pricePerKgMicros : pricePerKgMicros // ignore: cast_nullable_to_non_nullable
as int?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,initialPayment: freezed == initialPayment ? _self.initialPayment : initialPayment // ignore: cast_nullable_to_non_nullable
as LivestockSaleInitialPaymentDraft?,
  ));
}
/// Create a copy of LivestockSaleDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleInitialPaymentDraftCopyWith<$Res>? get initialPayment {
    if (_self.initialPayment == null) {
    return null;
  }

  return $LivestockSaleInitialPaymentDraftCopyWith<$Res>(_self.initialPayment!, (value) {
    return _then(_self.copyWith(initialPayment: value));
  });
}
}


/// Adds pattern-matching-related methods to [LivestockSaleDraft].
extension LivestockSaleDraftPatterns on LivestockSaleDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleDraft value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleDraft value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String dteNumber,  LivestockSaleType saleType,  int totalAmountCents,  List<String> animalIds,  LivestockSalePaymentCondition paymentCondition,  String? buyerLastName,  int? totalWeightGrams,  int? pricePerKgMicros,  String? observations,  LivestockSaleInitialPaymentDraft? initialPayment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleDraft() when $default != null:
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.dteNumber,_that.saleType,_that.totalAmountCents,_that.animalIds,_that.paymentCondition,_that.buyerLastName,_that.totalWeightGrams,_that.pricePerKgMicros,_that.observations,_that.initialPayment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String dteNumber,  LivestockSaleType saleType,  int totalAmountCents,  List<String> animalIds,  LivestockSalePaymentCondition paymentCondition,  String? buyerLastName,  int? totalWeightGrams,  int? pricePerKgMicros,  String? observations,  LivestockSaleInitialPaymentDraft? initialPayment)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleDraft():
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.dteNumber,_that.saleType,_that.totalAmountCents,_that.animalIds,_that.paymentCondition,_that.buyerLastName,_that.totalWeightGrams,_that.pricePerKgMicros,_that.observations,_that.initialPayment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String dteNumber,  LivestockSaleType saleType,  int totalAmountCents,  List<String> animalIds,  LivestockSalePaymentCondition paymentCondition,  String? buyerLastName,  int? totalWeightGrams,  int? pricePerKgMicros,  String? observations,  LivestockSaleInitialPaymentDraft? initialPayment)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleDraft() when $default != null:
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.dteNumber,_that.saleType,_that.totalAmountCents,_that.animalIds,_that.paymentCondition,_that.buyerLastName,_that.totalWeightGrams,_that.pricePerKgMicros,_that.observations,_that.initialPayment);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleDraft implements LivestockSaleDraft {
  const _LivestockSaleDraft({required this.establishmentId, required this.operationDate, required this.buyerType, required this.buyerName, required this.isCompany, required this.dteNumber, required this.saleType, required this.totalAmountCents, required final  List<String> animalIds, required this.paymentCondition, this.buyerLastName, this.totalWeightGrams, this.pricePerKgMicros, this.observations, this.initialPayment}): _animalIds = animalIds;
  

@override final  String establishmentId;
@override final  DateTime operationDate;
@override final  LivestockSaleBuyerType buyerType;
@override final  String buyerName;
@override final  bool isCompany;
@override final  String dteNumber;
@override final  LivestockSaleType saleType;
@override final  int totalAmountCents;
 final  List<String> _animalIds;
@override List<String> get animalIds {
  if (_animalIds is EqualUnmodifiableListView) return _animalIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animalIds);
}

@override final  LivestockSalePaymentCondition paymentCondition;
@override final  String? buyerLastName;
@override final  int? totalWeightGrams;
@override final  int? pricePerKgMicros;
@override final  String? observations;
@override final  LivestockSaleInitialPaymentDraft? initialPayment;

/// Create a copy of LivestockSaleDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleDraftCopyWith<_LivestockSaleDraft> get copyWith => __$LivestockSaleDraftCopyWithImpl<_LivestockSaleDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleDraft&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.totalAmountCents, totalAmountCents) || other.totalAmountCents == totalAmountCents)&&const DeepCollectionEquality().equals(other._animalIds, _animalIds)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.totalWeightGrams, totalWeightGrams) || other.totalWeightGrams == totalWeightGrams)&&(identical(other.pricePerKgMicros, pricePerKgMicros) || other.pricePerKgMicros == pricePerKgMicros)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.initialPayment, initialPayment) || other.initialPayment == initialPayment));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,operationDate,buyerType,buyerName,isCompany,dteNumber,saleType,totalAmountCents,const DeepCollectionEquality().hash(_animalIds),paymentCondition,buyerLastName,totalWeightGrams,pricePerKgMicros,observations,initialPayment);

@override
String toString() {
  return 'LivestockSaleDraft(establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, dteNumber: $dteNumber, saleType: $saleType, totalAmountCents: $totalAmountCents, animalIds: $animalIds, paymentCondition: $paymentCondition, buyerLastName: $buyerLastName, totalWeightGrams: $totalWeightGrams, pricePerKgMicros: $pricePerKgMicros, observations: $observations, initialPayment: $initialPayment)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleDraftCopyWith<$Res> implements $LivestockSaleDraftCopyWith<$Res> {
  factory _$LivestockSaleDraftCopyWith(_LivestockSaleDraft value, $Res Function(_LivestockSaleDraft) _then) = __$LivestockSaleDraftCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String dteNumber, LivestockSaleType saleType, int totalAmountCents, List<String> animalIds, LivestockSalePaymentCondition paymentCondition, String? buyerLastName, int? totalWeightGrams, int? pricePerKgMicros, String? observations, LivestockSaleInitialPaymentDraft? initialPayment
});


@override $LivestockSaleInitialPaymentDraftCopyWith<$Res>? get initialPayment;

}
/// @nodoc
class __$LivestockSaleDraftCopyWithImpl<$Res>
    implements _$LivestockSaleDraftCopyWith<$Res> {
  __$LivestockSaleDraftCopyWithImpl(this._self, this._then);

  final _LivestockSaleDraft _self;
  final $Res Function(_LivestockSaleDraft) _then;

/// Create a copy of LivestockSaleDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? dteNumber = null,Object? saleType = null,Object? totalAmountCents = null,Object? animalIds = null,Object? paymentCondition = null,Object? buyerLastName = freezed,Object? totalWeightGrams = freezed,Object? pricePerKgMicros = freezed,Object? observations = freezed,Object? initialPayment = freezed,}) {
  return _then(_LivestockSaleDraft(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,totalAmountCents: null == totalAmountCents ? _self.totalAmountCents : totalAmountCents // ignore: cast_nullable_to_non_nullable
as int,animalIds: null == animalIds ? _self._animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,buyerLastName: freezed == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String?,totalWeightGrams: freezed == totalWeightGrams ? _self.totalWeightGrams : totalWeightGrams // ignore: cast_nullable_to_non_nullable
as int?,pricePerKgMicros: freezed == pricePerKgMicros ? _self.pricePerKgMicros : pricePerKgMicros // ignore: cast_nullable_to_non_nullable
as int?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,initialPayment: freezed == initialPayment ? _self.initialPayment : initialPayment // ignore: cast_nullable_to_non_nullable
as LivestockSaleInitialPaymentDraft?,
  ));
}

/// Create a copy of LivestockSaleDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleInitialPaymentDraftCopyWith<$Res>? get initialPayment {
    if (_self.initialPayment == null) {
    return null;
  }

  return $LivestockSaleInitialPaymentDraftCopyWith<$Res>(_self.initialPayment!, (value) {
    return _then(_self.copyWith(initialPayment: value));
  });
}
}

/// @nodoc
mixin _$LivestockSale {

 String get id; String get establishmentId; DateTime get operationDate; LivestockSaleBuyerType get buyerType; String get buyerName; bool get isCompany; String get dteNumber; LivestockSaleType get saleType; int get totalAmountCents; List<String> get animalIds; LivestockSalePaymentCondition get paymentCondition; DateTime get createdAt; DateTime get updatedAt; LivestockSaleSyncStatus get syncStatus; String? get buyerLastName; int? get totalWeightGrams; int? get pricePerKgMicros; String? get observations; LivestockSaleInitialPayment? get initialPayment; String? get syncErrorCode;
/// Create a copy of LivestockSale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleCopyWith<LivestockSale> get copyWith => _$LivestockSaleCopyWithImpl<LivestockSale>(this as LivestockSale, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSale&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.totalAmountCents, totalAmountCents) || other.totalAmountCents == totalAmountCents)&&const DeepCollectionEquality().equals(other.animalIds, animalIds)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.totalWeightGrams, totalWeightGrams) || other.totalWeightGrams == totalWeightGrams)&&(identical(other.pricePerKgMicros, pricePerKgMicros) || other.pricePerKgMicros == pricePerKgMicros)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.initialPayment, initialPayment) || other.initialPayment == initialPayment)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,establishmentId,operationDate,buyerType,buyerName,isCompany,dteNumber,saleType,totalAmountCents,const DeepCollectionEquality().hash(animalIds),paymentCondition,createdAt,updatedAt,syncStatus,buyerLastName,totalWeightGrams,pricePerKgMicros,observations,initialPayment,syncErrorCode]);

@override
String toString() {
  return 'LivestockSale(id: $id, establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, dteNumber: $dteNumber, saleType: $saleType, totalAmountCents: $totalAmountCents, animalIds: $animalIds, paymentCondition: $paymentCondition, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus, buyerLastName: $buyerLastName, totalWeightGrams: $totalWeightGrams, pricePerKgMicros: $pricePerKgMicros, observations: $observations, initialPayment: $initialPayment, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleCopyWith<$Res>  {
  factory $LivestockSaleCopyWith(LivestockSale value, $Res Function(LivestockSale) _then) = _$LivestockSaleCopyWithImpl;
@useResult
$Res call({
 String id, String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String dteNumber, LivestockSaleType saleType, int totalAmountCents, List<String> animalIds, LivestockSalePaymentCondition paymentCondition, DateTime createdAt, DateTime updatedAt, LivestockSaleSyncStatus syncStatus, String? buyerLastName, int? totalWeightGrams, int? pricePerKgMicros, String? observations, LivestockSaleInitialPayment? initialPayment, String? syncErrorCode
});


$LivestockSaleInitialPaymentCopyWith<$Res>? get initialPayment;

}
/// @nodoc
class _$LivestockSaleCopyWithImpl<$Res>
    implements $LivestockSaleCopyWith<$Res> {
  _$LivestockSaleCopyWithImpl(this._self, this._then);

  final LivestockSale _self;
  final $Res Function(LivestockSale) _then;

/// Create a copy of LivestockSale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? dteNumber = null,Object? saleType = null,Object? totalAmountCents = null,Object? animalIds = null,Object? paymentCondition = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,Object? buyerLastName = freezed,Object? totalWeightGrams = freezed,Object? pricePerKgMicros = freezed,Object? observations = freezed,Object? initialPayment = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,totalAmountCents: null == totalAmountCents ? _self.totalAmountCents : totalAmountCents // ignore: cast_nullable_to_non_nullable
as int,animalIds: null == animalIds ? _self.animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as LivestockSaleSyncStatus,buyerLastName: freezed == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String?,totalWeightGrams: freezed == totalWeightGrams ? _self.totalWeightGrams : totalWeightGrams // ignore: cast_nullable_to_non_nullable
as int?,pricePerKgMicros: freezed == pricePerKgMicros ? _self.pricePerKgMicros : pricePerKgMicros // ignore: cast_nullable_to_non_nullable
as int?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,initialPayment: freezed == initialPayment ? _self.initialPayment : initialPayment // ignore: cast_nullable_to_non_nullable
as LivestockSaleInitialPayment?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of LivestockSale
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleInitialPaymentCopyWith<$Res>? get initialPayment {
    if (_self.initialPayment == null) {
    return null;
  }

  return $LivestockSaleInitialPaymentCopyWith<$Res>(_self.initialPayment!, (value) {
    return _then(_self.copyWith(initialPayment: value));
  });
}
}


/// Adds pattern-matching-related methods to [LivestockSale].
extension LivestockSalePatterns on LivestockSale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSale value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSale value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String dteNumber,  LivestockSaleType saleType,  int totalAmountCents,  List<String> animalIds,  LivestockSalePaymentCondition paymentCondition,  DateTime createdAt,  DateTime updatedAt,  LivestockSaleSyncStatus syncStatus,  String? buyerLastName,  int? totalWeightGrams,  int? pricePerKgMicros,  String? observations,  LivestockSaleInitialPayment? initialPayment,  String? syncErrorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSale() when $default != null:
return $default(_that.id,_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.dteNumber,_that.saleType,_that.totalAmountCents,_that.animalIds,_that.paymentCondition,_that.createdAt,_that.updatedAt,_that.syncStatus,_that.buyerLastName,_that.totalWeightGrams,_that.pricePerKgMicros,_that.observations,_that.initialPayment,_that.syncErrorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String dteNumber,  LivestockSaleType saleType,  int totalAmountCents,  List<String> animalIds,  LivestockSalePaymentCondition paymentCondition,  DateTime createdAt,  DateTime updatedAt,  LivestockSaleSyncStatus syncStatus,  String? buyerLastName,  int? totalWeightGrams,  int? pricePerKgMicros,  String? observations,  LivestockSaleInitialPayment? initialPayment,  String? syncErrorCode)  $default,) {final _that = this;
switch (_that) {
case _LivestockSale():
return $default(_that.id,_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.dteNumber,_that.saleType,_that.totalAmountCents,_that.animalIds,_that.paymentCondition,_that.createdAt,_that.updatedAt,_that.syncStatus,_that.buyerLastName,_that.totalWeightGrams,_that.pricePerKgMicros,_that.observations,_that.initialPayment,_that.syncErrorCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String dteNumber,  LivestockSaleType saleType,  int totalAmountCents,  List<String> animalIds,  LivestockSalePaymentCondition paymentCondition,  DateTime createdAt,  DateTime updatedAt,  LivestockSaleSyncStatus syncStatus,  String? buyerLastName,  int? totalWeightGrams,  int? pricePerKgMicros,  String? observations,  LivestockSaleInitialPayment? initialPayment,  String? syncErrorCode)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSale() when $default != null:
return $default(_that.id,_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.dteNumber,_that.saleType,_that.totalAmountCents,_that.animalIds,_that.paymentCondition,_that.createdAt,_that.updatedAt,_that.syncStatus,_that.buyerLastName,_that.totalWeightGrams,_that.pricePerKgMicros,_that.observations,_that.initialPayment,_that.syncErrorCode);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSale implements LivestockSale {
  const _LivestockSale({required this.id, required this.establishmentId, required this.operationDate, required this.buyerType, required this.buyerName, required this.isCompany, required this.dteNumber, required this.saleType, required this.totalAmountCents, required final  List<String> animalIds, required this.paymentCondition, required this.createdAt, required this.updatedAt, required this.syncStatus, this.buyerLastName, this.totalWeightGrams, this.pricePerKgMicros, this.observations, this.initialPayment, this.syncErrorCode}): _animalIds = animalIds;
  

@override final  String id;
@override final  String establishmentId;
@override final  DateTime operationDate;
@override final  LivestockSaleBuyerType buyerType;
@override final  String buyerName;
@override final  bool isCompany;
@override final  String dteNumber;
@override final  LivestockSaleType saleType;
@override final  int totalAmountCents;
 final  List<String> _animalIds;
@override List<String> get animalIds {
  if (_animalIds is EqualUnmodifiableListView) return _animalIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_animalIds);
}

@override final  LivestockSalePaymentCondition paymentCondition;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  LivestockSaleSyncStatus syncStatus;
@override final  String? buyerLastName;
@override final  int? totalWeightGrams;
@override final  int? pricePerKgMicros;
@override final  String? observations;
@override final  LivestockSaleInitialPayment? initialPayment;
@override final  String? syncErrorCode;

/// Create a copy of LivestockSale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleCopyWith<_LivestockSale> get copyWith => __$LivestockSaleCopyWithImpl<_LivestockSale>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSale&&(identical(other.id, id) || other.id == id)&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.totalAmountCents, totalAmountCents) || other.totalAmountCents == totalAmountCents)&&const DeepCollectionEquality().equals(other._animalIds, _animalIds)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.totalWeightGrams, totalWeightGrams) || other.totalWeightGrams == totalWeightGrams)&&(identical(other.pricePerKgMicros, pricePerKgMicros) || other.pricePerKgMicros == pricePerKgMicros)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.initialPayment, initialPayment) || other.initialPayment == initialPayment)&&(identical(other.syncErrorCode, syncErrorCode) || other.syncErrorCode == syncErrorCode));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,establishmentId,operationDate,buyerType,buyerName,isCompany,dteNumber,saleType,totalAmountCents,const DeepCollectionEquality().hash(_animalIds),paymentCondition,createdAt,updatedAt,syncStatus,buyerLastName,totalWeightGrams,pricePerKgMicros,observations,initialPayment,syncErrorCode]);

@override
String toString() {
  return 'LivestockSale(id: $id, establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, dteNumber: $dteNumber, saleType: $saleType, totalAmountCents: $totalAmountCents, animalIds: $animalIds, paymentCondition: $paymentCondition, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus, buyerLastName: $buyerLastName, totalWeightGrams: $totalWeightGrams, pricePerKgMicros: $pricePerKgMicros, observations: $observations, initialPayment: $initialPayment, syncErrorCode: $syncErrorCode)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleCopyWith<$Res> implements $LivestockSaleCopyWith<$Res> {
  factory _$LivestockSaleCopyWith(_LivestockSale value, $Res Function(_LivestockSale) _then) = __$LivestockSaleCopyWithImpl;
@override @useResult
$Res call({
 String id, String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String dteNumber, LivestockSaleType saleType, int totalAmountCents, List<String> animalIds, LivestockSalePaymentCondition paymentCondition, DateTime createdAt, DateTime updatedAt, LivestockSaleSyncStatus syncStatus, String? buyerLastName, int? totalWeightGrams, int? pricePerKgMicros, String? observations, LivestockSaleInitialPayment? initialPayment, String? syncErrorCode
});


@override $LivestockSaleInitialPaymentCopyWith<$Res>? get initialPayment;

}
/// @nodoc
class __$LivestockSaleCopyWithImpl<$Res>
    implements _$LivestockSaleCopyWith<$Res> {
  __$LivestockSaleCopyWithImpl(this._self, this._then);

  final _LivestockSale _self;
  final $Res Function(_LivestockSale) _then;

/// Create a copy of LivestockSale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? dteNumber = null,Object? saleType = null,Object? totalAmountCents = null,Object? animalIds = null,Object? paymentCondition = null,Object? createdAt = null,Object? updatedAt = null,Object? syncStatus = null,Object? buyerLastName = freezed,Object? totalWeightGrams = freezed,Object? pricePerKgMicros = freezed,Object? observations = freezed,Object? initialPayment = freezed,Object? syncErrorCode = freezed,}) {
  return _then(_LivestockSale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,totalAmountCents: null == totalAmountCents ? _self.totalAmountCents : totalAmountCents // ignore: cast_nullable_to_non_nullable
as int,animalIds: null == animalIds ? _self._animalIds : animalIds // ignore: cast_nullable_to_non_nullable
as List<String>,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as LivestockSaleSyncStatus,buyerLastName: freezed == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String?,totalWeightGrams: freezed == totalWeightGrams ? _self.totalWeightGrams : totalWeightGrams // ignore: cast_nullable_to_non_nullable
as int?,pricePerKgMicros: freezed == pricePerKgMicros ? _self.pricePerKgMicros : pricePerKgMicros // ignore: cast_nullable_to_non_nullable
as int?,observations: freezed == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String?,initialPayment: freezed == initialPayment ? _self.initialPayment : initialPayment // ignore: cast_nullable_to_non_nullable
as LivestockSaleInitialPayment?,syncErrorCode: freezed == syncErrorCode ? _self.syncErrorCode : syncErrorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of LivestockSale
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleInitialPaymentCopyWith<$Res>? get initialPayment {
    if (_self.initialPayment == null) {
    return null;
  }

  return $LivestockSaleInitialPaymentCopyWith<$Res>(_self.initialPayment!, (value) {
    return _then(_self.copyWith(initialPayment: value));
  });
}
}

// dart format on
