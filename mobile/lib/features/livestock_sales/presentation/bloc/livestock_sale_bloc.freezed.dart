// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestock_sale_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LivestockSaleEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LivestockSaleEvent()';
}


}

/// @nodoc
class $LivestockSaleEventCopyWith<$Res>  {
$LivestockSaleEventCopyWith(LivestockSaleEvent _, $Res Function(LivestockSaleEvent) __);
}


/// Adds pattern-matching-related methods to [LivestockSaleEvent].
extension LivestockSaleEventPatterns on LivestockSaleEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FormChanged value)?  formChanged,TResult Function( _AnimalAddRequested value)?  animalAddRequested,TResult Function( _RfidPrefixChanged value)?  rfidPrefixChanged,TResult Function( _AnimalRemoveRequested value)?  animalRemoveRequested,TResult Function( _NextStepRequested value)?  nextStepRequested,TResult Function( _PreviousStepRequested value)?  previousStepRequested,TResult Function( _SubmitRequested value)?  submitRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FormChanged() when formChanged != null:
return formChanged(_that);case _AnimalAddRequested() when animalAddRequested != null:
return animalAddRequested(_that);case _RfidPrefixChanged() when rfidPrefixChanged != null:
return rfidPrefixChanged(_that);case _AnimalRemoveRequested() when animalRemoveRequested != null:
return animalRemoveRequested(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _SubmitRequested() when submitRequested != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FormChanged value)  formChanged,required TResult Function( _AnimalAddRequested value)  animalAddRequested,required TResult Function( _RfidPrefixChanged value)  rfidPrefixChanged,required TResult Function( _AnimalRemoveRequested value)  animalRemoveRequested,required TResult Function( _NextStepRequested value)  nextStepRequested,required TResult Function( _PreviousStepRequested value)  previousStepRequested,required TResult Function( _SubmitRequested value)  submitRequested,}){
final _that = this;
switch (_that) {
case _FormChanged():
return formChanged(_that);case _AnimalAddRequested():
return animalAddRequested(_that);case _RfidPrefixChanged():
return rfidPrefixChanged(_that);case _AnimalRemoveRequested():
return animalRemoveRequested(_that);case _NextStepRequested():
return nextStepRequested(_that);case _PreviousStepRequested():
return previousStepRequested(_that);case _SubmitRequested():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FormChanged value)?  formChanged,TResult? Function( _AnimalAddRequested value)?  animalAddRequested,TResult? Function( _RfidPrefixChanged value)?  rfidPrefixChanged,TResult? Function( _AnimalRemoveRequested value)?  animalRemoveRequested,TResult? Function( _NextStepRequested value)?  nextStepRequested,TResult? Function( _PreviousStepRequested value)?  previousStepRequested,TResult? Function( _SubmitRequested value)?  submitRequested,}){
final _that = this;
switch (_that) {
case _FormChanged() when formChanged != null:
return formChanged(_that);case _AnimalAddRequested() when animalAddRequested != null:
return animalAddRequested(_that);case _RfidPrefixChanged() when rfidPrefixChanged != null:
return rfidPrefixChanged(_that);case _AnimalRemoveRequested() when animalRemoveRequested != null:
return animalRemoveRequested(_that);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested(_that);case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested(_that);case _SubmitRequested() when submitRequested != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LivestockSaleFormDraft form)?  formChanged,TResult Function( String rfidTagNumber)?  animalAddRequested,TResult Function( String prefix)?  rfidPrefixChanged,TResult Function( String animalId)?  animalRemoveRequested,TResult Function()?  nextStepRequested,TResult Function()?  previousStepRequested,TResult Function()?  submitRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FormChanged() when formChanged != null:
return formChanged(_that.form);case _AnimalAddRequested() when animalAddRequested != null:
return animalAddRequested(_that.rfidTagNumber);case _RfidPrefixChanged() when rfidPrefixChanged != null:
return rfidPrefixChanged(_that.prefix);case _AnimalRemoveRequested() when animalRemoveRequested != null:
return animalRemoveRequested(_that.animalId);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _SubmitRequested() when submitRequested != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LivestockSaleFormDraft form)  formChanged,required TResult Function( String rfidTagNumber)  animalAddRequested,required TResult Function( String prefix)  rfidPrefixChanged,required TResult Function( String animalId)  animalRemoveRequested,required TResult Function()  nextStepRequested,required TResult Function()  previousStepRequested,required TResult Function()  submitRequested,}) {final _that = this;
switch (_that) {
case _FormChanged():
return formChanged(_that.form);case _AnimalAddRequested():
return animalAddRequested(_that.rfidTagNumber);case _RfidPrefixChanged():
return rfidPrefixChanged(_that.prefix);case _AnimalRemoveRequested():
return animalRemoveRequested(_that.animalId);case _NextStepRequested():
return nextStepRequested();case _PreviousStepRequested():
return previousStepRequested();case _SubmitRequested():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LivestockSaleFormDraft form)?  formChanged,TResult? Function( String rfidTagNumber)?  animalAddRequested,TResult? Function( String prefix)?  rfidPrefixChanged,TResult? Function( String animalId)?  animalRemoveRequested,TResult? Function()?  nextStepRequested,TResult? Function()?  previousStepRequested,TResult? Function()?  submitRequested,}) {final _that = this;
switch (_that) {
case _FormChanged() when formChanged != null:
return formChanged(_that.form);case _AnimalAddRequested() when animalAddRequested != null:
return animalAddRequested(_that.rfidTagNumber);case _RfidPrefixChanged() when rfidPrefixChanged != null:
return rfidPrefixChanged(_that.prefix);case _AnimalRemoveRequested() when animalRemoveRequested != null:
return animalRemoveRequested(_that.animalId);case _NextStepRequested() when nextStepRequested != null:
return nextStepRequested();case _PreviousStepRequested() when previousStepRequested != null:
return previousStepRequested();case _SubmitRequested() when submitRequested != null:
return submitRequested();case _:
  return null;

}
}

}

/// @nodoc


class _FormChanged implements LivestockSaleEvent {
  const _FormChanged(this.form);
  

 final  LivestockSaleFormDraft form;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormChangedCopyWith<_FormChanged> get copyWith => __$FormChangedCopyWithImpl<_FormChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FormChanged&&(identical(other.form, form) || other.form == form));
}


@override
int get hashCode => Object.hash(runtimeType,form);

@override
String toString() {
  return 'LivestockSaleEvent.formChanged(form: $form)';
}


}

/// @nodoc
abstract mixin class _$FormChangedCopyWith<$Res> implements $LivestockSaleEventCopyWith<$Res> {
  factory _$FormChangedCopyWith(_FormChanged value, $Res Function(_FormChanged) _then) = __$FormChangedCopyWithImpl;
@useResult
$Res call({
 LivestockSaleFormDraft form
});


$LivestockSaleFormDraftCopyWith<$Res> get form;

}
/// @nodoc
class __$FormChangedCopyWithImpl<$Res>
    implements _$FormChangedCopyWith<$Res> {
  __$FormChangedCopyWithImpl(this._self, this._then);

  final _FormChanged _self;
  final $Res Function(_FormChanged) _then;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? form = null,}) {
  return _then(_FormChanged(
null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as LivestockSaleFormDraft,
  ));
}

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleFormDraftCopyWith<$Res> get form {
  
  return $LivestockSaleFormDraftCopyWith<$Res>(_self.form, (value) {
    return _then(_self.copyWith(form: value));
  });
}
}

/// @nodoc


class _AnimalAddRequested implements LivestockSaleEvent {
  const _AnimalAddRequested(this.rfidTagNumber);
  

 final  String rfidTagNumber;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalAddRequestedCopyWith<_AnimalAddRequested> get copyWith => __$AnimalAddRequestedCopyWithImpl<_AnimalAddRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalAddRequested&&(identical(other.rfidTagNumber, rfidTagNumber) || other.rfidTagNumber == rfidTagNumber));
}


@override
int get hashCode => Object.hash(runtimeType,rfidTagNumber);

@override
String toString() {
  return 'LivestockSaleEvent.animalAddRequested(rfidTagNumber: $rfidTagNumber)';
}


}

/// @nodoc
abstract mixin class _$AnimalAddRequestedCopyWith<$Res> implements $LivestockSaleEventCopyWith<$Res> {
  factory _$AnimalAddRequestedCopyWith(_AnimalAddRequested value, $Res Function(_AnimalAddRequested) _then) = __$AnimalAddRequestedCopyWithImpl;
@useResult
$Res call({
 String rfidTagNumber
});




}
/// @nodoc
class __$AnimalAddRequestedCopyWithImpl<$Res>
    implements _$AnimalAddRequestedCopyWith<$Res> {
  __$AnimalAddRequestedCopyWithImpl(this._self, this._then);

  final _AnimalAddRequested _self;
  final $Res Function(_AnimalAddRequested) _then;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rfidTagNumber = null,}) {
  return _then(_AnimalAddRequested(
null == rfidTagNumber ? _self.rfidTagNumber : rfidTagNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _RfidPrefixChanged implements LivestockSaleEvent {
  const _RfidPrefixChanged(this.prefix);
  

 final  String prefix;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RfidPrefixChangedCopyWith<_RfidPrefixChanged> get copyWith => __$RfidPrefixChangedCopyWithImpl<_RfidPrefixChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RfidPrefixChanged&&(identical(other.prefix, prefix) || other.prefix == prefix));
}


@override
int get hashCode => Object.hash(runtimeType,prefix);

@override
String toString() {
  return 'LivestockSaleEvent.rfidPrefixChanged(prefix: $prefix)';
}


}

/// @nodoc
abstract mixin class _$RfidPrefixChangedCopyWith<$Res> implements $LivestockSaleEventCopyWith<$Res> {
  factory _$RfidPrefixChangedCopyWith(_RfidPrefixChanged value, $Res Function(_RfidPrefixChanged) _then) = __$RfidPrefixChangedCopyWithImpl;
@useResult
$Res call({
 String prefix
});




}
/// @nodoc
class __$RfidPrefixChangedCopyWithImpl<$Res>
    implements _$RfidPrefixChangedCopyWith<$Res> {
  __$RfidPrefixChangedCopyWithImpl(this._self, this._then);

  final _RfidPrefixChanged _self;
  final $Res Function(_RfidPrefixChanged) _then;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? prefix = null,}) {
  return _then(_RfidPrefixChanged(
null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _AnimalRemoveRequested implements LivestockSaleEvent {
  const _AnimalRemoveRequested(this.animalId);
  

 final  String animalId;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalRemoveRequestedCopyWith<_AnimalRemoveRequested> get copyWith => __$AnimalRemoveRequestedCopyWithImpl<_AnimalRemoveRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalRemoveRequested&&(identical(other.animalId, animalId) || other.animalId == animalId));
}


@override
int get hashCode => Object.hash(runtimeType,animalId);

@override
String toString() {
  return 'LivestockSaleEvent.animalRemoveRequested(animalId: $animalId)';
}


}

/// @nodoc
abstract mixin class _$AnimalRemoveRequestedCopyWith<$Res> implements $LivestockSaleEventCopyWith<$Res> {
  factory _$AnimalRemoveRequestedCopyWith(_AnimalRemoveRequested value, $Res Function(_AnimalRemoveRequested) _then) = __$AnimalRemoveRequestedCopyWithImpl;
@useResult
$Res call({
 String animalId
});




}
/// @nodoc
class __$AnimalRemoveRequestedCopyWithImpl<$Res>
    implements _$AnimalRemoveRequestedCopyWith<$Res> {
  __$AnimalRemoveRequestedCopyWithImpl(this._self, this._then);

  final _AnimalRemoveRequested _self;
  final $Res Function(_AnimalRemoveRequested) _then;

/// Create a copy of LivestockSaleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? animalId = null,}) {
  return _then(_AnimalRemoveRequested(
null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _NextStepRequested implements LivestockSaleEvent {
  const _NextStepRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NextStepRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LivestockSaleEvent.nextStepRequested()';
}


}




/// @nodoc


class _PreviousStepRequested implements LivestockSaleEvent {
  const _PreviousStepRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviousStepRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LivestockSaleEvent.previousStepRequested()';
}


}




/// @nodoc


class _SubmitRequested implements LivestockSaleEvent {
  const _SubmitRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LivestockSaleEvent.submitRequested()';
}


}




/// @nodoc
mixin _$LivestockSaleFormDraft {

 String get establishmentId; DateTime get operationDate; LivestockSaleBuyerType get buyerType; String get buyerName; bool get isCompany; String get buyerLastName; String get dteNumber; LivestockSaleType get saleType; String get bulkTotalAmount; String get totalWeight; String get pricePerKg; LivestockSalePaymentCondition get paymentCondition; LivestockSalePaymentMethod get paymentMethod; String get amountToCollect; DateTime get paymentDate; String get observations; String get paymentObservations;
/// Create a copy of LivestockSaleFormDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleFormDraftCopyWith<LivestockSaleFormDraft> get copyWith => _$LivestockSaleFormDraftCopyWithImpl<LivestockSaleFormDraft>(this as LivestockSaleFormDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleFormDraft&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.bulkTotalAmount, bulkTotalAmount) || other.bulkTotalAmount == bulkTotalAmount)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight)&&(identical(other.pricePerKg, pricePerKg) || other.pricePerKg == pricePerKg)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.amountToCollect, amountToCollect) || other.amountToCollect == amountToCollect)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.paymentObservations, paymentObservations) || other.paymentObservations == paymentObservations));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,operationDate,buyerType,buyerName,isCompany,buyerLastName,dteNumber,saleType,bulkTotalAmount,totalWeight,pricePerKg,paymentCondition,paymentMethod,amountToCollect,paymentDate,observations,paymentObservations);

@override
String toString() {
  return 'LivestockSaleFormDraft(establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, buyerLastName: $buyerLastName, dteNumber: $dteNumber, saleType: $saleType, bulkTotalAmount: $bulkTotalAmount, totalWeight: $totalWeight, pricePerKg: $pricePerKg, paymentCondition: $paymentCondition, paymentMethod: $paymentMethod, amountToCollect: $amountToCollect, paymentDate: $paymentDate, observations: $observations, paymentObservations: $paymentObservations)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleFormDraftCopyWith<$Res>  {
  factory $LivestockSaleFormDraftCopyWith(LivestockSaleFormDraft value, $Res Function(LivestockSaleFormDraft) _then) = _$LivestockSaleFormDraftCopyWithImpl;
@useResult
$Res call({
 String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String buyerLastName, String dteNumber, LivestockSaleType saleType, String bulkTotalAmount, String totalWeight, String pricePerKg, LivestockSalePaymentCondition paymentCondition, LivestockSalePaymentMethod paymentMethod, String amountToCollect, DateTime paymentDate, String observations, String paymentObservations
});




}
/// @nodoc
class _$LivestockSaleFormDraftCopyWithImpl<$Res>
    implements $LivestockSaleFormDraftCopyWith<$Res> {
  _$LivestockSaleFormDraftCopyWithImpl(this._self, this._then);

  final LivestockSaleFormDraft _self;
  final $Res Function(LivestockSaleFormDraft) _then;

/// Create a copy of LivestockSaleFormDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? buyerLastName = null,Object? dteNumber = null,Object? saleType = null,Object? bulkTotalAmount = null,Object? totalWeight = null,Object? pricePerKg = null,Object? paymentCondition = null,Object? paymentMethod = null,Object? amountToCollect = null,Object? paymentDate = null,Object? observations = null,Object? paymentObservations = null,}) {
  return _then(_self.copyWith(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,buyerLastName: null == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,bulkTotalAmount: null == bulkTotalAmount ? _self.bulkTotalAmount : bulkTotalAmount // ignore: cast_nullable_to_non_nullable
as String,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as String,pricePerKg: null == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as String,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,amountToCollect: null == amountToCollect ? _self.amountToCollect : amountToCollect // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,observations: null == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String,paymentObservations: null == paymentObservations ? _self.paymentObservations : paymentObservations // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LivestockSaleFormDraft].
extension LivestockSaleFormDraftPatterns on LivestockSaleFormDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleFormDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleFormDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleFormDraft value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleFormDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleFormDraft value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleFormDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String buyerLastName,  String dteNumber,  LivestockSaleType saleType,  String bulkTotalAmount,  String totalWeight,  String pricePerKg,  LivestockSalePaymentCondition paymentCondition,  LivestockSalePaymentMethod paymentMethod,  String amountToCollect,  DateTime paymentDate,  String observations,  String paymentObservations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleFormDraft() when $default != null:
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.buyerLastName,_that.dteNumber,_that.saleType,_that.bulkTotalAmount,_that.totalWeight,_that.pricePerKg,_that.paymentCondition,_that.paymentMethod,_that.amountToCollect,_that.paymentDate,_that.observations,_that.paymentObservations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String buyerLastName,  String dteNumber,  LivestockSaleType saleType,  String bulkTotalAmount,  String totalWeight,  String pricePerKg,  LivestockSalePaymentCondition paymentCondition,  LivestockSalePaymentMethod paymentMethod,  String amountToCollect,  DateTime paymentDate,  String observations,  String paymentObservations)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleFormDraft():
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.buyerLastName,_that.dteNumber,_that.saleType,_that.bulkTotalAmount,_that.totalWeight,_that.pricePerKg,_that.paymentCondition,_that.paymentMethod,_that.amountToCollect,_that.paymentDate,_that.observations,_that.paymentObservations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String establishmentId,  DateTime operationDate,  LivestockSaleBuyerType buyerType,  String buyerName,  bool isCompany,  String buyerLastName,  String dteNumber,  LivestockSaleType saleType,  String bulkTotalAmount,  String totalWeight,  String pricePerKg,  LivestockSalePaymentCondition paymentCondition,  LivestockSalePaymentMethod paymentMethod,  String amountToCollect,  DateTime paymentDate,  String observations,  String paymentObservations)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleFormDraft() when $default != null:
return $default(_that.establishmentId,_that.operationDate,_that.buyerType,_that.buyerName,_that.isCompany,_that.buyerLastName,_that.dteNumber,_that.saleType,_that.bulkTotalAmount,_that.totalWeight,_that.pricePerKg,_that.paymentCondition,_that.paymentMethod,_that.amountToCollect,_that.paymentDate,_that.observations,_that.paymentObservations);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleFormDraft implements LivestockSaleFormDraft {
  const _LivestockSaleFormDraft({required this.establishmentId, required this.operationDate, required this.buyerType, required this.buyerName, required this.isCompany, required this.buyerLastName, required this.dteNumber, required this.saleType, required this.bulkTotalAmount, required this.totalWeight, required this.pricePerKg, required this.paymentCondition, required this.paymentMethod, required this.amountToCollect, required this.paymentDate, required this.observations, required this.paymentObservations});
  

@override final  String establishmentId;
@override final  DateTime operationDate;
@override final  LivestockSaleBuyerType buyerType;
@override final  String buyerName;
@override final  bool isCompany;
@override final  String buyerLastName;
@override final  String dteNumber;
@override final  LivestockSaleType saleType;
@override final  String bulkTotalAmount;
@override final  String totalWeight;
@override final  String pricePerKg;
@override final  LivestockSalePaymentCondition paymentCondition;
@override final  LivestockSalePaymentMethod paymentMethod;
@override final  String amountToCollect;
@override final  DateTime paymentDate;
@override final  String observations;
@override final  String paymentObservations;

/// Create a copy of LivestockSaleFormDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleFormDraftCopyWith<_LivestockSaleFormDraft> get copyWith => __$LivestockSaleFormDraftCopyWithImpl<_LivestockSaleFormDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleFormDraft&&(identical(other.establishmentId, establishmentId) || other.establishmentId == establishmentId)&&(identical(other.operationDate, operationDate) || other.operationDate == operationDate)&&(identical(other.buyerType, buyerType) || other.buyerType == buyerType)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.isCompany, isCompany) || other.isCompany == isCompany)&&(identical(other.buyerLastName, buyerLastName) || other.buyerLastName == buyerLastName)&&(identical(other.dteNumber, dteNumber) || other.dteNumber == dteNumber)&&(identical(other.saleType, saleType) || other.saleType == saleType)&&(identical(other.bulkTotalAmount, bulkTotalAmount) || other.bulkTotalAmount == bulkTotalAmount)&&(identical(other.totalWeight, totalWeight) || other.totalWeight == totalWeight)&&(identical(other.pricePerKg, pricePerKg) || other.pricePerKg == pricePerKg)&&(identical(other.paymentCondition, paymentCondition) || other.paymentCondition == paymentCondition)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.amountToCollect, amountToCollect) || other.amountToCollect == amountToCollect)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.observations, observations) || other.observations == observations)&&(identical(other.paymentObservations, paymentObservations) || other.paymentObservations == paymentObservations));
}


@override
int get hashCode => Object.hash(runtimeType,establishmentId,operationDate,buyerType,buyerName,isCompany,buyerLastName,dteNumber,saleType,bulkTotalAmount,totalWeight,pricePerKg,paymentCondition,paymentMethod,amountToCollect,paymentDate,observations,paymentObservations);

@override
String toString() {
  return 'LivestockSaleFormDraft(establishmentId: $establishmentId, operationDate: $operationDate, buyerType: $buyerType, buyerName: $buyerName, isCompany: $isCompany, buyerLastName: $buyerLastName, dteNumber: $dteNumber, saleType: $saleType, bulkTotalAmount: $bulkTotalAmount, totalWeight: $totalWeight, pricePerKg: $pricePerKg, paymentCondition: $paymentCondition, paymentMethod: $paymentMethod, amountToCollect: $amountToCollect, paymentDate: $paymentDate, observations: $observations, paymentObservations: $paymentObservations)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleFormDraftCopyWith<$Res> implements $LivestockSaleFormDraftCopyWith<$Res> {
  factory _$LivestockSaleFormDraftCopyWith(_LivestockSaleFormDraft value, $Res Function(_LivestockSaleFormDraft) _then) = __$LivestockSaleFormDraftCopyWithImpl;
@override @useResult
$Res call({
 String establishmentId, DateTime operationDate, LivestockSaleBuyerType buyerType, String buyerName, bool isCompany, String buyerLastName, String dteNumber, LivestockSaleType saleType, String bulkTotalAmount, String totalWeight, String pricePerKg, LivestockSalePaymentCondition paymentCondition, LivestockSalePaymentMethod paymentMethod, String amountToCollect, DateTime paymentDate, String observations, String paymentObservations
});




}
/// @nodoc
class __$LivestockSaleFormDraftCopyWithImpl<$Res>
    implements _$LivestockSaleFormDraftCopyWith<$Res> {
  __$LivestockSaleFormDraftCopyWithImpl(this._self, this._then);

  final _LivestockSaleFormDraft _self;
  final $Res Function(_LivestockSaleFormDraft) _then;

/// Create a copy of LivestockSaleFormDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? establishmentId = null,Object? operationDate = null,Object? buyerType = null,Object? buyerName = null,Object? isCompany = null,Object? buyerLastName = null,Object? dteNumber = null,Object? saleType = null,Object? bulkTotalAmount = null,Object? totalWeight = null,Object? pricePerKg = null,Object? paymentCondition = null,Object? paymentMethod = null,Object? amountToCollect = null,Object? paymentDate = null,Object? observations = null,Object? paymentObservations = null,}) {
  return _then(_LivestockSaleFormDraft(
establishmentId: null == establishmentId ? _self.establishmentId : establishmentId // ignore: cast_nullable_to_non_nullable
as String,operationDate: null == operationDate ? _self.operationDate : operationDate // ignore: cast_nullable_to_non_nullable
as DateTime,buyerType: null == buyerType ? _self.buyerType : buyerType // ignore: cast_nullable_to_non_nullable
as LivestockSaleBuyerType,buyerName: null == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String,isCompany: null == isCompany ? _self.isCompany : isCompany // ignore: cast_nullable_to_non_nullable
as bool,buyerLastName: null == buyerLastName ? _self.buyerLastName : buyerLastName // ignore: cast_nullable_to_non_nullable
as String,dteNumber: null == dteNumber ? _self.dteNumber : dteNumber // ignore: cast_nullable_to_non_nullable
as String,saleType: null == saleType ? _self.saleType : saleType // ignore: cast_nullable_to_non_nullable
as LivestockSaleType,bulkTotalAmount: null == bulkTotalAmount ? _self.bulkTotalAmount : bulkTotalAmount // ignore: cast_nullable_to_non_nullable
as String,totalWeight: null == totalWeight ? _self.totalWeight : totalWeight // ignore: cast_nullable_to_non_nullable
as String,pricePerKg: null == pricePerKg ? _self.pricePerKg : pricePerKg // ignore: cast_nullable_to_non_nullable
as String,paymentCondition: null == paymentCondition ? _self.paymentCondition : paymentCondition // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentCondition,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as LivestockSalePaymentMethod,amountToCollect: null == amountToCollect ? _self.amountToCollect : amountToCollect // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,observations: null == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as String,paymentObservations: null == paymentObservations ? _self.paymentObservations : paymentObservations // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LivestockSaleState {

 LivestockSaleFormDraft get form; LivestockSaleStep get currentStep; LivestockSaleSelection get selection; ResultState<LivestockSaleSelection> get animalSelectionResult; ResultState<List<LivestockSaleAnimal>> get rfidSuggestions; String get rfidPrefix; ResultState<LivestockSale> get submitResult; DomainException? get stepError;
/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestockSaleStateCopyWith<LivestockSaleState> get copyWith => _$LivestockSaleStateCopyWithImpl<LivestockSaleState>(this as LivestockSaleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestockSaleState&&(identical(other.form, form) || other.form == form)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.selection, selection) || other.selection == selection)&&(identical(other.animalSelectionResult, animalSelectionResult) || other.animalSelectionResult == animalSelectionResult)&&(identical(other.rfidSuggestions, rfidSuggestions) || other.rfidSuggestions == rfidSuggestions)&&(identical(other.rfidPrefix, rfidPrefix) || other.rfidPrefix == rfidPrefix)&&(identical(other.submitResult, submitResult) || other.submitResult == submitResult)&&(identical(other.stepError, stepError) || other.stepError == stepError));
}


@override
int get hashCode => Object.hash(runtimeType,form,currentStep,selection,animalSelectionResult,rfidSuggestions,rfidPrefix,submitResult,stepError);

@override
String toString() {
  return 'LivestockSaleState(form: $form, currentStep: $currentStep, selection: $selection, animalSelectionResult: $animalSelectionResult, rfidSuggestions: $rfidSuggestions, rfidPrefix: $rfidPrefix, submitResult: $submitResult, stepError: $stepError)';
}


}

/// @nodoc
abstract mixin class $LivestockSaleStateCopyWith<$Res>  {
  factory $LivestockSaleStateCopyWith(LivestockSaleState value, $Res Function(LivestockSaleState) _then) = _$LivestockSaleStateCopyWithImpl;
@useResult
$Res call({
 LivestockSaleFormDraft form, LivestockSaleStep currentStep, LivestockSaleSelection selection, ResultState<LivestockSaleSelection> animalSelectionResult, ResultState<List<LivestockSaleAnimal>> rfidSuggestions, String rfidPrefix, ResultState<LivestockSale> submitResult, DomainException? stepError
});


$LivestockSaleFormDraftCopyWith<$Res> get form;$LivestockSaleSelectionCopyWith<$Res> get selection;$ResultStateCopyWith<LivestockSaleSelection, $Res> get animalSelectionResult;$ResultStateCopyWith<List<LivestockSaleAnimal>, $Res> get rfidSuggestions;$ResultStateCopyWith<LivestockSale, $Res> get submitResult;$DomainExceptionCopyWith<$Res>? get stepError;

}
/// @nodoc
class _$LivestockSaleStateCopyWithImpl<$Res>
    implements $LivestockSaleStateCopyWith<$Res> {
  _$LivestockSaleStateCopyWithImpl(this._self, this._then);

  final LivestockSaleState _self;
  final $Res Function(LivestockSaleState) _then;

/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? form = null,Object? currentStep = null,Object? selection = null,Object? animalSelectionResult = null,Object? rfidSuggestions = null,Object? rfidPrefix = null,Object? submitResult = null,Object? stepError = freezed,}) {
  return _then(_self.copyWith(
form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as LivestockSaleFormDraft,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as LivestockSaleStep,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as LivestockSaleSelection,animalSelectionResult: null == animalSelectionResult ? _self.animalSelectionResult : animalSelectionResult // ignore: cast_nullable_to_non_nullable
as ResultState<LivestockSaleSelection>,rfidSuggestions: null == rfidSuggestions ? _self.rfidSuggestions : rfidSuggestions // ignore: cast_nullable_to_non_nullable
as ResultState<List<LivestockSaleAnimal>>,rfidPrefix: null == rfidPrefix ? _self.rfidPrefix : rfidPrefix // ignore: cast_nullable_to_non_nullable
as String,submitResult: null == submitResult ? _self.submitResult : submitResult // ignore: cast_nullable_to_non_nullable
as ResultState<LivestockSale>,stepError: freezed == stepError ? _self.stepError : stepError // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}
/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleFormDraftCopyWith<$Res> get form {
  
  return $LivestockSaleFormDraftCopyWith<$Res>(_self.form, (value) {
    return _then(_self.copyWith(form: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleSelectionCopyWith<$Res> get selection {
  
  return $LivestockSaleSelectionCopyWith<$Res>(_self.selection, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<LivestockSaleSelection, $Res> get animalSelectionResult {
  
  return $ResultStateCopyWith<LivestockSaleSelection, $Res>(_self.animalSelectionResult, (value) {
    return _then(_self.copyWith(animalSelectionResult: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<LivestockSaleAnimal>, $Res> get rfidSuggestions {
  
  return $ResultStateCopyWith<List<LivestockSaleAnimal>, $Res>(_self.rfidSuggestions, (value) {
    return _then(_self.copyWith(rfidSuggestions: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<LivestockSale, $Res> get submitResult {
  
  return $ResultStateCopyWith<LivestockSale, $Res>(_self.submitResult, (value) {
    return _then(_self.copyWith(submitResult: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get stepError {
    if (_self.stepError == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.stepError!, (value) {
    return _then(_self.copyWith(stepError: value));
  });
}
}


/// Adds pattern-matching-related methods to [LivestockSaleState].
extension LivestockSaleStatePatterns on LivestockSaleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestockSaleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestockSaleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestockSaleState value)  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestockSaleState value)?  $default,){
final _that = this;
switch (_that) {
case _LivestockSaleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LivestockSaleFormDraft form,  LivestockSaleStep currentStep,  LivestockSaleSelection selection,  ResultState<LivestockSaleSelection> animalSelectionResult,  ResultState<List<LivestockSaleAnimal>> rfidSuggestions,  String rfidPrefix,  ResultState<LivestockSale> submitResult,  DomainException? stepError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestockSaleState() when $default != null:
return $default(_that.form,_that.currentStep,_that.selection,_that.animalSelectionResult,_that.rfidSuggestions,_that.rfidPrefix,_that.submitResult,_that.stepError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LivestockSaleFormDraft form,  LivestockSaleStep currentStep,  LivestockSaleSelection selection,  ResultState<LivestockSaleSelection> animalSelectionResult,  ResultState<List<LivestockSaleAnimal>> rfidSuggestions,  String rfidPrefix,  ResultState<LivestockSale> submitResult,  DomainException? stepError)  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleState():
return $default(_that.form,_that.currentStep,_that.selection,_that.animalSelectionResult,_that.rfidSuggestions,_that.rfidPrefix,_that.submitResult,_that.stepError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LivestockSaleFormDraft form,  LivestockSaleStep currentStep,  LivestockSaleSelection selection,  ResultState<LivestockSaleSelection> animalSelectionResult,  ResultState<List<LivestockSaleAnimal>> rfidSuggestions,  String rfidPrefix,  ResultState<LivestockSale> submitResult,  DomainException? stepError)?  $default,) {final _that = this;
switch (_that) {
case _LivestockSaleState() when $default != null:
return $default(_that.form,_that.currentStep,_that.selection,_that.animalSelectionResult,_that.rfidSuggestions,_that.rfidPrefix,_that.submitResult,_that.stepError);case _:
  return null;

}
}

}

/// @nodoc


class _LivestockSaleState implements LivestockSaleState {
  const _LivestockSaleState({required this.form, this.currentStep = LivestockSaleStep.animals, this.selection = const LivestockSaleSelection(), this.animalSelectionResult = const ResultState<LivestockSaleSelection>.initial(), this.rfidSuggestions = const ResultState<List<LivestockSaleAnimal>>.initial(), this.rfidPrefix = '', this.submitResult = const ResultState<LivestockSale>.initial(), this.stepError});
  

@override final  LivestockSaleFormDraft form;
@override@JsonKey() final  LivestockSaleStep currentStep;
@override@JsonKey() final  LivestockSaleSelection selection;
@override@JsonKey() final  ResultState<LivestockSaleSelection> animalSelectionResult;
@override@JsonKey() final  ResultState<List<LivestockSaleAnimal>> rfidSuggestions;
@override@JsonKey() final  String rfidPrefix;
@override@JsonKey() final  ResultState<LivestockSale> submitResult;
@override final  DomainException? stepError;

/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestockSaleStateCopyWith<_LivestockSaleState> get copyWith => __$LivestockSaleStateCopyWithImpl<_LivestockSaleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestockSaleState&&(identical(other.form, form) || other.form == form)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.selection, selection) || other.selection == selection)&&(identical(other.animalSelectionResult, animalSelectionResult) || other.animalSelectionResult == animalSelectionResult)&&(identical(other.rfidSuggestions, rfidSuggestions) || other.rfidSuggestions == rfidSuggestions)&&(identical(other.rfidPrefix, rfidPrefix) || other.rfidPrefix == rfidPrefix)&&(identical(other.submitResult, submitResult) || other.submitResult == submitResult)&&(identical(other.stepError, stepError) || other.stepError == stepError));
}


@override
int get hashCode => Object.hash(runtimeType,form,currentStep,selection,animalSelectionResult,rfidSuggestions,rfidPrefix,submitResult,stepError);

@override
String toString() {
  return 'LivestockSaleState(form: $form, currentStep: $currentStep, selection: $selection, animalSelectionResult: $animalSelectionResult, rfidSuggestions: $rfidSuggestions, rfidPrefix: $rfidPrefix, submitResult: $submitResult, stepError: $stepError)';
}


}

/// @nodoc
abstract mixin class _$LivestockSaleStateCopyWith<$Res> implements $LivestockSaleStateCopyWith<$Res> {
  factory _$LivestockSaleStateCopyWith(_LivestockSaleState value, $Res Function(_LivestockSaleState) _then) = __$LivestockSaleStateCopyWithImpl;
@override @useResult
$Res call({
 LivestockSaleFormDraft form, LivestockSaleStep currentStep, LivestockSaleSelection selection, ResultState<LivestockSaleSelection> animalSelectionResult, ResultState<List<LivestockSaleAnimal>> rfidSuggestions, String rfidPrefix, ResultState<LivestockSale> submitResult, DomainException? stepError
});


@override $LivestockSaleFormDraftCopyWith<$Res> get form;@override $LivestockSaleSelectionCopyWith<$Res> get selection;@override $ResultStateCopyWith<LivestockSaleSelection, $Res> get animalSelectionResult;@override $ResultStateCopyWith<List<LivestockSaleAnimal>, $Res> get rfidSuggestions;@override $ResultStateCopyWith<LivestockSale, $Res> get submitResult;@override $DomainExceptionCopyWith<$Res>? get stepError;

}
/// @nodoc
class __$LivestockSaleStateCopyWithImpl<$Res>
    implements _$LivestockSaleStateCopyWith<$Res> {
  __$LivestockSaleStateCopyWithImpl(this._self, this._then);

  final _LivestockSaleState _self;
  final $Res Function(_LivestockSaleState) _then;

/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? form = null,Object? currentStep = null,Object? selection = null,Object? animalSelectionResult = null,Object? rfidSuggestions = null,Object? rfidPrefix = null,Object? submitResult = null,Object? stepError = freezed,}) {
  return _then(_LivestockSaleState(
form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as LivestockSaleFormDraft,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as LivestockSaleStep,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as LivestockSaleSelection,animalSelectionResult: null == animalSelectionResult ? _self.animalSelectionResult : animalSelectionResult // ignore: cast_nullable_to_non_nullable
as ResultState<LivestockSaleSelection>,rfidSuggestions: null == rfidSuggestions ? _self.rfidSuggestions : rfidSuggestions // ignore: cast_nullable_to_non_nullable
as ResultState<List<LivestockSaleAnimal>>,rfidPrefix: null == rfidPrefix ? _self.rfidPrefix : rfidPrefix // ignore: cast_nullable_to_non_nullable
as String,submitResult: null == submitResult ? _self.submitResult : submitResult // ignore: cast_nullable_to_non_nullable
as ResultState<LivestockSale>,stepError: freezed == stepError ? _self.stepError : stepError // ignore: cast_nullable_to_non_nullable
as DomainException?,
  ));
}

/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleFormDraftCopyWith<$Res> get form {
  
  return $LivestockSaleFormDraftCopyWith<$Res>(_self.form, (value) {
    return _then(_self.copyWith(form: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LivestockSaleSelectionCopyWith<$Res> get selection {
  
  return $LivestockSaleSelectionCopyWith<$Res>(_self.selection, (value) {
    return _then(_self.copyWith(selection: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<LivestockSaleSelection, $Res> get animalSelectionResult {
  
  return $ResultStateCopyWith<LivestockSaleSelection, $Res>(_self.animalSelectionResult, (value) {
    return _then(_self.copyWith(animalSelectionResult: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<List<LivestockSaleAnimal>, $Res> get rfidSuggestions {
  
  return $ResultStateCopyWith<List<LivestockSaleAnimal>, $Res>(_self.rfidSuggestions, (value) {
    return _then(_self.copyWith(rfidSuggestions: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResultStateCopyWith<LivestockSale, $Res> get submitResult {
  
  return $ResultStateCopyWith<LivestockSale, $Res>(_self.submitResult, (value) {
    return _then(_self.copyWith(submitResult: value));
  });
}/// Create a copy of LivestockSaleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DomainExceptionCopyWith<$Res>? get stepError {
    if (_self.stepError == null) {
    return null;
  }

  return $DomainExceptionCopyWith<$Res>(_self.stepError!, (value) {
    return _then(_self.copyWith(stepError: value));
  });
}
}

// dart format on
